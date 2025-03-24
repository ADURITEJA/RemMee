plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.dementia_memory_app" // ✅ Keep only this, remove other namespace
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.dementia_memory_app"
        minSdk = 26
        targetSdk = 35
        versionCode = 1 // ✅ FIXED (Replace flutter.versionCode if needed)
        versionName = "1.0.0" // ✅ FIXED (Replace flutter.versionName if needed)
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17 // ✅ Fixed Syntax
        targetCompatibility = JavaVersion.VERSION_17 // ✅ Fixed Syntax
        isCoreLibraryDesugaringEnabled = true // ✅ Fixed Kotlin DSL Syntax
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.9.0")

    // ✅ Correctly use coreLibraryDesugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
