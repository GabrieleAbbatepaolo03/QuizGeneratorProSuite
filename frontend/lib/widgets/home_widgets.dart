import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart'; 
import 'package:quiz_generator_pro/l10n/app_localizations.dart';
import 'package:quiz_generator_pro/models/quiz_models.dart';

const Color kVividGreen = Color(0xFF00E676);
const Color kSurfaceColor = Color(0xFF161616);
const Color kCardColor = Color(0xFF1E1E1E);

// --- 1. TILE CRONOLOGIA ---
class HistoryTile extends StatelessWidget {
  final QuizSession session;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onRename;
  final VoidCallback onExport; 

  const HistoryTile({
    super.key,
    required this.session,
    required this.onTap,
    required this.onDelete,
    required this.onRename,
    required this.onExport, 
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    if (session.isCompleted) {
      statusColor = Colors.green;
      statusIcon = CupertinoIcons.check_mark_circled_solid;
    } else if (session.isStarted) {
      statusColor = Colors.yellowAccent;
      statusIcon = CupertinoIcons.forward_fill; 
    } else {
      statusColor = Colors.redAccent;
      statusIcon = CupertinoIcons.play_arrow_solid;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          radius: 22,
          child: Icon(statusIcon, size: 22, color: statusColor),
        ),
        title: Text(
          session.topic, 
          maxLines: 1, 
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600, 
            color: Colors.white,
            fontSize: 16
          )
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              DateFormat('dd/MM/yyyy HH:mm').format(session.date),
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500]),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text("${session.answeredQuestions}/${session.totalQuestions} ", 
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)
                ),
                const SizedBox(width: 8),
                _buildDot(Colors.green, session.correctAnswers),
                const SizedBox(width: 4),
                _buildDot(Colors.redAccent, session.wrongAnswers),
                const SizedBox(width: 4),
                _buildDot(Colors.grey, session.totalQuestions - session.answeredQuestions),
              ],
            )
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(CupertinoIcons.share, size: 20, color: Colors.blueAccent),
              tooltip: "Export JSON",
              onPressed: onExport,
            ),
            IconButton(
              icon: const Icon(CupertinoIcons.pencil, size: 20, color: kVividGreen),
              onPressed: onRename,
            ),
            IconButton(
              icon: const Icon(IconlyLight.delete, size: 20, color: Colors.redAccent),
              onPressed: onDelete,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDot(Color color, int count) {
    if (count == 0) return const SizedBox.shrink();
    return Row(
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 3),
        Text("$count", style: GoogleFonts.poppins(fontSize: 10, color: color))
      ],
    );
  }
}

// --- 2. DIALOG SPECIFICHE SISTEMA ---
class SystemSpecsDialog extends StatelessWidget {
  final Map<String, dynamic>? systemStatus;

  const SystemSpecsDialog({super.key, this.systemStatus});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final specs = systemStatus?['specs'] as Map<String, dynamic>?;

    return AlertDialog(
      backgroundColor: kCardColor,
      title: Text(l10n.systemSpecs, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(CupertinoIcons.desktopcomputer, color: kVividGreen),
            title: Text(l10n.backendApi, style: GoogleFonts.poppins(color: Colors.white)),
            subtitle: Text(systemStatus?['status'] ?? "Offline", 
              style: GoogleFonts.poppins(color: (systemStatus?['status'] == 'online') ? Colors.green : Colors.red)
            ),
          ),
          const Divider(color: Colors.white24),
          if (specs != null) ...[
             Padding(
               padding: const EdgeInsets.only(bottom: 8.0),
               child: Text(l10n.hardware, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
             ),
             _buildSpecRow("CPU", specs['cpu'] ?? "N/A", CupertinoIcons.waveform_path_ecg),
             const SizedBox(height: 8),
             _buildSpecRow("GPU", specs['gpu'] ?? "N/A", CupertinoIcons.layers_alt),
             const SizedBox(height: 8),
             _buildSpecRow("RAM", "${specs['ram_used']} / ${specs['ram_total']}", CupertinoIcons.bolt_horizontal),
             const Divider(color: Colors.white24),
          ],
          Padding(
               padding: const EdgeInsets.symmetric(vertical: 8.0),
               child: Text(l10n.aiModels, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
          ),
          ...(systemStatus?['models'] as List? ?? []).map((m) {
            final model = ModelInfo.fromJson(m);
            return ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(model.name, style: GoogleFonts.poppins(color: Colors.white70)),
              subtitle: Text(model.id, style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12)),
              trailing: model.active 
                ? const Icon(Icons.check_circle, color: kVividGreen, size: 20)
                : const SizedBox.shrink(),
            );
          })
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.close, style: GoogleFonts.poppins(color: Colors.white)))
      ],
    );
  }

  Widget _buildSpecRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white70),
        const SizedBox(width: 12),
        Text("$label:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white70)),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: GoogleFonts.poppins(color: Colors.white), overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

// --- 3. PANNELLO CONFIGURAZIONE QUIZ ---
class QuizConfigPanel extends StatefulWidget {
  final List<ModelInfo> models;
  final String? selectedModelId;
  final String selectedType;
  final int maxOptions;
  final double numQuestions;
  final TextEditingController promptController;
  final bool isGenerating;
  final double generationProgress;
  final bool isReady;
  
  final Function(String?) onModelChanged;
  final Function(String) onTypeChanged;
  final Function(int) onMaxOptionsChanged;
  final Function(double) onNumQuestionsChanged;
  final VoidCallback onStartGeneration;
  final VoidCallback onOpenQuiz;

  const QuizConfigPanel({
    super.key,
    required this.models,
    required this.selectedModelId,
    required this.selectedType,
    required this.maxOptions,
    required this.numQuestions,
    required this.promptController,
    required this.isGenerating,
    required this.generationProgress,
    required this.isReady,
    required this.onModelChanged,
    required this.onTypeChanged,
    required this.onMaxOptionsChanged,
    required this.onNumQuestionsChanged,
    required this.onStartGeneration,
    required this.onOpenQuiz,
  });

  @override
  State<QuizConfigPanel> createState() => _QuizConfigPanelState();
}

class _QuizConfigPanelState extends State<QuizConfigPanel> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final dropdownDecor = InputDecoration(
      filled: true,
      fillColor: const Color(0xFF2C2C2C),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      labelStyle: GoogleFonts.poppins(color: Colors.grey[400]),
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: kVividGreen.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(color: kVividGreen.withOpacity(0.05), blurRadius: 30, offset: const Offset(0, 10))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(CupertinoIcons.slider_horizontal_3, color: kVividGreen),
              const SizedBox(width: 10),
              Text(l10n.configQuiz, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 24),
          
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: dropdownDecor.copyWith(labelText: l10n.aiModelLabel),
                  value: widget.selectedModelId,
                  dropdownColor: const Color(0xFF333333),
                  borderRadius: BorderRadius.circular(16),
                  style: GoogleFonts.poppins(color: Colors.white),
                  items: widget.models.map((m) => DropdownMenuItem(value: m.id, child: Text(m.name, style: GoogleFonts.poppins(color: Colors.white)))).toList(),
                  onChanged: (widget.isGenerating || widget.isReady) ? null : widget.onModelChanged,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: dropdownDecor.copyWith(labelText: l10n.typeLabel),
                  value: widget.selectedType,
                  dropdownColor: const Color(0xFF333333),
                  borderRadius: BorderRadius.circular(16),
                  style: GoogleFonts.poppins(color: Colors.white),
                  items: [
                    DropdownMenuItem(value: "mixed", child: Text(l10n.quizTypeMixed, style: const TextStyle(color: Colors.white))),
                    DropdownMenuItem(value: "open", child: Text(l10n.quizTypeOpen, style: const TextStyle(color: Colors.white))),
                    DropdownMenuItem(value: "multiple", child: Text(l10n.quizTypeMultiple, style: const TextStyle(color: Colors.white))),
                  ],
                  onChanged: (widget.isGenerating || widget.isReady) ? null : (v) => widget.onTypeChanged(v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          TextField(
            controller: widget.promptController,
            enabled: !widget.isGenerating && !widget.isReady,
            style: GoogleFonts.poppins(color: Colors.white),
            decoration: InputDecoration(
              labelText: l10n.customPromptLabel,
              hintText: l10n.customPromptHint,
              hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
              labelStyle: GoogleFonts.poppins(color: Colors.grey[400]),
              prefixIcon: const Icon(CupertinoIcons.sparkles, size: 18, color: Colors.white70),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${l10n.numberOfQuestions}: ${widget.numQuestions.round()}", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                    Transform.translate(
                      offset: const Offset(-24, 0),
                      child: Slider(
                        value: widget.numQuestions, 
                        min: 1, max: 100, divisions: 99, 
                        activeColor: kVividGreen,
                        onChanged: (widget.isGenerating || widget.isReady) ? null : widget.onNumQuestionsChanged
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.selectedType != "open") ...[
                const SizedBox(width: 20),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${l10n.optionsLabel}: ${widget.maxOptions}", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                      Transform.translate(
                        offset: const Offset(-24, 0),
                        child: Slider(
                          value: widget.maxOptions.toDouble(), 
                          min: 2, max: 5, divisions: 3, 
                          activeColor: kVividGreen,
                          onChanged: (widget.isGenerating || widget.isReady) ? null : (v) => widget.onMaxOptionsChanged(v.toInt())
                        ),
                      ),
                    ],
                  ),
                )
              ]
            ],
          ),

          const SizedBox(height: 30),

          GestureDetector(
            onTap: widget.isGenerating 
                ? null 
                : (widget.isReady ? widget.onOpenQuiz : widget.onStartGeneration),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 65,
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: widget.isReady ? kVividGreen : const Color(0xFF252525),
                borderRadius: BorderRadius.circular(16),
                boxShadow: widget.isGenerating 
                  ? [BoxShadow(color: kVividGreen.withOpacity(0.6), blurRadius: 25, spreadRadius: 1)]
                  : [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 4))]
              ),
              child: Stack(
                children: [
                  if (!widget.isReady)
                    AnimatedFractionallySizedBox(
                      duration: const Duration(milliseconds: 300),
                      widthFactor: widget.isGenerating ? widget.generationProgress : 0.0,
                      heightFactor: 1.0,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [kVividGreen, Color(0xFF00C853)]),
                        ),
                      ),
                    ),
                  
                  Center(
                    child: widget.isGenerating 
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20, height: 20, 
                            child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                          ),
                          const SizedBox(width: 12),
                          // FIX: Localized text for generating
                          Text(
                            "${l10n.generating} ${(widget.generationProgress * widget.numQuestions).round()} / ${widget.numQuestions.round()}",
                            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                          ),
                        ],
                      )
                    : widget.isReady 
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                               const Icon(CupertinoIcons.play_arrow_solid, color: Colors.black, size: 28),
                               const SizedBox(width: 10),
                               Text(l10n.startQuizBtn.toUpperCase(), 
                                  style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.5)
                               ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                               const Icon(CupertinoIcons.bolt_fill, color: kVividGreen),
                               const SizedBox(width: 10),
                               Text(l10n.generateBtn.toUpperCase(), 
                                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.5)
                               ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

// --- 4. EMPTY STATE BUTTON ---
class EmptyStateButton extends StatelessWidget {
  const EmptyStateButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10)
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CupertinoIcons.lock_fill, color: Colors.grey),
            const SizedBox(width: 10),
            Text("Upload a PDF to unlock Quiz Generation", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}