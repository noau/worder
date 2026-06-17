import 'dart:async';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:auto_route/annotations.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:worder/config.dart';
import 'package:worder/entity/llm_config.dart';
import 'package:worder/repository.dart';
import 'package:worder/service/ai_service.dart';

@RoutePage()
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const _saveErrorMessage = 'Failed to save settings';
  static const _testSuccessMessage = 'Connection OK';
  static const _testUnexpectedErrorMessage = 'Test failed: unexpected error';

  late final PreferencesRepository _repository;
  late final AIService _aiService;
  late final TextEditingController _baseURLController;
  late final TextEditingController _apiKeyController;
  late final TextEditingController _modelController;
  late final FocusNode _baseURLFocus;
  late final FocusNode _apiKeyFocus;
  late final FocusNode _modelFocus;
  late final ValueNotifier<bool> _canTest;
  Timer? _saveDebounce;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _repository = context.read<PreferencesRepository>();
    _aiService = context.read<AIService>();
    final config = _repository.currentLLMConfig();
    _baseURLController = TextEditingController(text: config.baseURL);
    _apiKeyController = TextEditingController(text: config.apiKey);
    _modelController = TextEditingController(text: config.modelName);
    _baseURLFocus = FocusNode()..addListener(() => _onFocusLost(_baseURLFocus));
    _apiKeyFocus = FocusNode()..addListener(() => _onFocusLost(_apiKeyFocus));
    _modelFocus = FocusNode()..addListener(() => _onFocusLost(_modelFocus));
    _canTest = ValueNotifier(_areAllFieldsFilled());
    // Single listener per controller: updates the Test-button enable
    // state and arms the debounced save on every keystroke. Focus-loss
    // and dispose saves remain as belt-and-braces.
    _baseURLController.addListener(_onAnyFieldChanged);
    _apiKeyController.addListener(_onAnyFieldChanged);
    _modelController.addListener(_onAnyFieldChanged);
  }

  bool _areAllFieldsFilled() =>
      _baseURLController.text.isNotEmpty &&
      _apiKeyController.text.isNotEmpty &&
      _modelController.text.isNotEmpty;

  void _onAnyFieldChanged() {
    _canTest.value = _areAllFieldsFilled();
    _saveDebounce?.cancel();
    _saveDebounce = Timer(kSettingsSaveDebounce, () {
      _saveDebounce = null;
      unawaited(_saveConfig());
    });
  }

  void _onFocusLost(FocusNode node) {
    if (!node.hasFocus) {
      // Cancel any pending debounced save so we don't write the same
      // value twice when focus moves between fields.
      _saveDebounce?.cancel();
      _saveDebounce = null;
      unawaited(_saveConfig());
    }
  }

  Future<void> _saveConfig() async {
    final next = LLMConfig(
      baseURL: _baseURLController.text,
      modelName: _modelController.text,
      apiKey: _apiKeyController.text,
    );
    final current = _repository.currentLLMConfig();
    if (current.baseURL == next.baseURL &&
        current.modelName == next.modelName &&
        current.apiKey == next.apiKey) {
      return;
    }
    try {
      await _repository.setLLMConfig(config: next);
    } catch (_) {
      _safeToast(_saveErrorMessage);
    }
  }

  void _safeToast(String text) {
    if (!mounted) return;
    BotToast.showText(text: text);
  }

  Future<void> _onTest() async {
    if (_isTesting) return;
    // Flip the spinner on before the async save so the button reflects
    // the in-flight state even on a slow first SharedPreferences write.
    setState(() => _isTesting = true);
    // Flush any pending debounced save so the Test call sees the latest
    // values from SharedPreferences, not the controller buffer.
    _saveDebounce?.cancel();
    _saveDebounce = null;
    await _saveConfig();
    try {
      await _aiService.testConnection();
      _safeToast(_testSuccessMessage);
    } on LLMException catch (e) {
      _safeToast(e.message);
    } catch (_) {
      _safeToast(_testUnexpectedErrorMessage);
    } finally {
      if (mounted) setState(() => _isTesting = false);
    }
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    unawaited(_saveConfig());
    _baseURLController.dispose();
    _apiKeyController.dispose();
    _modelController.dispose();
    _baseURLFocus.dispose();
    _apiKeyFocus.dispose();
    _modelFocus.dispose();
    _canTest.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = AdaptiveTheme.of(context).mode;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Theme', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  SegmentedButton<AdaptiveThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: AdaptiveThemeMode.light,
                        label: Text('Light'),
                      ),
                      ButtonSegment(
                        value: AdaptiveThemeMode.dark,
                        label: Text('Dark'),
                      ),
                      ButtonSegment(
                        value: AdaptiveThemeMode.system,
                        label: Text('System'),
                      ),
                    ],
                    selected: {themeMode},
                    onSelectionChanged: (selection) {
                      AdaptiveTheme.of(context).setThemeMode(selection.first);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Configuration',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Only OpenAI-compatible APIs are supported.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _baseURLController,
                    focusNode: _baseURLFocus,
                    decoration: const InputDecoration(
                      labelText: 'Base URL',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _apiKeyController,
                    focusNode: _apiKeyFocus,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'API Key',
                      helperText: 'Hidden for privacy',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _modelController,
                    focusNode: _modelFocus,
                    decoration: const InputDecoration(
                      labelText: 'Model',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _canTest,
                      builder: (_, canTest, _) => FilledButton.tonal(
                        onPressed: canTest && !_isTesting ? _onTest : null,
                        child: _isTesting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Test'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
