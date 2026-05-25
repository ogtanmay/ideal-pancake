import 'package:flutter/foundation.dart';

class NetworkEvent {
  const NetworkEvent({
    required this.timestamp,
    required this.endpoint,
    required this.blocked,
    required this.reason,
  });

  final DateTime timestamp;
  final String endpoint;
  final bool blocked;
  final String reason;
}

class NetworkAudit extends ChangeNotifier {
  final List<NetworkEvent> _events = <NetworkEvent>[];

  List<NetworkEvent> get events => List<NetworkEvent>.unmodifiable(_events);

  void log({required String endpoint, required bool blocked, required String reason}) {
    _events.insert(
      0,
      NetworkEvent(
        timestamp: DateTime.now(),
        endpoint: endpoint,
        blocked: blocked,
        reason: reason,
      ),
    );
    if (_events.length > 500) {
      _events.removeRange(500, _events.length);
    }
    notifyListeners();
  }

  void clear() {
    _events.clear();
    notifyListeners();
  }
}
