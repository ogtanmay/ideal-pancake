import 'chat_message.dart';

abstract class ChatRepository {
  Future<void> init();
  Future<List<ChatMessageEntity>> listRecent({int limit = 200});
  Future<void> append({required String role, required String content});
  Future<void> clear();
}
