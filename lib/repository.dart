import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:worder/entity/llm_config.dart';

class PreferencesRepository {
  static const String _llmConfigKey = "LLM_CONFIG";

  // TODO: 后续在 Settings UI 加设置项并持久化到 SharedPreferences,
  //       getter 改为读 preferences.getInt(_batchSizeKey) 并暴露 setter。
  static const int _defaultReviewBatchSize = 20;
  static const int _defaultLearnBatchSize = 10;

  late SharedPreferences preferences;

  Future<void> init() async {
    preferences = await SharedPreferences.getInstance();
  }

  LLMConfig currentLLMConfig() {
    var llmConfig = preferences.getString(_llmConfigKey);
    if (llmConfig == null) {
      return LLMConfig.empty;
    } else {
      return LLMConfig.fromJson(jsonDecode(llmConfig));
    }
  }

  Future<void> setLLMConfig({required LLMConfig config}) async {
    await preferences.setString(_llmConfigKey, jsonEncode(config.toJson()));
  }

  int get reviewBatchSize => _defaultReviewBatchSize;
  int get learnBatchSize => _defaultLearnBatchSize;
}
