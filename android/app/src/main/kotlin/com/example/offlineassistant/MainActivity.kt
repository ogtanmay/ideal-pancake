package com.example.offlineassistant

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.view.WindowManager
import com.example.offlineassistant.runtime.InferenceRuntime
import com.example.offlineassistant.runtime.VoiceRuntime
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val voiceChannelName = "offline_assistant/voice"
    private val toolChannelName = "offline_assistant/tools"
    private val inferenceChannelName = "offline_assistant/inference"
    private val streamChannelName = "offline_assistant/inference_stream"
    private val inferenceRuntime = InferenceRuntime()
    private val voiceRuntime = VoiceRuntime()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        setupVoiceChannel(flutterEngine)
        setupToolChannel(flutterEngine)
        setupInferenceChannel(flutterEngine)
        setupInferenceStream(flutterEngine)
    }

    private fun setupVoiceChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, voiceChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "initialize" -> {
                        val voskModelPath = call.argument<String>("voskModelPath").orEmpty()
                        val piperModelPath = call.argument<String>("piperModelPath").orEmpty()
                        val wakeWord = call.argument<String>("wakeWord").orEmpty()
                        runCatching {
                            voiceRuntime.initialize(voskModelPath, piperModelPath, wakeWord)
                        }.onSuccess {
                            result.success(null)
                        }.onFailure {
                            result.error("voice_initialize_failed", it.message, null)
                        }
                    }
                    "startWakeListener" -> {
                        runCatching {
                            voiceRuntime.startWakeListener()
                        }.onSuccess {
                            result.success(null)
                        }.onFailure {
                            result.error("voice_start_failed", it.message, null)
                        }
                    }
                    "stopWakeListener" -> {
                        runCatching {
                            voiceRuntime.stopWakeListener()
                        }.onSuccess {
                            result.success(null)
                        }.onFailure {
                            result.error("voice_stop_failed", it.message, null)
                        }
                    }
                    "transcribeStreaming" -> {
                        runCatching {
                            voiceRuntime.transcribeStreaming()
                        }.onSuccess {
                            result.success(it)
                        }.onFailure {
                            result.error("voice_transcribe_failed", it.message, null)
                        }
                    }
                    "speak" -> {
                        val text = call.argument<String>("text").orEmpty()
                        val interruptible = call.argument<Boolean>("interruptible") ?: true
                        runCatching {
                            voiceRuntime.speak(text, interruptible)
                        }.onSuccess {
                            result.success(null)
                        }.onFailure {
                            result.error("voice_speak_failed", it.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun setupToolChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, toolChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "execute" -> {
                        val args = call.arguments as? Map<*, *> ?: emptyMap<String, String>()
                        val actionType = args["actionType"]?.toString() ?: ""
                        when (actionType) {
                            "appLauncher" -> {
                                val packageName = args["packageName"]?.toString()
                                if (packageName.isNullOrBlank()) {
                                    result.error("invalid_args", "packageName required", null)
                                    return@setMethodCallHandler
                                }
                                val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
                                if (launchIntent != null) {
                                    startActivity(launchIntent)
                                    result.success(mapOf("message" to "Launched $packageName"))
                                } else {
                                    result.error("launch_failed", "Package not found", null)
                                }
                            }
                            "browserResearch" -> {
                                val url = args["url"]?.toString() ?: "https://www.google.com"
                                startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))
                                result.success(mapOf("message" to "Opened browser"))
                            }
                            else -> {
                                result.success(mapOf("message" to "Action queued for accessibility engine"))
                            }
                        }
                    }
                    "rollback" -> result.success(null)
                    else -> result.notImplemented()
                }
            }
    }

    private fun setupInferenceChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, inferenceChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "loadModel" -> {
                        val modelPath = call.argument<String>("modelPath").orEmpty()
                        val threads = call.argument<Int>("threads") ?: 4
                        val context = call.argument<Int>("context") ?: 4096
                        runCatching {
                            inferenceRuntime.loadModel(modelPath, threads, context)
                        }.onSuccess {
                            result.success(null)
                        }.onFailure {
                            result.error("load_model_failed", it.message, null)
                        }
                    }
                    "startGeneration" -> {
                        val prompt = call.argument<String>("prompt").orEmpty()
                        val memoryContext = call.argument<String>("memoryContext").orEmpty()
                        runCatching {
                            inferenceRuntime.startGeneration(prompt, memoryContext)
                        }.onSuccess {
                            result.success(null)
                        }.onFailure {
                            result.error("generation_failed", it.message, null)
                        }
                    }
                    "cancelGeneration" -> {
                        inferenceRuntime.cancelGeneration()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun setupInferenceStream(flutterEngine: FlutterEngine) {
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, streamChannelName)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    inferenceRuntime.attachSink(events)
                }

                override fun onCancel(arguments: Any?) {
                    inferenceRuntime.attachSink(null)
                }
            })
    }

    override fun onDestroy() {
        super.onDestroy()
        inferenceRuntime.shutdown()
    }
}
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }
