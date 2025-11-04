//
//  AppDelegate.swift
//  Katya AI REChain Mesh
//
//  Created by Flutter Team on 2024
//

import UIKit
import Flutter
import FlutterMacOS
import flutter_local_notifications
import webview_flutter_wkwebview
import LocalAuthentication
import BackgroundTasks
import Security
import WebKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Configure iOS specific settings
    configureIOSFeatures()

    // MethodChannel + EventChannel for BLE
    if let controller = window?.rootViewController as? FlutterViewController {
      var eventSink: FlutterEventSink?

      let events = FlutterEventChannel(name: "katya.mesh/ble/events", binaryMessenger: controller.binaryMessenger)
      events.setStreamHandler(FlutterStreamHandlerWrapper(
        onListen: { args, sink in eventSink = sink; return nil },
        onCancel: { _ in eventSink = nil; return nil }
      ))

      let channel = FlutterMethodChannel(name: "katya.mesh/ble", binaryMessenger: controller.binaryMessenger)
      channel.setMethodCallHandler { (call: FlutterMethodCall, result: FlutterResult) -> Void in
        switch call.method {
        case "startScan":
          NSLog("BLE startScan called (iOS)")
          // Emit a stub peer for scaffolding
          DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            eventSink?([
              "type": "peerFound",
              "id": "ios-stub-\(Int(Date().timeIntervalSince1970))",
              "name": "iOS Mesh Peer",
              "address": "IOS_ADDR",
              "rssi": -55,
              "lastSeen": Int64(Date().timeIntervalSince1970 * 1000)
            ])
          }
          result(true)
        case "stopScan":
          NSLog("BLE stopScan called (iOS)")
          result(true)
        case "advertise":
          NSLog("BLE advertise called (iOS)")
          result(true)
        case "stopAdvertise":
          NSLog("BLE stopAdvertise called (iOS)")
          result(true)
        case "send":
          NSLog("BLE send called (iOS): \(String(describing: call.arguments))")
          result(true)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func configureIOSFeatures() {
    // Configure iOS specific features
    setupLocalNotifications()
    setupWebView()
    setupBackgroundTasks()
    setupSecurityFeatures()
  }

  private func setupLocalNotifications() {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }

    let flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin()
    flutterLocalNotificationsPlugin.requestPermissions()
  }

  private func setupWebView() {
    // Configure WebView for iOS
    let webViewConfig = WKWebViewConfiguration()
    webViewConfig.allowsInlineMediaPlayback = true
    webViewConfig.mediaTypesRequiringUserActionForPlayback = []
  }

  private func setupBackgroundTasks() {
    // Register background tasks for iOS
    BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.katyaairechainmesh.refresh", using: nil) { task in
      self.handleBackgroundRefresh(task: task as! BGAppRefreshTask)
    }
  }

  private func setupSecurityFeatures() {
    // Configure iOS security features
    configureBiometrics()
    configureKeychain()
  }

  private func configureBiometrics() {
    // iOS biometric authentication setup
    if #available(iOS 11.0, *) {
      let context = LAContext()
      var error: NSError?

      if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
        // Biometrics available
        print("Biometrics authentication available")
      }
    }
  }

  private func configureKeychain() {
    // Keychain configuration for secure storage
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: "katya_rechain_mesh_key",
      kSecValueData as String: "secure_data".data(using: .utf8)!
    ]

    SecItemAdd(query as CFDictionary, nil)
  }

  private func handleBackgroundRefresh(task: BGAppRefreshTask) {
    // Handle background refresh for iOS
    scheduleNextBackgroundRefresh()

    task.setTaskCompleted(success: true)
  }

  private func scheduleNextBackgroundRefresh() {
    let request = BGAppRefreshTaskRequest(identifier: "com.katyaairechainmesh.refresh")
    request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes

    do {
      try BGTaskScheduler.shared.submit(request)
    } catch {
      print("Could not schedule app refresh: \(error)")
    }
  }

  // iOS App Lifecycle methods
  override func applicationDidEnterBackground(_ application: UIApplication) {
    // Handle entering background
    print("App entered background")
  }

  override func applicationWillEnterForeground(_ application: UIApplication) {
    // Handle entering foreground
    print("App entered foreground")
  }

  override func applicationWillResignActive(_ application: UIApplication) {
    // Handle resigning active
    print("App resigned active")
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    // Handle becoming active
    print("App became active")
  }
}
