import 'dart:async';
import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:auto_route/annotations.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:worder/config.dart';
import 'package:worder/database.dart';
import 'package:worder/entity/llm_config.dart';
import 'package:worder/manager/backup_exception.dart';
import 'package:worder/manager/backup_manager.dart';
import 'package:worder/repository.dart';
import 'package:worder/service/ai_service.dart';
import 'package:worder/util/backup_error_localizer.dart';
import 'package:worder/util/context_l10n.dart';
import 'package:worder/util/llm_error_localizer.dart';

@RoutePage()
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final PreferencesRepository _repository;
  late final AIService _aiService;
  late final AppDatabase _appDatabase;
  late final SchedulerRepository _schedulerRepository;
  late final TextEditingController _baseURLController;
  late final TextEditingController _apiKeyController;
  late final TextEditingController _modelController;
  late final FocusNode _baseURLFocus;
  late final FocusNode _apiKeyFocus;
  late final FocusNode _modelFocus;
  late final ValueNotifier<bool> _canTest;
  Timer? _saveDebounce;
  bool _isTesting = false;
  bool _isBackupBusy = false;

  @override
  void initState() {
    super.initState();
    _repository = context.read<PreferencesRepository>();
    _aiService = context.read<AIService>();
    _appDatabase = context.read<AppDatabase>();
    _schedulerRepository = context.read<SchedulerRepository>();
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
      _safeToast(context.l10n.settingsToastSaveError);
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
      _safeToast(context.l10n.settingsToastTestSuccess);
    } on LLMException catch (e) {
      _safeToast(LlmErrorLocalizer.localizeLLMException(context, e));
    } catch (_) {
      _safeToast(context.l10n.settingsToastTestUnexpectedError);
    } finally {
      if (mounted) setState(() => _isTesting = false);
    }
  }

  /// Build a fresh [BackupManager] inline — the manager is short-lived
  /// per backup operation, not a Provider singleton (matches the
  /// `AIEnhancer` / `LearningSessionManager` convention).
  BackupManager _buildBackupManager() => BackupManager(
    appDatabase: _appDatabase,
    preferencesRepository: _repository,
    schedulerRepository: _schedulerRepository,
  );

  Future<void> _onExport() async {
    if (_isBackupBusy) return;
    setState(() => _isBackupBusy = true);
    // Capture all l10n strings BEFORE the first await so the analyzer is
    // happy and the wording is stable across the await.
    final l10n = context.l10n;
    try {
      final ts = _backupTimestampCompact(DateTime.now());
      final destinationPath = await FilePicker.saveFile(
        dialogTitle: l10n.settingsBackupExportDialogTitle,
        fileName: 'worder-backup-$ts.zip',
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );
      if (destinationPath == null) return; // User cancelled the dialog.
      await _buildBackupManager().export(destinationPath: destinationPath);
      if (!mounted) return;
      _safeToast(l10n.settingsBackupExportSuccess);
    } on BackupException catch (e, st) {
      // Surface the structured cause in the console so a failure can
      // be diagnosed without re-running. The user still only sees the
      // localized toast.
      debugPrint('Backup import failed: $e\n$st');
      if (!mounted) return;
      _safeToast(BackupErrorLocalizer.localize(context, e));
    } on Object catch (e, st) {
      debugPrint('Backup export failed: $e\n$st');
      if (!mounted) return;
      _safeToast(l10n.settingsBackupErrorGeneric(e.toString()));
    } finally {
      if (mounted) setState(() => _isBackupBusy = false);
    }
  }

  Future<void> _onImport() async {
    if (_isBackupBusy) return;
    setState(() => _isBackupBusy = true);
    // Capture l10n before the first await.
    final l10n = context.l10n;
    try {
      final picked = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
        withData: false,
      );
      if (picked == null || picked.files.isEmpty) return;
      final sourcePath = picked.files.single.path;
      if (sourcePath == null) return; // Picker returned a stub with no path.

      if (!mounted) return;
      // Destructive confirmation. Mention the auto safety backup so the
      // user knows the current state is preserved before the swap.
      final ok = await showOkCancelAlertDialog(
        context: context,
        title: l10n.settingsBackupImportConfirmTitle,
        message: l10n.settingsBackupImportConfirmMessage,
        okLabel: l10n.settingsBackupImportConfirmOk,
        cancelLabel: l10n.settingsBackupImportConfirmCancel,
        isDestructiveAction: true,
      );
      if (ok != OkCancelResult.ok) return;

      final result = await _buildBackupManager().restore(
        sourcePath: sourcePath,
      );
      if (!mounted) return;
      _safeToast(l10n.settingsBackupImportSuccess);
      await _showRestartDialog(result.preRestoreZipPath);
    } on BackupException catch (e, st) {
      // Surface the structured cause in the console so a failure can
      // be diagnosed without re-running. The user still only sees the
      // localized toast.
      debugPrint('Backup import failed: $e\n$st');
      if (!mounted) return;
      _safeToast(BackupErrorLocalizer.localize(context, e));
    } on Object catch (e, st) {
      debugPrint('Backup import failed: $e\n$st');
      if (!mounted) return;
      _safeToast(l10n.settingsBackupErrorGeneric(e.toString()));
    } finally {
      if (mounted) setState(() => _isBackupBusy = false);
    }
  }

  /// Post-restore dialog. The restore is already done on disk; we tell
  /// the user that visible lists may be stale until restart and offer
  /// to actually terminate the app so the next launch picks up the new
  /// file.
  ///
  /// Android gets [SystemNavigator.pop] (polite, goes through the
  /// Activity finish flow). Windows / macOS / Linux / iOS get
  /// `exit(0)` from `dart:io` — portable, the only reliable way to
  /// terminate a Flutter desktop process. The user reopens the app
  /// manually; we don't try to relaunch because finding the running
  /// executable portably is fiddly and most users will just click the
  /// taskbar / dock icon to reopen anyway.
  Future<void> _showRestartDialog(String preRestoreZipPath) async {
    if (!mounted) return;
    final result = await showOkCancelAlertDialog(
      context: context,
      title: context.l10n.settingsBackupRestartTitle,
      message: context.l10n.settingsBackupRestartMessage(
        p.basename(preRestoreZipPath),
      ),
      okLabel: context.l10n.settingsBackupRestartOk,
      cancelLabel: context.l10n.settingsBackupRestartCancel,
    );
    if (!mounted) return;
    if (result != OkCancelResult.ok) return;
    if (Platform.isAndroid) {
      await SystemNavigator.pop();
    } else {
      // dart:io exit() — terminates the Dart VM. The restore is
      // already on disk by this point, so there's no in-flight state
      // to lose.
      exit(0);
    }
  }

  /// `yyyyMMdd-HHmmss` in local time. Duplicated from
  /// `BackupManager._timestampCompact` (which uses `DateTime.now()`)
  /// so the filename suggested in the save dialog matches what an
  /// export of the same moment would produce internally.
  String _backupTimestampCompact(DateTime now) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${now.year}${two(now.month)}${two(now.day)}-'
        '${two(now.hour)}${two(now.minute)}${two(now.second)}';
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
                  Text(
                    context.l10n.settingsSectionTheme,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<AdaptiveThemeMode>(
                    segments: [
                      ButtonSegment(
                        value: AdaptiveThemeMode.light,
                        label: Text(context.l10n.settingsThemeLight),
                      ),
                      ButtonSegment(
                        value: AdaptiveThemeMode.dark,
                        label: Text(context.l10n.settingsThemeDark),
                      ),
                      ButtonSegment(
                        value: AdaptiveThemeMode.system,
                        label: Text(context.l10n.settingsThemeSystem),
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
                    context.l10n.settingsSectionAiConfig,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.settingsAiConfigDescription,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _baseURLController,
                    focusNode: _baseURLFocus,
                    decoration: InputDecoration(
                      labelText: context.l10n.settingsFieldBaseUrl,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _apiKeyController,
                    focusNode: _apiKeyFocus,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: context.l10n.settingsFieldApiKey,
                      helperText: context.l10n.settingsFieldApiKeyHelper,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _modelController,
                    focusNode: _modelFocus,
                    decoration: InputDecoration(
                      labelText: context.l10n.settingsFieldModel,
                      border: const OutlineInputBorder(),
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
                            : Text(context.l10n.settingsTestButton),
                      ),
                    ),
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
                    context.l10n.settingsSectionBackup,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.settingsBackupDescription,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(
                      spacing: 8,
                      alignment: WrapAlignment.end,
                      children: [
                        FilledButton.tonal(
                          onPressed: _isBackupBusy ? null : _onExport,
                          child: _isBackupBusy
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(context.l10n.settingsBackupExportButton),
                        ),
                        FilledButton.tonal(
                          onPressed: _isBackupBusy ? null : _onImport,
                          child: _isBackupBusy
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(context.l10n.settingsBackupImportButton),
                        ),
                      ],
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
