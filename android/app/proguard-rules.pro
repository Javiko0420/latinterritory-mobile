# Flutter core
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**
-keepattributes *Annotation*

# just_audio_background + audio_service (com.ryanheise.*)
# R8 must not remove or rename these — the AudioService is bound by the OS
# via the manifest entry and uses reflection internally.
-keep class com.ryanheise.** { *; }
-keepclassmembers class com.ryanheise.** { *; }

# just_audio uses ExoPlayer under the hood
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn com.google.android.exoplayer2.**

# flutter_secure_storage — uses EncryptedSharedPreferences via reflection
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# google_sign_in
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# google_sign_in 7.x — Credential Manager (androidx.credentials) + googleid.
# R8 must not strip these: GoogleIdTokenCredential is parsed via reflection
# from the credential bundle, and the play-services bridge is loaded lazily.
-if class androidx.credentials.CredentialManager
-keep class androidx.credentials.playservices.** { *; }
-keep class com.google.android.libraries.identity.googleid.** { *; }
-dontwarn androidx.credentials.**

# connectivity_plus
-keep class dev.fluttercommunity.plus.connectivity.** { *; }

# package_info_plus
-keep class dev.fluttercommunity.plus.packageinfo.** { *; }

# image_picker
-keep class io.flutter.plugins.imagepicker.** { *; }

# url_launcher
-keep class io.flutter.plugins.urllauncher.** { *; }

# shared_preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Kotlin coroutines (used by several plugins)
-keepclassmembernames class kotlinx.** {
    volatile <fields>;
}
-dontwarn kotlinx.coroutines.**
