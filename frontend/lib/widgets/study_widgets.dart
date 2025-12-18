import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart'; // Import Iconly
import 'package:quiz_generator_pro/models/quiz_models.dart';

// --- COSTANTI COLORI ---
const Color kVividGreen = Color(0xFF00E676);
const Color kCardColor = Color(0xFF1E1E1E);
const Color kSurfaceColor = Color(0xFF161616);
const Color kDropdownColor = Color(0xFF2C2C2C); // Colore Dropdown Home

// --- 1. QUIZ CARD ---
class QuizCard extends StatelessWidget {
  final QuizQuestion question;
  final Function(String) onSubmit;
  final Function(String) onRegenerate;
  final VoidCallback onDelete;

  const QuizCard({
    super.key,
    required this.question,
    required this.onSubmit,
    required this.onRegenerate,
    required this.onDelete,
  });

  void _showEditDialog(BuildContext context) {
    TextEditingController ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCardColor,
        title: Text("Edit Question", style: GoogleFonts.poppins(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "E.g. Make it harder", 
            filled: true, 
            fillColor: Colors.black12,
            hintStyle: TextStyle(color: Colors.grey)
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kVividGreen),
            onPressed: () {
              Navigator.pop(ctx);
              onRegenerate(ctrl.text);
            }, 
            child: const Text("Update AI")
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController(text: question.userAnswer ?? "");
    
    // Parsiamo il feedback per vedere se è il nuovo formato con "###SPLIT###"
    String feedbackPart = question.aiFeedback ?? "";
    String? idealPart;
    
    if (question.type != "multipla" && feedbackPart.contains("###SPLIT###")) {
      final parts = feedbackPart.split("###SPLIT###");
      feedbackPart = parts[0];
      if (parts.length > 1) idealPart = parts[1];
    }

    return Center(
      child: Container(
        width: 800,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))]
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- HEADER ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: kVividGreen.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            question.type == "multipla" ? "MULTIPLE CHOICE" : "OPEN ANSWER",
                            style: GoogleFonts.poppins(color: kVividGreen, fontSize: 10, fontWeight: FontWeight.bold)
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(CupertinoIcons.doc_text, size: 12, color: Colors.grey),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    question.sourceFile,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: GoogleFonts.poppins(color: Colors.grey[300], fontSize: 10)
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(CupertinoIcons.wand_stars, size: 25, color: kVividGreen), onPressed: () => _showEditDialog(context)),
                      IconButton(icon: const Icon(IconlyLight.delete, size: 25, color: Colors.redAccent), onPressed: onDelete),
                    ],
                  )
                ],
              ),
              
              const SizedBox(height: 30),
              
              // --- DOMANDA ---
              Text(
                question.questionText,
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white, height: 1.4),
              ),
              
              const SizedBox(height: 40),

              // --- RISPOSTA MULTIPLA ---
              if (question.type == "multipla")
                ...question.options.map((opt) {
                  bool isSelected = question.userAnswer == opt;
                  bool isCorrect = question.isLocked && opt.startsWith(question.correctAnswer.split(')')[0]);
                  
                  Color tileColor = const Color(0xFF252525);
                  Color textColor = Colors.white;
                  IconData icon = Icons.circle_outlined;
                  Color iconColor = Colors.grey[700]!;
                  
                  if (isSelected) {
                    tileColor = kVividGreen.withOpacity(0.2);
                    textColor = kVividGreen;
                    icon = Icons.check_circle;
                    iconColor = kVividGreen;
                  }
                  if (isCorrect) {
                    tileColor = Colors.green.withOpacity(0.2);
                    textColor = Colors.green;
                    icon = Icons.check_circle;
                    iconColor = Colors.green;
                  } else if (question.isLocked && isSelected && !isCorrect) {
                    tileColor = Colors.red.withOpacity(0.2);
                    textColor = Colors.red;
                    icon = Icons.cancel;
                    iconColor = Colors.red;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => onSubmit(opt),
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: tileColor,
                          borderRadius: BorderRadius.circular(16),
                          border: isSelected || isCorrect 
                            ? Border.all(color: textColor.withOpacity(0.5)) 
                            : Border.all(color: Colors.transparent),
                        ),
                        child: Row(
                          children: [
                            Icon(icon, color: iconColor, size: 20),
                            const SizedBox(width: 15),
                            Expanded(child: Text(opt, style: GoogleFonts.poppins(color: textColor, fontSize: 16))),
                          ],
                        ),
                      ),
                    ),
                  );
                })
              else
                // --- RISPOSTA APERTA ---
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: textController,
                      enabled: !question.isLocked,
                      style: GoogleFonts.poppins(color: Colors.white),
                      onSubmitted: onSubmit,
                      minLines: 1,
                      maxLines: 8,
                      decoration: InputDecoration(
                        hintText: "Type your answer here...",
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        filled: true, fillColor: const Color(0xFF252525),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        suffixIcon: !question.isLocked 
                          ? IconButton(
                              icon: const Icon(Icons.send, color: kVividGreen),
                              onPressed: () => onSubmit(textController.text),
                            )
                          : null,
                      ),
                    ),
                  ],
                ),

              // --- FEEDBACK AI UNIFICATO (SOLO SE BLOCCATO) ---
              if (question.isLocked && question.aiFeedback != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 30),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: (question.aiScore ?? 0) >= 60 ? kVividGreen.withOpacity(0.1) : Colors.redAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: (question.aiScore ?? 0) >= 60 ? kVividGreen.withOpacity(0.3) : Colors.redAccent.withOpacity(0.3)
                    )
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Punteggio
                      Row(
                        children: [
                          Icon((question.aiScore ?? 0) >= 60 ? Icons.check_circle : Icons.warning_amber_rounded, 
                            color: (question.aiScore ?? 0) >= 60 ? kVividGreen : Colors.redAccent, size: 24),
                          const SizedBox(width: 10),
                          Text("AI Evaluation: ${question.aiScore}/100", 
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                        ],
                      ),
                      
                      const SizedBox(height: 15),
                      const Divider(color: Colors.white12),
                      const SizedBox(height: 15),

                      // SEZIONE 1: COMMENTI
                      Text("FEEDBACK", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                      const SizedBox(height: 5),
                      Text(feedbackPart, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, height: 1.5)),

                      // SEZIONE 2: RISPOSTA IDEALE (Se disponibile)
                      if (idealPart != null) ...[
                        const SizedBox(height: 20),
                        Container(height: 1, color: Colors.white10), // Divisore interno
                        const SizedBox(height: 15),
                        Text("IDEAL ANSWER", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: kVividGreen, letterSpacing: 1.2)),
                        const SizedBox(height: 5),
                        Text(idealPart, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14, fontStyle: FontStyle.italic, height: 1.5)),
                      ]
                    ],
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
// --- 2. CHAT PANEL ---
class ChatPanel extends StatelessWidget {
  final VoidCallback onClose;
  final List<Map<String, String>> messages;
  final TextEditingController controller;
  final VoidCallback onSend;

  const ChatPanel({
    super.key,
    required this.onClose,
    required this.messages,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kSurfaceColor,
        border: Border(left: BorderSide(color: Colors.white10))
      ),
      child: Column(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("AI Assistant", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                  IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: onClose)
                ],
              ),
            ),
          ),
          const Divider(color: Colors.white10),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (ctx, i) {
                final msg = messages[i];
                bool isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? kVividGreen.withOpacity(0.2) : Colors.black26,
                      borderRadius: BorderRadius.circular(12),
                      border: isUser ? Border.all(color: kVividGreen.withOpacity(0.5)) : null
                    ),
                    child: Text(msg['text']!, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: "Ask AI...",
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true, fillColor: Colors.black26,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: kVividGreen),
                  onPressed: onSend,
                )
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- 3. FILTER DROPDOWN ---
class FilterDropdown extends StatelessWidget {
  final String value;
  final List<DropdownMenuItem<String>> items;
  final Function(String?) onChanged;

  const FilterDropdown({super.key, required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: kDropdownColor, 
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items,
          onChanged: onChanged,
          dropdownColor: kDropdownColor,
          borderRadius: BorderRadius.circular(12),
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}