# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Google Play Core (required by Flutter deferred components)
-dontwarn com.google.android.play.core.**

# Keep annotations
-keepattributes *Annotation*

# Crashlytics: preserve source file and line numbers so deobfuscated stack
# traces in the Firebase console actually point to a real line. The mapping
# file is uploaded automatically by the Crashlytics gradle plugin.
-keepattributes SourceFile,LineNumberTable
# Hide original source file name in user-visible traces (Crashlytics will
# still resolve via the uploaded mapping).
-renamesourcefileattribute SourceFile
# Keep custom Exception subclasses unobfuscated so they group correctly.
-keep public class * extends java.lang.Exception
