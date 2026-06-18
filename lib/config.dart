// UI Debugs
import 'package:logging/logging.dart';

const bool disableDebugLabel = false;

//AI Debugs
const bool debugLLMMode = true;
const Level debugLLMLogLevel = Level.ALL;

/// Upper bound for any single LLM HTTP request (chat completion, etc).
/// Long enough for slow local endpoints, short enough to fail visibly
/// before the user thinks the app is hung.
const Duration kLLMRequestTimeout = Duration(minutes: 10);

/// Delay between the last keystroke on a Settings field and the
/// debounced SharedPreferences write.
const Duration kSettingsSaveDebounce = Duration(milliseconds: 300);

// Database Debugs
const bool debugDatabaseLogs = false;
const bool debugDeleteAllDatabaseTables = false;
