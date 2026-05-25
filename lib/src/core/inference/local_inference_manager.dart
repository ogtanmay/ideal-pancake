import 'dart:async';

import 'package:flutter/services.dart';

class LocalInferenceManager {
  static const MethodChannel _channel = MethodChannel('offline_assistant/inference');
  static const EventChannel _streamChannel = EventChannel('offline_assistant/inference_stream');

  Future<void> loadModel(String modelPath, {int threads = 4, int context = 4096}) {
    return _channel.invokeMethod<void>('loadModel', {
      'modelPath': modelPath,
      'threads': threads,
      'context': context,
    });
  }

  Stream<String> streamCompletion({
    required String prompt,
    required String memoryContext,
  }) {
    late final StreamController<String> controller;
    StreamSubscription<dynamic>? sub;

    controller = StreamController<String>(
      onListen: () async {
        sub = _streamChannel.receiveBroadcastStream().listen(
          (event) {
            if (event is String) controller.add(event);
          },
          onError: controller.addError,
          onDone: controller.close,
        );
        try {
          await _channel.invokeMethod<void>('startGeneration', {
            'prompt': prompt,
            'memoryContext': memoryContext,
          });
        } catch (e) {
          await sub?.cancel();
          controller.addError(e);
          await controller.close();
        }
      },
      onCancel: () async {
        await sub?.cancel();
      },
    );

    return controller.stream;
  }

  Future<void> cancelGeneration() {
    return _channel.invokeMethod<void>('cancelGeneration');
  }
}
