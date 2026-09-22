# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep youtubedl-android & ffmpeg
-keep class com.yausername.youtubedl_android.** { *; }
-keep class com.yausername.ffmpeg.** { *; }
-dontwarn com.yausername.youtubedl_android.**
-dontwarn com.yausername.ffmpeg.**

# Keep Jackson Databind and models (prevents "class o3.a is not a concrete class" crash)
-keep class com.fasterxml.jackson.** { *; }
-dontwarn com.fasterxml.jackson.**
-keepattributes *Annotation*,EnclosingMethod,Signature,InnerClasses

# Keep custom plugin
-keep class com.example.vibemusica.** { *; }

# Suppress warnings for Play Core deferred components
-dontwarn com.google.android.play.core.**

