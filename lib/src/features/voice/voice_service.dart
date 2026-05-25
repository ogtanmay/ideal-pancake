import 'package:flutter/services.dart';

class VoiceService {
  static const MethodChannel _channel = MethodChannel('offline_assistant/voice');

  Future<void> initialize({
    required String voskModelPath,
    required String piperModelPath,
    required String wakeWord,
  }) async {
    await _channel.invokeMethod<void>('initialize', {
      'voskModelPath': voskModelPath,
      'piperModelPath': piperModelPath,
      'wakeWord': wakeWord,
    });
  }

  Future<void> startWakeListener() => _channel.invokeMethod<void>('startWakeListener');

  Future<void> stopWakeListener() => _channel.invokeMethod<void>('stopWakeListener');

  Future<String> transcribeStreaming() async {
    final text = await _channel.invokeMethod<String>('transcribeStreaming');
    return text ?? '';
  }

  Future<void> speak(String text, {bool interruptible = true}) {
    return _channel.invokeMethod<void>('speak', {
      'text': text,
      'interruptible': interruptible,
    });
  }
}
