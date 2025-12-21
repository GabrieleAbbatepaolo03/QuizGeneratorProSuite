class QuizSession {
  final String id;
  final String topic;
  final DateTime date;
  final List<QuizQuestion> questions;

  QuizSession({
    required this.id,
    required this.topic,
    required this.date,
    required this.questions,
  });

  // Getter helper
  bool get isCompleted => questions.every((q) => q.isLocked);
  bool get isStarted => questions.any((q) => q.isLocked);
  int get totalQuestions => questions.length;
  int get answeredQuestions => questions.where((q) => q.isLocked).length;
  int get correctAnswers => questions.where((q) => (q.aiScore ?? 0) >= 60).length;
  int get wrongAnswers => questions.where((q) => q.isLocked && (q.aiScore ?? 0) < 60).length;

  // Serializzazione JSON (per Export/Salvataggio locale)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topic': topic,
      'date': date.toIso8601String(),
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }

  factory QuizSession.fromJson(Map<String, dynamic> json) {
    return QuizSession(
      id: json['id'],
      topic: json['topic'],
      date: DateTime.parse(json['date']),
      questions: (json['questions'] as List).map((q) => QuizQuestion.fromJson(q)).toList(),
    );
  }
}

class QuizQuestion {
  final String questionText;
  final String type; // Ora userà: "multiple_choice" | "open_ended"
  final List<String> options;
  final String correctAnswer;
  final String sourceFile;
  
  // Stato Utente
  String? userAnswer;
  bool isLocked;
  int? aiScore;
  String? aiFeedback;

  QuizQuestion({
    required this.questionText,
    required this.type,
    required this.options,
    required this.correctAnswer,
    required this.sourceFile,
    this.userAnswer,
    this.isLocked = false,
    this.aiScore,
    this.aiFeedback,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionText': questionText,
      'type': type,
      'options': options,
      'correctAnswer': correctAnswer,
      'sourceFile': sourceFile,
      'userAnswer': userAnswer,
      'isLocked': isLocked,
      'aiScore': aiScore,
      'aiFeedback': aiFeedback,
    };
  }

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    // 1. Normalizzazione Tipo (Backend Standard -> Frontend Standard)
    String rawType = json['type'] ?? json['tipo'] ?? "multiple_choice";
    if (rawType.toLowerCase().contains('multi') || rawType.toLowerCase().contains('choice')) {
      rawType = "multiple_choice";
    } else {
      rawType = "open_ended";
    }

    // 2. Lettura Opzioni (Gestisce sia 'options' API che 'opzioni' legacy)
    List<String> parsedOptions = [];
    if (json['options'] != null) {
      parsedOptions = List<String>.from(json['options']);
    } else if (json['opzioni'] != null) {
      parsedOptions = List<String>.from(json['opzioni']);
    }

    return QuizQuestion(
      // Supporta: 'question' (Nuova API), 'questionText' (Locale), 'domanda' (Vecchia API)
      questionText: json['question'] ?? json['questionText'] ?? json['domanda'] ?? "",
      
      type: rawType,
      
      options: parsedOptions,
      
      // Supporta: 'answer' (Nuova API), 'correctAnswer' (Locale), 'corretta' (Vecchia API)
      correctAnswer: json['answer'] ?? json['correctAnswer'] ?? json['corretta'] ?? "",
      
      // Supporta: 'source_file' (API), 'sourceFile' (Locale)
      sourceFile: json['source_file'] ?? json['sourceFile'] ?? "Unknown",
      
      userAnswer: json['userAnswer'],
      isLocked: json['isLocked'] ?? false,
      aiScore: json['aiScore'],
      
      // Mappa 'explanation' dell'API nel campo feedback se disponibile e se il feedback è vuoto
      aiFeedback: json['aiFeedback'] ?? (json['explanation'] != null ? "Explanation: ${json['explanation']}" : null),
    );
  }
}

class ModelInfo {
  final String id;
  final String name;
  final bool active;

  ModelInfo({required this.id, required this.name, required this.active});

  factory ModelInfo.fromJson(Map<String, dynamic> json) {
    return ModelInfo(
      id: json['id'],
      name: json['name'],
      active: json['active'] ?? false,
    );
  }
}