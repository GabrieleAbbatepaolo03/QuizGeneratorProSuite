import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:quiz_generator_pro/models/quiz_models.dart'; // Nota l'import corretto

class ApiService {
  // IMPORTANTISSIMO: Assicurati che questa porta corrisponda a quella di Uvicorn (8001)
  static const String baseUrl = "http://127.0.0.1:8001";

  static Future<Map<String, dynamic>> getSystemStatus() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/system/status'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print("Connection error: $e");
    }
    return {};
  }

  static Future<bool> switchModel(String modelId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/system/switch-model/$modelId'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> uploadPdf(File file) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/files/upload'));
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      var response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteFile(String filename) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/files/delete/$filename'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> clearAllFiles() async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/files/clear_all'));
      return response.statusCode == 200;
    } catch (e) {
      print("Clear all error: $e");
      return false;
    }
  }

  static Future<String> chat(String question) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"question": question}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data['answer'] ?? "Error parsing answer";
      }
    } catch (e) {
      return "Error: $e";
    }
    return "Error";
  }

  // --- METODI GENERAZIONE QUIZ ---

  static Future<String?> startQuizGeneration(
      int numQuestions, String prompt, String language, String type, int maxOptions) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/quiz/start_generation'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "num_questions": numQuestions,
          "custom_prompt": prompt,
          "language": language,
          "question_type": type,
          "max_options": maxOptions
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['job_id'];
      }
    } catch (e) {
      print("Start Gen Error: $e");
    }
    return null;
  }

  static Future<Map<String, dynamic>?> checkQuizStatus(String jobId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/quiz/status/$jobId'));
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {
      print("Check Status Error: $e");
    }
    return null;
  }

  static Future<QuizQuestion?> regenerateSingleQuestion(
      String originalQuestion, String instruction, String language) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/quiz/regenerate_single'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "question_text": originalQuestion,
          "instruction": instruction,
          "language": language
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return QuizQuestion.fromJson(data);
      }
    } catch (e) {
      print("Regen Error: $e");
    }
    return null;
  }

  static Future<Map<String, dynamic>> gradeAnswer(
      String question, String correctAnswer, String userAnswer, String language) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/quiz/grade'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "question": question,
          "correct_answer": correctAnswer,
          "user_answer": userAnswer,
          "language": language
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {
      print("Grading Error: $e");
    }
    return {"score": 0, "feedback": "Errore di connessione."};
  }
}