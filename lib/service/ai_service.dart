import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:openai_dart/openai_dart.dart';

import '../config.dart';
import '../entity/llm_config.dart';
import '../repository.dart';

/// Thin wrapper around `openai_dart 6.2.0` that pulls the current
/// [LLMConfig] from [PreferencesRepository] on every call, so the latest
/// user-edited values are always used.
///
/// Public API:
///   * [isConfigured]   — cheap config-present check.
///   * [testConnection] — used by the Settings "Test" button.
///   * [chatCompletion] — generic transport used by feature-specific
///                        managers (e.g. [AIEnhancer] for the AddWordPage
///                        "AI Enhance" button).
class AIService {
  AIService(this._prefs);

  final PreferencesRepository _prefs;

  /// Pull-based: re-read on every use, so changes the user just typed in
  /// Settings show up on the next call without any plumbing for change
  /// notifications.
  LLMConfig get _config => _prefs.currentLLMConfig();

  /// True iff [baseURL], [modelName], and [apiKey] are all non-empty.
  ///
  /// Cheap: just reads from in-memory prefs. Safe to call on every build.
  /// Used by the AddWordPage "AI Enhance" button to decide whether to
  /// enable itself.
  bool get isConfigured => !_config.isEmpty;

  OpenAIClient _buildClient(LLMConfig config) {
    return OpenAIClient(
      config: OpenAIConfig(
        authProvider: ApiKeyProvider(config.apiKey),
        baseUrl: config.baseURL,
        timeout: kLLMRequestTimeout,
        // Test/Enhance calls should fail fast on a bad config rather
        // than burning 3 retries on a misconfigured baseURL.
        retryPolicy: const RetryPolicy(maxRetries: 0),
        logLevel: kDebugMode && debugLLMMode ? debugLLMLogLevel : null,
      ),
    );
  }

  /// Single chokepoint for every LLM call: ensures config is present,
  /// builds a fresh [OpenAIClient], runs [body] against it, translates
  /// typed `openai_dart` exceptions into a user-facing [LLMException],
  /// and always closes the client.
  ///
  /// Domain methods ([testConnection], [chatCompletion]) are a thin
  /// one-liner that picks the chat request shape and any result-parsing —
  /// they should not re-implement the config / client / error-handling
  /// policy.
  Future<T> _execute<T>({
    required String methodName,
    required Future<T> Function(OpenAIClient client, LLMConfig config) body,
  }) async {
    final config = _config;
    if (config.isEmpty) {
      throw const LLMException(
        'AI not configured. Fill Base URL, Model, and API Key first.',
      );
    }
    final client = _buildClient(config);
    try {
      final result = await body(client, config);
      log('AIService.$methodName: ok', name: 'AIService');
      return result;
    } on AuthenticationException {
      // 401 — by far the most common error on a fresh key paste.
      log('AIService.$methodName: 401', name: 'AIService');
      throw const LLMException('Invalid API key (401). Double-check the key.');
    } on NotFoundException catch (e) {
      // 404 — model name typo or wrong baseURL path.
      log('AIService.$methodName: 404 ${e.message}', name: 'AIService');
      throw LLMException(
        'Model not found (404). Verify the model name and that '
        '${config.baseURL} serves an OpenAI-compatible API. '
        '(server: ${e.message})',
      );
    } on RequestTimeoutException {
      log('AIService.$methodName: timeout', name: 'AIService');
      throw LLMException(
        'Request timed out (limit: ${kLLMRequestTimeout.inMinutes} minutes). '
        'Check baseURL reachability.',
      );
    } on ConnectionException catch (e) {
      // DNS / refused / no-network — baseURL is the prime suspect.
      log('AIService.$methodName: connection ${e.url}', name: 'AIService');
      throw LLMException(
        'Cannot reach ${config.baseURL}. Check the address and your network.',
      );
    } on OpenAIException catch (e) {
      // Catch-all base: covers 400/403/409/422/429/5xx, ParseException,
      // and anything else openai_dart throws. Rarer paths collapse to a
      // generic "AI error" with the library's own message.
      log(
        'AIService.$methodName: ${e.runtimeType} ${e.message}',
        name: 'AIService',
      );
      throw LLMException('AI error: ${e.message}');
    } finally {
      client.close();
    }
  }

  /// Fire a minimal chat completion to verify that [baseURL], [apiKey],
  /// and [modelName] are all valid and that the endpoint speaks an
  /// OpenAI-compatible API.
  ///
  /// Throws [LLMException] with a user-facing message on any failure.
  /// Callers are expected to `try/catch` and surface the message via
  /// BotToast.
  Future<void> testConnection() => _execute<void>(
    methodName: 'testConnection',
    body: (client, config) async {
      await client.chat.completions.create(
        ChatCompletionCreateRequest(
          model: config.modelName,
          messages: [ChatMessage.user('hi')],
          maxTokens: 5,
        ),
      );
    },
  );

  /// Send a chat completion and return the raw assistant text.
  ///
  /// Goes through [_execute] for config gating + exception translation.
  /// The transport itself does not interpret the result; callers
  /// (e.g. [AIEnhancer]) own the prompt contract and response parsing.
  ///
  /// * [temperature] default `0.4` balances creativity with format
  ///   adherence. Set higher for more variance, lower for stricter output.
  /// * [maxTokens] optional upper bound. `null` means "model default".
  ///   Both `maxTokens` and `maxCompletionTokens` are set to the same
  ///   value to be robust across vendors that accept only one form.
  /// * [abortTrigger] when its future completes, the underlying HTTP
  ///   call is cancelled via `openai_dart`'s `abortTrigger` argument.
  ///   The transport does not interpret the cancellation; callers must
  ///   inspect their own state (e.g. [AIEnhancer] checks the abort
  ///   completer to distinguish "user-cancelled" from "real error").
  Future<String> chatCompletion({
    required List<ChatMessage> messages,
    double temperature = 0.4,
    int? maxTokens,
    Future<void>? abortTrigger,
  }) {
    return _execute<String>(
      methodName: 'chatCompletion',
      body: (client, config) async {
        final res = await client.chat.completions.create(
          ChatCompletionCreateRequest(
            model: config.modelName,
            messages: messages,
            temperature: temperature,
            maxTokens: maxTokens,
            maxCompletionTokens: maxTokens,
          ),
          abortTrigger: abortTrigger,
        );
        return res.choices.first.message.content ?? '';
      },
    );
  }
}

/// User-facing AI error. `message` is short and ready for a BotToast.
class LLMException implements Exception {
  const LLMException(this.message);

  final String message;
}
