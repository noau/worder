import 'dart:async';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:auto_route/auto_route.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:worder/config.dart';
import 'package:worder/database.dart';
import 'package:worder/entity/word_model.dart';
import 'package:worder/manager/ai_enhancer.dart';
import 'package:worder/manager/enhance_field.dart';
import 'package:worder/service/ai_service.dart';
import 'package:worder/util/context_l10n.dart';
import 'package:worder/util/llm_error_localizer.dart';

@RoutePage()
class AddWordPage extends StatefulWidget {
  const AddWordPage({super.key});

  @override
  State<AddWordPage> createState() => _AddWordPageState();
}

class _AddWordPageState extends State<AddWordPage> {
  late final TextEditingController _wordCtrl;
  late final TextEditingController _pinyinCtrl;
  late final TextEditingController _meaningCtrl;
  late final TextEditingController _noteCtrl;
  late final FocusNode _wordFocus;
  late final ValueNotifier<bool> _canConfirm;

  /// Cached at `initState` from [AIService.isConfigured]. The page is a
  /// fresh navigation, so re-entering after editing config in Settings
  /// re-reads. v1 limitation: changing config in Settings while this page
  /// is open in the foreground does not refresh the cached value.
  late final AIService _aiService;
  late final bool _aiConfigured;

  late final AppDatabase _db;

  /// Drives the yellow `helperText` + amber `suffixIcon` decoration on the
  /// Word field. Updated by [_onWordChangedForDup] after a debounced
  /// [AppDatabase.getWordExists] query.
  late final ValueNotifier<bool> _isDuplicate;
  Timer? _dupDebounce;

  @override
  void initState() {
    super.initState();
    _wordCtrl = TextEditingController();
    _pinyinCtrl = TextEditingController();
    _meaningCtrl = TextEditingController();
    _noteCtrl = TextEditingController();
    _wordFocus = FocusNode();
    _canConfirm = ValueNotifier(false);
    _aiService = context.read<AIService>();
    _aiConfigured = _aiService.isConfigured;
    _db = context.read<AppDatabase>();
    _isDuplicate = ValueNotifier(false);
    _wordCtrl.addListener(_updateButtons);
    _pinyinCtrl.addListener(_updateButtons);
    _meaningCtrl.addListener(_updateButtons);
    _wordCtrl.addListener(_onWordChangedForDup);
  }

  @override
  void dispose() {
    _dupDebounce?.cancel();
    _isDuplicate.dispose();
    _wordCtrl.dispose();
    _pinyinCtrl.dispose();
    _meaningCtrl.dispose();
    _noteCtrl.dispose();
    _wordFocus.dispose();
    _canConfirm.dispose();
    super.dispose();
  }

  bool _isFilled(TextEditingController c) => c.text.trim().isNotEmpty;

  void _updateButtons() {
    _canConfirm.value =
        _isFilled(_wordCtrl) &&
        _isFilled(_pinyinCtrl) &&
        _isFilled(_meaningCtrl);
  }

  /// Debounced duplicate-check listener. Restarts the timer on every
  /// keystroke; the actual `getWordExists` query only runs after
  /// [kDuplicateCheckDebounce] of inactivity. Empty / whitespace-only input
  /// short-circuits to `false` without a query.
  void _onWordChangedForDup() {
    _dupDebounce?.cancel();
    final trimmed = _wordCtrl.text.trim();
    if (trimmed.isEmpty) {
      _isDuplicate.value = false;
      return;
    }
    _dupDebounce = Timer(kDuplicateCheckDebounce, () async {
      final exists = await _db.getWordExists(trimmed);
      if (!mounted) return;
      _isDuplicate.value = exists;
    });
  }

  Future<void> _onEnhance() async {
    if (!await _confirmProceedIfDuplicate()) return;
    if (!mounted) return;
    // Read the current app locale at the moment the sheet opens. The
    // enhancer bakes this into the LLM prompt's output-language directive,
    // so the meaning / note come back in the same language the user is
    // seeing the rest of the UI in.
    final locale = Localizations.localeOf(context);
    final result = await showModalBottomSheet<EnhanceResult>(
      context: context,
      // Indismissable by design: no drag handle, no swipe-down, no
      // tap-on-scrim, and `PopScope(canPop: false)` inside the sheet
      // blocks the OS back button. The only exits are the bottom
      // Cancel / Confirm buttons.
      showDragHandle: false,
      useSafeArea: true,
      isScrollControlled: true,
      enableDrag: false,
      isDismissible: false,
      constraints: BoxConstraints(minHeight: 600),
      builder: (_) => _EnhanceSheet(
        aiService: _aiService,
        outputLocale: locale,
        word: _wordCtrl.text.trim(),
        originalPinyin: _pinyinCtrl.text.trim(),
        originalMeaning: _meaningCtrl.text.trim(),
        originalNote: _noteCtrl.text.trim(),
      ),
    );
    if (result == null || !mounted) return;
    _pinyinCtrl.text = result.pinyin;
    _meaningCtrl.text = result.meaning;
    if (result.note != null) _noteCtrl.text = result.note!;
  }

  /// Click-time duplicate check. Re-queries the DB (independent of the
  /// debounced [_isDuplicate] snapshot) so concurrent edits — e.g. deleting
  /// the duplicate from LibraryPage in another tab — are reflected. Returns
  /// `true` to proceed, `false` to abort.
  Future<bool> _confirmProceedIfDuplicate() async {
    final wordText = _wordCtrl.text.trim();
    if (wordText.isEmpty) return true;
    final exists = await _db.getWordExists(wordText);
    if (!exists) return true;
    if (!mounted) return false;
    final result = await showOkCancelAlertDialog(
      context: context,
      title: context.l10n.addWordDuplicateDialogTitle,
      message: context.l10n.addWordDuplicateDialogMessage(wordText),
      okLabel: context.l10n.addWordDuplicateDialogOk,
      cancelLabel: context.l10n.addWordDuplicateDialogCancel,
      barrierDismissible: false,
    );
    return result == OkCancelResult.ok;
  }

  Future<void> _onConfirm() async {
    if (!await _confirmProceedIfDuplicate()) return;
    if (!mounted) return;
    final dbService = _db;
    final result = await showOkCancelAlertDialog(
      context: context,
      title: context.l10n.addWordSaveDialogTitle,
      message: context.l10n.addWordSaveDialogMessage,
      okLabel: context.l10n.addWordSaveDialogOk,
      cancelLabel: context.l10n.addWordSaveDialogCancel,
    );
    if (result != OkCancelResult.ok) return;
    final wordText = _wordCtrl.text.trim();
    final pinyinText = _pinyinCtrl.text.trim();
    final meaningText = _meaningCtrl.text.trim();
    final noteText = _noteCtrl.text.trim();
    final word = await WordModel.create(
      word: wordText,
      pinyin: pinyinText,
      meaning: meaningText,
      note: noteText,
    );
    try {
      await dbService.saveWord(word);
    } catch (_) {
      if (!mounted) return;
      BotToast.showText(text: context.l10n.addWordToastSaveError);
      return;
    }
    if (!mounted) return;
    _wordCtrl.clear();
    _pinyinCtrl.clear();
    _meaningCtrl.clear();
    _noteCtrl.clear();
    _wordFocus.requestFocus();
    BotToast.showText(text: context.l10n.addWordToastSaveSuccess);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.addWordAppBarTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 96, 16, 16),
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: _isDuplicate,
            builder: (_, isDup, _) => TextField(
              controller: _wordCtrl,
              focusNode: _wordFocus,
              autofocus: true,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: context.l10n.addWordFieldWord,
                border: const OutlineInputBorder(),
                helperText: isDup ? context.l10n.addWordDuplicateWarning : null,
                helperStyle: isDup
                    ? TextStyle(color: Colors.amber.shade700)
                    : null,
                suffixIcon: isDup
                    ? const Icon(Icons.warning_amber_rounded, color: Colors.amber)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pinyinCtrl,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: context.l10n.addWordFieldPinyin,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _meaningCtrl,
            minLines: 1,
            maxLines: null,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              labelText: context.l10n.addWordFieldMeaning,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteCtrl,
            minLines: 1,
            maxLines: null,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              labelText: context.l10n.addWordFieldNote,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          child: Row(
            children: [
              Expanded(
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _wordCtrl,
                  builder: (_, value, _) => OutlinedButton.icon(
                    onPressed: (_aiConfigured && value.text.trim().isNotEmpty)
                        ? _onEnhance
                        : null,
                    icon: const Icon(Icons.auto_awesome),
                    label: Text(context.l10n.addWordAiEnhanceButton),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ValueListenableBuilder<bool>(
                  valueListenable: _canConfirm,
                  builder: (_, can, _) => FilledButton(
                    onPressed: can ? _onConfirm : null,
                    child: Text(context.l10n.addWordConfirmButton),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// AI Enhance bottom sheet
// ===========================================================================

/// Indismissable bottom sheet hosting one Enhance session.
///
/// Sheet architecture (see `we-re-now-coming-to-splendid-dahl.md` for the
/// four reliability fixes that drove this design):
///
///   1. Controller sync is **never** performed inside [build]. It runs in
///      [_onEnhancerStateChanged] via [WidgetsBinding.addPostFrameCallback]
///      so the build phase only reads state, never mutates controllers.
///   2. [dispose] removes the listener BEFORE calling [_enhancer.dispose],
///      and the enhancer's own dispose marks `_disposed` first so any
///      in-flight catch block short-circuits its state write.
///   3. History rollback uses reference-based lookup inside
///      [AIEnhancer], robust to abort races.
///   4. Per-field regen uses **anchor values** captured before the call,
///      so non-target fields are restored to whatever the user had
///      (typed or AI-given) — independent of the LLM's echoed output.
class _EnhanceSheet extends StatefulWidget {
  const _EnhanceSheet({
    required this.aiService,
    required this.outputLocale,
    required this.word,
    required this.originalPinyin,
    required this.originalMeaning,
    required this.originalNote,
  });

  final AIService aiService;
  final Locale outputLocale;
  final String word;
  final String originalPinyin;
  final String originalMeaning;
  final String originalNote;

  @override
  State<_EnhanceSheet> createState() => _EnhanceSheetState();
}

class _EnhanceSheetState extends State<_EnhanceSheet> {
  late final AIEnhancer _enhancer;
  late final TextEditingController _pinyinCtrl;
  late final TextEditingController _meaningCtrl;
  late final TextEditingController _noteCtrl;

  /// True when the next [EnhanceSuccess] should write all three controllers
  /// from the result (initial call, "Re-generate all" button). Set false
  /// whenever a per-field regen is queued.
  bool _fullSyncPending = true;

  /// When non-null, the next [EnhanceSuccess] only writes the targeted
  /// field; the other two are restored from [_anchors].
  EnhanceField? _partialSyncField;

  /// Snapshot of controller values taken right before a per-field regen,
  /// so the non-target fields can be restored regardless of what the LLM
  /// echoed back.
  ({String pinyin, String meaning, String note})? _anchors;

  @override
  void initState() {
    super.initState();
    _pinyinCtrl = TextEditingController(text: widget.originalPinyin);
    _meaningCtrl = TextEditingController(text: widget.originalMeaning);
    _noteCtrl = TextEditingController(text: widget.originalNote);
    _enhancer = AIEnhancer(
      aiService: widget.aiService,
      outputLocale: widget.outputLocale,
    );
    _enhancer.state.addListener(_onEnhancerStateChanged);
    _enhancer.start(
      word: widget.word,
      pinyin: widget.originalPinyin,
      meaning: widget.originalMeaning,
      note: widget.originalNote,
    );
  }

  // ── Fix 1: controller mutations only happen AFTER the current frame,
  // inside addPostFrameCallback. Reading _enhancer.state.value inside
  // build is safe (ValueListenableBuilder rebuilds for us); mutating
  // controllers in build is not.
  void _onEnhancerStateChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final s = _enhancer.state.value;
      if (s is! EnhanceSuccess) return;
      if (_partialSyncField != null) {
        _applyPartialSync(s.result);
      } else if (_fullSyncPending) {
        _applyFullSync(s.result);
      }
      _fullSyncPending = false;
      _partialSyncField = null;
      _anchors = null;
    });
  }

  void _applyFullSync(EnhanceResult r) {
    _setIfDifferent(_pinyinCtrl, r.pinyin);
    _setIfDifferent(_meaningCtrl, r.meaning);
    _setIfDifferent(_noteCtrl, r.note ?? '');
  }

  // ── Fix 4: ignore the LLM's echoed values for non-target fields; use
  // the anchors captured before the call.
  void _applyPartialSync(EnhanceResult r) {
    final a = _anchors!;
    final field = _partialSyncField!;
    switch (field) {
      case EnhanceField.pinyin:
        _setIfDifferent(_pinyinCtrl, r.pinyin);
        _setIfDifferent(_meaningCtrl, a.meaning);
        _setIfDifferent(_noteCtrl, a.note);
      case EnhanceField.meaning:
        _setIfDifferent(_pinyinCtrl, a.pinyin);
        _setIfDifferent(_meaningCtrl, r.meaning);
        _setIfDifferent(_noteCtrl, a.note);
      case EnhanceField.note:
        _setIfDifferent(_pinyinCtrl, a.pinyin);
        _setIfDifferent(_meaningCtrl, a.meaning);
        _setIfDifferent(_noteCtrl, r.note ?? a.note);
    }
  }

  void _setIfDifferent(TextEditingController c, String value) {
    if (c.text == value) return;
    c.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  Future<void> _onRegenerateField(EnhanceField field) async {
    _anchors = (
      pinyin: _pinyinCtrl.text,
      meaning: _meaningCtrl.text,
      note: _noteCtrl.text,
    );
    _partialSyncField = field;
    _fullSyncPending = false;
    await _enhancer.regenerate(field);
  }

  Future<void> _onRegenerateAll() async {
    _fullSyncPending = true;
    _partialSyncField = null;
    _anchors = null;
    await _enhancer.regenerate(null);
  }

  void _onCancel() {
    _enhancer.abort();
    context.pop();
  }

  void _onConfirm() {
    final noteText = _noteCtrl.text.trim();
    context.pop(
      EnhanceResult(
        pinyin: _pinyinCtrl.text.trim(),
        meaning: _meaningCtrl.text.trim(),
        note: noteText.isEmpty ? null : noteText,
      ),
    );
  }

  @override
  void dispose() {
    // Order matters: removeListener first so the post-frame callback in
    // _onEnhancerStateChanged can't write to a disposed ValueNotifier;
    // then dispose the enhancer (which sets _disposed + aborts); then
    // dispose our own controllers.
    _enhancer.state.removeListener(_onEnhancerStateChanged);
    _enhancer.dispose();
    _pinyinCtrl.dispose();
    _meaningCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: ValueListenableBuilder<EnhanceState>(
            valueListenable: _enhancer.state,
            builder: (context, state, _) {
              return switch (state) {
                EnhanceInitial() || EnhanceLoading() => const _LoadingView(),
                EnhanceError error => _ErrorView(error: error),
                EnhanceSuccess(:final result) => _SuccessView(
                  pinyinCtrl: _pinyinCtrl,
                  meaningCtrl: _meaningCtrl,
                  noteCtrl: _noteCtrl,
                  word: widget.word,
                  originalPinyin: widget.originalPinyin,
                  originalMeaning: widget.originalMeaning,
                  originalNote: widget.originalNote,
                  showNote: result.note != null,
                  isLoading: false,
                  onRegenerateField: _onRegenerateField,
                  onRegenerateAll: _onRegenerateAll,
                  onCancel: _onCancel,
                  onConfirm: _onConfirm,
                ),
              };
            },
          ),
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: double.infinity),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(context.l10n.addWordEnhanceLoading),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error});

  final EnhanceError error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = LlmErrorLocalizer.localizeEnhanceError(context, error);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error, size: 32),
          const SizedBox(height: 12),
          Text(
            message,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.addWordEnhanceErrorClose),
          ),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({
    required this.pinyinCtrl,
    required this.meaningCtrl,
    required this.noteCtrl,
    required this.word,
    required this.originalPinyin,
    required this.originalMeaning,
    required this.originalNote,
    required this.showNote,
    required this.isLoading,
    required this.onRegenerateField,
    required this.onRegenerateAll,
    required this.onCancel,
    required this.onConfirm,
  });

  final TextEditingController pinyinCtrl;
  final TextEditingController meaningCtrl;
  final TextEditingController noteCtrl;
  final String word;
  final String originalPinyin;
  final String originalMeaning;
  final String originalNote;
  final bool showNote;
  final bool isLoading;
  final ValueChanged<EnhanceField> onRegenerateField;
  final VoidCallback onRegenerateAll;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Text(word, style: Theme.of(context).textTheme.displayMedium),
          _FieldRow(
            controller: pinyinCtrl,
            original: originalPinyin,
            field: EnhanceField.pinyin,
            isLoading: isLoading,
            onRegenerate: onRegenerateField,
          ),
          _FieldRow(
            controller: meaningCtrl,
            original: originalMeaning,
            field: EnhanceField.meaning,
            isLoading: isLoading,
            onRegenerate: onRegenerateField,
          ),
          if (showNote) ...[
            _FieldRow(
              controller: noteCtrl,
              original: originalNote,
              field: EnhanceField.note,
              isLoading: isLoading,
              onRegenerate: onRegenerateField,
            ),
          ],
          _ActionBar(
            isLoading: isLoading,
            onCancel: onCancel,
            onRegenerateAll: onRegenerateAll,
            onConfirm: onConfirm,
          ),
        ],
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.controller,
    required this.original,
    required this.field,
    required this.isLoading,
    required this.onRegenerate,
  });

  final TextEditingController controller;
  final String original;
  final EnhanceField field;
  final bool isLoading;
  final ValueChanged<EnhanceField> onRegenerate;

  @override
  Widget build(BuildContext context) {
    final labelText = switch (field) {
      EnhanceField.pinyin => context.l10n.addWordFieldPinyin,
      EnhanceField.meaning => context.l10n.addWordFieldMeaning,
      EnhanceField.note => context.l10n.addWordFieldNote,
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            minLines: 1,
            maxLines: null,
            decoration: InputDecoration(
              labelText: labelText,
              isDense: true,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: context.l10n.addWordEnhanceRegenerateTooltip,
              onPressed: isLoading ? null : () => onRegenerate(field),
            ),
            // Restore button tracks the controller via ValueListenableBuilder
            // so it re-evaluates on every keystroke (the surrounding build
            // only fires on enhancer state changes, not on text changes).
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (_, value, _) {
                final atOriginal = value.text.trim() == original.trim();
                return IconButton(
                  icon: const Icon(Icons.undo),
                  tooltip: context.l10n.addWordEnhanceRestoreTooltip,
                  onPressed: (isLoading || atOriginal)
                      ? null
                      : () {
                          controller.value = TextEditingValue(
                            text: original,
                            selection: TextSelection.collapsed(
                              offset: original.length,
                            ),
                          );
                        },
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.isLoading,
    required this.onCancel,
    required this.onRegenerateAll,
    required this.onConfirm,
  });

  final bool isLoading;
  final VoidCallback onCancel;
  final VoidCallback onRegenerateAll;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: isLoading ? null : onRegenerateAll,
          icon: const Icon(Icons.auto_awesome),
          label: Text(context.l10n.addWordEnhanceRegenerateAll),
        ),
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: OutlinedButton(
                // Cancel works mid-load: it aborts the in-flight call and
                // pops the sheet. The sheet's dispose() then disposes the
                // enhancer, which aborts again (idempotent).
                onPressed: onCancel,
                child: Text(context.l10n.addWordEnhanceCancel),
              ),
            ),
            Expanded(
              child: FilledButton(
                onPressed: isLoading ? null : onConfirm,
                child: Text(context.l10n.addWordEnhanceConfirm),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
