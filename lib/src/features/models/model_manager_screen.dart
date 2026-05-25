import 'package:flutter/material.dart';

import '../../core/model/model_registry.dart';

class ModelManagerScreen extends StatefulWidget {
  const ModelManagerScreen({super.key, required this.registry});

  final ModelRegistry registry;

  @override
  State<ModelManagerScreen> createState() => _ModelManagerScreenState();
}

class _ModelManagerScreenState extends State<ModelManagerScreen> {
  @override
  Widget build(BuildContext context) {
    final models = widget.registry.all();
    final active = widget.registry.active().id;
    return SafeArea(
      child: ListView(
        children: [
          const ListTile(
            title: Text('Offline Model Manager'),
            subtitle: Text('GGUF model import, compatibility, and runtime switching'),
          ),
          ...models.map(
            (model) => RadioListTile<String>(
              value: model.id,
              groupValue: active,
              onChanged: (value) {
                if (value == null) return;
                setState(() => widget.registry.activate(value));
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
