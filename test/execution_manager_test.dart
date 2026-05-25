import 'package:flutter_test/flutter_test.dart';
import 'package:offline_assistant/src/core/agent/assistant_action.dart';
import 'package:offline_assistant/src/core/agent/execution_manager.dart';
import 'package:offline_assistant/src/core/agent/execution_models.dart';
import 'package:offline_assistant/src/core/agent/tool_registry.dart';

class _FakeRegistry extends ToolRegistry {
  _FakeRegistry(this.behavior);

  final Map<String, List<bool>> behavior;
  final List<String> rollbacks = [];

  @override
  Future<ActionExecutionResult> execute(AssistantAction action) async {
    final outcomes = behavior[action.id] ?? [true];
    final attempt = outcomes.removeAt(0);
    return ActionExecutionResult(
      status: attempt ? ExecutionStatus.succeeded : ExecutionStatus.failed,
      message: attempt ? 'ok' : 'fail',
    );
  }

  @override
  Future<void> rollback(AssistantAction action) async {
    rollbacks.add(action.id);
  }
}

void main() {
  test('execution manager retries and rollbacks on failure', () async {
    final registry = _FakeRegistry({
      'a1': [true],
      'a2': [false, false, false],
    });

    final manager = ExecutionManager(registry: registry, maxRetries: 2);
    final report = await manager.run(
      ExecutionPlan(
        intent: 'test',
        requiresConfirmation: false,
        actions: const [
          AssistantAction(id: 'a1', type: AssistantActionType.localSearch, payload: {}),
          AssistantAction(id: 'a2', type: AssistantActionType.localSearch, payload: {}),
        ],
      ),
      approved: true,
    );

    expect(report.success, isFalse);
    expect(report.failedAction?.id, 'a2');
    expect(registry.rollbacks, ['a1']);
  });
}
