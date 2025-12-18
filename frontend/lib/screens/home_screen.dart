import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:quiz_generator_pro/services/api_service.dart';
import 'package:quiz_generator_pro/models/quiz_models.dart';
import 'package:quiz_generator_pro/services/history_service.dart';
import 'package:quiz_generator_pro/screens/study_screen.dart';
import 'package:quiz_generator_pro/widgets/home_widgets.dart';
import 'package:quiz_generator_pro/l10n/app_localizations.dart';
import 'package:quiz_generator_pro/main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  // Data for the Library
  List<String> _libraryFiles = []; 
  Set<String> _selectedFiles = {}; 
  
  List<QuizSession> _history = [];
  Map<String, dynamic>? _systemStatus;
  
  bool _isLoadingData = false;
  bool _isUploading = false;
  
  // Generation State
  bool _isGenerating = false;
  double _generationProgress = 0.0;
  Timer? _pollingTimer; 
  
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
    
    Map<String, dynamic> status = {'files': [], 'models': []};
    try {
      status = await ApiService.getSystemStatus();
    } catch (e) {
      debugPrint("Backend offline: $e");
    }

    final history = await QuizHistoryService.getHistory();
    
    if (mounted) {
      setState(() {
        _libraryFiles = List<String>.from(status['files'] ?? []);
        _selectedFiles = _selectedFiles.intersection(_libraryFiles.toSet());
        _systemStatus = status;
        _history = history;
        _isLoadingData = false;
        
        if (_selectedModelId == null && status['models'] != null && (status['models'] as List).isNotEmpty) {
          final models = (status['models'] as List).map((m) => ModelInfo.fromJson(m)).toList();
          if (models.isNotEmpty) {
            _selectedModelId = models.firstWhere((m) => m.active, orElse: () => models.first).id;
          }
        }
      });
    }
  }

  // --- UPLOAD LOGIC ---
  Future<void> _uploadPdf() async {
    final l10n = AppLocalizations.of(context)!;
    
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom, allowedExtensions: ['pdf'], allowMultiple: true 
    );

    if (result != null) {
      setState(() => _isUploading = true);
      
      for (var f in result.files) {
        if (f.path == null) continue;
        
        if (_libraryFiles.contains(f.name)) {
          if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l10n.errorFileExists(f.name)),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 2),
          ));
          continue;
        }

        bool ok = await ApiService.uploadPdf(File(f.path!));
        if (ok) {
           setState(() {
             _selectedFiles.add(f.name);
           });
        } else {
           if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorUploadFailed(f.name))));
        }
      }
      
      await _refreshData();
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _deleteFile(String filename) async {
    await ApiService.deleteFile(filename);
    setState(() {
      _selectedFiles.remove(filename);
    });
    await _refreshData();
  }

  // --- GENERATION LOGIC ---
  Future<void> _startQuizGeneration() async {
    if (_isGenerating) return;
    
    final l10n = AppLocalizations.of(context)!;

    if (_selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorSelectFile), 
          backgroundColor: Colors.orange
        )
      );
      return;
    }

    setState(() {
      _generatedSession = null;
      _isGenerating = true;
      _generationProgress = 0.0;
    });

    try {
      bool contextOk = await ApiService.loadContext(_selectedFiles.toList());
      
      if (!contextOk) {
        throw l10n.errorLoadContext;
      }

      if (_selectedModelId != null) {
         await ApiService.switchModel(_selectedModelId!);
      }

      final locale = Localizations.localeOf(context).languageCode;
      final prompt = _promptController.text.isEmpty ? "General review" : _promptController.text;
      
      final jobId = await ApiService.startQuizGeneration(
        _numQuestions.round(), 
        prompt, 
        locale, 
        _selectedType,
        _maxOptions
      );

      if (jobId == null) throw l10n.errorStartGeneration;

      _pollingTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) async {
        final status = await ApiService.checkQuizStatus(jobId);
        if (status == null || !mounted) return;

        final state = status['status'];
        final progress = status['progress'] as int;
        final total = status['total'] as int;

        setState(() {
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
          if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${status['error']}")));
        }
      });

    } catch (e) {
       _pollingTimer?.cancel();
       setState(() => _isGenerating = false);
       if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _exportSession(QuizSession session) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      String jsonStr = jsonEncode(session.toJson());
      String fileName = "quiz_${session.topic.replaceAll(' ', '_')}.json";
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Quiz Session',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (outputFile != null) {
        if (!outputFile.toLowerCase().endsWith('.json')) outputFile += '.json';
        await File(outputFile).writeAsString(jsonStr);
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.successExport)));
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorExport(e.toString()))));
    }
  }

  Future<void> _importSession() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['json'],
      );
      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        String content = await file.readAsString();
        Map<String, dynamic> jsonData = jsonDecode(content);
        jsonData['id'] = DateTime.now().millisecondsSinceEpoch.toString(); 
        QuizSession importedSession = QuizSession.fromJson(jsonData);
        await QuizHistoryService.saveSession(importedSession);
        await _refreshData();
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.successImport)));
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorImport(e.toString()))));
    }
  }

  Future<void> _deleteSession(String sessionId) async {
    await QuizHistoryService.deleteSession(sessionId);
    await _refreshData();
  }

  Future<void> _renameSession(QuizSession session) async {
    final l10n = AppLocalizations.of(context)!;
    TextEditingController renameCtrl = TextEditingController(text: session.topic);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(l10n.renameSession, style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: renameCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(hintText: l10n.newName),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
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
            child: Text(l10n.save)
          )
        ],
      ),
    );
  }

  Future<void> _openGeneratedQuiz() async {
    if (_generatedSession != null) {
      await QuizHistoryService.saveSession(_generatedSession!);
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => StudyScreen(existingSession: _generatedSession, systemStatus: _systemStatus))).then((_) { 
        _refreshData();
        setState(() => _generatedSession = null); 
      });
    }
  }

  void _showSystemSpecs() {
    showDialog(context: context, builder: (ctx) => SystemSpecsDialog(systemStatus: _systemStatus));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    
    final bool showSideMenu = screenWidth >= 1100;
    const double sideMenuWidth = 400;

    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: showSideMenu ? 0 : null,
        title: Padding(
          padding: EdgeInsets.only(left: showSideMenu ? sideMenuWidth + 24 : 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/QUIZAI_logo.png', height: 35, errorBuilder: (c,e,s) => const Icon(Icons.flash_on, color: Color(0xFF00E676))),
              const SizedBox(width: 12),
              if (screenWidth > 600)
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
              DropdownButton<Locale>(
                value: Localizations.localeOf(context),
                dropdownColor: const Color(0xFF2C2C2C),
                underline: Container(),
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
      drawer: showSideMenu 
          ? null 
          : SizedBox(
              width: sideMenuWidth, 
              child: Drawer(
                backgroundColor: const Color(0xFF0A0A0A), 
                child: _buildHistoryColumn(l10n)
              ),
            ),
      body: Row(
        children: [
          if (showSideMenu) 
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
                      padding: EdgeInsets.fromLTRB(
                        screenWidth > 600 ? 24 : 16, 
                        110, 
                        screenWidth > 600 ? 24 : 16, 
                        0
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(l10n.activeFile, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[400], letterSpacing: 1.2)),
                              TextButton.icon(
                                onPressed: _isUploading ? null : _uploadPdf,
                                icon: _isUploading 
                                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Icon(CupertinoIcons.add, size: 18),
                                label: Text(_isUploading ? l10n.uploading : l10n.addNewPdf),
                                style: TextButton.styleFrom(foregroundColor: _vividGreen),
                              )
                            ],
                          ),
                          const SizedBox(height: 10),

                          Container(
                            constraints: const BoxConstraints(maxHeight: 250), 
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white.withOpacity(0.05)),
                            ),
                            child: _libraryFiles.isEmpty 
                              ? Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(CupertinoIcons.folder, size: 40, color: Colors.grey[700]),
                                      const SizedBox(height: 10),
                                      Text(l10n.libraryEmpty, style: TextStyle(color: Colors.grey[600])),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.all(8),
                                  itemCount: _libraryFiles.length,
                                  separatorBuilder: (_, __) => const Divider(color: Color(0xFF2A2A2A), height: 1),
                                  itemBuilder: (ctx, i) {
                                    final fileName = _libraryFiles[i];
                                    final isSelected = _selectedFiles.contains(fileName);

                                    return CheckboxListTile(
                                      value: isSelected,
                                      activeColor: _vividGreen,
                                      checkColor: Colors.black,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      title: Text(
                                        fileName, 
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : Colors.grey[400], 
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      secondary: IconButton(
                                        icon: const Icon(IconlyLight.delete, size: 20, color: Colors.redAccent),
                                        onPressed: () => _deleteFile(fileName), 
                                      ),
                                      onChanged: (bool? val) {
                                        setState(() {
                                          if (val == true) {
                                            _selectedFiles.add(fileName);
                                          } else {
                                            _selectedFiles.remove(fileName);
                                          }
                                        });
                                      },
                                      controlAffinity: ListTileControlAffinity.leading, 
                                    );
                                  },
                                ),
                          ),
                          
                          if (_libraryFiles.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8, right: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    l10n.selectedFiles(_selectedFiles.length), 
                                    style: TextStyle(color: _selectedFiles.isNotEmpty ? _vividGreen : Colors.grey[600], fontSize: 12)
                                  ),
                                  if (_selectedFiles.isNotEmpty) ...[
                                    const SizedBox(width: 10),
                                    TextButton(
                                      onPressed: () {
                                        for(var f in _selectedFiles.toList()) {
                                          _deleteFile(f);
                                        }
                                      }, 
                                      child: Text(l10n.deleteSelected, style: const TextStyle(color: Colors.redAccent, fontSize: 12))
                                    )
                                  ]
                                ],
                              ),
                            ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth > 600 ? 24 : 16, 
                        vertical: 16
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),
                          if (_libraryFiles.isEmpty && _generatedSession == null)
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
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 10),
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(CupertinoIcons.time, color: _vividGreen),
                  const SizedBox(width: 12),
                  Text(l10n.quizHistory, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Colors.white)),
                ],
              ),
              IconButton(
                onPressed: _importSession,
                tooltip: "Import Quiz JSON",
                icon: const Icon(CupertinoIcons.arrow_down_doc, color: Colors.white),
              )
            ],
          ),
        ),
        const Divider(color: Color(0xFF2A2A2A), height: 1),
        Expanded(
          child: _history.isEmpty 
            ? Center(child: Text(l10n.noHistory, style: TextStyle(color: Colors.grey[700])))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                itemCount: _history.length,
                itemBuilder: (ctx, i) {
                  return HistoryTile(
                    session: _history[i],
                    onDelete: () => _deleteSession(_history[i].id),
                    onRename: () => _renameSession(_history[i]), 
                    onExport: () => _exportSession(_history[i]), 
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