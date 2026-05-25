import 'package:flutter/material.dart';

import 'chat_controller.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.controller});

  final ChatController controller;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _input = TextEditingController();
  bool _approveSensitive = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    _input.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(colors: [Color(0xAA18FFFF), Color(0xAA7C4DFF)]),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.controller.isThinking ? 'Thinking and planning actions...' : 'Private Offline AI Assistant',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: widget.controller.messages.length,
              itemBuilder: (context, index) {
                final message = widget.controller.messages[widget.controller.messages.length - 1 - index];
                final isUser = message.role == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(13),
                    constraints: const BoxConstraints(maxWidth: 350),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: isUser
                          ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.95)
                          : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.85),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (message.streaming)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 6),
                            child: LinearProgressIndicator(minHeight: 2),
                          ),
                        Text(message.text.isEmpty ? '...' : message.text),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SwitchListTile(
            dense: true,
            title: const Text('Approve sensitive actions for next command'),
            value: _approveSensitive,
            onChanged: (value) => setState(() => _approveSensitive = value),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    maxLines: 4,
                    minLines: 1,
                    decoration: const InputDecoration(
                      hintText: 'Ask, automate, summarize, or search locally...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    final prompt = _input.text;
                    _input.clear();
                    widget.controller.submit(prompt, approveSensitiveActions: _approveSensitive);
                    setState(() => _approveSensitive = false);
                  },
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
