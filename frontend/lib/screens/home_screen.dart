import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart'; // Import Iconly
import 'package:quiz_generator_pro/services/api_service.dart';
import 'package:quiz_generator_pro/models/quiz_models.dart';
import 'package:quiz_generator_pro/services/history_service.dart';
import 'package:quiz_generator_pro/screens/study_screen.dart';
import 'package:quiz_generator_pro/widgets/home_widgets.dart'; // Contiene EmptyStateButton
import 'package:quiz_generator_pro/l10n/app_localizations.dart';
import 'package:quiz_generator_pro/main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<String> _remoteFiles = [];
  List<QuizSession> _history = [];
  Map<String, dynamic>? _systemStatus;
  
  bool _isLoadingData = false;
  bool _isUploading = false;
  
  // Stato Generazione
  bool _isGenerating = false;
  double _generationProgress = 0.0;
  Timer? _pollingTimer; // Timer per il polling
  
  // Stato Post-Generazione (Quiz Pronto ma non aperto)
  QuizSession? _generatedSession;

  String? _selectedModelId;
  String _selectedType = "mixed";
  int _maxOptions = 4;
  double _numQuestions = 5;
  final TextEditingController _promptController = TextEditingController();

  final Color _vividGreen = const Color(0xFF00E676);

  @override
  void initState() {
    super.initState();
    _refreshData();
    _promptController.addListener(() {
      if (_generatedSession != null) setState(() => _generatedSession = null);
    });
  }

  @override
  void dispose() {
    _promptController.dispose();
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() => _isLoadingData = true);
    final status = await ApiService.getSystemStatus();
    final history = await QuizHistoryService.getHistory();
    
    if (mounted) {
      setState(() {
        _remoteFiles = List<String>.from(status['files'] ?? []);
        _systemStatus = status;
        _history = history;
        _isLoadingData = false;
        
        if (_selectedModelId == null && status['models'] != null) {
          final models = (status['models'] as List).map((m) => ModelInfo.fromJson(m)).toList();
          if (models.isNotEmpty) {
            _selectedModelId = models.firstWhere((m) => m.active, orElse: () => models.first).id;
          }
        }
      });
    }
  }

  Future<void> _uploadPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom, allowedExtensions: ['pdf'], allowMultiple: true 
    );

    if (result != null) {
      setState(() => _isUploading = true);
      for (var f in result.files) {
        if (f.path != null) await ApiService.uploadPdf(File(f.path!));
      }
      await _refreshData();
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _deleteFile(String filename) async {
    await ApiService.deleteFile(filename);
    await _refreshData();
  }

  Future<void> _deleteSession(String sessionId) async {
    await QuizHistoryService.deleteSession(sessionId);
    await _refreshData();
  }

  Future<void> _renameSession(QuizSession session) async {
    TextEditingController renameCtrl = TextEditingController(text: session.topic);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("Rename Session", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: renameCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: "New name"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _vividGreen),
            onPressed: () async {
              Navigator.pop(ctx);
              if (renameCtrl.text.isNotEmpty) {
                final updated = QuizSession(
                  id: session.id, 
                  topic: renameCtrl.text,
                  date: session.date, 
                  questions: session.questions
                );
                await QuizHistoryService.updateSession(updated);
                _refreshData();
              }
            }, 
            child: const Text("Save")
          )
        ],
      ),
    );
  }

  // --- LOGICA GENERAZIONE CON POLLING ---
  Future<void> _startQuizGeneration() async {
    if (_isGenerating) return;

    setState(() {
      _generatedSession = null;
      _isGenerating = true;
      _generationProgress = 0.0;
    });

    try {
      if (_selectedModelId != null) {
         await ApiService.switchModel(_selectedModelId!);
      }

      final locale = Localizations.localeOf(context).languageCode;
      final prompt = _promptController.text.isEmpty ? "General review" : _promptController.text;
      
      // 1. Avvia generazione
      final jobId = await ApiService.startQuizGeneration(
        _numQuestions.round(), 
        prompt, 
        locale, 
        _selectedType,
        _maxOptions
      );

      if (jobId == null) {
        throw "Failed to start generation";
      }

      // 2. Polling loop
      _pollingTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) async {
        final status = await ApiService.checkQuizStatus(jobId);
        
        if (status == null || !mounted) return;

        final state = status['status'];
        final progress = status['progress'] as int;
        final total = status['total'] as int;

        setState(() {
          // Calcolo percentuale reale
          _generationProgress = total > 0 ? (progress / total) : 0.0;
        });

        if (state == 'completed') {
          timer.cancel();
          
          final List<dynamic> questionsJson = status['result'];
          final questions = questionsJson.map((q) => QuizQuestion.fromJson(q)).toList();

          if (questions.isNotEmpty) {
            final session = QuizSession(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              topic: prompt,
              date: DateTime.now(),
              questions: questions
            );
            
            // Pulizia
            await ApiService.clearAllFiles(); 
            await _refreshData(); 
            
            setState(() {
              _isGenerating = false;
              _generatedSession = session;
              _generationProgress = 1.0;
            });
          }
        } else if (state == 'failed') {
          timer.cancel();
          setState(() => _isGenerating = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${status['error']}")));
        }
      });

    } catch (e) {
       _pollingTimer?.cancel();
       setState(() => _isGenerating = false);
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _openGeneratedQuiz() async {
    if (_generatedSession != null) {
      await QuizHistoryService.saveSession(_generatedSession!);
      
      if (!mounted) return;

      Navigator.push(
        context, 
        MaterialPageRoute(builder: (_) => StudyScreen(existingSession: _generatedSession, systemStatus: _systemStatus))
      ).then((_) { 
        _refreshData();
        setState(() => _generatedSession = null); 
      });
    }
  }

  void _showSystemSpecs() {
    showDialog(
      context: context,
      builder: (ctx) => SystemSpecsDialog(systemStatus: _systemStatus),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isWide = MediaQuery.of(context).size.width > 900;
    const double sideMenuWidth = 350;

    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: isWide ? 0 : null,
        title: Padding(
          padding: EdgeInsets.only(left: isWide ? sideMenuWidth + 24 : 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/QUIZAI_logo.png', height: 35),
              const SizedBox(width: 12),
              Text(l10n.dashboardTitle, 
                style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 24, color: Colors.white)
              ),
            ],
          ),
        ),
        actions: [
          Row(
            children: [
              Icon(CupertinoIcons.globe, size: 20, color: _vividGreen),
              const SizedBox(width: 4),
              Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  focusColor: Colors.transparent,
                ),
                child: DropdownButton<Locale>(
                  value: Localizations.localeOf(context),
                  dropdownColor: const Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.circular(12),
                  underline: Container(),
                  elevation: 0,
                  focusColor: Colors.transparent,
                  icon: Icon(CupertinoIcons.chevron_down, size: 16, color: _vividGreen),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  items: const [
                      DropdownMenuItem(value: Locale('en'), child: Text("EN")),
                      DropdownMenuItem(value: Locale('it'), child: Text("IT")),
                  ],
                  onChanged: (Locale? newLocale) {
                    if (newLocale != null) QuizApp.setLocale(context, newLocale);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          IconButton(
            icon: Icon(CupertinoIcons.info_circle, color: _vividGreen),
            onPressed: _showSystemSpecs,
          ),
          const SizedBox(width: 24),
        ],
      ),
      drawer: isWide ? null : Drawer(backgroundColor: const Color(0xFF0A0A0A), child: _buildHistoryColumn(l10n)),
      body: Row(
        children: [
          if (isWide) 
            Container(
              width: sideMenuWidth, 
              decoration: const BoxDecoration(
                color: Color(0xFF161616),
                border: Border(right: BorderSide(color: Color(0xFF2A2A2A)))
              ),
              child: _buildHistoryColumn(l10n)
            ),
          
          Expanded(
            child: _isLoadingData 
            ? Center(child: CircularProgressIndicator(color: _vividGreen))
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 110, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(l10n.activeFile, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[400], letterSpacing: 1.2)),
                          const SizedBox(height: 15),
                          Container(
                            constraints: const BoxConstraints(maxHeight: 250),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white.withOpacity(0.05)),
                            ),
                            child: _remoteFiles.isEmpty 
                              ? Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(CupertinoIcons.doc_text_search, size: 48, color: Colors.grey[700]),
                                      const SizedBox(height: 16),
                                      Text(l10n.noFileLoaded, style: TextStyle(color: Colors.grey[600])),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _remoteFiles.length,
                                  separatorBuilder: (_, __) => const Divider(color: Color(0xFF2A2A2A)),
                                  itemBuilder: (ctx, i) {
                                    final f = _remoteFiles[i];
                                    return ListTile(
                                      leading: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12)
                                        ),
                                        child: const Icon(CupertinoIcons.doc_fill, color: Colors.redAccent),
                                      ),
                                      title: Text(f, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white)),
                                      trailing: IconButton(
                                        icon: const Icon(IconlyLight.delete, size: 20, color: Colors.redAccent), 
                                        onPressed: () => _deleteFile(f)
                                      ),
                                    );
                                  },
                                ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: TextButton.icon(
                              onPressed: _isUploading ? null : _uploadPdf,
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white70,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              ),
                              icon: _isUploading 
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                                : const Icon(CupertinoIcons.add),
                              label: Text(_isUploading ? l10n.readingPdf : l10n.uploadPdf),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 40),
                          if (_remoteFiles.isEmpty && _generatedSession == null)
                            const EmptyStateButton() 
                          else 
                            QuizConfigPanel(
                              models: (_systemStatus?['models'] as List?)?.map((m) => ModelInfo.fromJson(m)).toList() ?? [],
                              selectedModelId: _selectedModelId,
                              selectedType: _selectedType,
                              maxOptions: _maxOptions,
                              numQuestions: _numQuestions,
                              promptController: _promptController,
                              isGenerating: _isGenerating,
                              generationProgress: _generationProgress,
                              isReady: _generatedSession != null,
                              onModelChanged: (v) => setState(() { _selectedModelId = v; _generatedSession = null; }),
                              onTypeChanged: (v) => setState(() { _selectedType = v; _generatedSession = null; }),
                              onMaxOptionsChanged: (v) => setState(() { _maxOptions = v; _generatedSession = null; }),
                              onNumQuestionsChanged: (v) => setState(() { _numQuestions = v; _generatedSession = null; }),
                              onStartGeneration: _startQuizGeneration,
                              onOpenQuiz: _openGeneratedQuiz, 
                            ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryColumn(AppLocalizations l10n) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Icon(CupertinoIcons.time, color: _vividGreen),
              const SizedBox(width: 12),
              Text(l10n.quizHistory, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Colors.white)),
            ],
          ),
        ),
        const Divider(color: Color(0xFF2A2A2A), height: 1),
        Expanded(
          child: _history.isEmpty 
            ? Center(child: Text(l10n.noHistory, style: TextStyle(color: Colors.grey[700])))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _history.length,
                itemBuilder: (ctx, i) {
                  return HistoryTile(
                    session: _history[i],
                    onDelete: () => _deleteSession(_history[i].id),
                    onRename: () => _renameSession(_history[i]), 
                    onTap: () {
                       if (Scaffold.of(ctx).hasDrawer) Navigator.pop(context);
                       Navigator.push(context, MaterialPageRoute(builder: (_) => StudyScreen(existingSession: _history[i], systemStatus: _systemStatus))).then((_) => _refreshData());
                    },
                  );
                },
              ),
        )
      ],
    );
  }
}