import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
// `Level` is referenced solely as a type for `openai_dart`'s `logLevel`
// knob (only set when `debugLLMMode` is on). Project-level diagnostics
// still use `dart:developer`'s `log(...)`.
import 'package:logging/logging.dart';
import 'package:openai_dart/openai_dart.dart';

import '../config.dart';
import '../entity/llm_config.dart';
import '../repository.dart';

/// Thin wrapper around `openai_dart 6.2.0` that pulls the current
/// [LLMConfig] from [PreferencesRepository] on every call, so the latest
/// user-edited values are always used.
///
/// Designed to be the single point of contact for all AI features. Right
/// now it exposes only [testConnection] (used by the Settings page Test
/// button). The AddWordPage "AI Enhance" hook is a future addition — see
/// CLAUDE.md "AI Enhance behavior (deferred)".
class AIService {
  AIService(this._prefs);

  final PreferencesRepository _prefs;

  /// Pull-based: re-read on every use, so changes the user just typed in
  /// Settings show up on the next call without any plumbing for change
  /// notifications.
  LLMConfig get _config => _prefs.currentLLMConfig();

  OpenAIClient _buildClient(LLMConfig config) {
    return OpenAIClient(
      config: OpenAIConfig(
        authProvider: ApiKeyProvider(config.apiKey),
        baseUrl: config.baseURL,
        timeout: kLLMRequestTimeout,
        // Test/Enhance calls should fail fast on a bad config rather
        // than burning 3 retries on a misconfigured baseURL.
        retryPolicy: const RetryPolicy(maxRetries: 0),
        logLevel: kDebugMode && debugLLMMode ? Level.FINE : null,
      ),
    );
  }

  /// Single chokepoint for every LLM call: ensures config is present,
  /// builds a fresh [OpenAIClient], runs [body] against it, translates
  /// typed `openai_dart` exceptions into a user-facing [LLMException],
  /// and always closes the client.
  ///
  /// Domain methods (currently [testConnection]; future `enhanceWord`,
  /// etc.) are expected to be a thin one-liner that picks the chat
  /// request shape and any result-parsing — they should not re-implement
  /// the config / client / error-handling policy.
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
}

/// User-facing AI error. `message` is short and ready for a BotToast.
class LLMException implements Exception {
  const LLMException(this.message);
  final String message;
}
