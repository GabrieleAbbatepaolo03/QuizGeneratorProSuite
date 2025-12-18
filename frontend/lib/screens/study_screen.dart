import 'dart:ui'; 
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quiz_generator_pro/l10n/app_localizations.dart';
import 'package:quiz_generator_pro/models/quiz_models.dart';
import 'package:quiz_generator_pro/services/api_service.dart';
import 'package:quiz_generator_pro/services/history_service.dart';
import 'package:quiz_generator_pro/widgets/study_widgets.dart';

const Color kVividGreen = Color(0xFF00E676);
const Color kBgColor = Color(0xFF0A0A0A);

class StudyScreen extends StatefulWidget {
  final QuizSession? existingSession;
  final Map<String, dynamic>? systemStatus;

  const StudyScreen({super.key, this.existingSession, this.systemStatus});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  List<QuizQuestion> _allQuestions = [];
  List<QuizQuestion> _filteredQuestions = [];
  
  late PageController _pageController;
  int _currentQuestionIndex = 0;
  bool _isProcessing = false;
  
  bool _isAiAvailable = false; 

  String _filterFile = "all";
  String _filterType = "all";

  List<Map<String, String>> _chatMessages = [];
  final TextEditingController _chatInputController = TextEditingController();
  bool _isChatOpen = false;

  String? _currentSessionId;
  String _topicTitle = "";

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    if (widget.existingSession != null) {
      _allQuestions = widget.existingSession!.questions;
      _filteredQuestions = List.from(_allQuestions);
      _currentSessionId = widget.existingSession!.id;
      _topicTitle = widget.existingSession!.topic;
    }
    
    _checkContextAvailability();
  }

  Future<void> _checkContextAvailability() async {
    try {
      final status = await ApiService.getSystemStatus();
      final List<String> remoteFiles = List<String>.from(status['files'] ?? []);
      
      bool found = false;
      for (var q in _allQuestions) {
        if (remoteFiles.contains(q.sourceFile)) {
          found = true;
          break;
        }
      }

      if (mounted) {
        setState(() {
          _isAiAvailable = found;
        });
        
        if (!_isAiAvailable) {
          _chatMessages.add({
            'role': 'system', 
            'text': AppLocalizations.of(context)!.importedModeWarning
          });
        }
      }
    } catch (e) {
      debugPrint("Check Context Error: $e");
      if (mounted) {
        setState(() => _isAiAvailable = false);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _chatInputController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {
      _filteredQuestions = _allQuestions.where((q) {
        bool fileMatch = _filterFile == "all" || q.sourceFile == _filterFile;
        bool typeMatch = _filterType == "all" || q.type == _filterType;
        return fileMatch && typeMatch;
      }).toList();
      
      _currentQuestionIndex = 0;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    });
  }

  Future<void> _saveSessionState() async {
    if (_allQuestions.isNotEmpty && _currentSessionId != null) {
      final updatedSession = QuizSession(
        id: _currentSessionId!,
        topic: _topicTitle,
        date: widget.existingSession?.date ?? DateTime.now(),
        questions: _allQuestions
      );
      await QuizHistoryService.updateSession(updatedSession);
    }
  }

  // --- LOGICA DI CONFRONTO ROBUSTA ---
  bool _isAnswerMatching(String option, String correctAnswer) {
    final RegExp prefixRegex = RegExp(r'^([a-zA-Z0-9]+[\.\)])\s*');
    String cleanOption = option.replaceAll(prefixRegex, '').trim().toLowerCase();
    String cleanCorrect = correctAnswer.replaceAll(prefixRegex, '').trim().toLowerCase();
    return cleanOption == cleanCorrect || option.trim().toLowerCase() == correctAnswer.trim().toLowerCase();
  }

  void _submitAnswer(String answer) async {
    if (_filteredQuestions.isEmpty) return;
    QuizQuestion q = _filteredQuestions[_currentQuestionIndex];
    final l10n = AppLocalizations.of(context)!;

    if (q.isLocked || answer.trim().isEmpty) return;
    
    setState(() {
      q.userAnswer = answer;
      q.isLocked = true;
    });

    if (q.type == "multipla") {
      bool isCorrect = _isAnswerMatching(answer, q.correctAnswer);
      
      setState(() {
        q.aiScore = isCorrect ? 100 : 0;
        q.aiFeedback = isCorrect ? "Correct Answer!" : "Wrong. Correct answer: ${q.correctAnswer}";
      });
    } else {
      if (_isAiAvailable) {
        final locale = Localizations.localeOf(context).languageCode;
        final grading = await ApiService.gradeAnswer(q.questionText, q.correctAnswer, answer, locale);
        
        if (mounted) {
          setState(() {
            q.aiScore = grading['score'];
            String feedbackPart = grading['feedback'] ?? "No feedback";
            String idealPart = grading['ideal_answer'] ?? q.correctAnswer;
            q.aiFeedback = "$feedbackPart###SPLIT###$idealPart";
          });
        }
      } else {
        setState(() {
          q.aiScore = 0; 
          String warningMsg = l10n.aiGradingUnavailable;
          String idealPart = q.correctAnswer; 
          
          q.aiFeedback = "$warningMsg###SPLIT###$idealPart";
        });
      }
    }
    await _saveSessionState();

    bool allAnswered = _filteredQuestions.every((q) => q.isLocked);
    if (allAnswered) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) _showCompletionDialog();
      });
    }
  }

  // --- LOGICA COLORE PALLINO ---
  Color _getDotColor(QuizQuestion q, bool isActive) {
    if (!q.isLocked) {
      // Non risposta: Grigio se inattivo, Bianco/Verde se attivo
      return isActive ? Colors.white : Colors.grey[800]!;
    }
    
    // Risposta data: Controlla se corretta
    bool isCorrect = false;
    if (q.type == "multipla") {
      isCorrect = _isAnswerMatching(q.userAnswer ?? "", q.correctAnswer);
    } else {
      // Per le aperte consideriamo "corretto" se score >= 60 (o logica custom)
      isCorrect = (q.aiScore ?? 0) >= 60;
    }

    return isCorrect ? kVividGreen : Colors.redAccent;
  }

  // ... (Dialog Completion, Restart, ecc. invariati) ...
  void _showCompletionDialog() {
      // ... (Usa il codice esistente per il dialog) ...
      // Per brevità non lo ricopio tutto qui se non è cambiato
      // Ma assicurati che _showCompletionDialog sia presente nel file finale
      final l10n = AppLocalizations.of(context)!;
      int total = _filteredQuestions.length;
      int correct = _filteredQuestions.where((q) => (q.aiScore ?? 0) >= 60).length;
      int score = total > 0 ? ((correct / total) * 100).round() : 0;
      // ... (resto del dialog) ...
      showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Results",
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (ctx, anim1, anim2) => Container(),
      transitionBuilder: (ctx, anim1, anim2, child) {
        final curvedValue = Curves.easeInOutBack.transform(anim1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: kVividGreen, width: 2)),
              title: Text(l10n.quizCompleted, 
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: kVividGreen, fontWeight: FontWeight.bold, fontSize: 22)
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.resultsSummary, style: GoogleFonts.poppins(color: Colors.white70)),
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 100, height: 100,
                        child: CircularProgressIndicator(
                          value: total > 0 ? correct / total : 0,
                          strokeWidth: 8,
                          backgroundColor: Colors.white10,
                          color: kVividGreen,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("$score%", style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          Text("$correct / $total", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 30),
                  _buildDialogButton(
                    icon: CupertinoIcons.refresh, 
                    label: l10n.restartShuffle, 
                    color: Colors.white,
                    onTap: () { Navigator.pop(ctx); _restartQuiz(); }
                  ),
                  const SizedBox(height: 10),
                  if (correct < total) ...[
                    _buildDialogButton(
                      icon: CupertinoIcons.exclamationmark_triangle, 
                      label: l10n.reviewErrors, 
                      color: Colors.orangeAccent,
                      onTap: () { Navigator.pop(ctx); _retryWrong(); }
                    ),
                    const SizedBox(height: 10),
                  ],
                  _buildDialogButton(
                    icon: CupertinoIcons.home, 
                    label: l10n.backToHome, 
                    color: Colors.grey,
                    onTap: () async {
                      Navigator.of(ctx).pop(); 
                      await Future.delayed(const Duration(milliseconds: 250));
                      if (context.mounted) Navigator.of(context).pop();
                    } 
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: color),
        label: Text(label, style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withOpacity(0.3)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
        ),
      ),
    );
  }

  void _restartQuiz() {
    setState(() {
      for (var q in _allQuestions) {
        q.userAnswer = null;
        q.isLocked = false;
        q.aiScore = null;
        q.aiFeedback = null;
      }
      _allQuestions.shuffle();
      _applyFilters();
      _currentQuestionIndex = 0;
      if (_pageController.hasClients) _pageController.jumpToPage(0);
    });
    _saveSessionState();
  }

  void _retryWrong() {
    setState(() {
      for (var q in _allQuestions) {
        if (q.isLocked && (q.aiScore ?? 0) < 60) {
          q.userAnswer = null;
          q.isLocked = false;
          q.aiScore = null;
          q.aiFeedback = null;
        }
      }
      _filteredQuestions = _allQuestions.where((q) => !q.isLocked).toList();
      _currentQuestionIndex = 0;
      if (_pageController.hasClients) _pageController.jumpToPage(0);
    });
    _saveSessionState();
  }

  Future<void> _regenerateQuestion(String instruction) async {
    final l10n = AppLocalizations.of(context)!;
    if (!_isAiAvailable) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.aiRegenUnavailable)));
       return;
    }
    
    if (_filteredQuestions.isEmpty) return;
    QuizQuestion currentQ = _filteredQuestions[_currentQuestionIndex];

    setState(() => _isProcessing = true);
    final locale = Localizations.localeOf(context).languageCode;
    
    final newQ = await ApiService.regenerateSingleQuestion(currentQ.questionText, instruction, locale);
    
    if (newQ != null && mounted) {
      setState(() {
        int idx = _allQuestions.indexOf(currentQ);
        if (idx != -1) _allQuestions[idx] = newQ;
        _applyFilters(); 
      });
      _saveSessionState();
    }
    setState(() => _isProcessing = false);
  }

  void _deleteQuestion() {
    if (_filteredQuestions.isEmpty) return;
    QuizQuestion q = _filteredQuestions[_currentQuestionIndex];
    
    setState(() {
      _allQuestions.remove(q);
      _applyFilters();
    });
    _saveSessionState();
  }
  
  void _renameTitle() {
    final l10n = AppLocalizations.of(context)!;
    TextEditingController ctrl = TextEditingController(text: _topicTitle);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(l10n.renameQuiz, style: GoogleFonts.poppins(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          style: GoogleFonts.poppins(color: Colors.white),
          decoration: InputDecoration(
            filled: true, fillColor: Colors.black26,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kVividGreen),
            onPressed: () {
              setState(() => _topicTitle = ctrl.text);
              _saveSessionState();
              Navigator.pop(ctx);
            }, 
            child: Text(l10n.save)
          )
        ],
      ),
    );
  }

  void _sendChatMessage() async {
    final l10n = AppLocalizations.of(context)!;
    final text = _chatInputController.text.trim();
    if (text.isEmpty) return;
    
    setState(() {
      _chatMessages.add({'role': 'user', 'text': text});
      _chatInputController.clear();
    });

    if (!_isAiAvailable) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _chatMessages.add({
            'role': 'system', 
            'text': l10n.aiChatUnavailable
          });
        });
      }
      return;
    }

    final response = await ApiService.chat(text);
    if (mounted) {
      setState(() {
        _chatMessages.add({'role': 'ai', 'text': response});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;
    final sources = _allQuestions.map((q) => q.sourceFile).toSet().toList();

    return Scaffold(
      backgroundColor: kBgColor,
      body: Row( 
        children: [
          Expanded(
            child: Column(
              children: [
                // ... (AppBar e Header invariati) ...
                Container(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 10, left: 20, right: 20),
                  color: kBgColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(CupertinoIcons.home, color: Colors.white), 
                              onPressed: () => Navigator.pop(context)
                            ),
                            IconButton(
                              icon: const Icon(CupertinoIcons.refresh, color: Colors.white),
                              tooltip: l10n.restartQuiz,
                              onPressed: _restartQuiz,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: InkWell(
                                onTap: _renameTitle,
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          _topicTitle.isEmpty ? l10n.newSession : _topicTitle,
                                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(CupertinoIcons.pencil, size: 14, color: Colors.grey)
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          if (isWide) ...[
                            FilterDropdown(
                              value: _filterType,
                              items: [
                                DropdownMenuItem(value: "all", child: Text(l10n.allTypes)),
                                DropdownMenuItem(value: "aperta", child: Text(l10n.openType)),
                                DropdownMenuItem(value: "multipla", child: Text(l10n.multipleChoiceType)),
                              ],
                              onChanged: (v) { setState(() => _filterType = v!); _applyFilters(); }
                            ),
                            const SizedBox(width: 10),
                            FilterDropdown(
                              value: _filterFile,
                              items: [
                                DropdownMenuItem(value: "all", child: Text(l10n.allFiles)),
                                ...sources.map((s) => DropdownMenuItem(value: s, child: Text(s.length > 15 ? "...${s.substring(s.length-15)}" : s))),
                              ],
                              onChanged: (v) { setState(() => _filterFile = v!); _applyFilters(); }
                            ),
                            const SizedBox(width: 10),
                          ],
                          IconButton(
                            icon: Icon(CupertinoIcons.chat_bubble_2_fill, color: _isChatOpen ? kVividGreen : Colors.grey),
                            onPressed: () => setState(() => _isChatOpen = !_isChatOpen),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                
                if (_isProcessing) const LinearProgressIndicator(color: kVividGreen, backgroundColor: kBgColor),

                Expanded(
                  child: _filteredQuestions.isEmpty 
                    ? Center(child: Text(l10n.noQuestionsFound, style: GoogleFonts.poppins(color: Colors.grey)))
                    : PageView.builder(
                        controller: _pageController,
                        physics: const BouncingScrollPhysics(),
                        onPageChanged: (index) => setState(() => _currentQuestionIndex = index),
                        itemCount: _filteredQuestions.length,
                        itemBuilder: (ctx, index) {
                          return QuizCard(
                            question: _filteredQuestions[index],
                            onSubmit: (ans) => _submitAnswer(ans),
                            onRegenerate: (instr) => _regenerateQuestion(instr),
                            onDelete: () => _deleteQuestion(),
                          );
                        },
                      ),
                ),
                
                if (_filteredQuestions.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                    color: kBgColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: _currentQuestionIndex > 0 
                            ? () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)
                            : null,
                          icon: const Icon(CupertinoIcons.arrow_left, size: 20),
                          label: Text(l10n.previous, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                          style: TextButton.styleFrom(foregroundColor: Colors.white, disabledForegroundColor: Colors.white12),
                        ),

                        // --- PAGINAZIONE / PALLINI ---
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final int total = _filteredQuestions.length;
                              // Stima: ogni pallino occupa circa 20px (12 width + 8 margin)
                              final double requiredWidth = total * 20.0;
                              
                              // SE C'È SPAZIO: Mostra i pallini colorati
                              if (requiredWidth <= constraints.maxWidth) {
                                return Center(
                                  child: SizedBox(
                                    height: 30,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: total,
                                      itemBuilder: (ctx, i) {
                                        bool isActive = i == _currentQuestionIndex;
                                        QuizQuestion q = _filteredQuestions[i];
                                        
                                        // Calcolo colore pallino
                                        Color dotColor = _getDotColor(q, isActive);
                                        
                                        return GestureDetector(
                                          onTap: () => _pageController.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 200),
                                            margin: const EdgeInsets.symmetric(horizontal: 4),
                                            width: isActive ? 12 : 8,
                                            height: isActive ? 12 : 8,
                                            decoration: BoxDecoration(
                                              color: dotColor,
                                              shape: BoxShape.circle,
                                              // GLOW solo se attivo
                                              boxShadow: isActive 
                                                ? [BoxShadow(color: dotColor.withOpacity(0.6), blurRadius: 8, spreadRadius: 1)] 
                                                : null
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              } else {
                                // SE NON C'È SPAZIO: Mostra testo "X / Y" con colore dinamico
                                QuizQuestion currentQ = _filteredQuestions[_currentQuestionIndex];
                                Color textColor = _getDotColor(currentQ, true);
                                
                                return Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05), 
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: textColor.withOpacity(0.3))
                                    ),
                                    child: Text(
                                      "${_currentQuestionIndex + 1} / $total",
                                      style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        
                        TextButton.icon(
                          onPressed: _currentQuestionIndex < _filteredQuestions.length - 1
                            ? () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)
                            : null,
                          label: Text(l10n.next, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                          icon: const Icon(CupertinoIcons.arrow_right, size: 20),
                          style: TextButton.styleFrom(foregroundColor: Colors.white, disabledForegroundColor: Colors.white12),
                        ),
                      ],
                    ),
                  )
              ],
            ),
          ),
          
          // ... (Chat Sidebar invariata) ...
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            width: _isChatOpen ? (isWide ? 400 : 300) : 0,
            child: OverflowBox(
              minWidth: 0,
              maxWidth: isWide ? 400 : 300,
              alignment: Alignment.centerLeft,
              child: ChatPanel(
                onClose: () => setState(() => _isChatOpen = false),
                messages: _chatMessages,
                controller: _chatInputController,
                onSend: _sendChatMessage,
              ),
            ),
          ),
        ],
      ),
    );
  }
}