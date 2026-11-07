import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release-Signierung: Codemagic legt android/key.properties aus den
// Signing-Einstellungen an (storeFile, storePassword, keyAlias, keyPassword).
// Lokal kann man die Datei selbst anlegen; sie ist in android/.gitignore.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}
val releaseSigningKeys = listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
val hasReleaseSigning = releaseSigningKeys.all { !keystoreProperties.getProperty(it).isNullOrBlank() }

// Auf dem Build-Server (CI=true) nie still mit dem Debug-Schlüssel signieren –
// Google Play lehnt so ein Bundle ab.
val isCi = System.getenv("CI")?.equals("true", ignoreCase = true) == true
if (isCi && !hasReleaseSigning && gradle.startParameter.taskNames.any { it.contains("Release", ignoreCase = true) }) {
    throw GradleException(
        "Release-Build ohne Signierschlüssel: android/key.properties fehlt oder ist unvollständig. " +
            "In Codemagic die Android-Code-Signierung für diese App einrichten.",
    )
}

android {
    namespace = "com.xy36.topflop"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.xy36.topflop"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // Ohne key.properties (lokal) mit dem Debug-Schlüssel, damit
            // `flutter run --release` weiter funktioniert.
            signingConfig = signingConfigs.getByName(if (hasReleaseSigning) "release" else "debug")
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
