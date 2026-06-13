import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:worder/entity/llm_config.dart';

class PreferencesRepository {
  static const String _llmConfigKey = "LLM_CONFIG";

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
}
