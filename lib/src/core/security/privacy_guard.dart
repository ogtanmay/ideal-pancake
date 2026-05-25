import 'package:flutter/foundation.dart';

class PrivacyGuard extends ChangeNotifier {
  bool _strictOffline = true;
  bool _browserResearchEnabled = false;

  bool get strictOffline => _strictOffline;
  bool get browserResearchEnabled => _browserResearchEnabled;

  void setStrictOffline(bool value) {
    if (_strictOffline == value) return;
    _strictOffline = value;
    if (_strictOffline) {
      _browserResearchEnabled = false;
    }
    notifyListeners();
  }

  void setBrowserResearchEnabled(bool value) {
    if (_strictOffline && value) {
      throw StateError('Browser research is blocked by strict offline mode');
    }
    _browserResearchEnabled = value;
    notifyListeners();
  }
}
