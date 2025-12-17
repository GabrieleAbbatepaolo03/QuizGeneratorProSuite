class ModelInfo {
  final String id;
  final String name;
  final bool installed;
  final bool compatible;
  final bool active;

  ModelInfo({
    required this.id,
    required this.name,
    required this.installed,
    required this.compatible,
    required this.active,
  });

  factory ModelInfo.fromJson(Map<String, dynamic> json) {
    return ModelInfo(
      id: json['id'],
      name: json['name'],
      installed: json['installed'] ?? false,
      compatible: json['compatible'] ?? false,
      active: json['active'] ?? false,
    );
  }
}

class QuizQuestion {
  final String questionText;
  final String type; // "multipla" o "aperta"
  final List<String> options;
  final String correctAnswer;
  final String sourceFile;
  
  String? userAnswer;
  int? aiScore;
  String? aiFeedback;
  bool isLocked;

  QuizQuestion({
    required this.questionText,
    required this.type,
    required this.options,
    required this.correctAnswer,
    this.sourceFile = "Unknown",
    this.userAnswer,
    this.aiScore,
    this.aiFeedback,
    this.isLocked = false,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    List<String> parsedOptions = [];
    if (json['opzioni'] != null) {
      if (json['opzioni'] is List) {
        parsedOptions = List<String>.from(json['opzioni']);
      } else {
        parsedOptions = [json['opzioni'].toString()];
      }
    }

    return QuizQuestion(
      questionText: json['domanda'] ?? "Error",
      type: json['tipo'] ?? "aperta",
      options: parsedOptions,
      correctAnswer: json['corretta'] ?? "",
      sourceFile: json['source_file'] ?? "Unknown",
    );
  }

  Map<String, dynamic> toJson() => {
    'domanda': questionText,
    'tipo': type,
    'opzioni': options,
    'corretta': correctAnswer,
    'source_file': sourceFile,
    'userAnswer': userAnswer,
    'aiScore': aiScore,
    'aiFeedback': aiFeedback,
    'isLocked': isLocked,
  };
}

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

  // Helpers
  int get totalQuestions => questions.length;
  int get answeredQuestions => questions.where((q) => q.isLocked).length;
  bool get isCompleted => answeredQuestions == totalQuestions;
  bool get isStarted => answeredQuestions > 0;
  int get correctAnswers => questions.where((q) => (q.aiScore ?? 0) >= 60).length;
  int get wrongAnswers => questions.where((q) => q.isLocked && (q.aiScore ?? 0) < 60).length;

  Map<String, dynamic> toJson() => {
    'id': id,
    'topic': topic,
    'date': date.toIso8601String(),
    'questions': questions.map((q) => q.toJson()).toList(),
  };

  factory QuizSession.fromJson(Map<String, dynamic> json) {
    return QuizSession(
      id: json['id'],
      topic: json['topic'],
      date: DateTime.parse(json['date']),
      questions: (json['questions'] as List)
          .map((q) {
            var quest = QuizQuestion.fromJson(q);
            quest.userAnswer = q['userAnswer'];
            quest.aiScore = q['aiScore'];
            quest.aiFeedback = q['aiFeedback'];
            quest.isLocked = q['isLocked'] ?? false;
            return quest;
          })
          .toList(),
    );
  }
}