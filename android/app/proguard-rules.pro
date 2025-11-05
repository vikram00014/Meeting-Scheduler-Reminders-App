# Flutter Local Notifications
-keep class com.dexterous.** { *; }
-keep class androidx.core.app.NotificationCompat { *; }
-keep class androidx.core.app.NotificationCompat$* { *; }

# Keep generic signature of all classes (fixes type parameter issues)
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod

# Gson specific classes (used by flutter_local_notifications for serialization)
-keep class com.google.gson.** { *; }
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep notification related classes
-keep class * extends android.app.Notification { *; }
-keep class * extends android.app.NotificationManager { *; }
