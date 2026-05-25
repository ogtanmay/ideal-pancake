# Offline Assistant (Flutter + Android Kotlin)

This repository contains a production-oriented offline Android AI assistant foundation designed for local-first privacy.

## Core product goals implemented here

- Strict offline-first architecture with privacy controls and local-only defaults
- Agent execution stack with planning, queueing model, retries, rollback, and approval-gated sensitive actions
- Local memory system with short-term + long-term + semantic memory and offline semantic retrieval
- Lightweight local RAG context assembly from indexed memories
- Flutter Material 3 multi-screen app with modern dark UI, animated responses, and streaming assistant output
- Kotlin bridge for Android integrations (app launch, accessibility hooks, quick settings tile, voice and inference channels)
- Network security config and app policy defaults to minimize accidental network exposure
- GGUF model metadata registry for local model lifecycle and runtime switching

## Architecture

```text
lib/src/
  core/
    agent/
      assistant_action.dart
      task_planner.dart
      task_queue.dart
      execution_manager.dart
      tool_registry.dart
      execution_models.dart
    memory/
      memory_models.dart
      semantic_index.dart
      memory_manager.dart
      rag_engine.dart
    inference/
      local_inference_manager.dart
    security/
      privacy_guard.dart
    model/
      model_registry.dart
    network_audit.dart
  features/
    chat/
      chat_controller.dart
      chat_screen.dart
    models/model_manager_screen.dart
    network/network_monitor_screen.dart
    privacy/privacy_dashboard_screen.dart
    settings/settings_screen.dart
    voice/voice_service.dart
  app.dart
lib/main.dart
android/app/src/main/
  AndroidManifest.xml
  kotlin/com/example/offlineassistant/
    MainActivity.kt
    assistant/
      AssistantAccessibilityService.kt
      AssistantQuickSettingsTileService.kt
  res/xml/
    accessibility_service_config.xml
    network_security_config.xml
test/
  task_planner_test.dart
  execution_manager_test.dart
  memory_manager_test.dart
```

## Safety model

Sensitive actions (send message, email send, social post, delete file, payment) are flagged by planner policy and require explicit user approval before execution.

Execution manager behavior:

1. Build action plan from prompt + contextual memory
2. Enforce confirmation policy
3. Execute steps via internal tool channel
4. Retry failed steps (`maxRetries`)
5. Roll back already-completed steps when terminal failure occurs
6. Persist execution traces into semantic memory for future contextual decisions

## Local memory and retrieval

- `MemoryManager` stores prioritized short-term, long-term, and semantic entries
- `SemanticIndex` performs fully offline vector-style retrieval via deterministic local embeddings
- `RagEngine` injects relevant local context into generation prompt

## Android integrations

Implemented native channels:

- `offline_assistant/tools` for internal action engine calls
- `offline_assistant/voice` for Vosk/Piper lifecycle hooks
- `offline_assistant/inference` for model lifecycle hooks
- `offline_assistant/inference_stream` for token streaming transport

Accessibility service includes practical primitives:

- click by text
- input text into focused field
- gesture tap dispatch

Quick Settings tile scaffold included for fast assistant activation.

## Build and run

1. Install Flutter stable and Android SDK
2. Run `flutter pub get`
3. Run `flutter run -d <android-device-id>`
4. Release build: `flutter build apk --release`

## Integrating real local inference runtime (llama.cpp + GGUF)

1. Build llama.cpp JNI library for target ABIs
2. Connect JNI calls in `MainActivity` inference handlers:
   - `loadModel`
   - streaming token callbacks into `EventChannel`
   - cancellation pathway
3. Keep model files in app-private storage or SAF-granted URI locations
4. Use quantized models (Phi-3 Mini/Gemma 2B GGUF) for mid-range phones

## Integrating voice runtime (Vosk + Piper)

1. Bundle/download local STT and TTS models once
2. Wire native voice channel methods to Vosk and Piper engines
3. Support wake listener loop + interruptible TTS playback

## Privacy posture in this repository

- No Firebase, telemetry, analytics, ad SDK, or cloud AI API code included
- Strict offline mode available in settings
- Browser research mode is disabled by default and cannot be enabled while strict offline mode is active
- Network inspection screen included for local audit visibility

