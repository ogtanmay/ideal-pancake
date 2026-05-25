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

  Stream<String> streamCompletion({required String prompt, required String memoryContext}) async* {
    final stream = _streamChannel.receiveBroadcastStream({
      'event': 'token_stream',
      'prompt': prompt,
      'memoryContext': memoryContext,
    });
    await for (final token in stream) {
      if (token is String) {
        yield token;
      }
    }
  }

  Future<void> cancelGeneration() {
    return _channel.invokeMethod<void>('cancelGeneration');
  }
}
