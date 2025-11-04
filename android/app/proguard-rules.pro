# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# Keep Flutter classes
-keep class io.flutter.** { *; }
-keep class androidx.** { *; }

# Keep mesh service classes
-keep class com.katya.rechain.mesh.** { *; }

# Keep crypto classes
-keep class javax.crypto.** { *; }
-keep class java.security.** { *; }

# Keep Bluetooth classes
-keep class android.bluetooth.** { *; }

# Keep notification classes
-keep class androidx.core.app.NotificationCompat { *; }

# Keep method channels
-keep class io.flutter.plugin.common.MethodChannel { *; }
-keep class io.flutter.plugin.common.MethodCall { *; }
