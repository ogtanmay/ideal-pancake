import 'package:flutter_test/flutter_test.dart';
import 'package:offline_assistant/src/core/security/privacy_guard.dart';
import 'package:offline_assistant/src/core/settings/settings_repository.dart';

class _MemorySettingsRepo implements SettingsRepository {
  bool strict = true;
  bool browser = false;

  @override
  Future<bool> loadBrowserResearch() async => browser;

  @override
  Future<bool> loadStrictOffline() async => strict;

  @override
  Future<void> saveBrowserResearch(bool value) async {
    browser = value;
  }

  @override
  Future<void> saveStrictOffline(bool value) async {
    strict = value;
  }
}

void main() {
  test('privacy guard blocks browser research in strict mode', () async {
    final repo = _MemorySettingsRepo();
    final guard = PrivacyGuard(repo);

    await guard.load();
    expect(guard.strictOffline, isTrue);

    await expectLater(
      guard.setBrowserResearchEnabled(true),
      throwsA(isA<StateError>()),
    );

    await guard.setStrictOffline(false);
    await guard.setBrowserResearchEnabled(true);
    expect(guard.browserResearchEnabled, isTrue);
  });
}
