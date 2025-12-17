import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quiz_generator_pro/models/quiz_models.dart';

class QuizHistoryService {
  static const String _key = 'quiz_history';

  // Salva una nuova sessione (In cima alla lista)
  static Future<void> saveSession(QuizSession session) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_key) ?? [];
    
    history.insert(0, jsonEncode(session.toJson()));
    
    await prefs.setStringList(_key, history);
  }

  // Aggiorna una sessione esistente
  static Future<void> updateSession(QuizSession updatedSession) async {
    final prefs = await SharedPreferences.getInstance();
    List<QuizSession> sessions = await getHistory();
    
    final index = sessions.indexWhere((s) => s.id == updatedSession.id);
    
    if (index != -1) {
      sessions[index] = updatedSession;
      List<String> newHistory = sessions.map((s) => jsonEncode(s.toJson())).toList();
      await prefs.setStringList(_key, newHistory);
    } else {
      await saveSession(updatedSession);
    }
  }

  // Carica tutto
  static Future<List<QuizSession>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_key) ?? [];
    
    return history
        .map((str) => QuizSession.fromJson(jsonDecode(str)))
        .toList();
  }

  // Cancella una sessione specifica
  static Future<void> deleteSession(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<QuizSession> sessions = await getHistory();
    sessions.removeWhere((s) => s.id == id);
    
    List<String> newHistory = sessions.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList(_key, newHistory);
  }
}