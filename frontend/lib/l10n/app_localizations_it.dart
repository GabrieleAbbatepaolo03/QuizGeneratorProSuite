// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get dashboardTitle => 'Study Buddy';

  @override
  String get noFileLoaded => 'Nessuna Knowledge Base Caricata';

  @override
  String get uploadPdf => 'Aggiungi Documento PDF';

  @override
  String get readingPdf => 'Lettura PDF in corso...';

  @override
  String get activeFile => 'File Attivo:';

  @override
  String get chatWithAi => 'Chatta con AI';

  @override
  String get generateQuiz => 'Genera Quiz';

  @override
  String get changeFile => 'Gestisci File';

  @override
  String get pdfUploaded => 'PDF Aggiunto al Cervello!';

  @override
  String get settingsTitle => 'Impostazioni & Sistema';

  @override
  String get detectedHardware => 'HARDWARE RILEVATO';

  @override
  String get compatible => 'Compatibile con il tuo PC';

  @override
  String get incompatible => 'Hardware insufficiente';

  @override
  String get active => 'Attivo';

  @override
  String get load => 'Carica';

  @override
  String get missingFile => 'File Mancante';

  @override
  String get language => 'Lingua';

  @override
  String get selectLanguage => 'Lingua App';

  @override
  String get chatTitle => 'Chat';

  @override
  String get chatHint => 'Chiedi qualcosa sul documento...';

  @override
  String get quizTitle => 'Generatore Quiz';

  @override
  String get configQuiz => 'Configura il tuo Quiz';

  @override
  String get customPromptLabel => 'Argomento e Stile';

  @override
  String get customPromptHint => 'Es: Domande difficili sulla Fisica Quantistica, stile accademico...';

  @override
  String get numberOfQuestions => 'Numero di Domande';

  @override
  String get difficultyLabel => 'Livello di Difficoltà';

  @override
  String get generateBtn => 'Genera Quiz';

  @override
  String get startQuizBtn => 'Avvia Quiz';

  @override
  String get generating => 'Generazione in corso...';

  @override
  String get quizResults => 'Risultati Quiz';

  @override
  String get newQuiz => 'Nuovo Quiz';

  @override
  String get correctAnswer => 'Risposta Corretta:';

  @override
  String get quizHistory => 'Cronologia Quiz';

  @override
  String get noHistory => 'Nessun quiz ancora svolto';

  @override
  String get delete => 'Elimina';

  @override
  String get startSession => 'Avvia Sessione di Studio';

  @override
  String get subStart => 'Chat • Quiz • Verifica';

  @override
  String get aiChat => 'Chat AI';

  @override
  String get newSession => 'Nuova Sessione';

  @override
  String get config => 'Configurazione';

  @override
  String get questions => 'Domande';

  @override
  String get sceltaMultipla => 'Scelta Multipla';

  @override
  String get rispostaAperta => 'Risposta Aperta';

  @override
  String get feedbackAI => 'Feedback AI';

  @override
  String get writeAnswer => 'Scrivi la tua risposta qui...';

  @override
  String get sendAnswer => 'Invia Risposta';

  @override
  String get previous => 'Precedente';

  @override
  String get next => 'Successivo';

  @override
  String get aiAssistant => 'Assistente AI';

  @override
  String get quizCompleted => 'Quiz Completato!';

  @override
  String get retry => 'Riprova';

  @override
  String get generateMore => 'Genera Altri';

  @override
  String get keepOldSession => 'Mantenere sessione precedente?';

  @override
  String get keep => 'Mantieni';

  @override
  String get discard => 'Scarta';

  @override
  String get quizTypeMixed => 'Misto (Aperta + Multipla)';

  @override
  String get quizTypeOpen => 'Solo Domande Aperte';

  @override
  String get quizTypeMultiple => 'Solo Scelta Multipla';

  @override
  String get optionsLabel => 'Opzioni per domanda';

  @override
  String get resultsSummary => 'Riepilogo Risultati';

  @override
  String get score => 'Punteggio';

  @override
  String get restartShuffle => 'Riavvia & Mischia';

  @override
  String get reviewErrors => 'Ripeti Errori';

  @override
  String get backToHome => 'Torna alla Home';

  @override
  String get restartQuiz => 'Ricomincia';

  @override
  String errorFileExists(String fileName) {
    return 'Errore: \'$fileName\' esiste già nella libreria.';
  }

  @override
  String errorUploadFailed(String fileName) {
    return 'Caricamento fallito per $fileName';
  }

  @override
  String get errorSelectFile => 'Seleziona almeno un file dall\'Archivio.';

  @override
  String get errorLoadContext => 'Impossibile caricare il contesto. Controlla la connessione al backend.';

  @override
  String get errorStartGeneration => 'Impossibile avviare la generazione';

  @override
  String get successExport => 'Quiz esportato con successo!';

  @override
  String errorExport(String error) {
    return 'Esportazione fallita: $error';
  }

  @override
  String get successImport => 'Quiz importato con successo!';

  @override
  String errorImport(String error) {
    return 'Importazione fallita: $error';
  }

  @override
  String get renameSession => 'Rinomina Sessione';

  @override
  String get renameQuiz => 'Rinomina Quiz';

  @override
  String get newName => 'Nuovo nome';

  @override
  String get save => 'Salva';

  @override
  String get cancel => 'Annulla';

  @override
  String get addNewPdf => 'Aggiungi Nuovo PDF';

  @override
  String get uploading => 'Caricamento...';

  @override
  String get libraryEmpty => 'Libreria vuota';

  @override
  String selectedFiles(int count) {
    return '$count selezionati';
  }

  @override
  String get deleteSelected => 'Elimina Selezionati';

  @override
  String get importedModeWarning => '⚠️ MODALITÀ IMPORT: File sorgenti non trovati. Chat AI e Valutazione disabilitati.';

  @override
  String get aiGradingUnavailable => '⚠️ Valutazione AI non disponibile perché mancano i file sorgenti (Modalità Import).';

  @override
  String get aiChatUnavailable => '⚠️ AI non disponibile: Documenti sorgente mancanti. Chat disabilitata per questa sessione importata.';

  @override
  String get aiRegenUnavailable => 'Rigenerazione AI non disponibile in Modalità Import.';

  @override
  String get noQuestionsFound => 'Nessuna domanda trovata.';

  @override
  String get editQuestion => 'Modifica Domanda';

  @override
  String get updateAi => 'Aggiorna AI';

  @override
  String aiEvaluation(int score) {
    return 'Valutazione AI: $score/100';
  }

  @override
  String get aiUnavailable => 'AI Non Disponibile';

  @override
  String get feedbackLabel => 'FEEDBACK';

  @override
  String get idealAnswerLabel => 'RISPOSTA IDEALE';

  @override
  String get systemSpecs => 'Specifiche Sistema';

  @override
  String get backendApi => 'API Backend';

  @override
  String get hardware => 'HARDWARE';

  @override
  String get aiModels => 'MODELLI AI';

  @override
  String get close => 'Chiudi';

  @override
  String get aiModelLabel => 'Modello AI';

  @override
  String get typeLabel => 'Tipo';

  @override
  String get allTypes => 'Tutti i Tipi';

  @override
  String get openType => 'Aperta';

  @override
  String get multipleChoiceType => 'Scelta Multipla';

  @override
  String get allFiles => 'Tutti i File';
}
