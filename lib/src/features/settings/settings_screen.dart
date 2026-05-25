import 'package:flutter/material.dart';

import '../../core/security/privacy_guard.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.privacyGuard});

  final PrivacyGuard privacyGuard;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    widget.privacyGuard.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.privacyGuard.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        children: [
          const ListTile(
            title: Text('Security & Privacy Center'),
            subtitle: Text('Permissions, offline policy, and local-only processing controls.'),
          ),
          SwitchListTile(
            title: const Text('Strict Offline Firewall Mode'),
            subtitle: const Text('Blocks browser research mode and network-origin actions.'),
            value: widget.privacyGuard.strictOffline,
            onChanged: widget.privacyGuard.setStrictOffline,
          ),
          SwitchListTile(
            title: const Text('Enable Browser Research Mode'),
            subtitle: const Text('Disabled by default. Requires strict offline mode to be off.'),
            value: widget.privacyGuard.browserResearchEnabled,
            onChanged: (value) {
              try {
                widget.privacyGuard.setBrowserResearchEnabled(value);
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Disable strict offline mode first.')),
                );
              }
            },
          ),
          const ListTile(
            title: Text('Permission visibility'),
            subtitle: Text(
              'Accessibility: app automation\n'
              'Microphone: offline voice\n'
              'Storage: model and document indexing\n'
              'Notifications: smart reply assistant',
            ),
          ),
        ],
      ),
    );
  }
}
