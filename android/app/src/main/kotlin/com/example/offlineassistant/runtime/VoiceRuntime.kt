package com.example.offlineassistant.runtime

import java.util.concurrent.atomic.AtomicBoolean

class VoiceRuntime {
    private val wakeListening = AtomicBoolean(false)

    fun initialize(voskModelPath: String, piperModelPath: String, wakeWord: String) {
        require(voskModelPath.isNotBlank()) { "voskModelPath required" }
        require(piperModelPath.isNotBlank()) { "piperModelPath required" }
        require(wakeWord.isNotBlank()) { "wakeWord required" }
    }

    fun startWakeListener() {
        wakeListening.set(true)
    }

    fun stopWakeListener() {
        wakeListening.set(false)
    }

    fun transcribeStreaming(): String {
        check(wakeListening.get()) { "Wake listener is not running" }
        return ""
    }

    fun speak(text: String, interruptible: Boolean) {
        require(text.isNotBlank()) { "text required" }
        wakeListening.set(interruptible)
    }
}
