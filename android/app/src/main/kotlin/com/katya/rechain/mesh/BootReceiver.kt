package com.katya.rechain.mesh

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            Intent.ACTION_PACKAGE_REPLACED -> {
                Log.d("BootReceiver", "Boot completed or package replaced, starting mesh service")
                startMeshService(context)
            }
        }
    }

    private fun startMeshService(context: Context) {
        try {
            val serviceIntent = Intent(context, MeshService::class.java).apply {
                // Add flags for Android 12+ compatibility
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(serviceIntent)
            } else {
                context.startService(serviceIntent)
            }

            Log.d("BootReceiver", "Mesh service started successfully")
        } catch (e: Exception) {
            Log.e("BootReceiver", "Error starting mesh service on boot", e)
        }
    }
}