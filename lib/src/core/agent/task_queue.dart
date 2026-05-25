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
    for (var i = 0; i < _tasks.length; i++) {
      final current = _tasks.elementAt(i);
      if (task.priority > current.priority) {
        _tasks.insert(i, task);
        inserted = true;
        break;
      }
    }

    if (!inserted) {
      _tasks.add(task);
    }
  }

  QueuedTask? dequeue() => _tasks.isEmpty ? null : _tasks.removeFirst();

  bool get isEmpty => _tasks.isEmpty;
  int get length => _tasks.length;
}
