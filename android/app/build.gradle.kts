import java.io.FileInputStream
import java.util.Base64
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

// Values passed with --dart-define / --dart-define-from-file, which Flutter
// forwards to Gradle base64-encoded.
val dartDefines: Map<String, String> =
    (project.findProperty("dart-defines") as String?)
        ?.split(",")
        ?.map { String(Base64.getDecoder().decode(it)).split("=", limit = 2) }
        ?.filter { it.size == 2 }
        ?.associate { it[0] to it[1] }
        ?: emptyMap()

android {
    namespace = "com.example.flutterweather"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // New listing: the original spanion.flutterweather.xyz signing key was lost.
        applicationId = "in.spanion.weather"
        minSdk = flutter.minSdkVersion
        // Google Play requires targeting Android 16 (API 36) from 31 Aug 2026.
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // Google's sample AdMob app ID serves test ads only.
        manifestPlaceholders["admobAppId"] =
            dartDefines["ADMOB_APP_ID"]?.takeIf { it.isNotBlank() } ?: "ca-app-pub-3940256099942544~3347511713"
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        release {
            // Falls back to debug keys when key.properties is absent so local release builds still run.
            signingConfig =
                if (keystorePropertiesFile.exists()) {
                    signingConfigs.getByName("release")
                } else {
                    signingConfigs.getByName("debug")
                }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // RemoteViewsCompat: collection widgets (the card stack) on every supported Android version.
    implementation("androidx.core:core-remoteviews:1.1.0")
}
