import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../chat/chat_repository.dart';
import '../memory/memory_manager.dart';
import '../network_audit.dart';
import '../settings/secure_settings_repository.dart';
import '../settings/settings_repository.dart';
import '../storage/secure_key_store.dart';
import '../storage/sqlcipher_chat_repository.dart';
import '../security/privacy_guard.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  if (sl.isRegistered<PrivacyGuard>()) return;

  const secureStorage = FlutterSecureStorage();
  sl.registerSingleton<FlutterSecureStorage>(secureStorage);

  sl.registerLazySingleton<SecureKeyStore>(() => SecureKeyStore(sl()));
  sl.registerLazySingleton<SettingsRepository>(() => SecureSettingsRepository(sl()));
  sl.registerLazySingleton<ChatRepository>(() => SqlCipherChatRepository(sl()));

  sl.registerSingleton<NetworkAudit>(NetworkAudit());
  sl.registerSingleton<MemoryManager>(MemoryManager());
  sl.registerSingleton<PrivacyGuard>(PrivacyGuard(sl()));

  await sl<ChatRepository>().init();
  await sl<PrivacyGuard>().load();
}
