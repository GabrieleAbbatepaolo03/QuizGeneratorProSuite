import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

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
    Locale('en'),
    Locale('it')
  ];

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Study Buddy Dashboard'**
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
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'it': return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
