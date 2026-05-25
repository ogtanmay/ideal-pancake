import 'package:flutter_test/flutter_test.dart';
import 'package:offline_assistant/src/core/agent/assistant_action.dart';
import 'package:offline_assistant/src/core/agent/task_planner.dart';

void main() {
  group('TaskPlanner', () {
    test('creates sensitive plan for instagram message instruction', () {
      final planner = TaskPlanner();

      final plan = planner.buildPlan(
        prompt: "Send a message to Rahul on Instagram saying I'll call later",
        context: 'rahul is colleague',
      );

      expect(plan.requiresConfirmation, isTrue);
      expect(plan.actions.any((a) => a.type == AssistantActionType.appLauncher), isTrue);
      expect(plan.actions.any((a) => a.type == AssistantActionType.sendMessage), isTrue);
    });

    test('routes unknown prompts to local search', () {
      final planner = TaskPlanner();

      final plan = planner.buildPlan(prompt: 'find invoice from march', context: '');

      expect(plan.requiresConfirmation, isFalse);
      expect(plan.actions.first.type, AssistantActionType.localSearch);
    });
  });
}
