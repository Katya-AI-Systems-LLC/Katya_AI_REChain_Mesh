package com.katya.rechain.katya_ai_rechain_mesh

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.bluetooth.le.AdvertiseCallback
import android.bluetooth.le.AdvertiseData
import android.bluetooth.le.AdvertiseSettings
import android.bluetooth.le.BluetoothLeAdvertiser
import android.bluetooth.le.BluetoothLeScanner
import android.bluetooth.le.ScanCallback
import android.bluetooth.le.ScanResult
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.util.Log
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {
    private val BLE_CHANNEL = "katya.mesh/ble"
    private var bluetoothAdapter: BluetoothAdapter? = null
    private var scanner: BluetoothLeScanner? = null
    private var advertiser: BluetoothLeAdvertiser? = null
    private var scanning = false
    private var advertising = false
    private var eventSink: EventChannel.EventSink? = null

    private val scanCallback = object : ScanCallback() {
        override fun onScanResult(callbackType: Int, result: ScanResult?) {
            super.onScanResult(callbackType, result)
            Log.d("BLE_CHANNEL", "scan result: ${result?.device?.address}")
            result?.let { r ->
                val payload = mapOf(
                    "type" to "peerFound",
                    "id" to (r.device.address ?: "unknown"),
                    "name" to (r.device.name ?: "Unknown"),
                    "address" to (r.device.address ?: ""),
                    "rssi" to r.rssi,
                    "lastSeen" to System.currentTimeMillis()
                )
                eventSink?.success(payload)
            }
        }
    }

    private val advertiseCallback = object : AdvertiseCallback() {
        override fun onStartSuccess(settingsInEffect: AdvertiseSettings?) {
            Log.d("BLE_CHANNEL", "advertise started")
        }
        override fun onStartFailure(errorCode: Int) {
            Log.e("BLE_CHANNEL", "advertise failed: $errorCode")
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val bm = getSystemService(BLUETOOTH_SERVICE) as BluetoothManager
        bluetoothAdapter = bm.adapter
        scanner = bluetoothAdapter?.bluetoothLeScanner
        advertiser = bluetoothAdapter?.bluetoothLeAdvertiser

        val messenger = flutterEngine.dartExecutor.binaryMessenger

        EventChannel(messenger, "katya.mesh/ble/events").setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
            }
            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })

        MethodChannel(messenger, BLE_CHANNEL).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "startScan" -> {
                        if (!hasBlePermissions()) {
                            result.error("PERMISSION", "BLE permission missing", null)
                        } else if (scanner == null) {
                            result.error("UNAVAILABLE", "Scanner unavailable", null)
                        } else if (!scanning) {
                            scanner?.startScan(scanCallback)
                            scanning = true
                            Log.d("BLE_CHANNEL", "startScan")
                            result.success(true)
                        } else {
                            result.success(true)
                        }
                    }
                    "stopScan" -> {
                        if (scanning) {
                            scanner?.stopScan(scanCallback)
                            scanning = false
                        }
                        Log.d("BLE_CHANNEL", "stopScan")
                        result.success(true)
                    }
                    "advertise" -> {
                        val name = (call.argument<String>("name") ?: "KatyaMesh")
                        if (!hasBlePermissions()) {
                            result.error("PERMISSION", "BLE permission missing", null)
                        } else if (advertiser == null) {
                            result.error("UNAVAILABLE", "Advertiser unavailable", null)
                        } else if (!advertising) {
                            val settings = AdvertiseSettings.Builder()
                                .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY)
                                .setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_MEDIUM)
                                .setConnectable(true)
                                .build()
                            val data = AdvertiseData.Builder()
                                .setIncludeDeviceName(true)
                                .build()
                            bluetoothAdapter?.setName(name)
                            advertiser?.startAdvertising(settings, data, advertiseCallback)
                            advertising = true
                            Log.d("BLE_CHANNEL", "advertise start: $name")
                            result.success(true)
                        } else {
                            result.success(true)
                        }
                    }
                    "stopAdvertise" -> {
                        if (advertising) {
                            advertiser?.stopAdvertising(advertiseCallback)
                            advertising = false
                        }
                        Log.d("BLE_CHANNEL", "advertise stop")
                        result.success(true)
                    }
                    "send" -> {
                        Log.d("BLE_CHANNEL", "send called: ${call.arguments}")
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                Log.e("BLE_CHANNEL", "Error handling method", e)
                result.error("BLE_ERROR", e.message, null)
            }
        }
    }

    private fun hasBlePermissions(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val c = ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_CONNECT) == PackageManager.PERMISSION_GRANTED
            val s = ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_SCAN) == PackageManager.PERMISSION_GRANTED
            c && s
        } else {
            ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH) == PackageManager.PERMISSION_GRANTED
        }
    }
}
