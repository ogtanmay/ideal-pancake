import 'assistant_action.dart';
import 'execution_models.dart';

class TaskPlanner {
  ExecutionPlan buildPlan({
    required String prompt,
    required String context,
  }) {
    final normalized = prompt.toLowerCase();
    final actions = <AssistantAction>[];

    if (normalized.contains('open') && normalized.contains('instagram')) {
      actions.add(
        const AssistantAction(
          id: 'open-instagram',
          type: AssistantActionType.appLauncher,
          payload: {'packageName': 'com.instagram.android'},
        ),
      );
      actions.add(
        const AssistantAction(
          id: 'navigate-chat',
          type: AssistantActionType.accessibilityAutomation,
          payload: {'command': 'open_messages'},
        ),
      );
    }

    if (normalized.contains('send') && normalized.contains('message')) {
      actions.add(
        AssistantAction(
          id: 'draft-message',
          type: AssistantActionType.sendMessage,
          payload: {
            'message': prompt,
            'context': context,
          },
          rollbackPayload: const {'command': 'clear_message_draft'},
        ),
      );
    }

    if (normalized.contains('summarize') && normalized.contains('.pdf')) {
      actions.add(
        const AssistantAction(
          id: 'read-pdf',
          type: AssistantActionType.pdfSummarizer,
          payload: {'mode': 'summary'},
        ),
      );
    }

    if (normalized.contains('clipboard')) {
      actions.add(
        const AssistantAction(
          id: 'clipboard-read',
          type: AssistantActionType.clipboardReader,
          payload: {'format': 'text'},
        ),
      );
    }

    if (normalized.contains('research') || normalized.contains('browse')) {
      actions.add(
        AssistantAction(
          id: 'browser-research',
          type: AssistantActionType.browserResearch,
          payload: {
            'url': normalized.contains('http') ? prompt : 'https://duckduckgo.com/',
          },
        ),
      );
    }

    if (actions.isEmpty) {
      actions.add(
        AssistantAction(
          id: 'local-search',
          type: AssistantActionType.localSearch,
          payload: {'query': prompt},
        ),
      );
    }

    return ExecutionPlan(
      intent: prompt,
      actions: actions,
      requiresConfirmation: actions.any((action) => action.isSensitive),
    );
  }
}
