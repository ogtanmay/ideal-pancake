import 'package:flutter_test/flutter_test.dart';
import 'package:offline_assistant/src/core/agent/execution_models.dart';
import 'package:offline_assistant/src/core/agent/task_queue.dart';

void main() {
  test('task queue dequeues by priority', () {
    final queue = TaskQueue();

    queue.enqueue(
      QueuedTask(
        id: 'low',
        priority: 1,
        createdAt: DateTime.now(),
        plan: const ExecutionPlan(intent: 'a', actions: [], requiresConfirmation: false),
      ),
    );
    queue.enqueue(
      QueuedTask(
        id: 'high',
        priority: 10,
        createdAt: DateTime.now(),
        plan: const ExecutionPlan(intent: 'b', actions: [], requiresConfirmation: false),
      ),
    );

    expect(queue.dequeue()?.id, 'high');
    expect(queue.dequeue()?.id, 'low');
  });
}
