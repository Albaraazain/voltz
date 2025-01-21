# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.** { *; }

# Warning suppressions for Play Core tasks
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task

# Play Services Tasks
-keep class com.google.android.gms.tasks.** { *; }
-keep interface com.google.android.gms.tasks.** { *; }
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.base.** { *; }

# Play Core modular libraries
-keep class com.google.android.play.core.common.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }

# App Update
-keep class com.google.android.play.core.appupdate.** { *; }
-keep class com.google.android.play.core.install.** { *; }

# Reviews
-keep class com.google.android.play.core.review.** { *; }

# Feature Delivery
-keep class com.google.android.play.core.splitinstall.** { *; }

# Multidex
-keep class androidx.multidex.** { *; }

# Keep your model classes if using any
-keep class com.albaraa.voltzy.models.** { *; }

# General rules
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keepattributes Signature
-keep public class * extends java.lang.Exception

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Enum
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelable
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

# Keep Task API implementations
-keepclassmembers class * implements com.google.android.gms.tasks.OnCompleteListener {
    public void onComplete(com.google.android.gms.tasks.Task);
}
-keepclassmembers class * implements com.google.android.gms.tasks.OnSuccessListener {
    public void onSuccess(java.lang.Object);
}
-keepclassmembers class * implements com.google.android.gms.tasks.OnFailureListener {
    public void onFailure(java.lang.Exception);
}