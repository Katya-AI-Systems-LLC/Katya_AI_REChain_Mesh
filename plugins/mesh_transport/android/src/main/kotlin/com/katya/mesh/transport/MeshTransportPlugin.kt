package com.katya.mesh.transport

import android.content.Context
import android.os.Handler
import android.os.Looper
import com.google.android.gms.nearby.Nearby
import com.google.android.gms.nearby.connection.AdvertisingOptions
import com.google.android.gms.nearby.connection.ConnectionInfo
import com.google.android.gms.nearby.connection.ConnectionLifecycleCallback
import com.google.android.gms.nearby.connection.ConnectionResolution
import com.google.android.gms.nearby.connection.ConnectionsStatusCodes
import com.google.android.gms.nearby.connection.DiscoveryOptions
import com.google.android.gms.nearby.connection.Payload
import com.google.android.gms.nearby.connection.PayloadCallback
import com.google.android.gms.nearby.connection.PayloadTransferUpdate
import com.google.android.gms.nearby.connection.Strategy
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MeshTransportPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var sink: EventChannel.EventSink? = null
    private val handler = Handler(Looper.getMainLooper())
    private var advertising = false
    private var discovering = false
    private lateinit var appContext: Context
    private val SERVICE_ID = "mesh-transport"
    private var localEndpointName: String = "AndroidMesh"

    private val payloadCallback = object : PayloadCallback() {
        override fun onPayloadReceived(endpointId: String, payload: Payload) {
            val bytes = payload.asBytes()
            if (bytes != null) {
                sink?.success(mapOf(
                    "type" to "message",
                    "fromId" to endpointId,
                    "data" to bytes.toList()
                ))
            }
        }

        override fun onPayloadTransferUpdate(endpointId: String, update: PayloadTransferUpdate) {}
    }

    private val connectionLifecycleCallback = object : ConnectionLifecycleCallback() {
        override fun onConnectionInitiated(endpointId: String, connectionInfo: ConnectionInfo) {
            Nearby.getConnectionsClient(appContext).acceptConnection(endpointId, payloadCallback)
        }
        override fun onConnectionResult(endpointId: String, resolution: ConnectionResolution) {
            if (resolution.status.statusCode == ConnectionsStatusCodes.STATUS_OK) {
                sink?.success(mapOf("type" to "peerFound", "id" to endpointId, "name" to endpointId, "rssi" to -45))
            }
        }
        override fun onDisconnected(endpointId: String) {}
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = MethodChannel(binding.binaryMessenger, "katya.mesh/transport")
        methodChannel.setMethodCallHandler(this)
        eventChannel = EventChannel(binding.binaryMessenger, "katya.mesh/transport/events")
        eventChannel.setStreamHandler(this)
        appContext = binding.applicationContext
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "discover" -> {
                discovering = true
                val options = DiscoveryOptions.Builder().setStrategy(Strategy.P2P_CLUSTER).build()
                Nearby.getConnectionsClient(appContext)
                    .startDiscovery(SERVICE_ID, object : com.google.android.gms.nearby.connection.EndpointDiscoveryCallback() {
                        override fun onEndpointFound(endpointId: String, info: com.google.android.gms.nearby.connection.DiscoveredEndpointInfo) {
                            sink?.success(mapOf("type" to "peerFound", "id" to endpointId, "name" to info.endpointName, "rssi" to -50))
                        }
                        override fun onEndpointLost(endpointId: String) {}
                    }, options)
                    .addOnSuccessListener { result.success(true) }
                    .addOnFailureListener { e -> result.error("DISCOVERY_FAIL", e.message, null) }
            }
            "stopDiscover" -> { discovering = false; result.success(true) }
            "advertise" -> {
                advertising = true
                val options = AdvertisingOptions.Builder().setStrategy(Strategy.P2P_CLUSTER).build()
                val name = call.argument<String>("name") ?: localEndpointName
                Nearby.getConnectionsClient(appContext)
                    .startAdvertising(name, SERVICE_ID, connectionLifecycleCallback, options)
                    .addOnSuccessListener { result.success(true) }
                    .addOnFailureListener { e -> result.error("ADVERTISE_FAIL", e.message, null) }
            }
            "stopAdvertise" -> { advertising = false; result.success(true) }
            "connect" -> {
                val peerId = call.argument<String>("peerId") ?: return result.error("ARGS", "peerId required", null)
                Nearby.getConnectionsClient(appContext)
                    .requestConnection(localEndpointName, peerId, connectionLifecycleCallback)
                    .addOnSuccessListener { result.success(true) }
                    .addOnFailureListener { e -> result.error("CONNECT_FAIL", e.message, null) }
            }
            "send" -> {
                val peerId = call.argument<String>("peerId")
                val data = call.argument<List<Int>>("data")
                if (peerId == null || data == null) return result.error("ARGS", "peerId/data required", null)
                val payload = Payload.fromBytes(data.map { it.toByte() }.toByteArray())
                Nearby.getConnectionsClient(appContext)
                    .sendPayload(peerId, payload)
                    .addOnSuccessListener { result.success(true) }
                    .addOnFailureListener { e -> result.error("SEND_FAIL", e.message, null) }
            }
            else -> result.notImplemented()
        }
    }
}


