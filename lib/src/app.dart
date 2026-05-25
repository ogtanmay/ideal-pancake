import 'package:flutter/material.dart';

import 'core/memory/memory_manager.dart';
import 'core/model/model_registry.dart';
import 'core/network_audit.dart';
import 'core/security/privacy_guard.dart';
import 'features/chat/chat_controller.dart';
import 'features/chat/chat_screen.dart';
import 'features/models/model_manager_screen.dart';
import 'features/network/network_monitor_screen.dart';
import 'features/privacy/privacy_dashboard_screen.dart';
import 'features/settings/settings_screen.dart';

class OfflineAssistantApp extends StatefulWidget {
  const OfflineAssistantApp({super.key});

  @override
  State<OfflineAssistantApp> createState() => _OfflineAssistantAppState();
}

class _OfflineAssistantAppState extends State<OfflineAssistantApp> {
  final PrivacyGuard _privacyGuard = PrivacyGuard();
  final NetworkAudit _networkAudit = NetworkAudit();
  final MemoryManager _memoryManager = MemoryManager();
  final ModelRegistry _modelRegistry = ModelRegistry();
  late final ChatController _chatController;

  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _chatController = ChatController(
      privacyGuard: _privacyGuard,
      networkAudit: _networkAudit,
      memoryManager: _memoryManager,
    );
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF18FFFF), brightness: Brightness.dark),
    );

    return MaterialApp(
      title: 'Offline Assistant',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: Scaffold(
        body: IndexedStack(
          index: _tab,
          children: [
            ChatScreen(controller: _chatController),
            ModelManagerScreen(registry: _modelRegistry),
            NetworkMonitorScreen(audit: _networkAudit),
            PrivacyDashboardScreen(),
            SettingsScreen(privacyGuard: _privacyGuard),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (index) => setState(() => _tab = index),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
            NavigationDestination(icon: Icon(Icons.memory), label: 'Models'),
            NavigationDestination(icon: Icon(Icons.network_ping), label: 'Network'),
            NavigationDestination(icon: Icon(Icons.shield), label: 'Privacy'),
            NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}
