import 'package:flutter/foundation.dart';

import '../settings/settings_repository.dart';

class PrivacyGuard extends ChangeNotifier {
  PrivacyGuard(this._settingsRepository);

  final SettingsRepository _settingsRepository;
  bool _strictOffline = true;
  bool _browserResearchEnabled = false;

  bool get strictOffline => _strictOffline;
  bool get browserResearchEnabled => _browserResearchEnabled;

  Future<void> load() async {
    _strictOffline = await _settingsRepository.loadStrictOffline();
    _browserResearchEnabled = _strictOffline
        ? false
        : await _settingsRepository.loadBrowserResearch();
    notifyListeners();
  }

  Future<void> setStrictOffline(bool value) async {
    if (_strictOffline == value) return;
    _strictOffline = value;
    if (_strictOffline) {
      _browserResearchEnabled = false;
      await _settingsRepository.saveBrowserResearch(false);
    }
    await _settingsRepository.saveStrictOffline(value);
    notifyListeners();
  }

  Future<void> setBrowserResearchEnabled(bool value) async {
    if (_strictOffline && value) {
      throw StateError('Browser research is blocked by strict offline mode');
    }
    _browserResearchEnabled = value;
    await _settingsRepository.saveBrowserResearch(value);
    notifyListeners();
  }
}
