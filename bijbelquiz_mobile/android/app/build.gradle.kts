import java.io.FileInputStream
import java.util.Base64
import java.util.Properties

// `--dart-define=APP_BRAND=biblequizzes` builds Bible Quizzes: own package name
// and app name. Without it this is BijbelQuiz, unchanged. Flutter hands the
// dart-defines to Gradle base64-encoded in the `dart-defines` property.
val dartDefines: Map<String, String> = (project.findProperty("dart-defines") as String?)
    ?.split(",")
    ?.mapNotNull { encoded ->
        val pair = String(Base64.getDecoder().decode(encoded)).split("=", limit = 2)
        if (pair.size == 2) pair[0] to pair[1] else null
    }
    ?.toMap() ?: emptyMap()
val isBibleQuizzes = dartDefines["APP_BRAND"] == "biblequizzes"

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.bijbelquiz.app"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // Required by flutter_local_notifications, which uses java.time to
        // schedule the streak reminder and needs it back-ported for minSdk 24.
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // Production package name for Google Play Store
        applicationId = if (isBibleQuizzes) "com.biblequizzes.app" else "com.bijbelquiz.app"
        manifestPlaceholders["appLabel"] = if (isBibleQuizzes) "Bible Quizzes" else "Bijbelquiz"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storeFile = keystoreProperties.getProperty("storeFile")?.let { file(it) }
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
