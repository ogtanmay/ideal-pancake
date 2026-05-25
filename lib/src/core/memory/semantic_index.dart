import 'dart:math';

class SemanticIndex {
  final Map<String, List<double>> _vectors = <String, List<double>>{};

  void index(String id, String text) {
    _vectors[id] = _embed(text);
  }

  List<String> search(String query, {int limit = 5}) {
    final queryVec = _embed(query);
    final scored = _vectors.entries
        .map((entry) => MapEntry(entry.key, _cosine(queryVec, entry.value)))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return scored.take(limit).where((e) => e.value > 0).map((e) => e.key).toList();
  }

  List<double> _embed(String text) {
    final vec = List<double>.filled(32, 0);
    final tokens = text.toLowerCase().split(RegExp(r'\W+')).where((t) => t.isNotEmpty);
    for (final token in tokens) {
      final index = token.hashCode.abs() % vec.length;
      vec[index] += 1;
    }
    final norm = sqrt(vec.fold<double>(0, (sum, value) => sum + value * value));
    if (norm == 0) return vec;
    return vec.map((value) => value / norm).toList();
  }

  double _cosine(List<double> a, List<double> b) {
    var dot = 0.0;
    for (var i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
    }
    return dot;
  }
}
