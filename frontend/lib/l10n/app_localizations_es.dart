// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get dashboardTitle => 'Quiz Generator Pro';

  @override
  String get noFileLoaded => 'Ninguna base de conocimiento cargada';

  @override
  String get uploadPdf => 'Añadir documento PDF';

  @override
  String get readingPdf => 'Leyendo PDF...';

  @override
  String get activeFile => 'Base de conocimiento:';

  @override
  String get chatWithAi => 'Chatear con IA';

  @override
  String get generateQuiz => 'Generar Cuestionario';

  @override
  String get changeFile => 'Gestionar Archivos';

  @override
  String get pdfUploaded => '¡PDF añadido al cerebro!';

  @override
  String get settingsTitle => 'Sistema y Configuración';

  @override
  String get detectedHardware => 'HARDWARE DETECTADO';

  @override
  String get compatible => 'Compatible con tu PC';

  @override
  String get incompatible => 'Hardware insuficiente';

  @override
  String get active => 'Activo';

  @override
  String get load => 'Cargar';

  @override
  String get missingFile => 'Archivo faltante';

  @override
  String get language => 'Idioma';

  @override
  String get selectLanguage => 'Idioma de la App';

  @override
  String get chatTitle => 'Chat';

  @override
  String get chatHint => 'Pregunta sobre tu documento...';

  @override
  String get quizTitle => 'Generador de Cuestionarios';

  @override
  String get configQuiz => 'Configura tu Cuestionario';

  @override
  String get customPromptLabel => 'Enfoque y Estilo';

  @override
  String get customPromptHint => 'Ej: Preguntas difíciles sobre Física Cuántica, estilo académico...';

  @override
  String get numberOfQuestions => 'Número de Preguntas';

  @override
  String get difficultyLabel => 'Nivel de Dificultad';

  @override
  String get generateBtn => 'Generar Cuestionario';

  @override
  String get startQuizBtn => 'Iniciar Cuestionario';

  @override
  String get generating => 'Generando...';

  @override
  String get quizResults => 'Resultados';

  @override
  String get newQuiz => 'Nuevo Cuestionario';

  @override
  String get correctAnswer => 'Respuesta:';

  @override
  String get quizHistory => 'Historial';

  @override
  String get noHistory => 'Aún no hay cuestionarios';

  @override
  String get delete => 'Eliminar';

  @override
  String get startSession => 'Iniciar Sesión de Estudio';

  @override
  String get subStart => 'Chat • Quiz • Verificar';

  @override
  String get aiChat => 'Chat IA';

  @override
  String get newSession => 'Nueva Sesión';

  @override
  String get config => 'Configuración';

  @override
  String get questions => 'Preguntas';

  @override
  String get sceltaMultipla => 'Opción Múltiple';

  @override
  String get rispostaAperta => 'Respuesta Abierta';

  @override
  String get feedbackAI => 'Feedback IA';

  @override
  String get writeAnswer => 'Escribe tu respuesta aquí...';

  @override
  String get sendAnswer => 'Enviar Respuesta';

  @override
  String get previous => 'Anterior';

  @override
  String get next => 'Siguiente';

  @override
  String get aiAssistant => 'Asistente IA';

  @override
  String get quizCompleted => '¡Cuestionario Completado!';

  @override
  String get retry => 'Reintentar';

  @override
  String get generateMore => 'Generar Más';

  @override
  String get keepOldSession => '¿Mantener sesión anterior?';

  @override
  String get keep => 'Mantener';

  @override
  String get discard => 'Descartar';

  @override
  String get quizTypeMixed => 'Mixto (Abierta + OM)';

  @override
  String get quizTypeOpen => 'Solo Preguntas Abiertas';

  @override
  String get quizTypeMultiple => 'Solo Opción Múltiple';

  @override
  String get optionsLabel => 'Opciones por pregunta';

  @override
  String get resultsSummary => 'Resumen de Resultados';

  @override
  String get score => 'Puntuación';

  @override
  String get restartShuffle => 'Reiniciar y Barajar';

  @override
  String get reviewErrors => 'Revisar Errores';

  @override
  String get backToHome => 'Volver al Inicio';

  @override
  String get restartQuiz => 'Reiniciar';

  @override
  String errorFileExists(String fileName) {
    return 'Error: \'$fileName\' ya existe en la biblioteca.';
  }

  @override
  String errorUploadFailed(String fileName) {
    return 'Error al cargar $fileName';
  }

  @override
  String get errorSelectFile => 'Por favor, selecciona al menos un archivo del Archivo.';

  @override
  String get errorLoadContext => 'Error al cargar el contexto. Verifica la conexión con el backend.';

  @override
  String get errorStartGeneration => 'Error al iniciar el trabajo de generación';

  @override
  String get successExport => '¡Cuestionario exportado con éxito!';

  @override
  String errorExport(String error) {
    return 'Error en la exportación: $error';
  }

  @override
  String get successImport => '¡Cuestionario importado con éxito!';

  @override
  String errorImport(String error) {
    return 'Error en la importación: $error';
  }

  @override
  String get renameSession => 'Renombrar Sesión';

  @override
  String get renameQuiz => 'Renombrar Cuestionario';

  @override
  String get newName => 'Nuevo nombre';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get addNewPdf => 'Añadir Nuevo PDF';

  @override
  String get uploading => 'Subiendo...';

  @override
  String get libraryEmpty => 'La biblioteca está vacía';

  @override
  String selectedFiles(int count) {
    return '$count seleccionados';
  }

  @override
  String get deleteSelected => 'Eliminar Seleccionados';

  @override
  String get importedModeWarning => '⚠️ MODO IMPORTADO: Archivos fuente no encontrados. Chat IA y Calificación desactivados.';

  @override
  String get aiGradingUnavailable => '⚠️ Calificación IA no disponible porque faltan archivos fuente (Modo Importado).';

  @override
  String get aiChatUnavailable => '⚠️ IA no disponible: Faltan documentos fuente. Chat desactivado para esta sesión importada.';

  @override
  String get aiRegenUnavailable => 'Regeneración IA no disponible en Modo Importado.';

  @override
  String get noQuestionsFound => 'No se encontraron preguntas.';

  @override
  String get editQuestion => 'Editar Pregunta';

  @override
  String get updateAi => 'Actualizar IA';

  @override
  String aiEvaluation(int score) {
    return 'Evaluación IA: $score/100';
  }

  @override
  String get aiUnavailable => 'IA No Disponible';

  @override
  String get feedbackLabel => 'COMENTARIOS';

  @override
  String get idealAnswerLabel => 'RESPUESTA IDEAL';

  @override
  String get systemSpecs => 'Especificaciones del Sistema';

  @override
  String get backendApi => 'API Backend';

  @override
  String get hardware => 'HARDWARE';

  @override
  String get aiModels => 'MODELOS IA';

  @override
  String get close => 'Cerrar';

  @override
  String get aiModelLabel => 'Modelo IA';

  @override
  String get typeLabel => 'Tipo';

  @override
  String get allTypes => 'Todos los Tipos';

  @override
  String get openType => 'Abierta';

  @override
  String get multipleChoiceType => 'Opción Múltiple';

  @override
  String get allFiles => 'Todos los Archivos';

  @override
  String get uploadToUnlock => 'Sube un PDF para desbloquear la generación de cuestionarios';

  @override
  String get quizConfigTitle => 'Configurar Cuestionario';

  @override
  String get selectAiModel => 'Seleccionar Modelo IA';

  @override
  String get questionType => 'Tipo de Pregunta';

  @override
  String get optionsCount => 'Cantidad de Opciones';

  @override
  String get initializing => 'Iniciando...';

  @override
  String get analyzingTopics => 'Analizando Temas...';

  @override
  String get stopGeneration => 'Detener Generación';

  @override
  String get stopping => 'Deteniendo...';

  @override
  String get aborting => 'Abortando...';

  @override
  String get processing => 'Procesando...';

  @override
  String get completed => '¡Completado!';

  @override
  String get generationStoppedSafely => 'Generación detenida con seguridad.';
}
