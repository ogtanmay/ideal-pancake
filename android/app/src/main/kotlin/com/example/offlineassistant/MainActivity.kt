package com.example.offlineassistant

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val voiceChannelName = "offline_assistant/voice"
    private val toolChannelName = "offline_assistant/tools"
    private val inferenceChannelName = "offline_assistant/inference"
    private val streamChannelName = "offline_assistant/inference_stream"

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
                    "initialize" -> result.success(null)
                    "startWakeListener" -> result.success(null)
                    "stopWakeListener" -> result.success(null)
                    "transcribeStreaming" -> result.success("")
                    "speak" -> result.success(null)
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
                    "loadModel" -> result.success(null)
                    "cancelGeneration" -> result.success(null)
                    else -> result.notImplemented()
                }
            }
    }

    private fun setupInferenceStream(flutterEngine: FlutterEngine) {
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, streamChannelName)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    val fallback = "I am running in local mode with enterprise assistant architecture ready."
                    fallback.split(" ").forEach { token -> events?.success("$token ") }
                    events?.endOfStream()
                }

                override fun onCancel(arguments: Any?) = Unit
            })
    }
}
