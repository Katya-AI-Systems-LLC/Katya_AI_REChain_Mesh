//
//  AppDelegate.swift
//  Katya AI REChain Mesh
//
//  Created by Flutter Team on 2024
//

import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {

    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    override func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Configure macOS specific settings
        configureMacOSFeatures()

        super.applicationDidFinishLaunching(aNotification)
    }

    override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    private func configureMacOSFeatures() {
        setupMenuBar()
        setupDockIntegration()
        setupSecurityFeatures()
        setupAppleEvents()
    }

    private func setupMenuBar() {
        // Configure macOS menu bar
        if let mainMenu = NSApp.mainMenu {
            // Add application-specific menu items
            let appMenuItem = mainMenu.item(at: 0)
            if let appMenu = appMenuItem?.submenu {
                appMenu.addItem(NSMenuItem.separator())
                let preferencesItem = NSMenuItem(title: "Preferences...", action: #selector(showPreferences), keyEquivalent: ",")
                preferencesItem.target = self
                appMenu.addItem(preferencesItem)
            }
        }
    }

    private func setupDockIntegration() {
        // Configure dock icon and badge
        NSApp.dockTile.badgeLabel = nil
        NSApp.dockTile.showsApplicationBadge = true
    }

    private func setupSecurityFeatures() {
        // Configure macOS security features
        configureKeychain()
        configureSandbox()
        configureHardenedRuntime()
    }

    private func setupAppleEvents() {
        // Configure Apple Events for automation
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(handleAppleEvent(event:reply:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )
    }

    private func configureKeychain() {
        // macOS Keychain configuration
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "katya_rechain_mesh_key",
            kSecValueData as String: "secure_data".data(using: .utf8)!,
            kSecAttrSynchronizable as String: kCFBooleanTrue!
        ]

        SecItemAdd(query as CFDictionary, nil)
    }

    private func configureSandbox() {
        // macOS App Sandbox configuration
        // Sandbox entitlements are configured in entitlements file
        print("macOS App Sandbox configured")
    }

    private func configureHardenedRuntime() {
        // macOS Hardened Runtime configuration
        // Hardened Runtime is configured in build settings
        print("macOS Hardened Runtime configured")
    }

    @objc private func handleAppleEvent(event: NSAppleEventDescriptor, reply: NSAppleEventDescriptor) {
        // Handle Apple Events (URL schemes, etc.)
        if let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue {
            print("Received Apple Event URL: \(urlString)")
            // Handle URL opening
        }
    }

    @objc private func showPreferences() {
        // Show preferences window
        print("Show preferences")
    }

    // macOS App Lifecycle methods
    override func applicationWillTerminate(_ aNotification: Notification) {
        // Handle application termination
        print("App will terminate")
    }

    override func applicationDidBecomeActive(_ notification: Notification) {
        // Handle application becoming active
        print("App became active")
    }

    override func applicationDidResignActive(_ notification: Notification) {
        // Handle application resigning active
        print("App resigned active")
    }
}
