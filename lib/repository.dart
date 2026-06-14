import 'dart:convert';
import 'dart:developer';

import 'package:fsrs/fsrs.dart' as fsrs;
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

// TODO: We currently always uses default parameters for scheduler.
//       However, later we may introduce fsrs optimizer which can
//       automatically optimize scheduler to generate custom parameters
//       for each user, so this is not over-engineering or YAGNI.
class SchedulerRepository {
  late SharedPreferences preferences;
  late fsrs.Scheduler scheduler;

  static const _schedulerKey = "fsrs.scheduler";

  Future<void> init() async {
    preferences = await SharedPreferences.getInstance();
    final savedScheduler = preferences.getString(_schedulerKey);
    if (savedScheduler != null) {
      scheduler = fsrs.Scheduler.fromMap(jsonDecode(savedScheduler));
    } else {
      scheduler = fsrs.Scheduler();
      await saveScheduler();
    }
  }

  Future<void> saveScheduler() async {
    if (!await preferences.setString(
      _schedulerKey,
      jsonEncode(scheduler.toMap()),
    )) {
      log("Failed to save scheduler.");
    }
  }
}
