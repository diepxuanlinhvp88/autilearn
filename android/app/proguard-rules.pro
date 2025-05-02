# Keep `Companion` object fields of serializable classes.
# This avoids serializer lookup through `getDeclaredClasses` as done for named companion objects.
-if @kotlinx.serialization.Serializable class **
-keepclassmembers class <1> {
    static <1>$Companion Companion;
}

# Keep `serializer()` on companion objects (both default and named) of serializable classes.
-if @kotlinx.serialization.Serializable class ** {
    static **$* *;
}
-keepclassmembers class <2>$<3> {
    kotlinx.serialization.KSerializer serializer(...);
}

# Keep `INSTANCE.serializer()` of serializable objects.
-if @kotlinx.serialization.Serializable class ** {
    public static ** INSTANCE;
}
-keepclassmembers class <1> {
    public static <1> INSTANCE;
    kotlinx.serialization.KSerializer serializer(...);
}

# @Serializable and @Polymorphic are used at runtime for polymorphic serialization.
-keepattributes RuntimeVisibleAnnotations,AnnotationDefault

# Don't shrink image_picker classes
-keep class io.flutter.plugins.imagepicker.** { *; }
-keep class io.flutter.plugins.flutter_plugin_android_lifecycle.** { *; }

# Don't shrink firebase classes
-keep class com.google.firebase.** { *; }
-keep class io.flutter.plugins.firebase.** { *; }

# Keep Pigeon generated classes
-keep class dev.flutter.pigeon.** { *; }

# Keep classes used by image_picker
-keep class androidx.core.content.FileProvider
-keep class androidx.core.app.ActivityCompat
-keep class android.content.ContentResolver
-keep class android.content.ContentValues
-keep class android.provider.MediaStore
-keep class android.os.Environment
-keep class android.graphics.Bitmap
-keep class android.graphics.BitmapFactory
-keep class android.net.Uri
-keep class android.app.Activity
-keep class android.content.Intent
-keep class android.content.Context
-keep class android.content.pm.PackageManager
-keep class android.Manifest$permission
-keep class android.support.v4.content.FileProvider
-keep class android.support.v4.app.ActivityCompat
-keep class android.support.v4.content.ContextCompat
-keep class androidx.core.content.ContextCompat
