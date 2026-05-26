import 'dart:collection';

import 'execution_models.dart';

class QueuedTask {
  const QueuedTask({
    required this.id,
    required this.plan,
    required this.priority,
    required this.createdAt,
  });

  final String id;
  final ExecutionPlan plan;
  final int priority;
  final DateTime createdAt;
}

class TaskQueue {
  final ListQueue<QueuedTask> _tasks = ListQueue<QueuedTask>();

  void enqueue(QueuedTask task) {
    if (_tasks.isEmpty) {
      _tasks.add(task);
      return;
    }

    final orderedTasks = _tasks.toList();
    var insertIndex = orderedTasks.length;
    for (var i = 0; i < orderedTasks.length; i++) {
      if (task.priority > orderedTasks[i].priority) {
        insertIndex = i;
        break;
      }
    }
    orderedTasks.insert(insertIndex, task);
    _tasks
      ..clear()
      ..addAll(orderedTasks);
  }

  QueuedTask? dequeue() => _tasks.isEmpty ? null : _tasks.removeFirst();

  bool get isEmpty => _tasks.isEmpty;
  int get length => _tasks.length;
}
