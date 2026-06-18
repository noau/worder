import 'package:flutter/widgets.dart';

import '../manager/ai_enhancer.dart';
import '../service/ai_service.dart';
import 'context_l10n.dart';

/// Resolve a structured [LLMException] / [EnhanceError] to a localized
/// user-facing string.
///
/// The service and manager layers carry only data ([LLMErrorKind] / params,
/// or [EnhanceErrorKind] / cause) so they stay locale-agnostic and
/// unit-testable. The `BuildContext`-bound resolution happens here, at the
/// UI edge, where Flutter's [AppLocalizations] is in scope.
class LlmErrorLocalizer {
  const LlmErrorLocalizer._();

  /// Map an [LLMException.kind] + [LLMException.params] to a localized
  /// string via `context.l10n.aiErrorXxx(...)`.
  static String localizeLLMException(
    BuildContext context,
    LLMException e,
  ) {
    final l10n = context.l10n;
    final p = e.params ?? const <String, Object>{};
    switch (e.kind) {
      case LLMErrorKind.notConfigured:
        return l10n.aiErrorNotConfigured;
      case LLMErrorKind.invalidApiKey:
        return l10n.aiErrorInvalidKey;
      case LLMErrorKind.modelNotFound:
        return l10n.aiErrorModelNotFound(
          p['baseURL'] as String,
          p['message'] as String,
        );
      case LLMErrorKind.requestTimeout:
        return l10n.aiErrorRequestTimeout(p['minutes'] as int);
      case LLMErrorKind.cannotReach:
        return l10n.aiErrorCannotReach(p['baseURL'] as String);
      case LLMErrorKind.generic:
        return l10n.aiErrorGeneric(p['message'] as String);
    }
  }

  /// Map an [EnhanceError] to a localized string. For
  /// [EnhanceErrorKind.llmException], re-delegates to
  /// [localizeLLMException] using the carried [LLMException] from
  /// [EnhanceError.cause]. For [EnhanceErrorKind.unknown], formats the
  /// `cause.toString()` into the generic AI error template.
  static String localizeEnhanceError(
    BuildContext context,
    EnhanceError e,
  ) {
    final l10n = context.l10n;
    switch (e.kind) {
      case EnhanceErrorKind.unexpectedFormat:
        return l10n.aiErrorUnexpectedFormat;
      case EnhanceErrorKind.llmException:
        final cause = e.cause;
        if (cause is LLMException) {
          return localizeLLMException(context, cause);
        }
        // Defensive: a non-LLMException snuck in. Fall through to unknown.
        return l10n.aiErrorUnknown(cause?.toString() ?? '');
      case EnhanceErrorKind.unknown:
        return l10n.aiErrorUnknown(e.cause?.toString() ?? '');
    }
  }
}
