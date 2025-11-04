import 'package:flutter/services.dart';

class BleChannel {
  static const MethodChannel _channel = MethodChannel('katya.mesh/ble');
  static const EventChannel _events = EventChannel('katya.mesh/ble/events');

  static Future<void> startScan() => _channel.invokeMethod('startScan');
  static Future<void> stopScan() => _channel.invokeMethod('stopScan');
  static Future<void> advertise(String name) =>
      _channel.invokeMethod('advertise', {'name': name});
  static Future<void> stopAdvertise() => _channel.invokeMethod('stopAdvertise');
  static Future<void> send(Map<String, dynamic> msg) =>
      _channel.invokeMethod('send', msg);

  static Stream<dynamic> get events => _events.receiveBroadcastStream();
}
