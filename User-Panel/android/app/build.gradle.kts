import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
} else {
    throw GradleException("key.properties file NOT FOUND at: ${keystorePropertiesFile.absolutePath}")
}

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}
android {
    namespace = "com.bullwave.rides.user"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }
    defaultConfig {
        applicationId = "com.bullwave.rides.user"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
                ?: throw GradleException("keyAlias missing in key.properties")
            keyPassword = keystoreProperties.getProperty("keyPassword")
                ?: throw GradleException("keyPassword missing in key.properties")
            storeFile = file(keystoreProperties.getProperty("storeFile")
                ?: throw GradleException("storeFile missing in key.properties"))
            storePassword = keystoreProperties.getProperty("storePassword")
                ?: throw GradleException("storePassword missing in key.properties")
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
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
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
if (file("google-services.json").exists()) {
    apply(plugin = "com.google.gms.google-services")
}