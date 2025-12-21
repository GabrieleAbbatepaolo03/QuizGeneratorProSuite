// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get dashboardTitle => 'Quiz Generator Pro';

  @override
  String get noFileLoaded => '未加载知识库';

  @override
  String get uploadPdf => '添加 PDF 文档';

  @override
  String get readingPdf => '正在读取 PDF...';

  @override
  String get activeFile => '知识库:';

  @override
  String get chatWithAi => '与 AI 聊天';

  @override
  String get generateQuiz => '生成测验';

  @override
  String get changeFile => '管理文件';

  @override
  String get pdfUploaded => 'PDF 已添加到大脑！';

  @override
  String get settingsTitle => '系统与设置';

  @override
  String get detectedHardware => '检测到的硬件';

  @override
  String get compatible => '与您的电脑兼容';

  @override
  String get incompatible => '硬件不足';

  @override
  String get active => '活跃';

  @override
  String get load => '加载';

  @override
  String get missingFile => '文件缺失';

  @override
  String get language => '语言';

  @override
  String get selectLanguage => '应用语言';

  @override
  String get chatTitle => '聊天';

  @override
  String get chatHint => '询问关于您文档的问题...';

  @override
  String get quizTitle => '测验生成器';

  @override
  String get configQuiz => '配置您的测验';

  @override
  String get customPromptLabel => '测验重点与风格';

  @override
  String get customPromptHint => '例如：关于量子物理的难题，学术风格...';

  @override
  String get numberOfQuestions => '题目数量';

  @override
  String get difficultyLabel => '难度级别';

  @override
  String get generateBtn => '生成测验';

  @override
  String get startQuizBtn => '开始测验';

  @override
  String get generating => '正在生成...';

  @override
  String get quizResults => '测验结果';

  @override
  String get newQuiz => '新测验';

  @override
  String get correctAnswer => '答案:';

  @override
  String get quizHistory => '测验历史';

  @override
  String get noHistory => '尚未进行测验';

  @override
  String get delete => '删除';

  @override
  String get startSession => '开始学习';

  @override
  String get subStart => '聊天 • 测验 • 验证';

  @override
  String get aiChat => 'AI 聊天';

  @override
  String get newSession => '新会话';

  @override
  String get config => '配置';

  @override
  String get questions => '问题';

  @override
  String get sceltaMultipla => '多项选择';

  @override
  String get rispostaAperta => '开放式回答';

  @override
  String get feedbackAI => 'AI 反馈';

  @override
  String get writeAnswer => '在此输入您的答案...';

  @override
  String get sendAnswer => '提交答案';

  @override
  String get previous => '上一个';

  @override
  String get next => '下一个';

  @override
  String get aiAssistant => 'AI 助手';

  @override
  String get quizCompleted => '测验完成！';

  @override
  String get retry => '重试';

  @override
  String get generateMore => '生成更多';

  @override
  String get keepOldSession => '保留之前的会话？';

  @override
  String get keep => '保留';

  @override
  String get discard => '丢弃';

  @override
  String get quizTypeMixed => '混合 (开放 + 多选)';

  @override
  String get quizTypeOpen => '仅开放式问题';

  @override
  String get quizTypeMultiple => '仅多项选择';

  @override
  String get optionsLabel => '每个问题的选项数';

  @override
  String get resultsSummary => '结果摘要';

  @override
  String get score => '得分';

  @override
  String get restartShuffle => '重新开始并打乱';

  @override
  String get reviewErrors => '重试错误';

  @override
  String get backToHome => '返回首页';

  @override
  String get restartQuiz => '重新开始';

  @override
  String errorFileExists(String fileName) {
    return '错误：\'$fileName\' 已存在于库中。';
  }

  @override
  String errorUploadFailed(String fileName) {
    return '$fileName 上传失败';
  }

  @override
  String get errorSelectFile => '请从档案中至少选择一个文件。';

  @override
  String get errorLoadContext => '加载上下文失败。请检查后端连接。';

  @override
  String get errorStartGeneration => '启动生成任务失败';

  @override
  String get successExport => '测验导出成功！';

  @override
  String errorExport(String error) {
    return '导出失败: $error';
  }

  @override
  String get successImport => '测验导入成功！';

  @override
  String errorImport(String error) {
    return '导入失败: $error';
  }

  @override
  String get renameSession => '重命名会话';

  @override
  String get renameQuiz => '重命名测验';

  @override
  String get newName => '新名称';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get addNewPdf => '添加新 PDF';

  @override
  String get uploading => '上传中...';

  @override
  String get libraryEmpty => '库为空';

  @override
  String selectedFiles(int count) {
    return '已选择 $count 个';
  }

  @override
  String get deleteSelected => '删除选中项';

  @override
  String get importedModeWarning => '⚠️ 导入模式：未找到源文件。AI 聊天和评分已禁用。';

  @override
  String get aiGradingUnavailable => '⚠️ 由于缺少源文件（导入模式），AI 评分不可用。';

  @override
  String get aiChatUnavailable => '⚠️ AI 不可用：缺少源文档。此导入会话已禁用聊天。';

  @override
  String get aiRegenUnavailable => '导入模式下 AI 重新生成不可用。';

  @override
  String get noQuestionsFound => '未找到问题。';

  @override
  String get editQuestion => '编辑问题';

  @override
  String get updateAi => '更新 AI';

  @override
  String aiEvaluation(int score) {
    return 'AI 评估: $score/100';
  }

  @override
  String get aiUnavailable => 'AI 不可用';

  @override
  String get feedbackLabel => '反馈';

  @override
  String get idealAnswerLabel => '理想答案';

  @override
  String get systemSpecs => '系统规格';

  @override
  String get backendApi => '后端 API';

  @override
  String get hardware => '硬件';

  @override
  String get aiModels => 'AI 模型';

  @override
  String get close => '关闭';

  @override
  String get aiModelLabel => 'AI 模型';

  @override
  String get typeLabel => '类型';

  @override
  String get allTypes => '所有类型';

  @override
  String get openType => '开放式';

  @override
  String get multipleChoiceType => '多项选择';

  @override
  String get allFiles => '所有文件';

  @override
  String get uploadToUnlock => '上传 PDF 以解锁测验生成';

  @override
  String get quizConfigTitle => '配置测验';

  @override
  String get selectAiModel => '选择 AI 模型';

  @override
  String get questionType => '问题类型';

  @override
  String get optionsCount => '选项数量';

  @override
  String get initializing => '正在初始化...';

  @override
  String get analyzingTopics => '正在分析主题...';

  @override
  String get stopGeneration => '停止生成';

  @override
  String get stopping => '停止中...';

  @override
  String get aborting => '正在中止...';

  @override
  String get processing => '处理中...';

  @override
  String get completed => '完成！';

  @override
  String get generationStoppedSafely => '生成已安全停止。';
}
