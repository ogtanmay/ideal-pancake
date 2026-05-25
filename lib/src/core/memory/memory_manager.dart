import 'memory_models.dart';
import 'semantic_index.dart';

class MemoryManager {
  MemoryManager() : _semanticIndex = SemanticIndex();

  final SemanticIndex _semanticIndex;
  final Map<String, MemoryEntry> _entries = <String, MemoryEntry>{};

  void store(MemoryEntry entry) {
    _entries[entry.id] = entry;
    _semanticIndex.index(entry.id, entry.text);
  }

  List<MemoryEntry> shortTerm({int limit = 20}) {
    final entries = _entries.values
        .where((entry) => entry.type == MemoryType.shortTerm)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entries.take(limit).toList();
  }

  List<ScoredMemory> semanticSearch(String query, {int limit = 5}) {
    final ids = _semanticIndex.search(query, limit: limit * 2);
    final scored = <ScoredMemory>[];
    for (final id in ids) {
      final entry = _entries[id];
      if (entry == null) continue;
      final score = _scorePriority(entry);
      scored.add(ScoredMemory(entry: entry, score: score));
    }
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.take(limit).toList();
  }

  String summarizeRecent({int maxChars = 600}) {
    final items = shortTerm(limit: 8).map((e) => e.text).join(' | ');
    if (items.length <= maxChars) return items;
    return '${items.substring(0, maxChars)}...';
  }

  double _scorePriority(MemoryEntry entry) {
    final ageMinutes = DateTime.now().difference(entry.createdAt).inMinutes.clamp(1, 100000);
    return entry.priority * 100 / ageMinutes;
  }
}
