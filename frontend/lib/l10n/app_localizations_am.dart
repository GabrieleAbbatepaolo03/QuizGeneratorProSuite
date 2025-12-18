// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Amharic (`am`).
class AppLocalizationsAm extends AppLocalizations {
  AppLocalizationsAm([String locale = 'am']) : super(locale);

  @override
  String get dashboardTitle => 'Quiz Generator Pro';

  @override
  String get noFileLoaded => 'ምንም የእውቀት መሠረት አልተጫነም';

  @override
  String get uploadPdf => 'PDF ሰነድ አክል';

  @override
  String get readingPdf => 'PDF በማንበብ ላይ...';

  @override
  String get activeFile => 'የእውቀት መሠረት:';

  @override
  String get chatWithAi => 'ከ AI ጋር ተወያይ';

  @override
  String get generateQuiz => 'ጥያቄዎችን አመንጭ';

  @override
  String get changeFile => 'ፋይሎችን አስተዳድር';

  @override
  String get pdfUploaded => 'PDF ወደ ጭንቅላት ታክሏል!';

  @override
  String get settingsTitle => 'ስርዓት እና ቅንብሮች';

  @override
  String get detectedHardware => 'የተገኘ ሃርድዌር';

  @override
  String get compatible => 'ከኮምፒውተርዎ ጋር ይጣጣማል';

  @override
  String get incompatible => 'ሃርድዌር በቂ አይደለም';

  @override
  String get active => 'ንቁ';

  @override
  String get load => 'ጫን';

  @override
  String get missingFile => 'ፋይል ጠፍቷል';

  @override
  String get language => 'ቋንቋ';

  @override
  String get selectLanguage => 'የመተግበሪያ ቋንቋ';

  @override
  String get chatTitle => 'ውይይት';

  @override
  String get chatHint => 'ስለ ሰነድዎ ይጠይቁ...';

  @override
  String get quizTitle => 'የጥያቄ አምራች';

  @override
  String get configQuiz => 'ጥያቄዎን ያዋቅሩ';

  @override
  String get customPromptLabel => 'የትኩረት አቅጣጫ እና ቅጥ';

  @override
  String get customPromptHint => 'ምሳሌ: ስለ ኳንተም ፊዚክስ ከባድ ጥያቄዎች, አካዳሚክ ቅጥ...';

  @override
  String get numberOfQuestions => 'የጥያቄዎች ብዛት';

  @override
  String get difficultyLabel => 'የክብደት ደረጃ';

  @override
  String get generateBtn => 'ጥያቄ አመንጭ';

  @override
  String get startQuizBtn => 'ጥያቄ ጀምር';

  @override
  String get generating => 'በማመንጨት ላይ...';

  @override
  String get quizResults => 'የጥያቄ ውጤቶች';

  @override
  String get newQuiz => 'አዲስ ጥያቄ';

  @override
  String get correctAnswer => 'መልስ:';

  @override
  String get quizHistory => 'የጥያቄ ታሪክ';

  @override
  String get noHistory => 'እስካሁን የተወሰደ ጥያቄ የለም';

  @override
  String get delete => 'ሰርዝ';

  @override
  String get startSession => 'የጥናት ጊዜ ጀምር';

  @override
  String get subStart => 'ውይይት • ጥያቄ • ማረጋገጥ';

  @override
  String get aiChat => 'AI ውይይት';

  @override
  String get newSession => 'አዲስ ክፍለ ጊዜ';

  @override
  String get config => 'ማዋቀሪያ';

  @override
  String get questions => 'ጥያቄዎች';

  @override
  String get sceltaMultipla => 'ምርጫ';

  @override
  String get rispostaAperta => 'ክፍት መልስ';

  @override
  String get feedbackAI => 'AI አስተያየት';

  @override
  String get writeAnswer => 'መልስዎን እዚህ ይጻፉ...';

  @override
  String get sendAnswer => 'መልስ አስገባ';

  @override
  String get previous => 'ቀዳሚ';

  @override
  String get next => 'ቀጣይ';

  @override
  String get aiAssistant => 'AI ረዳት';

  @override
  String get quizCompleted => 'ጥያቄ ተጠናቅቋል!';

  @override
  String get retry => 'እንደገና ሞክር';

  @override
  String get generateMore => 'ተጨማሪ አመንጭ';

  @override
  String get keepOldSession => 'የቀድሞውን ክፍለ ጊዜ ማቆየት ይፈልጋሉ?';

  @override
  String get keep => 'አቆይ';

  @override
  String get discard => 'አስወግድ';

  @override
  String get quizTypeMixed => 'ቅልቅል (ክፍት + ምርጫ)';

  @override
  String get quizTypeOpen => 'ክፍት ጥያቄዎች ብቻ';

  @override
  String get quizTypeMultiple => 'ምርጫ ብቻ';

  @override
  String get optionsLabel => 'ምርጫዎች በጥያቄ';

  @override
  String get resultsSummary => 'የውጤት ማጠቃለያ';

  @override
  String get score => 'ውጤት';

  @override
  String get restartShuffle => 'እንደገና ጀምር እና ቀላቅል';

  @override
  String get reviewErrors => 'ስህተቶችን እንደገና ሞክር';

  @override
  String get backToHome => 'ወደ መነሻ ተመለስ';

  @override
  String get restartQuiz => 'እንደገና ጀምር';

  @override
  String errorFileExists(String fileName) {
    return 'ስህተት: \'$fileName\' በቤተ-መጽሐፍት ውስጥ አስቀድሞ አለ።';
  }

  @override
  String errorUploadFailed(String fileName) {
    return 'ለ $fileName መጫን አልተሳካም';
  }

  @override
  String get errorSelectFile => 'እባክዎ ቢያንስ አንድ ፋይል ከማህደሩ ይምረጡ።';

  @override
  String get errorLoadContext => 'ይዘት መጫን አልተሳካም። እባክዎ የኋላ ግንኙነትን ያረጋግጡ።';

  @override
  String get errorStartGeneration => 'የማመንጨት ስራ መጀመር አልተሳካም';

  @override
  String get successExport => 'ጥያቄ በተሳካ ሁኔታ ተልኳል!';

  @override
  String errorExport(String error) {
    return 'መላክ አልተሳካም: $error';
  }

  @override
  String get successImport => 'ጥያቄ በተሳካ ሁኔታ ገብቷል!';

  @override
  String errorImport(String error) {
    return 'ማስገባት አልተሳካም: $error';
  }

  @override
  String get renameSession => 'ክፍለ ጊዜን እንደገና ይሰይሙ';

  @override
  String get renameQuiz => 'ጥያቄን እንደገና ይሰይሙ';

  @override
  String get newName => 'አዲስ ስም';

  @override
  String get save => 'አስቀምጥ';

  @override
  String get cancel => 'ሰርዝ';

  @override
  String get addNewPdf => 'አዲስ PDF አክል';

  @override
  String get uploading => 'በመጫን ላይ...';

  @override
  String get libraryEmpty => 'ቤተ-መጽሐፍት ባዶ ነው';

  @override
  String selectedFiles(int count) {
    return '$count ተመርጠዋል';
  }

  @override
  String get deleteSelected => 'የተመረጡትን ሰርዝ';

  @override
  String get importedModeWarning => '⚠️ የገቡበት ሁነታ: ምንጭ ፋይሎች አልተገኙም። የ AI ውይይት እና ደረጃ አሰጣጥ ተሰናክለዋል።';

  @override
  String get aiGradingUnavailable => '⚠️ ምንጭ ፋይሎች ስለጎደሉ የ AI ደረጃ አሰጣጥ አይገኝም (የገቡበት ሁነታ)።';

  @override
  String get aiChatUnavailable => '⚠️ AI አይገኝም: ምንጭ ሰነዶች ጠፍተዋል። ለዚህ የገባ ክፍለ ጊዜ ውይይት ተሰናክሏል።';

  @override
  String get aiRegenUnavailable => 'በገባ ሁነታ የ AI እንደገና ማመንጨት አይገኝም።';

  @override
  String get noQuestionsFound => 'ምንም ጥያቄዎች አልተገኙም።';

  @override
  String get editQuestion => 'ጥያቄን ያርትዑ';

  @override
  String get updateAi => 'AIን አዘምን';

  @override
  String aiEvaluation(int score) {
    return 'የ AI ግምገማ: $score/100';
  }

  @override
  String get aiUnavailable => 'AI አይገኝም';

  @override
  String get feedbackLabel => 'አስተያየት';

  @override
  String get idealAnswerLabel => 'ተስማሚ መልስ';

  @override
  String get systemSpecs => 'የስርዓት ዝርዝሮች';

  @override
  String get backendApi => 'የኋላ ኤፒአይ';

  @override
  String get hardware => 'ሃርድዌር';

  @override
  String get aiModels => 'AI ሞዴሎች';

  @override
  String get close => 'ዝጋ';

  @override
  String get aiModelLabel => 'AI ሞዴል';

  @override
  String get typeLabel => 'ዓይነት';

  @override
  String get allTypes => 'ሁሉም ዓይነቶች';

  @override
  String get openType => 'ክፍት';

  @override
  String get multipleChoiceType => 'ምርጫ';

  @override
  String get allFiles => 'ሁሉም ፋይሎች';

  @override
  String get uploadToUnlock => 'የጥያቄ ማመንጨትን ለመክፈት PDF ይስቀሉ';
}
