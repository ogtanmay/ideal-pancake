import 'package:flutter_test/flutter_test.dart';
import 'package:offline_assistant/src/core/memory/memory_manager.dart';
import 'package:offline_assistant/src/core/memory/memory_models.dart';

void main() {
  test('semantic memory search returns relevant high priority memory first', () {
    final manager = MemoryManager();

    manager.store(
      MemoryEntry(
        id: '1',
        text: 'Rahul Instagram follow-up call later',
        type: MemoryType.semantic,
        createdAt: DateTime.now(),
        priority: 10,
      ),
    );

    manager.store(
      MemoryEntry(
        id: '2',
        text: 'buy groceries milk and eggs',
        type: MemoryType.semantic,
        createdAt: DateTime.now(),
        priority: 2,
      ),
    );

    final result = manager.semanticSearch('instagram rahul call', limit: 1);

    expect(result, isNotEmpty);
    expect(result.first.entry.id, '1');
  });
}
