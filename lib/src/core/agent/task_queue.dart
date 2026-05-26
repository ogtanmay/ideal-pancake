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

    final reorderedTasks = ListQueue<QueuedTask>();
    var inserted = false;
    while (_tasks.isNotEmpty) {
      final current = _tasks.removeFirst();
      if (!inserted && task.priority > current.priority) {
        reorderedTasks.addLast(task);
        inserted = true;
      }
      reorderedTasks.addLast(current);
    }

    if (!inserted) {
      reorderedTasks.addLast(task);
    }

    _tasks.addAll(reorderedTasks);
  }

  QueuedTask? dequeue() => _tasks.isEmpty ? null : _tasks.removeFirst();

  bool get isEmpty => _tasks.isEmpty;
  int get length => _tasks.length;
}
