import 'package:flutter/services.dart';

import 'assistant_action.dart';
import 'execution_models.dart';

class ToolRegistry {
  static const MethodChannel _channel = MethodChannel('offline_assistant/tools');

  Future<ActionExecutionResult> execute(AssistantAction action) async {
    try {
      final result = await _channel.invokeMapMethod<String, String>('execute', {
        'actionType': action.type.name,
        ...action.payload,
      });
      return ActionExecutionResult(
        status: ExecutionStatus.succeeded,
        message: result?['message'] ?? 'Action executed',
        data: result ?? const {},
      );
    } on PlatformException catch (e) {
      return ActionExecutionResult(
        status: ExecutionStatus.failed,
        message: e.message ?? e.code,
      );
    }
  }

  Future<void> rollback(AssistantAction action) async {
    if (action.rollbackPayload.isEmpty) return;
    await _channel.invokeMethod<void>('rollback', {
      'actionType': action.type.name,
      ...action.rollbackPayload,
    });
  }
}
