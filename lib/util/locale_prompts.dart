import 'package:flutter/widgets.dart';

/// Convert a [Locale] to a human-readable language name suitable for
/// injecting into an LLM prompt.
///
/// Tries to match the full BCP47 tag first (e.g. `zh-Hans-CN`), then the
/// language subtag alone (e.g. `zh`). Falls back to a generic phrase
/// `<locale.toLanguageTag()>` for anything not in the known set — better
/// than silently getting it wrong, since the LLM can usually still infer
/// the language from a BCP47 tag (e.g. `fr` → French, `de` → German).
String languageNameForPrompt(Locale locale) {
  // Prefer the full BCP47 tag (covers script and region variants).
  final tag = locale.toLanguageTag();
  // Match the full tag (zh-Hans-CN matches "Simplified Chinese", not
  // "Chinese") so the LLM gets the most precise instruction possible.
  const known = <String, String>{
    'en': 'English',
    'zh-Hans': 'Simplified Chinese',
    'zh-Hant': 'Traditional Chinese',
    'zh-CN': 'Simplified Chinese',
    'zh-TW': 'Traditional Chinese',
    'zh-HK': 'Traditional Chinese',
    'ja': 'Japanese',
    'ko': 'Korean',
    'fr': 'French',
    'de': 'German',
    'es': 'Spanish',
    'ru': 'Russian',
    'pt': 'Portuguese',
    'it': 'Italian',
  };
  if (known.containsKey(tag)) return known[tag]!;
  if (known.containsKey(locale.languageCode)) {
    return known[locale.languageCode]!;
  }
  return "the user's preferred language ($tag)";
}
