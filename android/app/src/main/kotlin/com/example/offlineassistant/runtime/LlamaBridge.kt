package com.example.offlineassistant.runtime

object LlamaBridge {
    private var loaded = false

    init {
        loaded = runCatching {
            System.loadLibrary("llama_jni")
            true
        }.getOrDefault(false)
    }

    fun isAvailable(): Boolean = loaded

    external fun nativeLoadModel(modelPath: String, threads: Int, context: Int): Boolean
    external fun nativeGenerate(prompt: String, memoryContext: String): String
    external fun nativeCancel()
}
