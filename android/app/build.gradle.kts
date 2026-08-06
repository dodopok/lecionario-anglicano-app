import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// The upload key lives outside the repository and is described by
// android/key.properties, which is gitignored — see key.properties.example and
// docs/play-console.md. When it is absent the release build falls back to the
// debug key so `flutter run --release` still works; the Play Console rejects
// anything signed that way, and tool/verify_android_release.sh refuses to build
// a bundle for upload without it.
val signing = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) {
        file.inputStream().use { load(it) }
    }
}

android {
    namespace = "br.com.caminhoanglicano.lecionario_anglicano"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // Fixed for the lifetime of the listing: Play identifies the app by
        // this and it can never be changed once a build has been uploaded.
        applicationId = "br.com.caminhoanglicano.lecionario_anglicano"
        minSdk = flutter.minSdkVersion
        // Play refuses a release targeting an API level older than the one it
        // is currently enforcing, so the floor is stated here rather than left
        // to whichever Flutter SDK happens to build it. Raising the floor each
        // August is part of the release checklist.
        targetSdk = maxOf(flutter.targetSdkVersion, 35)
        // Both come from the version in pubspec.yaml; tool/version.sh moves it.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = signing.getProperty("keyAlias")
            keyPassword = signing.getProperty("keyPassword")
            storeFile = signing.getProperty("storeFile")?.let { file(it) }
            storePassword = signing.getProperty("storePassword")
        }
    }

    buildTypes {
        release {
            signingConfig = if (signing.isEmpty) {
                logger.warn(
                    "android/key.properties is missing: signing the release " +
                        "with the debug key. The Play Console will reject it."
                )
                signingConfigs.getByName("debug")
            } else {
                signingConfigs.getByName("release")
            }
        }
    }

    bundle {
        language {
            // The app carries its three languages in the Dart bundle and lets
            // the reader switch between them in Settings. A language split
            // would have Play deliver only the one the device is set to, and
            // the other two would be missing from the very screen that offers
            // them.
            enableSplit = false
        }
    }
}

flutter {
    source = "../.."
}
