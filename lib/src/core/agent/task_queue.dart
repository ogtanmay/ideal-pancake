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

    var inserted = false;
    final initialLength = _tasks.length;
    for (var i = 0; i < initialLength; i++) {
      final current = _tasks.removeFirst();
      if (!inserted && task.priority > current.priority) {
        _tasks.addLast(task);
        inserted = true;
      }
      _tasks.addLast(current);
    }

    if (!inserted) {
      _tasks.addLast(task);
    }
  }

  QueuedTask? dequeue() => _tasks.isEmpty ? null : _tasks.removeFirst();

  bool get isEmpty => _tasks.isEmpty;
  int get length => _tasks.length;
}
