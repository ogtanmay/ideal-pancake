import 'package:flutter/material.dart';

import '../../core/network_audit.dart';

class NetworkMonitorScreen extends StatefulWidget {
  const NetworkMonitorScreen({super.key, required this.audit});

  final NetworkAudit audit;

  @override
  State<NetworkMonitorScreen> createState() => _NetworkMonitorScreenState();
}

class _NetworkMonitorScreenState extends State<NetworkMonitorScreen> {
  @override
  void initState() {
    super.initState();
    widget.audit.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.audit.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final events = widget.audit.events;
    return SafeArea(
      child: Column(
        children: [
          ListTile(
            title: const Text('Offline Network Inspector'),
            subtitle: Text(events.isEmpty ? 'No attempts' : '${events.length} events logged'),
            trailing: IconButton(onPressed: widget.audit.clear, icon: const Icon(Icons.delete_outline)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  child: ListTile(
                    leading: Icon(event.blocked ? Icons.shield : Icons.public),
                    title: Text(event.endpoint),
                    subtitle: Text('${event.reason}\n${event.timestamp.toIso8601String()}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
