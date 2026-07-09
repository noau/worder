// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Worder';

  @override
  String get appSlogan => 'Every word, one step further.';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navLibrary => 'Library';

  @override
  String get navSettings => 'Settings';

  @override
  String get navNewWordTooltip => 'New Word';

  @override
  String get dashboardSlogan => 'Every word, one step further.';

  @override
  String dashboardDayCounter(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Day $days',
      one: 'Day 1',
      zero: 'Day 0',
    );
    return '$_temp0';
  }

  @override
  String get dashboardStatNeedToReview => 'Need to Review';

  @override
  String get dashboardStatReviewedToday => 'Reviewed Today';

  @override
  String get dashboardReviewButton => 'Review';

  @override
  String get dashboardLearnButton => 'Learn';

  @override
  String get dashboardRecentlyReviewed => 'Recently reviewed';

  @override
  String get dashboardErrorCouldNotLoadReviewStatus =>
      'Could not load review status';

  @override
  String get dashboardErrorCouldNotLoadLearningWords =>
      'Could not load learning words';

  @override
  String get dashboardErrorCouldNotLoadReviewWords =>
      'Could not load review words';

  @override
  String get dashboardErrorCouldNotLoadRecentReviews =>
      'Could not load recent reviews.';

  @override
  String get dashboardEmptyNoReviewedYet => 'No reviewed words yet.';

  @override
  String get dashboardDialogReviewFirstTitle => 'Review work waiting';

  @override
  String dashboardDialogReviewFirstMessage(int dueCount) {
    String _temp0 = intl.Intl.pluralLogic(
      dueCount,
      locale: localeName,
      other: 'words are',
      one: 'word is',
    );
    return '$dueCount $_temp0 due for review. Review them first, or continue with learning?';
  }

  @override
  String get dashboardDialogReviewFirstOk => 'Review';

  @override
  String get dashboardDialogReviewFirstCancel => 'Continue learning';

  @override
  String get dashboardDialogNoNewWordsTitle => 'No new words yet';

  @override
  String get dashboardDialogNoNewWordsMessage =>
      'You have no new words to learn right now. Try to add some new words!';

  @override
  String get dashboardDialogAllCaughtUpTitle => 'All caught up!';

  @override
  String get dashboardDialogAllCaughtUpMessage =>
      'You have no words due for review right now. Try to learn some new words!';

  @override
  String get addWordAppBarTitle => 'New Word';

  @override
  String get addWordFieldWord => 'Word';

  @override
  String get addWordFieldPinyin => 'Pinyin';

  @override
  String get addWordFieldMeaning => 'Meaning';

  @override
  String get addWordFieldNote => 'Note (optional)';

  @override
  String get addWordAiEnhanceButton => 'AI Enhance';

  @override
  String get addWordConfirmButton => 'Confirm';

  @override
  String get addWordSaveDialogTitle => 'Save this word?';

  @override
  String get addWordSaveDialogMessage => 'A new word entry will be created.';

  @override
  String get addWordSaveDialogOk => 'Save';

  @override
  String get addWordSaveDialogCancel => 'Cancel';

  @override
  String get addWordToastSaveSuccess => 'Saved';

  @override
  String get addWordToastSaveError => 'Failed to save the word';

  @override
  String get addWordDuplicateWarning => 'This word is already in your library';

  @override
  String get addWordDuplicateDialogTitle => 'Duplicate Word';

  @override
  String addWordDuplicateDialogMessage(String word) {
    return 'The word \"$word\" is already in your library. Do you want to add it again?';
  }

  @override
  String get addWordDuplicateDialogOk => 'Add anyway';

  @override
  String get addWordDuplicateDialogCancel => 'Cancel';

  @override
  String get addWordEnhanceLoading => 'Asking the AI to enhance your word…';

  @override
  String get addWordEnhanceErrorClose => 'Close';

  @override
  String get addWordEnhanceRegenerateTooltip => 'Re-generate';

  @override
  String get addWordEnhanceRestoreTooltip => 'Restore original';

  @override
  String get addWordEnhanceRegenerateAll => 'Re-generate all';

  @override
  String get addWordEnhanceCancel => 'Cancel';

  @override
  String get addWordEnhanceConfirm => 'Confirm';

  @override
  String get libraryToastDeleteSuccess => 'Deleted';

  @override
  String get libraryToastDeleteError => 'Failed to delete the word';

  @override
  String get libraryDialogDeleteTitle => 'Delete this word?';

  @override
  String libraryDialogDeleteMessage(String word) {
    return '\"$word\" will be removed from your library. This cannot be undone.';
  }

  @override
  String get libraryDialogDeleteOk => 'Delete';

  @override
  String get libraryDialogDeleteCancel => 'Cancel';

  @override
  String get libraryErrorLoadTitle => 'Couldn\'t load your library';

  @override
  String get libraryErrorRetry => 'Retry';

  @override
  String get libraryEmptyTitle => 'Library is empty';

  @override
  String get libraryEmptyMessage =>
      'Add your first word to start building your collection';

  @override
  String get libraryEmptyAddButton => 'Add Word';

  @override
  String get libraryActionsDelete => 'Delete';

  @override
  String get settingsSectionTheme => 'Theme';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsSectionAiConfig => 'AI Configuration';

  @override
  String get settingsAiConfigDescription =>
      'Only OpenAI-compatible APIs are supported.';

  @override
  String get settingsFieldBaseUrl => 'Base URL';

  @override
  String get settingsFieldApiKey => 'API Key';

  @override
  String get settingsFieldApiKeyHelper => 'Hidden for privacy';

  @override
  String get settingsFieldModel => 'Model';

  @override
  String get settingsTestButton => 'Test';

  @override
  String get settingsToastSaveError => 'Failed to save settings';

  @override
  String get settingsToastTestSuccess => 'Connection OK';

  @override
  String get settingsToastTestUnexpectedError =>
      'Test failed: unexpected error';

  @override
  String get settingsSectionBackup => 'Backup & Restore';

  @override
  String get settingsBackupDescription =>
      'Save a complete copy of your library and settings, or restore from one.';

  @override
  String get settingsBackupExportButton => 'Export backup';

  @override
  String get settingsBackupImportButton => 'Import backup';

  @override
  String get settingsBackupExportDialogTitle => 'Save backup as…';

  @override
  String get settingsBackupExportSuccess => 'Backup saved';

  @override
  String get settingsBackupImportSuccess =>
      'Restore complete. Restart to see changes.';

  @override
  String settingsBackupErrorGeneric(String message) {
    return 'Backup failed: $message';
  }

  @override
  String get settingsBackupImportConfirmTitle => 'Replace all data?';

  @override
  String get settingsBackupImportConfirmMessage =>
      'Your current library and settings will be replaced with the contents of the backup. A safety backup of the current state will be saved automatically. This cannot be undone after restart.';

  @override
  String get settingsBackupImportConfirmOk => 'Restore';

  @override
  String get settingsBackupImportConfirmCancel => 'Cancel';

  @override
  String get settingsBackupRestartTitle => 'Restart recommended';

  @override
  String settingsBackupRestartMessage(String path) {
    return 'The restore wrote to disk, but visible lists may be stale until restart. A safety backup of the previous state was saved as $path.';
  }

  @override
  String get settingsBackupRestartOk => 'Restart now';

  @override
  String get settingsBackupRestartCancel => 'Later';

  @override
  String get settingsBackupErrorIo =>
      'Could not read or write the backup file.';

  @override
  String get settingsBackupErrorZipCorrupted =>
      'The backup file is corrupted or not a valid zip.';

  @override
  String get settingsBackupErrorManifestMissing =>
      'The backup is missing its manifest.json.';

  @override
  String settingsBackupErrorUnsupportedVersion(int version) {
    return 'Backup schema version $version is not supported by this app.';
  }

  @override
  String get settingsBackupErrorDatabaseCorrupted =>
      'The database file inside the backup is corrupted.';

  @override
  String get settingsBackupErrorPreRestoreFailed =>
      'Safety backup failed; restore aborted to protect your data.';

  @override
  String get settingsBackupErrorRestoreFailed =>
      'Restore failed partway. The previous data is in the safety backup.';

  @override
  String learnHeaderProgressCounter(int reviewed, int total) {
    return '$reviewed / $total';
  }

  @override
  String get learnBackTooltip => 'Quit session';

  @override
  String get learnRevealButton => 'Reveal';

  @override
  String get learnRatingAgain => 'Again';

  @override
  String get learnRatingHard => 'Hard';

  @override
  String get learnRatingGood => 'Good';

  @override
  String get learnRatingEasy => 'Easy';

  @override
  String get learnToastRateError => 'Failed to record rating';

  @override
  String get learnDialogQuitTitle => 'Quit session?';

  @override
  String get learnDialogQuitMessage =>
      'Progress for reviewed words has been saved. The remaining queue will be lost.';

  @override
  String get learnDialogQuitOk => 'Quit';

  @override
  String get learnDialogQuitCancel => 'Stay';

  @override
  String get sessionCompleteTitle => 'Session complete!';

  @override
  String sessionCompleteCounter(int reviewedCount) {
    String _temp0 = intl.Intl.pluralLogic(
      reviewedCount,
      locale: localeName,
      other: 'words reviewed.',
      one: 'word reviewed.',
    );
    return '$reviewedCount $_temp0';
  }

  @override
  String get sessionCompleteBack => 'Back to Dashboard';

  @override
  String get wordDetailSectionStats => 'Stats';

  @override
  String get wordDetailSectionNotes => 'Notes';

  @override
  String get wordDetailFabTooltip => 'New note';

  @override
  String get wordDetailTimelineCreated => 'Created';

  @override
  String get wordDetailTimelineLastReview => 'Last review';

  @override
  String get wordDetailTimelineLastReviewNever => 'Never';

  @override
  String get wordDetailTimelineNextDue => 'Next due';

  @override
  String get wordDetailMemoryRecall => 'Recall';

  @override
  String get wordDetailMemoryDifficulty => 'Difficulty';

  @override
  String get wordDetailMemoryStability => 'Stability';

  @override
  String get wordDetailMemoryPlaceholder =>
      'Rate this card to see memory stats';

  @override
  String get wordDetailNotesEmpty => 'No notes yet';

  @override
  String get wordDetailNoteEdit => 'Edit';

  @override
  String get wordDetailNoteMoveToTop => 'Move to top';

  @override
  String get wordDetailNoteDelete => 'Delete';

  @override
  String get wordDetailNoteEditorHint => 'Write a note...';

  @override
  String get wordDetailNoteEditorCancel => 'Cancel';

  @override
  String get wordDetailNoteEditorSave => 'Save';

  @override
  String get wordDetailNoteSaveError => 'Failed to save note';

  @override
  String get aiErrorNotConfigured =>
      'AI not configured. Fill Base URL, Model, and API Key first.';

  @override
  String get aiErrorInvalidKey =>
      'Invalid API key (401). Double-check the key.';

  @override
  String aiErrorModelNotFound(String baseURL, String message) {
    return 'Model not found (404). Verify the model name and that $baseURL serves an OpenAI-compatible API. (server: $message)';
  }

  @override
  String aiErrorRequestTimeout(int minutes) {
    return 'Request timed out (limit: $minutes minutes). Check baseURL reachability.';
  }

  @override
  String aiErrorCannotReach(String baseURL) {
    return 'Cannot reach $baseURL. Check the address and your network.';
  }

  @override
  String aiErrorGeneric(String message) {
    return 'AI error: $message';
  }

  @override
  String get aiErrorUnexpectedFormat =>
      'AI returned an unexpected format. Try again.';

  @override
  String aiErrorUnknown(String message) {
    return 'AI error: $message';
  }

  @override
  String get relativeNow => 'now';

  @override
  String get relativeJustNow => 'just now';

  @override
  String relativeInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'days',
      one: 'day',
    );
    return 'in $days $_temp0';
  }

  @override
  String relativeOverdueDays(int overdue) {
    String _temp0 = intl.Intl.pluralLogic(
      overdue,
      locale: localeName,
      other: 'days',
      one: 'day',
    );
    return 'overdue by $overdue $_temp0';
  }
}
