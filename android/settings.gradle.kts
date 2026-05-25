pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            val localPropertiesFile = file("local.properties")
            require(localPropertiesFile.exists()) {
                "local.properties file not found. Run Flutter commands to generate it."
            }
            localPropertiesFile.inputStream().use { properties.load(it) }
            val sdkPath = properties.getProperty("flutter.sdk")
            require(!sdkPath.isNullOrBlank()) { "flutter.sdk not set in local.properties" }
            sdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "offline_assistant"
include(":app")
