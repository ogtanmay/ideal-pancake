import 'package:flutter/material.dart';

import '../../core/inference/local_inference_manager.dart';
import '../../core/model/model_registry.dart';

class ModelManagerScreen extends StatefulWidget {
  const ModelManagerScreen({
    super.key,
    required this.registry,
    required this.inferenceManager,
  });

  final ModelRegistry registry;
  final LocalInferenceManager inferenceManager;

  @override
  State<ModelManagerScreen> createState() => _ModelManagerScreenState();
}

class _ModelManagerScreenState extends State<ModelManagerScreen> {
  bool _loading = false;
  String _status = 'No model loaded for runtime yet';

  Future<void> _activateAndLoad(String id) async {
    setState(() {
      _loading = true;
      _status = 'Loading model...';
    });
    try {
      widget.registry.activate(id);
      final active = widget.registry.active();
      await widget.inferenceManager.loadModel(
        active.path,
        threads: 4,
        context: active.contextWindow,
      );
      if (!mounted) return;
      setState(() {
        _status = 'Loaded: ${active.name}';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = 'Load failed: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final models = widget.registry.all();
    final active = widget.registry.active().id;
    return SafeArea(
      child: ListView(
        children: [
          ListTile(
            title: Text('Offline Model Manager'),
            subtitle: Text('GGUF model import, compatibility, and runtime switching\n$_status'),
          ),
          if (_loading) const LinearProgressIndicator(minHeight: 2),
          ...models.map(
            (model) => RadioListTile<String>(
              value: model.id,
              groupValue: active,
              onChanged: (value) {
                if (value == null) return;
                _activateAndLoad(value);
              },
              title: Text(model.name),
              subtitle: Text(
                '${model.quantization} • ${model.estimatedRamMb}MB RAM • ctx ${model.contextWindow}',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
