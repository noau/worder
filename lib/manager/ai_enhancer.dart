import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:openai_dart/openai_dart.dart';

import '../constant/ai_prompts.dart';
import '../service/ai_service.dart';
import 'enhance_field.dart';

/// The structured response from a single AI Enhance call.
///
/// Immutable; equality is value-based so [ValueNotifier] can dedupe
/// notifications (re-emitting the same result does not trigger a rebuild).
@immutable
class EnhanceResult {
  const EnhanceResult({
    required this.pinyin,
    required this.meaning,
    this.note,
  });

  final String pinyin;
  final String meaning;

  /// `null` when the LLM did not return a note (and the user did not
  /// supply one worth polishing). The AddWordPage sheet hides the Note
  /// row entirely in this case.
  final String? note;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnhanceResult &&
          other.pinyin == pinyin &&
          other.meaning == meaning &&
          other.note == note;

  @override
  int get hashCode => Object.hash(pinyin, meaning, note);
}

/// Sealed family of states the [AIEnhancer] can be in. The bottom sheet
/// does an exhaustive `switch` over the cases, so adding a new state is
/// a compile-time error in the renderer.
sealed class EnhanceState {
  const EnhanceState();
}

/// Before the first call has been made. Treated identically to
/// [EnhanceLoading] in the UI.
class EnhanceInitial extends EnhanceState {
  const EnhanceInitial();
}

/// A chat completion is in flight.
class EnhanceLoading extends EnhanceState {
  const EnhanceLoading();
}

/// A chat completion succeeded and the response was parsed into [result].
class EnhanceSuccess extends EnhanceState {
  const EnhanceSuccess(this.result);
  final EnhanceResult result;
}

/// A chat completion failed (network, auth, parse, etc.) and the user
/// should be shown [message] with a path forward (retry or close).
class EnhanceError extends EnhanceState {
  const EnhanceError(this.message);
  final String message;
}

/// Stateful wrapper around the AI Enhance feature.
///
/// Owns:
///   * the multi-turn chat history ([List<ChatMessage>]),
///   * the current [EnhanceState] (exposed as a [ValueListenable] for the
///     sheet to bind with [ValueListenableBuilder]),
///   * in-flight call + abort plumbing,
///   * response parsing (pinyin / meaning / optional note).
///
/// Does not own: any UI. The bottom sheet in [AddWordPage] is the
/// renderer; the enhancer is the model.
///
/// Concurrency: only one LLM call is in flight at a time. A second
/// [regenerate] / [start] call while one is running first aborts the
/// in-flight call and waits for its future to settle before proceeding.
class AIEnhancer {
  AIEnhancer({required AIService aiService}) : _aiService = aiService;

  final AIService _aiService;

  final ValueNotifier<EnhanceState> _state =
      ValueNotifier<EnhanceState>(const EnhanceInitial());

  /// Read-only state stream. The sheet subscribes via
  /// [ValueListenableBuilder].
  ValueListenable<EnhanceState> get state => _state;

  /// The most recent successful result, or `null` if no success yet (or
  /// the last call failed).
  EnhanceResult? get latestResult => _state.value is EnhanceSuccess
      ? (_state.value as EnhanceSuccess).result
      : null;

  bool get isLoading => _state.value is EnhanceLoading;

  /// Multi-turn history. The system prompt is prepended on the very first
  /// call; subsequent calls (initial or regenerate) append new
  /// user/assistant messages to the same list.
  final List<ChatMessage> _history = [];

  /// Abort trigger for the in-flight call. `null` when no call is running.
  Completer<void>? _abort;

  /// Future awaited by the next call to ensure sequential execution.
  Future<void>? _inflight;

  /// Disposed guard. Once `dispose()` runs, every state mutation is a
  /// no-op and every pending catch block short-circuits. Prevents
  /// "A ValueNotifier was used after being disposed" when the user closes
  /// the sheet mid-call.
  bool _disposed = false;

  /// Fire the initial call. Clears any prior history and starts fresh.
  Future<void> start({
    required String word,
    String? pinyin,
    String? meaning,
    String? note,
  }) async {
    if (_disposed) return;

    _history
      ..clear()
      ..add(ChatMessage.system(kEnhanceSystemPrompt));

    await _sendUserMessage(
      _buildInitialUserPrompt(
        word: word,
        pinyin: pinyin,
        meaning: meaning,
        note: note,
      ),
    );
  }

  /// Re-generate one field, or all fields when [field] is `null`.
  ///
  /// For per-field regen, the assistant's previous answer is passed into
  /// the prompt as context. The frontend does NOT trust the LLM to keep
  /// the other fields verbatim — it overwrites non-target fields with
  /// anchor values from the sheet.
  Future<void> regenerate(EnhanceField? field) async {
    if (_disposed) return;
    await _sendUserMessage(_buildRegenUserPrompt(field, latestResult));
  }

  /// Build the user prompt for the first enhance call. Empty user fields
  /// are omitted from the prompt so the LLM knows they are blank, not
  /// zero-length valid values.
  String _buildInitialUserPrompt({
    required String word,
    String? pinyin,
    String? meaning,
    String? note,
  }) {
    final buf = StringBuffer()..writeln('Word: $word');
    if (pinyin != null && pinyin.isNotEmpty) {
      buf.writeln('User pinyin: $pinyin');
    }
    if (meaning != null && meaning.isNotEmpty) {
      buf.writeln('User meaning: $meaning');
    }
    if (note != null && note.isNotEmpty) {
      buf.writeln('User note: $note');
    }
    buf.write(
      'Enhance this word. Return pinyin / meaning / optional note in the '
      'exact output format.',
    );
    return buf.toString();
  }

  /// Build the user prompt for a regenerate call.
  ///
  /// - [field] == null means "regenerate all fields" — re-ask with the
  ///   same context, telling the LLM it may ignore its previous answer.
  /// - [field] != null means "regenerate only this field". The prompt
  ///   includes the previous AI's value for that field as a reference so
  ///   the LLM can produce a different answer rather than echoing
  ///   verbatim. The frontend overwrites non-target fields with anchor
  ///   values, so the LLM is not asked to "keep the other fields
  ///   exactly" — it is free to vary them.
  String _buildRegenUserPrompt(EnhanceField? field, EnhanceResult? prior) {
    if (field == null) {
      return 'Regenerate all three fields. Return a new pinyin / meaning / '
          'optional note. You may ignore your previous answer.';
    }
    final fieldName = switch (field) {
      EnhanceField.pinyin => 'pinyin',
      EnhanceField.meaning => 'meaning',
      EnhanceField.note => 'note',
    };
    final previous = switch (field) {
      EnhanceField.pinyin => prior?.pinyin,
      EnhanceField.meaning => prior?.meaning,
      EnhanceField.note => prior?.note,
    };
    return 'Regenerate only the $fieldName. Return the full pinyin / meaning '
        '/ optional note in the same output format. Previous $fieldName: '
        '${previous ?? "(none)"}.';
  }

  /// Send a user-prompted message and surface the result/error via state.
  ///
  /// Serialization: if a previous call is in flight, abort it and wait
  /// for it to fully settle (its rollback + state-change must have
  /// happened) before starting a new one.
  Future<void> _sendUserMessage(String userText) async {
    if (_inflight != null) {
      abort();
      await _inflight;
    }
    if (_disposed) return;

    final userMsg = ChatMessage.user(userText);
    _history.add(userMsg);
    _setState(const EnhanceLoading());

    final completer = Completer<void>();
    _abort = Completer<void>();
    _inflight = completer.future;
    final myAbort = _abort!;

    try {
      final raw = await _aiService.chatCompletion(
        messages: List<ChatMessage>.unmodifiable(_history),
        abortTrigger: myAbort.future,
      );
      if (_disposed) return; // Sheet closed while we were awaiting.
      final result = _parseEnhanceResult(raw);
      _history.add(ChatMessage.assistant(content: raw));
      _setState(EnhanceSuccess(result));
    } catch (e) {
      if (_disposed) return;

      // Roll back the user message we appended. Use reference-based lookup
      // (not `_history.last` check) because in an abort race, the prior
      // call's assistant message may have landed in between.
      _removeLastMatching(userMsg);

      // If we got here because the user (or a follow-up call) aborted
      // us, do NOT show "Request timed out" — that's a real error
      // message that would confuse a cancellation UX. Restore to
      // Initial instead. The follow-up call (if any) will move us out.
      if (myAbort.isCompleted) {
        _setState(const EnhanceInitial());
      } else if (e is LLMException) {
        _setState(EnhanceError(e.message));
      } else if (e is FormatException) {
        _setState(const EnhanceError(
          'AI returned an unexpected format. Try again.',
        ));
      } else {
        _setState(EnhanceError('AI error: $e'));
      }
    } finally {
      // Only clear if THIS call still owns the slot — a newer call may
      // have already replaced _abort / _inflight in _sendUserMessage.
      if (identical(_abort, myAbort)) {
        _abort = null;
        _inflight = null;
      }
      if (!completer.isCompleted) completer.complete();
    }
  }

  /// Complete the in-flight abort trigger. Idempotent and safe to call
  /// when no call is in flight. Called from the public `dispose` path
  /// AND from the next call's "wait for in-flight to settle" step.
  void abort() {
    final c = _abort;
    if (c != null && !c.isCompleted) c.complete();
  }

  void _setState(EnhanceState next) {
    if (_disposed) return;
    _state.value = next;
  }

  /// Remove the last message in [_history] that is `identical` to [msg].
  ///
  /// We don't use `_history.last == msg` because under an abort race
  /// the previous call's assistant message may have been appended
  /// between our `await chatCompletion` returning-throwing and us
  /// reaching the rollback. Reference-based lookup is robust against
  /// any interleaving.
  void _removeLastMatching(ChatMessage msg) {
    for (var i = _history.length - 1; i >= 0; i--) {
      if (identical(_history[i], msg)) {
        _history.removeAt(i);
        return;
      }
    }
  }

  /// Parse the raw LLM response into an [EnhanceResult].
  ///
  /// Throws [FormatException] on any structural problem; the caller
  /// converts that to a user-facing `LLMException` / `EnhanceError`
  /// message.
  ///
  /// Format contract (enforced by [kEnhanceSystemPrompt]):
  ///   line 0            — pinyin (non-empty)
  ///   line 1..N         — meaning (one line, or multi-line with
  ///                        `1.` `2.` `3.` prefix); non-empty
  ///   any line "> ..."  — note (optional; one or more lines, joined
  ///                        with `\n`); `null` when absent
  EnhanceResult _parseEnhanceResult(String text) {
    final lines = text
        .split('\n')
        .map((l) => l.trimRight())
        .where((l) => l.trim().isNotEmpty)
        .toList();
    if (lines.isEmpty) {
      throw const FormatException('Empty AI response');
    }
    final pinyin = lines.first.trim();
    if (pinyin.isEmpty) {
      throw const FormatException('Pinyin line is empty');
    }

    final meaningBuf = StringBuffer();
    final noteBuf = StringBuffer();
    var sawNote = false;
    for (var i = 1; i < lines.length; i++) {
      final line = lines[i];
      if (line.startsWith('>')) {
        sawNote = true;
        if (noteBuf.isNotEmpty) noteBuf.write('\n');
        // Strip one optional space after `>`.
        noteBuf.write(line.replaceFirst(RegExp(r'^>\s?'), ''));
      } else if (!sawNote) {
        if (meaningBuf.isNotEmpty) meaningBuf.write('\n');
        meaningBuf.write(line);
      } else {
        // A non-`>` line that appears after the first note line is
        // folded into the note block. Defensive against LLMs that emit
        // bullet-like structures mid-note.
        if (noteBuf.isNotEmpty) noteBuf.write('\n');
        noteBuf.write(line);
      }
    }
    final meaning = meaningBuf.toString().trim();
    if (meaning.isEmpty) {
      throw const FormatException('Meaning is empty');
    }
    final note = sawNote ? noteBuf.toString().trim() : null;
    return EnhanceResult(
      pinyin: pinyin,
      meaning: meaning,
      note: (note != null && note.isEmpty) ? null : note,
    );
  }

  /// Release resources. Idempotent. Marks the enhancer disposed FIRST so
  /// any in-flight catch block that fires after this call short-circuits
  /// its state write, then aborts the in-flight call, then disposes the
  /// internal [ValueNotifier].
  void dispose() {
    _disposed = true;
    abort();
    _state.dispose();
  }
}
