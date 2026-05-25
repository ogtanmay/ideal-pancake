import 'package:flutter/material.dart';

class PrivacyDashboardScreen extends StatelessWidget {
  const PrivacyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: const [
          Card(
            child: ListTile(
              title: Text('Data residency'),
              subtitle: Text('Chats, memory, indexes, and logs remain on this device only.'),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Telemetry policy'),
              subtitle: Text('No analytics SDK, ad tracking SDK, or crash reporting SDK is integrated.'),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Sensitive action policy'),
              subtitle: Text('Send/delete/post/payment actions are approval-gated before execution.'),
            ),
          ),
        ],
      ),
    );
  }
}
