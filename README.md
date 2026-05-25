# Offline Assistant (Flutter + Kotlin)

Production-oriented Phase 1 foundation for a private Android AI operating assistant.

## Phase 1 scope (implemented)

- Clean modular Flutter architecture (`core`, `features`, repository/service layers)
- Dependency injection with `get_it`
- Encrypted local chat persistence (SQLCipher + app-keystore-managed keys)
- Strict offline privacy policy manager with persistent settings
- Local network audit data model + monitor UI
- Agent framework foundation:
  - action types and sensitive-action policy
  - planner
  - priority task queue
  - execution manager with retries and rollback
  - tool registry bridge to Android
- Local memory stack:
  - short-term, long-term, semantic memory
  - semantic index
  - lightweight offline RAG context injection
- Local inference pipeline contract:
  - model lifecycle
  - token streaming channel
  - cancellation
- Native Android foundation:
  - AccessibilityService base primitives
  - Quick Settings tile
  - secure activity (`FLAG_SECURE`)
  - strict network security config
- Premium dark UI shell with chat streaming, policy controls, model manager, privacy dashboard

## Architecture

```text
lib/src/
  core/
    agent/
    chat/
    di/
    inference/
    memory/
    model/
    network_audit.dart
    permissions/
    security/
    settings/
    storage/
  features/
    chat/
    models/
    network/
    privacy/
    settings/
    voice/
android/
  app/src/main/
    AndroidManifest.xml
    kotlin/com/example/offlineassistant/
      MainActivity.kt
      assistant/
      runtime/
    res/xml/
test/
```

## Security posture

- No analytics, telemetry, or cloud AI SDK usage in codebase.
- Chat content is encrypted before database write.
- SQLCipher database uses key material from secure storage.
- Sensitive task types (message send, delete, payment, social post, email send) require explicit approval.
- Strict offline mode can disable browser research and enforce local-only operation policy.

## Native inference integration contract (llama.cpp)

`android/app/src/main/kotlin/com/example/offlineassistant/runtime/LlamaBridge.kt` defines JNI calls:

- `nativeLoadModel(modelPath, threads, context)`
- `nativeGenerate(prompt, memoryContext)`
- `nativeCancel()`

`InferenceRuntime` manages threaded execution and token streaming over Flutter `EventChannel`.

To complete runtime wiring:

1. Add llama.cpp JNI shared library as `libllama_jni.so`
2. Implement JNI entry points matching `LlamaBridge`
3. Provide quantized GGUF files in local storage
4. Load model from Flutter model manager flow before first generation

## Build notes

This repository includes Android Gradle Kotlin DSL config and app module baseline files. In this environment, Flutter SDK is not installed, so compilation/tests cannot be executed here.

## GitHub Actions workflows

Two workflows are included for automated build validation:

- `.github/workflows/flutter-ci.yml`
  - Runs `flutter pub get`, `flutter analyze`, and `flutter test`
- `.github/workflows/android-build.yml`
  - Builds release APK with `flutter build apk --release`
  - Uploads `app-release.apk` as a workflow artifact

You can trigger both from pull requests, pushes, or manually using **workflow_dispatch** in the Actions tab.

When running locally:

```bash
flutter pub get
flutter test
flutter run -d <android-device>
flutter build apk --release
```
