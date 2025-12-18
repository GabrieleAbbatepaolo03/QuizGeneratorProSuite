// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get dashboardTitle => 'Quiz Generator Pro';

  @override
  String get noFileLoaded => 'No Knowledge Base Loaded';

  @override
  String get uploadPdf => 'Add PDF Document';

  @override
  String get readingPdf => 'Reading PDF...';

  @override
  String get activeFile => 'Knowledge Base:';

  @override
  String get chatWithAi => 'Chat w/ AI';

  @override
  String get generateQuiz => 'Generate Quiz';

  @override
  String get changeFile => 'Manage Files';

  @override
  String get pdfUploaded => 'PDF Added to Brain!';

  @override
  String get settingsTitle => 'System & Settings';

  @override
  String get detectedHardware => 'DETECTED HARDWARE';

  @override
  String get compatible => 'Compatible with your PC';

  @override
  String get incompatible => 'Hardware insufficient';

  @override
  String get active => 'Active';

  @override
  String get load => 'Load';

  @override
  String get missingFile => 'Missing File';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'App Language';

  @override
  String get chatTitle => 'Chat';

  @override
  String get chatHint => 'Ask about your document...';

  @override
  String get quizTitle => 'Quiz Generator';

  @override
  String get configQuiz => 'Configure your Quiz';

  @override
  String get customPromptLabel => 'Quiz Focus & Style';

  @override
  String get customPromptHint => 'Ex: Hard questions about Quantum Physics, academic style...';

  @override
  String get numberOfQuestions => 'Number of Questions';

  @override
  String get difficultyLabel => 'Difficulty Level';

  @override
  String get generateBtn => 'Generate Quiz';

  @override
  String get startQuizBtn => 'Start Quiz';

  @override
  String get generating => 'Generating...';

  @override
  String get quizResults => 'Quiz Results';

  @override
  String get newQuiz => 'New Quiz';

  @override
  String get correctAnswer => 'Answer:';

  @override
  String get quizHistory => 'Quiz History';

  @override
  String get noHistory => 'No quizzes taken yet';

  @override
  String get delete => 'Delete';

  @override
  String get startSession => 'Start Study Session';

  @override
  String get subStart => 'Chat • Quiz • Verify';

  @override
  String get aiChat => 'AI Chat';

  @override
  String get newSession => 'New Session';

  @override
  String get config => 'Configuration';

  @override
  String get questions => 'Questions';

  @override
  String get sceltaMultipla => 'Multiple Choice';

  @override
  String get rispostaAperta => 'Open Answer';

  @override
  String get feedbackAI => 'AI Feedback';

  @override
  String get writeAnswer => 'Type your answer here...';

  @override
  String get sendAnswer => 'Submit Answer';

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get aiAssistant => 'AI Assistant';

  @override
  String get quizCompleted => 'Quiz Completed!';

  @override
  String get retry => 'Retry';

  @override
  String get generateMore => 'Generate More';

  @override
  String get keepOldSession => 'Keep previous session?';

  @override
  String get keep => 'Keep';

  @override
  String get discard => 'Discard';

  @override
  String get quizTypeMixed => 'Mixed (Open + MC)';

  @override
  String get quizTypeOpen => 'Open Questions Only';

  @override
  String get quizTypeMultiple => 'Multiple Choice Only';

  @override
  String get optionsLabel => 'Options per question';

  @override
  String get resultsSummary => 'Results Summary';

  @override
  String get score => 'Score';

  @override
  String get restartShuffle => 'Restart & Shuffle';

  @override
  String get reviewErrors => 'Retry Errors';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get restartQuiz => 'Restart';

  @override
  String errorFileExists(String fileName) {
    return 'Error: \'$fileName\' already exists in library.';
  }

  @override
  String errorUploadFailed(String fileName) {
    return 'Upload failed for $fileName';
  }

  @override
  String get errorSelectFile => 'Please select at least one file from the Archive.';

  @override
  String get errorLoadContext => 'Failed to load context. Please check backend connection.';

  @override
  String get errorStartGeneration => 'Failed to start generation job';

  @override
  String get successExport => 'Quiz Exported Successfully!';

  @override
  String errorExport(String error) {
    return 'Export Failed: $error';
  }

  @override
  String get successImport => 'Quiz Imported Successfully!';

  @override
  String errorImport(String error) {
    return 'Import Failed: $error';
  }

  @override
  String get renameSession => 'Rename Session';

  @override
  String get renameQuiz => 'Rename Quiz';

  @override
  String get newName => 'New name';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get addNewPdf => 'Add New PDF';

  @override
  String get uploading => 'Uploading...';

  @override
  String get libraryEmpty => 'Library is empty';

  @override
  String selectedFiles(int count) {
    return '$count selected';
  }

  @override
  String get deleteSelected => 'Delete Selected';

  @override
  String get importedModeWarning => '⚠️ IMPORTED MODE: Source files not found. AI Chat and Grading are disabled.';

  @override
  String get aiGradingUnavailable => '⚠️ AI Grading is unavailable because source files are missing (Imported Mode).';

  @override
  String get aiChatUnavailable => '⚠️ AI Unavailable: Source documents are missing. Chat is disabled for this imported session.';

  @override
  String get aiRegenUnavailable => 'AI Regeneration unavailable in Imported Mode.';

  @override
  String get noQuestionsFound => 'No questions found.';

  @override
  String get editQuestion => 'Edit Question';

  @override
  String get updateAi => 'Update AI';

  @override
  String aiEvaluation(int score) {
    return 'AI Evaluation: $score/100';
  }

  @override
  String get aiUnavailable => 'AI Unavailable';

  @override
  String get feedbackLabel => 'FEEDBACK';

  @override
  String get idealAnswerLabel => 'IDEAL ANSWER';

  @override
  String get systemSpecs => 'System Specs';

  @override
  String get backendApi => 'Backend API';

  @override
  String get hardware => 'HARDWARE';

  @override
  String get aiModels => 'AI MODELS';

  @override
  String get close => 'Close';

  @override
  String get aiModelLabel => 'AI Model';

  @override
  String get typeLabel => 'Type';

  @override
  String get allTypes => 'All Types';

  @override
  String get openType => 'Open';

  @override
  String get multipleChoiceType => 'Multiple Choice';

  @override
  String get allFiles => 'All Files';

  @override
  String get uploadToUnlock => 'Upload a PDF to unlock Quiz Generation';
}
