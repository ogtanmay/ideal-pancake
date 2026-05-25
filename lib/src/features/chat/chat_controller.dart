import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/agent/execution_manager.dart';
import '../../core/agent/execution_models.dart';
import '../../core/agent/task_planner.dart';
import '../../core/agent/tool_registry.dart';
import '../../core/inference/local_inference_manager.dart';
import '../../core/memory/memory_manager.dart';
import '../../core/memory/memory_models.dart';
import '../../core/memory/rag_engine.dart';
import '../../core/network_audit.dart';
import '../../core/security/privacy_guard.dart';

class ChatMessage {
  const ChatMessage({required this.role, required this.text, this.streaming = false});

  final String role;
  final String text;
  final bool streaming;
}

class ChatController extends ChangeNotifier {
  ChatController({
    required PrivacyGuard privacyGuard,
    required NetworkAudit networkAudit,
    required MemoryManager memoryManager,
    LocalInferenceManager? inference,
    ToolRegistry? tools,
  })  : _privacyGuard = privacyGuard,
        _networkAudit = networkAudit,
        _memory = memoryManager,
        _rag = RagEngine(memoryManager),
        _inference = inference ?? LocalInferenceManager(),
        _execution = ExecutionManager(registry: tools ?? ToolRegistry());

  final PrivacyGuard _privacyGuard;
  final NetworkAudit _networkAudit;
  final MemoryManager _memory;
  final RagEngine _rag;
  final LocalInferenceManager _inference;
  final ExecutionManager _execution;
  final TaskPlanner _planner = TaskPlanner();

  final List<ChatMessage> _messages = <ChatMessage>[];
  StreamSubscription<String>? _generation;

  bool _isThinking = false;
  bool get isThinking => _isThinking;

  List<ChatMessage> get messages => List<ChatMessage>.unmodifiable(_messages);

  Future<void> submit(String prompt, {required bool approveSensitiveActions}) async {
    final input = prompt.trim();
    if (input.isEmpty) return;

    _messages.add(ChatMessage(role: 'user', text: input));
    _remember(input, MemoryType.shortTerm, priority: 10);

    final memorySummary = _memory.summarizeRecent();
    final plan = _planner.buildPlan(prompt: input, context: memorySummary);

    if (_privacyGuard.strictOffline &&
        plan.actions.any((action) => action.type.name == 'browserResearch')) {
      _networkAudit.log(
        endpoint: 'browserResearch',
        blocked: true,
        reason: 'Strict offline firewall mode',
      );
    }

    final executionReport = await _execution.run(plan, approved: approveSensitiveActions);
    _storeExecutionMemory(executionReport);

    final rag = _rag.retrieve(input);

    await _generateAssistantResponse(
      prompt: input,
      executionReport: executionReport,
      ragContext: rag.context,
    );
  }

  Future<void> _generateAssistantResponse({
    required String prompt,
    required ExecutionReport executionReport,
    required String ragContext,
  }) async {
    _isThinking = true;
    notifyListeners();

    final prefix = executionReport.success
        ? 'Execution completed. '
        : 'Execution failed at ${executionReport.failedAction?.id ?? 'unknown action'}. ';
    final fullPrompt = '$prefix User: $prompt\nContext: $ragContext';

    var response = '';
    _messages.add(const ChatMessage(role: 'assistant', text: '', streaming: true));

    _generation?.cancel();
    _generation = _inference
        .streamCompletion(prompt: fullPrompt, memoryContext: _memory.summarizeRecent())
        .listen((token) {
      response += token;
      _messages[_messages.length - 1] = ChatMessage(role: 'assistant', text: response, streaming: true);
      notifyListeners();
    }, onError: (_) {
      _messages[_messages.length - 1] = const ChatMessage(
        role: 'assistant',
        text: 'I could not complete response generation locally. Please verify model readiness.',
      );
      _isThinking = false;
      notifyListeners();
    }, onDone: () {
      _messages[_messages.length - 1] = ChatMessage(role: 'assistant', text: response);
      _remember(response, MemoryType.longTerm, priority: executionReport.success ? 6 : 8);
      _isThinking = false;
      notifyListeners();
    });

    if (!_privacyGuard.strictOffline && _privacyGuard.browserResearchEnabled) {
      _networkAudit.log(
        endpoint: 'browserResearch',
        blocked: false,
        reason: 'User enabled browser research mode',
      );
      _remember('Browser research allowed for this session.', MemoryType.semantic, priority: 4);
    }
  }

  void _storeExecutionMemory(ExecutionReport report) {
    for (final log in report.logs) {
      _remember(
        '${log.action.type.name}:${log.status.name}:${log.message}',
        MemoryType.semantic,
        priority: log.status == ExecutionStatus.failed ? 10 : 3,
      );
    }
  }

  void _remember(String text, MemoryType type, {required int priority}) {
    _memory.store(
      MemoryEntry(
        id: '${DateTime.now().microsecondsSinceEpoch}-$priority',
        text: text,
        type: type,
        createdAt: DateTime.now(),
        priority: priority,
      ),
    );
  }

  Future<void> cancel() => _inference.cancelGeneration();

  @override
  void dispose() {
    _generation?.cancel();
    super.dispose();
  }
}
