-keep class proguard.annotation.Keep { *; }
-keep class proguard.annotation.KeepClassMembers { *; }
-dontwarn proguard.annotation.Keep
-dontwarn proguard.annotation.KeepClassMembers
# Firebase Rules
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.android.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**
-dontwarn com.google.android.**

# Keep Firebase models
-keep class com.firebase.** { *; }
-keep interface com.firebase.** { *; }

# Keep Firestore
-keep class com.google.cloud.firestore.** { *; }
-dontwarn com.google.cloud.firestore.**

# Keep Firebase Auth
-keep class com.google.firebase.auth.** { *; }
-dontwarn com.google.firebase.auth.**

# Flutter/Dart
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**
-dontwarn io.flutter.plugins.**

# Razorpay
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# General rules
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable