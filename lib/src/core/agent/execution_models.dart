import 'assistant_action.dart';

enum ExecutionStatus { queued, running, succeeded, failed, rolledBack }

class ExecutionPlan {
  const ExecutionPlan({
    required this.intent,
    required this.actions,
    required this.requiresConfirmation,
  });

  final String intent;
  final List<AssistantAction> actions;
  final bool requiresConfirmation;
}

class ActionExecutionResult {
  const ActionExecutionResult({
    required this.status,
    required this.message,
    this.data = const {},
  });

  final ExecutionStatus status;
  final String message;
  final Map<String, String> data;

  bool get isSuccess => status == ExecutionStatus.succeeded;
}

class ExecutionLogEntry {
  const ExecutionLogEntry({
    required this.action,
    required this.status,
    required this.timestamp,
    required this.message,
    required this.attempt,
  });

  final AssistantAction action;
  final ExecutionStatus status;
  final DateTime timestamp;
  final String message;
  final int attempt;
}

class ExecutionReport {
  const ExecutionReport({
    required this.success,
    required this.logs,
    required this.failedAction,
  });

  final bool success;
  final List<ExecutionLogEntry> logs;
  final AssistantAction? failedAction;
}
