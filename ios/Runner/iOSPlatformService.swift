//
//  iOSPlatformService.swift
//  Katya AI REChain Mesh
//
//  iOS specific platform services and configurations
//

import Foundation
import UIKit
import LocalAuthentication
import Security
import BackgroundTasks
import UserNotifications
import WebKit
import CoreLocation
import AVFoundation
import Photos
import Contacts

@objc public class IOSPlatformService: NSObject {

    // MARK: - Singleton
    @objc public static let shared = IOSPlatformService()

    private override init() {
        super.init()
        setupIOSServices()
    }

    // MARK: - iOS Services Setup
    private func setupIOSServices() {
        configureBackgroundTasks()
        configureLocalNotifications()
        configureSecurity()
        configureLocationServices()
        configureCameraAndPhotos()
        configureContacts()
        configureWebView()
    }

    // MARK: - Background Tasks
    private func configureBackgroundTasks() {
        if #available(iOS 13.0, *) {
            BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.katyaairechainmesh.refresh", using: nil) { task in
                self.handleBackgroundRefresh(task: task as! BGAppRefreshTask)
            }

            BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.katyaairechainmesh.sync", using: nil) { task in
                self.handleBackgroundSync(task: task as! BGProcessingTask)
            }
        }
    }

    private func handleBackgroundRefresh(task: BGAppRefreshTask) {
        scheduleNextBackgroundRefresh()

        // Perform background refresh tasks
        syncDataInBackground()

        task.setTaskCompleted(success: true)
    }

    private func handleBackgroundSync(task: BGProcessingTask) {
        // Perform background sync
        performBackgroundSync()

        task.setTaskCompleted(success: true)
    }

    private func scheduleNextBackgroundRefresh() {
        if #available(iOS 13.0, *) {
            let request = BGAppRefreshTaskRequest(identifier: "com.katyaairechainmesh.refresh")
            request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes

            do {
                try BGTaskScheduler.shared.submit(request)
            } catch {
                print("Could not schedule app refresh: \(error)")
            }
        }
    }

    // MARK: - Local Notifications
    private func configureLocalNotifications() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate

            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        }
    }

    // MARK: - Security Features
    private func configureSecurity() {
        configureBiometrics()
        configureKeychain()
        configureSecureEnclave()
    }

    private func configureBiometrics() {
        if #available(iOS 11.0, *) {
            let context = LAContext()
            var error: NSError?

            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                print("Biometrics authentication available")

                // Enable biometric authentication
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                     localizedReason: "Authenticate to access secure features") { success, error in
                    if success {
                        print("Biometric authentication successful")
                    }
                }
            }
        }
    }

    private func configureKeychain() {
        // Configure Keychain for secure storage
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "katya_rechain_mesh_key",
            kSecValueData as String: "secure_data".data(using: .utf8)!,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        SecItemAdd(query as CFDictionary, nil)
    }

    private func configureSecureEnclave() {
        if #available(iOS 10.3, *) {
            // Use Secure Enclave for key generation and storage
            let context = LAContext()
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                 localizedReason: "Secure Enclave access") { success, error in
                if success {
                    print("Secure Enclave access granted")
                }
            }
        }
    }

    // MARK: - Location Services
    private func configureLocationServices() {
        let locationManager = CLLocationManager()
        locationManager.delegate = self as? CLLocationManagerDelegate
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
    }

    // MARK: - Camera and Photos
    private func configureCameraAndPhotos() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                print("Camera access granted")
            }
        }

        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                print("Photo library access granted")
            }
        }
    }

    // MARK: - Contacts
    private func configureContacts() {
        CNContactStore().requestAccess(for: .contacts) { granted, error in
            if granted {
                print("Contacts access granted")
            }
        }
    }

    // MARK: - WebView Configuration
    private func configureWebView() {
        let webViewConfig = WKWebViewConfiguration()
        webViewConfig.allowsInlineMediaPlayback = true
        webViewConfig.mediaTypesRequiringUserActionForPlayback = []
        webViewConfig.preferences.javaScriptEnabled = true

        if #available(iOS 14.0, *) {
            webViewConfig.preferences.isFraudulentWebsiteWarningEnabled = true
        }
    }

    // MARK: - Data Sync Methods
    private func syncDataInBackground() {
        // Background data synchronization
        print("Performing background data sync")
    }

    private func performBackgroundSync() {
        // Background processing sync
        print("Performing background processing sync")
    }

    // MARK: - Public API Methods

    @objc public func authenticateWithBiometrics(completion: @escaping (Bool, Error?) -> Void) {
        if #available(iOS 11.0, *) {
            let context = LAContext()
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                 localizedReason: "Authenticate to access the app") { success, error in
                DispatchQueue.main.async {
                    completion(success, error)
                }
            }
        } else {
            completion(false, NSError(domain: "BiometricsNotAvailable", code: -1, userInfo: nil))
        }
    }

    @objc public func storeSecureData(_ data: Data, forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    @objc public func retrieveSecureData(forKey key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        return status == errSecSuccess ? result as? Data : nil
    }

    @objc public func getDeviceInfo() -> [String: Any] {
        var deviceInfo: [String: Any] = [:]

        deviceInfo["systemName"] = UIDevice.current.systemName
        deviceInfo["systemVersion"] = UIDevice.current.systemVersion
        deviceInfo["model"] = UIDevice.current.model
        deviceInfo["localizedModel"] = UIDevice.current.localizedModel
        deviceInfo["name"] = UIDevice.current.name
        deviceInfo["identifierForVendor"] = UIDevice.current.identifierForVendor?.uuidString ?? ""

        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            deviceInfo["appVersion"] = version
        }

        return deviceInfo
    }

    @objc public func scheduleLocalNotification(title: String, body: String, delay: TimeInterval) {
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = UNNotificationSound.default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                }
            }
        }
    }
}
