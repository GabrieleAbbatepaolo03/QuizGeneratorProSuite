import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_it.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('am'),
    Locale('en'),
    Locale('es'),
    Locale('it'),
    Locale('zh')
  ];

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Quiz Generator Pro'**
  String get dashboardTitle;

  /// No description provided for @noFileLoaded.
  ///
  /// In en, this message translates to:
  /// **'No Knowledge Base Loaded'**
  String get noFileLoaded;

  /// No description provided for @uploadPdf.
  ///
  /// In en, this message translates to:
  /// **'Add PDF Document'**
  String get uploadPdf;

  /// No description provided for @readingPdf.
  ///
  /// In en, this message translates to:
  /// **'Reading PDF...'**
  String get readingPdf;

  /// No description provided for @activeFile.
  ///
  /// In en, this message translates to:
  /// **'Knowledge Base:'**
  String get activeFile;

  /// No description provided for @chatWithAi.
  ///
  /// In en, this message translates to:
  /// **'Chat w/ AI'**
  String get chatWithAi;

  /// No description provided for @generateQuiz.
  ///
  /// In en, this message translates to:
  /// **'Generate Quiz'**
  String get generateQuiz;

  /// No description provided for @changeFile.
  ///
  /// In en, this message translates to:
  /// **'Manage Files'**
  String get changeFile;

  /// No description provided for @pdfUploaded.
  ///
  /// In en, this message translates to:
  /// **'PDF Added to Brain!'**
  String get pdfUploaded;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'System & Settings'**
  String get settingsTitle;

  /// No description provided for @detectedHardware.
  ///
  /// In en, this message translates to:
  /// **'DETECTED HARDWARE'**
  String get detectedHardware;

  /// No description provided for @compatible.
  ///
  /// In en, this message translates to:
  /// **'Compatible with your PC'**
  String get compatible;

  /// No description provided for @incompatible.
  ///
  /// In en, this message translates to:
  /// **'Hardware insufficient'**
  String get incompatible;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @load.
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get load;

  /// No description provided for @missingFile.
  ///
  /// In en, this message translates to:
  /// **'Missing File'**
  String get missingFile;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get selectLanguage;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatTitle;

  /// No description provided for @chatHint.
  ///
  /// In en, this message translates to:
  /// **'Ask about your document...'**
  String get chatHint;

  /// No description provided for @quizTitle.
  ///
  /// In en, this message translates to:
  /// **'Quiz Generator'**
  String get quizTitle;

  /// No description provided for @configQuiz.
  ///
  /// In en, this message translates to:
  /// **'Configure your Quiz'**
  String get configQuiz;

  /// No description provided for @customPromptLabel.
  ///
  /// In en, this message translates to:
  /// **'Quiz Focus & Style'**
  String get customPromptLabel;

  /// No description provided for @customPromptHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: Hard questions about Quantum Physics, academic style...'**
  String get customPromptHint;

  /// No description provided for @numberOfQuestions.
  ///
  /// In en, this message translates to:
  /// **'Number of Questions'**
  String get numberOfQuestions;

  /// No description provided for @difficultyLabel.
  ///
  /// In en, this message translates to:
  /// **'Difficulty Level'**
  String get difficultyLabel;

  /// No description provided for @generateBtn.
  ///
  /// In en, this message translates to:
  /// **'Generate Quiz'**
  String get generateBtn;

  /// No description provided for @startQuizBtn.
  ///
  /// In en, this message translates to:
  /// **'Start Quiz'**
  String get startQuizBtn;

  /// No description provided for @generating.
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get generating;

  /// No description provided for @quizResults.
  ///
  /// In en, this message translates to:
  /// **'Quiz Results'**
  String get quizResults;

  /// No description provided for @newQuiz.
  ///
  /// In en, this message translates to:
  /// **'New Quiz'**
  String get newQuiz;

  /// No description provided for @correctAnswer.
  ///
  /// In en, this message translates to:
  /// **'Answer:'**
  String get correctAnswer;

  /// No description provided for @quizHistory.
  ///
  /// In en, this message translates to:
  /// **'Quiz History'**
  String get quizHistory;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'No quizzes taken yet'**
  String get noHistory;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @startSession.
  ///
  /// In en, this message translates to:
  /// **'Start Study Session'**
  String get startSession;

  /// No description provided for @subStart.
  ///
  /// In en, this message translates to:
  /// **'Chat • Quiz • Verify'**
  String get subStart;

  /// No description provided for @aiChat.
  ///
  /// In en, this message translates to:
  /// **'AI Chat'**
  String get aiChat;

  /// No description provided for @newSession.
  ///
  /// In en, this message translates to:
  /// **'New Session'**
  String get newSession;

  /// No description provided for @config.
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get config;

  /// No description provided for @questions.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get questions;

  /// No description provided for @sceltaMultipla.
  ///
  /// In en, this message translates to:
  /// **'Multiple Choice'**
  String get sceltaMultipla;

  /// No description provided for @rispostaAperta.
  ///
  /// In en, this message translates to:
  /// **'Open Answer'**
  String get rispostaAperta;

  /// No description provided for @feedbackAI.
  ///
  /// In en, this message translates to:
  /// **'AI Feedback'**
  String get feedbackAI;

  /// No description provided for @writeAnswer.
  ///
  /// In en, this message translates to:
  /// **'Type your answer here...'**
  String get writeAnswer;

  /// No description provided for @sendAnswer.
  ///
  /// In en, this message translates to:
  /// **'Submit Answer'**
  String get sendAnswer;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @aiAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiAssistant;

  /// No description provided for @quizCompleted.
  ///
  /// In en, this message translates to:
  /// **'Quiz Completed!'**
  String get quizCompleted;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @generateMore.
  ///
  /// In en, this message translates to:
  /// **'Generate More'**
  String get generateMore;

  /// No description provided for @keepOldSession.
  ///
  /// In en, this message translates to:
  /// **'Keep previous session?'**
  String get keepOldSession;

  /// No description provided for @keep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get keep;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @quizTypeMixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed (Open + MC)'**
  String get quizTypeMixed;

  /// No description provided for @quizTypeOpen.
  ///
  /// In en, this message translates to:
  /// **'Open Questions Only'**
  String get quizTypeOpen;

  /// No description provided for @quizTypeMultiple.
  ///
  /// In en, this message translates to:
  /// **'Multiple Choice Only'**
  String get quizTypeMultiple;

  /// No description provided for @optionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Options per question'**
  String get optionsLabel;

  /// No description provided for @resultsSummary.
  ///
  /// In en, this message translates to:
  /// **'Results Summary'**
  String get resultsSummary;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @restartShuffle.
  ///
  /// In en, this message translates to:
  /// **'Restart & Shuffle'**
  String get restartShuffle;

  /// No description provided for @reviewErrors.
  ///
  /// In en, this message translates to:
  /// **'Retry Errors'**
  String get reviewErrors;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @restartQuiz.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restartQuiz;

  /// No description provided for @errorFileExists.
  ///
  /// In en, this message translates to:
  /// **'Error: \'{fileName}\' already exists in library.'**
  String errorFileExists(String fileName);

  /// No description provided for @errorUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed for {fileName}'**
  String errorUploadFailed(String fileName);

  /// No description provided for @errorSelectFile.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one file from the Archive.'**
  String get errorSelectFile;

  /// No description provided for @errorLoadContext.
  ///
  /// In en, this message translates to:
  /// **'Failed to load context. Please check backend connection.'**
  String get errorLoadContext;

  /// No description provided for @errorStartGeneration.
  ///
  /// In en, this message translates to:
  /// **'Failed to start generation job'**
  String get errorStartGeneration;

  /// No description provided for @successExport.
  ///
  /// In en, this message translates to:
  /// **'Quiz Exported Successfully!'**
  String get successExport;

  /// No description provided for @errorExport.
  ///
  /// In en, this message translates to:
  /// **'Export Failed: {error}'**
  String errorExport(String error);

  /// No description provided for @successImport.
  ///
  /// In en, this message translates to:
  /// **'Quiz Imported Successfully!'**
  String get successImport;

  /// No description provided for @errorImport.
  ///
  /// In en, this message translates to:
  /// **'Import Failed: {error}'**
  String errorImport(String error);

  /// No description provided for @renameSession.
  ///
  /// In en, this message translates to:
  /// **'Rename Session'**
  String get renameSession;

  /// No description provided for @renameQuiz.
  ///
  /// In en, this message translates to:
  /// **'Rename Quiz'**
  String get renameQuiz;

  /// No description provided for @newName.
  ///
  /// In en, this message translates to:
  /// **'New name'**
  String get newName;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @addNewPdf.
  ///
  /// In en, this message translates to:
  /// **'Add New PDF'**
  String get addNewPdf;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploading;

  /// No description provided for @libraryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Library is empty'**
  String get libraryEmpty;

  /// No description provided for @selectedFiles.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedFiles(int count);

  /// No description provided for @deleteSelected.
  ///
  /// In en, this message translates to:
  /// **'Delete Selected'**
  String get deleteSelected;

  /// No description provided for @importedModeWarning.
  ///
  /// In en, this message translates to:
  /// **'⚠️ IMPORTED MODE: Source files not found. AI Chat and Grading are disabled.'**
  String get importedModeWarning;

  /// No description provided for @aiGradingUnavailable.
  ///
  /// In en, this message translates to:
  /// **'⚠️ AI Grading is unavailable because source files are missing (Imported Mode).'**
  String get aiGradingUnavailable;

  /// No description provided for @aiChatUnavailable.
  ///
  /// In en, this message translates to:
  /// **'⚠️ AI Unavailable: Source documents are missing. Chat is disabled for this imported session.'**
  String get aiChatUnavailable;

  /// No description provided for @aiRegenUnavailable.
  ///
  /// In en, this message translates to:
  /// **'AI Regeneration unavailable in Imported Mode.'**
  String get aiRegenUnavailable;

  /// No description provided for @noQuestionsFound.
  ///
  /// In en, this message translates to:
  /// **'No questions found.'**
  String get noQuestionsFound;

  /// No description provided for @editQuestion.
  ///
  /// In en, this message translates to:
  /// **'Edit Question'**
  String get editQuestion;

  /// No description provided for @updateAi.
  ///
  /// In en, this message translates to:
  /// **'Update AI'**
  String get updateAi;

  /// No description provided for @aiEvaluation.
  ///
  /// In en, this message translates to:
  /// **'AI Evaluation: {score}/100'**
  String aiEvaluation(int score);

  /// No description provided for @aiUnavailable.
  ///
  /// In en, this message translates to:
  /// **'AI Unavailable'**
  String get aiUnavailable;

  /// No description provided for @feedbackLabel.
  ///
  /// In en, this message translates to:
  /// **'FEEDBACK'**
  String get feedbackLabel;

  /// No description provided for @idealAnswerLabel.
  ///
  /// In en, this message translates to:
  /// **'IDEAL ANSWER'**
  String get idealAnswerLabel;

  /// No description provided for @systemSpecs.
  ///
  /// In en, this message translates to:
  /// **'System Specs'**
  String get systemSpecs;

  /// No description provided for @backendApi.
  ///
  /// In en, this message translates to:
  /// **'Backend API'**
  String get backendApi;

  /// No description provided for @hardware.
  ///
  /// In en, this message translates to:
  /// **'HARDWARE'**
  String get hardware;

  /// No description provided for @aiModels.
  ///
  /// In en, this message translates to:
  /// **'AI MODELS'**
  String get aiModels;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @aiModelLabel.
  ///
  /// In en, this message translates to:
  /// **'AI Model'**
  String get aiModelLabel;

  /// No description provided for @typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeLabel;

  /// No description provided for @allTypes.
  ///
  /// In en, this message translates to:
  /// **'All Types'**
  String get allTypes;

  /// No description provided for @openType.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openType;

  /// No description provided for @multipleChoiceType.
  ///
  /// In en, this message translates to:
  /// **'Multiple Choice'**
  String get multipleChoiceType;

  /// No description provided for @allFiles.
  ///
  /// In en, this message translates to:
  /// **'All Files'**
  String get allFiles;

  /// No description provided for @uploadToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Upload a PDF to unlock Quiz Generation'**
  String get uploadToUnlock;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['am', 'en', 'es', 'it', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am': return AppLocalizationsAm();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'it': return AppLocalizationsIt();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
