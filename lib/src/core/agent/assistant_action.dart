enum AssistantActionType {
  appLauncher,
  accessibilityAutomation,
  browserResearch,
  localFileReader,
  screenshotAnalyzer,
  clipboardReader,
  pdfSummarizer,
  reminderCreator,
  localSearch,
  notesManager,
  settingsController,
  mediaController,
  notificationReader,
  calendarManager,
  codeExecutorSandbox,
  voicePipeline,
  sendMessage,
  deleteFile,
  emailSend,
  socialPost,
  payment,
}

class AssistantAction {
  const AssistantAction({
    required this.id,
    required this.type,
    required this.payload,
    this.rollbackPayload = const {},
  });

  final String id;
  final AssistantActionType type;
  final Map<String, String> payload;
  final Map<String, String> rollbackPayload;

  bool get isSensitive => const {
        AssistantActionType.sendMessage,
        AssistantActionType.deleteFile,
        AssistantActionType.emailSend,
        AssistantActionType.socialPost,
        AssistantActionType.payment,
      }.contains(type);
}
