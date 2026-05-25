class ChatMessageEntity {
  const ChatMessageEntity({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAtEpochMs,
  });

  final String id;
  final String role;
  final String content;
  final int createdAtEpochMs;
}
