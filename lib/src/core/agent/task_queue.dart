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
  final List<QueuedTask> _tasks = <QueuedTask>[];

  void enqueue(QueuedTask task) {
    if (_tasks.isEmpty) {
      _tasks.add(task);
      return;
    }

    var insertIndex = _tasks.length;
    for (var i = 0; i < _tasks.length; i++) {
      if (task.priority > _tasks[i].priority) {
        insertIndex = i;
        break;
      }
    }
    _tasks.insert(insertIndex, task);
  }

  QueuedTask? dequeue() => _tasks.isEmpty ? null : _tasks.removeAt(0);

  bool get isEmpty => _tasks.isEmpty;
  int get length => _tasks.length;
}
