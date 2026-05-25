import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../chat/chat_message.dart';
import '../chat/chat_repository.dart';
import 'message_cipher.dart';
import 'secure_key_store.dart';

class SqlCipherChatRepository implements ChatRepository {
  SqlCipherChatRepository(this._keyStore);

  final SecureKeyStore _keyStore;
  final Uuid _uuid = const Uuid();

  Database? _db;
  MessageCipher? _cipher;

  @override
  Future<void> init() async {
    if (_db != null && _cipher != null) return;

    final messageKey = await _keyStore.getOrCreateMessageKey();
    _cipher = MessageCipher(messageKey);

    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docsDir.path, 'offline_assistant_secure.db');

    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE chat_messages (
            id TEXT PRIMARY KEY,
            role TEXT NOT NULL,
            encrypted_content TEXT NOT NULL,
            created_at_epoch_ms INTEGER NOT NULL
          );
        ''');
        await db.execute(
          'CREATE INDEX idx_chat_created_at ON chat_messages(created_at_epoch_ms DESC);',
        );
      },
    );
  }

  @override
  Future<void> append({required String role, required String content}) async {
    await init();
    final db = _db!;
    final cipher = _cipher!;
    await db.insert('chat_messages', {
      'id': _uuid.v4(),
      'role': role,
      'encrypted_content': cipher.encrypt(content),
      'created_at_epoch_ms': DateTime.now().millisecondsSinceEpoch,
    });
  }

  @override
  Future<void> clear() async {
    await init();
    await _db!.delete('chat_messages');
  }

  @override
  Future<List<ChatMessageEntity>> listRecent({int limit = 200}) async {
    await init();
    final db = _db!;
    final cipher = _cipher!;

    final rows = await db.query(
      'chat_messages',
      orderBy: 'created_at_epoch_ms DESC',
      limit: limit,
    );

    return rows
        .map(
          (row) => ChatMessageEntity(
            id: row['id']! as String,
            role: row['role']! as String,
            content: cipher.decrypt(row['encrypted_content']! as String),
            createdAtEpochMs: row['created_at_epoch_ms']! as int,
          ),
        )
        .toList();
  }
}
