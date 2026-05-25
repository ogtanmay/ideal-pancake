import 'memory_manager.dart';

class RagResult {
  const RagResult({required this.context, required this.sources});

  final String context;
  final List<String> sources;
}

class RagEngine {
  RagEngine(this._memoryManager);

  final MemoryManager _memoryManager;

  RagResult retrieve(String query) {
    final memories = _memoryManager.semanticSearch(query, limit: 6);
    final context = memories.map((memory) => memory.entry.text).join('\n');
    final sources = memories.map((memory) => memory.entry.id).toList();
    return RagResult(context: context, sources: sources);
  }
}
