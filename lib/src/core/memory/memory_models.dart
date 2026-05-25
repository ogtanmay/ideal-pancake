enum MemoryType { shortTerm, longTerm, semantic }

class MemoryEntry {
  const MemoryEntry({
    required this.id,
    required this.text,
    required this.type,
    required this.createdAt,
    required this.priority,
  });

  final String id;
  final String text;
  final MemoryType type;
  final DateTime createdAt;
  final int priority;
}

class ScoredMemory {
  const ScoredMemory({required this.entry, required this.score});

  final MemoryEntry entry;
  final double score;
}
