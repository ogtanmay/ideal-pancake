package com.example.offlineassistant.runtime

import io.flutter.plugin.common.EventChannel
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.concurrent.atomic.AtomicBoolean

class InferenceRuntime {
    private val executor: ExecutorService = Executors.newSingleThreadExecutor()
    private val canceled = AtomicBoolean(false)

    @Volatile
    private var modelLoaded = false

    @Volatile
    private var streamSink: EventChannel.EventSink? = null

    fun attachSink(sink: EventChannel.EventSink?) {
        streamSink = sink
    }

    fun loadModel(modelPath: String, threads: Int, context: Int) {
        if (!LlamaBridge.isAvailable()) {
            throw IllegalStateException("llama_jni is not available. Bundle llama.cpp JNI library.")
        }
        modelLoaded = LlamaBridge.nativeLoadModel(modelPath, threads, context)
        if (!modelLoaded) {
            throw IllegalStateException("Model loading failed for path: $modelPath")
        }
    }

    fun startGeneration(prompt: String, memoryContext: String) {
        if (!modelLoaded) {
            throw IllegalStateException("No model loaded. Call loadModel before generation.")
        }

        canceled.set(false)

        executor.execute {
            runCatching {
                val output = LlamaBridge.nativeGenerate(prompt, memoryContext)
                if (canceled.get()) return@runCatching
                output.split(" ").forEach { token ->
                    if (!canceled.get()) {
                        streamSink?.success("$token ")
                    }
                }
                streamSink?.endOfStream()
            }.onFailure { throwable ->
                streamSink?.error("inference_failed", throwable.message, null)
            }
        }
    }

    fun cancelGeneration() {
        canceled.set(true)
        if (LlamaBridge.isAvailable()) {
            runCatching { LlamaBridge.nativeCancel() }
        }
    }

    fun shutdown() {
        cancelGeneration()
        executor.shutdownNow()
    }
}
