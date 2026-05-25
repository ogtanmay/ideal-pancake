class ModelMetadata {
  const ModelMetadata({
    required this.id,
    required this.name,
    required this.path,
    required this.quantization,
    required this.estimatedRamMb,
    required this.contextWindow,
  });

  final String id;
  final String name;
  final String path;
  final String quantization;
  final int estimatedRamMb;
  final int contextWindow;
}

class ModelRegistry {
  final List<ModelMetadata> _models = <ModelMetadata>[
    const ModelMetadata(
      id: 'phi3-mini-q4km',
      name: 'Phi-3 Mini Instruct',
      path: '/storage/emulated/0/OfflineAssistant/models/phi3-mini-q4_k_m.gguf',
      quantization: 'Q4_K_M',
      estimatedRamMb: 1800,
      contextWindow: 4096,
    ),
  ];

  String _active = 'phi3-mini-q4km';

  List<ModelMetadata> all() => List<ModelMetadata>.unmodifiable(_models);

  ModelMetadata active() => _models.firstWhere((m) => m.id == _active);

  void upsert(ModelMetadata model) {
    final index = _models.indexWhere((m) => m.id == model.id);
    if (index >= 0) {
      _models[index] = model;
    } else {
      _models.add(model);
    }
  }

  void activate(String id) {
    if (!_models.any((m) => m.id == id)) {
      throw ArgumentError.value(id, 'id', 'Unknown model id');
    }
    _active = id;
  }

  void remove(String id) {
    _models.removeWhere((m) => m.id == id);
    if (_models.isNotEmpty && !_models.any((m) => m.id == _active)) {
      _active = _models.first.id;
    }
  }
}
