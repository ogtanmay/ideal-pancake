import 'assistant_action.dart';
import 'execution_models.dart';
import 'tool_registry.dart';

class ExecutionManager {
  ExecutionManager({required ToolRegistry registry, this.maxRetries = 2}) : _registry = registry;

  final ToolRegistry _registry;
  final int maxRetries;

  Future<ExecutionReport> run(ExecutionPlan plan, {required bool approved}) async {
    if (plan.requiresConfirmation && !approved) {
      return ExecutionReport(success: false, logs: const [], failedAction: plan.actions.first);
    }

    final logs = <ExecutionLogEntry>[];
    final completed = <AssistantAction>[];

    for (final action in plan.actions) {
      var attempt = 0;
      ActionExecutionResult result = const ActionExecutionResult(
        status: ExecutionStatus.failed,
        message: 'Action not started',
      );

      while (attempt <= maxRetries) {
        attempt += 1;
        result = await _registry.execute(action);
        logs.add(
          ExecutionLogEntry(
            action: action,
            status: result.status,
            timestamp: DateTime.now(),
            message: result.message,
            attempt: attempt,
          ),
        );
        if (result.isSuccess) {
          completed.add(action);
          break;
        }
      }

      if (!result.isSuccess) {
        await _rollback(completed, logs);
        return ExecutionReport(success: false, logs: logs, failedAction: action);
      }
    }

    return ExecutionReport(success: true, logs: logs, failedAction: null);
  }

  Future<void> _rollback(
    List<AssistantAction> completed,
    List<ExecutionLogEntry> logs,
  ) async {
    for (final action in completed.reversed) {
      await _registry.rollback(action);
      logs.add(
        ExecutionLogEntry(
          action: action,
          status: ExecutionStatus.rolledBack,
          timestamp: DateTime.now(),
          message: 'Rollback executed',
          attempt: 1,
        ),
      );
    }
  }
}
