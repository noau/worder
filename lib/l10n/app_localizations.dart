import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale.fromSubtags(
      languageCode: 'zh',
      countryCode: 'CN',
      scriptCode: 'Hans',
    ),
    Locale.fromSubtags(
      languageCode: 'zh',
      countryCode: 'HK',
      scriptCode: 'Hant',
    ),
    Locale.fromSubtags(
      languageCode: 'zh',
      countryCode: 'TW',
      scriptCode: 'Hant',
    ),
  ];

  /// Application display name shown in the title bar, the Android launcher (via strings.xml), and system task switchers.
  ///
  /// In en, this message translates to:
  /// **'Worder'**
  String get appTitle;

  /// Short motivational tagline used as the default app slogan in marketing and about screens.
  ///
  /// In en, this message translates to:
  /// **'Every word, one step further.'**
  String get appSlogan;

  /// Bottom NavigationBar tab label for the dashboard (home) screen.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// Bottom NavigationBar tab label for the word library screen.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// Bottom NavigationBar tab label for the settings screen.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// FloatingActionButton tooltip on the dashboard and library tabs. Tapping opens the Add Word page.
  ///
  /// In en, this message translates to:
  /// **'New Word'**
  String get navNewWordTooltip;

  /// Dashboard header tagline displayed under the Worder brand title.
  ///
  /// In en, this message translates to:
  /// **'Every word, one step further.'**
  String get dashboardSlogan;

  /// Streak counter shown under the dashboard date. Shows the number of consecutive days the user has opened the app. Uses ICU plural so translators can customise the form for 0/1/other counts.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{Day 0} =1{Day 1} other{Day {days}}}'**
  String dashboardDayCounter(int days);

  /// Label of the left status card on the dashboard. Shows the count of words currently due for FSRS review.
  ///
  /// In en, this message translates to:
  /// **'Need to Review'**
  String get dashboardStatNeedToReview;

  /// Label of the right status card on the dashboard. Shows how many words the user has reviewed since local midnight.
  ///
  /// In en, this message translates to:
  /// **'Reviewed Today'**
  String get dashboardStatReviewedToday;

  /// Primary button on the dashboard that starts an FSRS review session for due words.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get dashboardReviewButton;

  /// Primary button on the dashboard that starts a learn session for new (or relearning) words.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get dashboardLearnButton;

  /// Section header above the list of the most recently reviewed words on the dashboard.
  ///
  /// In en, this message translates to:
  /// **'Recently reviewed'**
  String get dashboardRecentlyReviewed;

  /// Toast message shown when the dashboard fails to load the count of words due for review (typically before opening the Learn dialog).
  ///
  /// In en, this message translates to:
  /// **'Could not load review status'**
  String get dashboardErrorCouldNotLoadReviewStatus;

  /// Toast message shown when the Learn button fails to load the batch of new words.
  ///
  /// In en, this message translates to:
  /// **'Could not load learning words'**
  String get dashboardErrorCouldNotLoadLearningWords;

  /// Toast message shown when the Review button fails to load the batch of due words.
  ///
  /// In en, this message translates to:
  /// **'Could not load review words'**
  String get dashboardErrorCouldNotLoadReviewWords;

  /// Inline error message inside the 'Recently reviewed' section when its stream emits an error.
  ///
  /// In en, this message translates to:
  /// **'Could not load recent reviews.'**
  String get dashboardErrorCouldNotLoadRecentReviews;

  /// Inline empty-state message for the 'Recently reviewed' section when the user has not reviewed any words yet.
  ///
  /// In en, this message translates to:
  /// **'No reviewed words yet.'**
  String get dashboardEmptyNoReviewedYet;

  /// Title of the dialog shown when the user taps Learn while there are still words due for review. Encourages reviewing first.
  ///
  /// In en, this message translates to:
  /// **'Review work waiting'**
  String get dashboardDialogReviewFirstTitle;

  /// Body of the 'Review work waiting' dialog. Uses ICU plural to choose 'word'/'words' and 'is'/'are' based on the number of due reviews.
  ///
  /// In en, this message translates to:
  /// **'{dueCount} {dueCount, plural, =1{word is} other{words are}} due for review. Review them first, or continue with learning?'**
  String dashboardDialogReviewFirstMessage(int dueCount);

  /// OK button label of the 'Review work waiting' dialog. Switches to a review session.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get dashboardDialogReviewFirstOk;

  /// Cancel button label of the 'Review work waiting' dialog. Proceeds with the original Learn session.
  ///
  /// In en, this message translates to:
  /// **'Continue learning'**
  String get dashboardDialogReviewFirstCancel;

  /// Title of the dialog shown when the user taps Learn but no new or relearning words are available.
  ///
  /// In en, this message translates to:
  /// **'No new words yet'**
  String get dashboardDialogNoNewWordsTitle;

  /// Body of the 'No new words yet' dialog, encouraging the user to add new words.
  ///
  /// In en, this message translates to:
  /// **'You have no new words to learn right now. Try to add some new words!'**
  String get dashboardDialogNoNewWordsMessage;

  /// Title of the dialog shown when the user taps Review but no words are due. Celebratory tone.
  ///
  /// In en, this message translates to:
  /// **'All caught up!'**
  String get dashboardDialogAllCaughtUpTitle;

  /// Body of the 'All caught up!' dialog, nudging the user to add new words.
  ///
  /// In en, this message translates to:
  /// **'You have no words due for review right now. Try to learn some new words!'**
  String get dashboardDialogAllCaughtUpMessage;

  /// AppBar title of the Add Word full-screen page.
  ///
  /// In en, this message translates to:
  /// **'New Word'**
  String get addWordAppBarTitle;

  /// Label for the word input field on the Add Word form. Reused in the AI Enhance sheet for the same field.
  ///
  /// In en, this message translates to:
  /// **'Word'**
  String get addWordFieldWord;

  /// Label for the pinyin input field on the Add Word form. Reused in the AI Enhance sheet for the same field.
  ///
  /// In en, this message translates to:
  /// **'Pinyin'**
  String get addWordFieldPinyin;

  /// Label for the meaning/definition input field on the Add Word form. Reused in the AI Enhance sheet for the same field.
  ///
  /// In en, this message translates to:
  /// **'Meaning'**
  String get addWordFieldMeaning;

  /// Label for the optional notes input field on the Add Word form. The '(optional)' suffix signals the field is not required.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get addWordFieldNote;

  /// Outlined button on the Add Word bottom bar that opens the AI Enhance sheet to auto-fill pinyin, meaning, and notes.
  ///
  /// In en, this message translates to:
  /// **'AI Enhance'**
  String get addWordAiEnhanceButton;

  /// Primary filled button on the Add Word bottom bar. Opens a save confirmation dialog before persisting the new word.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get addWordConfirmButton;

  /// Title of the save confirmation dialog on the Add Word page.
  ///
  /// In en, this message translates to:
  /// **'Save this word?'**
  String get addWordSaveDialogTitle;

  /// Body of the save confirmation dialog on the Add Word page.
  ///
  /// In en, this message translates to:
  /// **'A new word entry will be created.'**
  String get addWordSaveDialogMessage;

  /// OK button label of the save confirmation dialog on the Add Word page.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get addWordSaveDialogOk;

  /// Cancel button label of the save confirmation dialog on the Add Word page.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get addWordSaveDialogCancel;

  /// Toast message shown after a new word is persisted successfully. The form is then cleared for batch entry.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get addWordToastSaveSuccess;

  /// Toast message shown when persisting a new word fails. The form is left intact for retry.
  ///
  /// In en, this message translates to:
  /// **'Failed to save the word'**
  String get addWordToastSaveError;

  /// Helper text shown under the Word TextField on the Add Word page when the typed word already exists in the database. Soft warning only — duplicates are allowed (per CLAUDE.md identifier strategy: same word can appear multiple times with different notes/contexts).
  ///
  /// In en, this message translates to:
  /// **'This word is already in your library'**
  String get addWordDuplicateWarning;

  /// Title of the dialog shown when the user clicks AI Enhance or Confirm on the Add Word page with a word that already exists in the database. Soft warning; the user can proceed by tapping Add anyway.
  ///
  /// In en, this message translates to:
  /// **'Duplicate Word'**
  String get addWordDuplicateDialogTitle;

  /// Body of the duplicate-word dialog on the Add Word page. Includes the offending word in double quotes so the user can verify they typed it correctly. Falls back to English in non-en locales until translated.
  ///
  /// In en, this message translates to:
  /// **'The word \"{word}\" is already in your library. Do you want to add it again?'**
  String addWordDuplicateDialogMessage(String word);

  /// OK button label of the duplicate-word dialog on the Add Word page. Proceeds with the existing flow (AI Enhance sheet open or save confirmation dialog).
  ///
  /// In en, this message translates to:
  /// **'Add anyway'**
  String get addWordDuplicateDialogOk;

  /// Cancel button label of the duplicate-word dialog on the Add Word page. Aborts the action.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get addWordDuplicateDialogCancel;

  /// Loading text shown inside the AI Enhance sheet while waiting for the LLM to return pinyin/meaning/notes.
  ///
  /// In en, this message translates to:
  /// **'Asking the AI to enhance your word…'**
  String get addWordEnhanceLoading;

  /// Button label in the AI Enhance sheet's error state. Dismisses the sheet.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get addWordEnhanceErrorClose;

  /// IconButton tooltip in the AI Enhance sheet. Re-asks the LLM for that single field (pinyin, meaning, or note).
  ///
  /// In en, this message translates to:
  /// **'Re-generate'**
  String get addWordEnhanceRegenerateTooltip;

  /// IconButton tooltip in the AI Enhance sheet. Reverts that field to whatever the user typed before the LLM filled it in.
  ///
  /// In en, this message translates to:
  /// **'Restore original'**
  String get addWordEnhanceRestoreTooltip;

  /// Outlined button label in the AI Enhance sheet. Re-asks the LLM for pinyin, meaning, and notes in one go.
  ///
  /// In en, this message translates to:
  /// **'Re-generate all'**
  String get addWordEnhanceRegenerateAll;

  /// Outlined button label in the AI Enhance sheet. Discards AI suggestions and closes the sheet.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get addWordEnhanceCancel;

  /// Primary button label in the AI Enhance sheet. Copies the AI-suggested pinyin/meaning/note back into the Add Word form.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get addWordEnhanceConfirm;

  /// Toast message shown after a word is successfully deleted from the library.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get libraryToastDeleteSuccess;

  /// Toast message shown when deleting a word from the library fails.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete the word'**
  String get libraryToastDeleteError;

  /// Title of the long-press delete confirmation dialog on the library page.
  ///
  /// In en, this message translates to:
  /// **'Delete this word?'**
  String get libraryDialogDeleteTitle;

  /// Body of the delete confirmation dialog. Includes the word's text in double quotes and warns the action is irreversible.
  ///
  /// In en, this message translates to:
  /// **'\"{word}\" will be removed from your library. This cannot be undone.'**
  String libraryDialogDeleteMessage(String word);

  /// OK button label of the library delete confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get libraryDialogDeleteOk;

  /// Cancel button label of the library delete confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get libraryDialogDeleteCancel;

  /// Heading of the error state on the library page when the words stream fails.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your library'**
  String get libraryErrorLoadTitle;

  /// Button label in the library error state. Re-subscribes to the words stream.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get libraryErrorRetry;

  /// Heading of the empty state on the library page when the user has no words saved yet.
  ///
  /// In en, this message translates to:
  /// **'Library is empty'**
  String get libraryEmptyTitle;

  /// Subtext of the library empty state, encouraging the user to add their first word.
  ///
  /// In en, this message translates to:
  /// **'Add your first word to start building your collection'**
  String get libraryEmptyMessage;

  /// Primary button label in the library empty state. Navigates to the Add Word page.
  ///
  /// In en, this message translates to:
  /// **'Add Word'**
  String get libraryEmptyAddButton;

  /// Title of the destructive 'Delete' ListTile in the per-card actions bottom sheet on the library page. Separate key from the dialog confirm button so the sheet can be styled as destructive without forcing the dialog button to be styled the same way.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get libraryActionsDelete;

  /// Section heading on the settings page that groups the theme SegmentedButton.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsSectionTheme;

  /// Segment label that forces the light theme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// Segment label that forces the dark theme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// Segment label that follows the OS theme preference.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// Section heading on the settings page that groups the LLM config fields (base URL, API key, model).
  ///
  /// In en, this message translates to:
  /// **'AI Configuration'**
  String get settingsSectionAiConfig;

  /// Subtitle below the AI Configuration section heading, clarifying that only OpenAI-compatible LLM endpoints are valid.
  ///
  /// In en, this message translates to:
  /// **'Only OpenAI-compatible APIs are supported.'**
  String get settingsAiConfigDescription;

  /// Label for the Base URL input field in AI Configuration. Typically an OpenAI-compatible endpoint root (e.g. https://api.openai.com/v1).
  ///
  /// In en, this message translates to:
  /// **'Base URL'**
  String get settingsFieldBaseUrl;

  /// Label for the API key input field in AI Configuration. The field is rendered as a password (obscured).
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get settingsFieldApiKey;

  /// Helper text under the API key field, reassuring the user that the key is obscured in the UI.
  ///
  /// In en, this message translates to:
  /// **'Hidden for privacy'**
  String get settingsFieldApiKeyHelper;

  /// Label for the model name input field in AI Configuration (e.g. gpt-4o-mini, qwen2.5:7b).
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get settingsFieldModel;

  /// Label of the FilledButton that fires AIService.testConnection() and toasts the result.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get settingsTestButton;

  /// Toast message shown when persisting the LLM config (debounced auto-save) fails.
  ///
  /// In en, this message translates to:
  /// **'Failed to save settings'**
  String get settingsToastSaveError;

  /// Toast message shown after AIService.testConnection() succeeds.
  ///
  /// In en, this message translates to:
  /// **'Connection OK'**
  String get settingsToastTestSuccess;

  /// Toast message shown when AIService.testConnection() throws something that is not an LLMException.
  ///
  /// In en, this message translates to:
  /// **'Test failed: unexpected error'**
  String get settingsToastTestUnexpectedError;

  /// Small header text on the Learn / Review session page showing how many of the session's words have been rated.
  ///
  /// In en, this message translates to:
  /// **'{reviewed} / {total}'**
  String learnHeaderProgressCounter(int reviewed, int total);

  /// Tooltip of the back-arrow IconButton in the Learn / Review session AppBar. Opens a quit-confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Quit session'**
  String get learnBackTooltip;

  /// Label of the front-of-card button that flips the card to show pinyin/meaning/notes. After tapping, it is replaced by the FSRS rating grid.
  ///
  /// In en, this message translates to:
  /// **'Reveal'**
  String get learnRevealButton;

  /// FSRS rating button label meaning 'failed recall — show again soon'. Maps to fsrs.Rating.again.
  ///
  /// In en, this message translates to:
  /// **'Again'**
  String get learnRatingAgain;

  /// FSRS rating button label meaning 'recalled with significant difficulty'. Maps to fsrs.Rating.hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get learnRatingHard;

  /// FSRS rating button label meaning 'recalled correctly'. Maps to fsrs.Rating.good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get learnRatingGood;

  /// FSRS rating button label meaning 'recalled with no effort'. Maps to fsrs.Rating.easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get learnRatingEasy;

  /// Toast message shown when persisting a rating via LearningSessionManager.rateWord fails. The back of the card stays put for retry.
  ///
  /// In en, this message translates to:
  /// **'Failed to record rating'**
  String get learnToastRateError;

  /// Title of the quit-confirmation dialog shown when the user tries to leave a Learn / Review session early.
  ///
  /// In en, this message translates to:
  /// **'Quit session?'**
  String get learnDialogQuitTitle;

  /// Body of the quit-confirmation dialog. Explains that already-rated words are persisted but the rest of the queue is discarded.
  ///
  /// In en, this message translates to:
  /// **'Progress for reviewed words has been saved. The remaining queue will be lost.'**
  String get learnDialogQuitMessage;

  /// OK button label of the quit-confirmation dialog. Exits the session and returns to the dashboard.
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get learnDialogQuitOk;

  /// Cancel button label of the quit-confirmation dialog. Returns to the session.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get learnDialogQuitCancel;

  /// Heading on the post-session summary page after the queue is exhausted.
  ///
  /// In en, this message translates to:
  /// **'Session complete!'**
  String get sessionCompleteTitle;

  /// Subtext on the post-session summary page. Shows the total number of words reviewed in this session. Uses ICU plural for word/words inflection.
  ///
  /// In en, this message translates to:
  /// **'{reviewedCount} {reviewedCount, plural, =1{word reviewed.} other{words reviewed.}}'**
  String sessionCompleteCounter(int reviewedCount);

  /// Primary button label on the post-session summary page. Returns to the dashboard tab.
  ///
  /// In en, this message translates to:
  /// **'Back to Dashboard'**
  String get sessionCompleteBack;

  /// Section header on the word detail page for the FSRS memory statistics (recall, difficulty, stability, timeline).
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get wordDetailSectionStats;

  /// Section header on the word detail page for the user's notes attached to this word.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get wordDetailSectionNotes;

  /// FloatingActionButton tooltip on the word detail page. Opens the note editor sheet.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get wordDetailFabTooltip;

  /// Label of the timeline cell showing when the word was first added to the library.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get wordDetailTimelineCreated;

  /// Label of the timeline cell showing the most recent review time. Shows 'Never' if the word has never been reviewed.
  ///
  /// In en, this message translates to:
  /// **'Last review'**
  String get wordDetailTimelineLastReview;

  /// Placeholder value for the 'Last review' timeline cell when the word has not been reviewed yet.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get wordDetailTimelineLastReviewNever;

  /// Label of the timeline cell showing when the word is next due for review (FSRS due date).
  ///
  /// In en, this message translates to:
  /// **'Next due'**
  String get wordDetailTimelineNextDue;

  /// Label of the memory stats cell showing the FSRS recall probability as a percentage.
  ///
  /// In en, this message translates to:
  /// **'Recall'**
  String get wordDetailMemoryRecall;

  /// Label of the memory stats cell showing the FSRS difficulty value (1.0–10.0 range, formatted to 1 decimal).
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get wordDetailMemoryDifficulty;

  /// Label of the memory stats cell showing the FSRS stability value in days, with a 'd' suffix.
  ///
  /// In en, this message translates to:
  /// **'Stability'**
  String get wordDetailMemoryStability;

  /// Placeholder message shown in the memory stats section when the word has not been reviewed yet — no stats exist to display.
  ///
  /// In en, this message translates to:
  /// **'Rate this card to see memory stats'**
  String get wordDetailMemoryPlaceholder;

  /// Message shown inside the Notes section card when the word has no notes.
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get wordDetailNotesEmpty;

  /// Title of the 'Edit' ListTile in the per-note actions bottom sheet on the word detail page.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get wordDetailNoteEdit;

  /// Title of the 'Move to top' ListTile in the per-note actions bottom sheet.
  ///
  /// In en, this message translates to:
  /// **'Move to top'**
  String get wordDetailNoteMoveToTop;

  /// Title of the destructive 'Delete' ListTile in the per-note actions bottom sheet on the word detail page.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get wordDetailNoteDelete;

  /// Placeholder hint text inside the TextField of the note editor bottom sheet.
  ///
  /// In en, this message translates to:
  /// **'Write a note...'**
  String get wordDetailNoteEditorHint;

  /// Cancel button label in the note editor bottom sheet. Discards the new/edited note.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get wordDetailNoteEditorCancel;

  /// Save button label in the note editor bottom sheet. Persists the new/edited note.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get wordDetailNoteEditorSave;

  /// Toast message shown when persisting a new or edited note fails.
  ///
  /// In en, this message translates to:
  /// **'Failed to save note'**
  String get wordDetailNoteSaveError;

  /// LLMException message shown when the user invokes an AI feature before saving a complete LLMConfig (base URL, model, API key all required).
  ///
  /// In en, this message translates to:
  /// **'AI not configured. Fill Base URL, Model, and API Key first.'**
  String get aiErrorNotConfigured;

  /// LLMException message shown when the LLM endpoint returns HTTP 401 (authentication failure).
  ///
  /// In en, this message translates to:
  /// **'Invalid API key (401). Double-check the key.'**
  String get aiErrorInvalidKey;

  /// LLMException message shown when the LLM endpoint returns HTTP 404 (model not found, or endpoint is not OpenAI-compatible).
  ///
  /// In en, this message translates to:
  /// **'Model not found (404). Verify the model name and that {baseURL} serves an OpenAI-compatible API. (server: {message})'**
  String aiErrorModelNotFound(String baseURL, String message);

  /// LLMException message shown when the LLM request exceeds the 10-minute timeout. Usually indicates a network/proxy issue.
  ///
  /// In en, this message translates to:
  /// **'Request timed out (limit: {minutes} minutes). Check baseURL reachability.'**
  String aiErrorRequestTimeout(int minutes);

  /// LLMException message shown when the LLM endpoint is unreachable (DNS failure, refused connection, etc.).
  ///
  /// In en, this message translates to:
  /// **'Cannot reach {baseURL}. Check the address and your network.'**
  String aiErrorCannotReach(String baseURL);

  /// LLMException catch-all message for any other library-thrown error (400/403/409/422/429/5xx, parse errors, etc.).
  ///
  /// In en, this message translates to:
  /// **'AI error: {message}'**
  String aiErrorGeneric(String message);

  /// EnhanceError message shown when the AI Enhance sheet receives a response that doesn't match the expected pinyin/meaning/notes structure (FormatException).
  ///
  /// In en, this message translates to:
  /// **'AI returned an unexpected format. Try again.'**
  String get aiErrorUnexpectedFormat;

  /// EnhanceError catch-all message for any non-LLMException thrown by the AI Enhancer. Kept separate from aiErrorGeneric so translators can adjust phrasing.
  ///
  /// In en, this message translates to:
  /// **'AI error: {message}'**
  String aiErrorUnknown(String message);

  /// Relative-time label for timestamps within 60 seconds of 'now'. Used in word detail and dashboard.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get relativeNow;

  /// Relative-time label for timestamps earlier today (UTC day boundary).
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get relativeJustNow;

  /// Relative-time label for future dates. Uses ICU plural for day/days inflection.
  ///
  /// In en, this message translates to:
  /// **'in {days} {days, plural, =1{day} other{days}}'**
  String relativeInDays(int days);

  /// Relative-time label for past dates past the UTC day boundary. Uses ICU plural for day/days inflection.
  ///
  /// In en, this message translates to:
  /// **'overdue by {overdue} {overdue, plural, =1{day} other{days}}'**
  String relativeOverdueDays(int overdue);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script+country codes are specified.
  switch (locale.toString()) {
    case 'zh_Hans_CN':
      return AppLocalizationsZhHansCn();
    case 'zh_Hant_HK':
      return AppLocalizationsZhHantHk();
    case 'zh_Hant_TW':
      return AppLocalizationsZhHantTw();
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
