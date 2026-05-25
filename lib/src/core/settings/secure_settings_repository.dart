import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'settings_repository.dart';

class SecureSettingsRepository implements SettingsRepository {
  SecureSettingsRepository(this._storage);

  final FlutterSecureStorage _storage;

  static const _strictOfflineKey = 'settings.strict_offline';
  static const _browserResearchKey = 'settings.browser_research';

  @override
  Future<bool> loadBrowserResearch() async {
    final value = await _storage.read(key: _browserResearchKey);
    return value == '1';
  }

  @override
  Future<bool> loadStrictOffline() async {
    final value = await _storage.read(key: _strictOfflineKey);
    if (value == null) return true;
    return value == '1';
  }

  @override
  Future<void> saveBrowserResearch(bool value) async {
    await _storage.write(key: _browserResearchKey, value: value ? '1' : '0');
  }

  @override
  Future<void> saveStrictOffline(bool value) async {
    await _storage.write(key: _strictOfflineKey, value: value ? '1' : '0');
  }
}
