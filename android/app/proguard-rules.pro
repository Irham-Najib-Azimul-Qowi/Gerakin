# Flutter Core Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# ObjectBox Rules
-keep class io.objectbox.** { *; }
-dontwarn io.objectbox.**
-keepclassmembers class * {
    @io.objectbox.annotation.Entity *;
    @io.objectbox.annotation.Id *;
    @io.objectbox.annotation.Property *;
}

# Firebase Rules
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Google Play Core & Deferred Components Rules
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# MLKit & Native Plugins Rules
-dontwarn com.google.mlkit.**
-keep class com.google.mlkit.** { *; }
