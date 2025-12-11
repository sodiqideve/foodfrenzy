# Flutter ProGuard Rules
# ======================

# Keep Flutter engine classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Flame game engine classes
-keep class com.flame.** { *; }

# Keep annotations
-keepattributes *Annotation*

# Keep line numbers for debugging
-keepattributes SourceFile,LineNumberTable

# If using reflection
-keepattributes Signature
-keepattributes Exceptions

# Don't warn about missing classes from dependencies
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**

