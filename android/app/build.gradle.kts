plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.domicert"
    compileSdk = 35
    ndkVersion = "29.0.13113456"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
        freeCompilerArgs += listOf("-Xjvm-default=all")
    }

    defaultConfig {
        applicationId = "com.example.domicert"
        minSdk = 23
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:33.13.0"))
    
    // Add Firebase Analytics
    implementation("com.google.firebase:firebase-analytics")
    
    // Add Firebase Auth
    implementation("com.google.firebase:firebase-auth")
    
    // Add Firestore
    implementation("com.google.firebase:firebase-firestore")
    
    // Add Google Sign-In
    implementation("com.google.android.gms:play-services-auth:21.0.0")
}

flutter {
    source = "../.."
}
