# Flutter Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep native methods and JNI bindings
-keepclasseswithmembernames class * {
    native <methods>;
}

# Zoom SDK ProGuard Rules
-keep class us.zoom.** { *; }
-keep interface us.zoom.** { *; }
-keep class com.zipow.** { *; }
-keep interface com.zipow.** { *; }
-keep class org.webrtc.** { *; }
-keep interface org.webrtc.** { *; }
-dontwarn us.zoom.**
-dontwarn com.zipow.**
-dontwarn org.webrtc.**

# Keep our MainActivity Zoom bindings
-keep class com.abtechnologies.fitHer.MainActivity { *; }
-keep class com.abtechnologies.fitHer.MyApp { *; }

# Facebook SDK
-keep class com.facebook.** { *; }
-dontwarn com.facebook.**

# Firebase & Google Play Services
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Crypto / Tink
-keep class com.google.crypto.tink.** { *; }
-dontwarn com.google.crypto.tink.**

# ExoPlayer
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn com.google.android.exoplayer2.**

# General warnings suppress
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**

# Lottie
-keep class com.airbnb.lottie.** { *; }
-dontwarn com.airbnb.lottie.**

# Glide
-keep public class * implements com.bumptech.glide.module.GlideModule
-keep class com.bumptech.glide.** { *; }
-dontwarn com.bumptech.glide.**

# RxJava
-dontwarn io.reactivex.**
-keepclassmembers class io.reactivex.** { *; }

# Compose (if referenced by Zoom SDK)
-dontwarn androidx.compose.**

# ML Kit / BlueParrott / Camera (from Zoom SDK dependencies)
-dontwarn com.google.mlkit.**
-dontwarn com.blueparrott.**
-dontwarn androidx.camera.**
-dontwarn androidx.window.**

# Play Core / SplitInstall (Flutter Deferred Components)
-dontwarn com.google.android.play.core.**
