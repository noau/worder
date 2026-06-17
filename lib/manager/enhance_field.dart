/// Which field of an [EnhanceResult] a per-field regenerate targets.
///
/// Lives in its own file (no deps on [AIEnhancer] or [ai_prompts]) to avoid
/// a circular import between `ai_enhancer.dart` and `ai_prompts.dart` —
/// `ai_prompts.dart` consumes this enum, while `ai_enhancer.dart` also
/// imports `ai_prompts.dart` for the prompt builders.
enum EnhanceField { pinyin, meaning, note }
