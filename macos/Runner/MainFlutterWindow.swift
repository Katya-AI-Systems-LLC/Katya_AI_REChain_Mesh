//
//  MainFlutterWindow.swift
//  Katya AI REChain Mesh
//
//  macOS main window configuration
//

import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
    override func awakeFromNib() {
        let flutterViewController = FlutterViewController.init()
        let windowFrame = self.frame
        self.contentViewController = flutterViewController
        self.setFrame(windowFrame, display: true)

        // Configure macOS specific window properties
        configureWindowProperties()

        RegisterGeneratedPlugins(registry: flutterViewController.pluginRegistry())

        super.awakeFromNib()
    }

    private func configureWindowProperties() {
        // macOS window configuration
        self.title = "Katya AI REChain Mesh"
        self.titlebarAppearsTransparent = true
        self.titleVisibility = .visible
        self.isMovableByWindowBackground = true

        // Set minimum and maximum window sizes
        self.minSize = NSSize(width: 800, height: 600)
        self.maxSize = NSSize(width: 3840, height: 2160)

        // Configure window style
        self.styleMask.insert(.fullSizeContentView)
        self.styleMask.insert(.unifiedTitleAndToolbar)
        self.styleMask.insert(.closable)
        self.styleMask.insert(.miniaturizable)
        self.styleMask.insert(.resizable)
        self.styleMask.insert(.titled)

        // Enable vibrancy for macOS 10.10+
        if #available(macOS 10.10, *) {
            self.appearance = NSAppearance(named: .vibrantDark)
        }

        // Configure traffic lights (red, yellow, green buttons)
        self.standardWindowButton(.closeButton)?.isEnabled = true
        self.standardWindowButton(.miniaturizeButton)?.isEnabled = true
        self.standardWindowButton(.zoomButton)?.isEnabled = true

        // Set window level
        self.level = .normal

        // Configure collection behavior
        if #available(macOS 10.11, *) {
            self.collectionBehavior = [.managed, .fullScreenPrimary]
        }

        // Configure sharing service picker
        if #available(macOS 10.12, *) {
            self.collectionBehavior.insert(.fullScreenAllowsTiling)
        }

        // Set window aspect ratio
        let aspectRatio = CGSize(width: 16, height: 9)
        self.contentAspectRatio = aspectRatio

        // Configure window animations
        self.animationBehavior = .alertPanel

        // Set up window delegate
        self.delegate = self as? NSWindowDelegate
    }

    // Window delegate methods
    func windowWillClose(_ notification: Notification) {
        print("Window will close")
    }

    func windowDidResize(_ notification: Notification) {
        print("Window did resize: \(self.frame.size)")
    }

    func windowDidMiniaturize(_ notification: Notification) {
        print("Window did miniaturize")
    }

    func windowDidDeminiaturize(_ notification: Notification) {
        print("Window did deminiaturize")
    }

    func windowDidEnterFullScreen(_ notification: Notification) {
        print("Window did enter full screen")
    }

    func windowDidExitFullScreen(_ notification: Notification) {
        print("Window did exit full screen")
    }

    func windowWillEnterFullScreen(_ notification: Notification) {
        print("Window will enter full screen")
    }

    func windowWillExitFullScreen(_ notification: Notification) {
        print("Window will exit full screen")
    }

    // Custom window management methods
    func toggleFullScreen() {
        if #available(macOS 10.11, *) {
            if self.styleMask.contains(.fullScreen) {
                self.toggleFullScreen(nil)
            } else {
                self.toggleFullScreen(nil)
            }
        }
    }

    func centerWindow() {
        self.center()
    }

    func setWindowSize(_ size: NSSize) {
        let frame = NSRect(origin: self.frame.origin, size: size)
        self.setFrame(frame, display: true, animate: true)
    }

    func setWindowPosition(_ point: NSPoint) {
        var frame = self.frame
        frame.origin = point
        self.setFrame(frame, display: true, animate: true)
    }

    func makeKeyAndOrderFront() {
        self.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func closeWindow() {
        self.close()
    }

    func minimizeWindow() {
        self.miniaturize(nil)
    }

    func zoomWindow() {
        self.zoom(nil)
    }

    func updateWindowTitle(_ title: String) {
        self.title = title
    }

    func setWindowIcon(_ image: NSImage) {
        self.standardWindowButton(.documentIconButton)?.image = image
    }

    func setWindowBackgroundColor(_ color: NSColor) {
        self.backgroundColor = color
    }

    func setWindowTransparency(_ alpha: CGFloat) {
        self.alphaValue = alpha
    }

    func setWindowAlwaysOnTop(_ alwaysOnTop: Bool) {
        if alwaysOnTop {
            self.level = .floating
        } else {
            self.level = .normal
        }
    }

    func setWindowMovable(_ movable: Bool) {
        self.isMovable = movable
        self.isMovableByWindowBackground = movable
    }

    func setWindowResizable(_ resizable: Bool) {
        if resizable {
            self.styleMask.insert(.resizable)
        } else {
            self.styleMask.remove(.resizable)
        }
    }

    func setWindowMinimizable(_ minimizable: Bool) {
        if minimizable {
            self.styleMask.insert(.miniaturizable)
        } else {
            self.styleMask.remove(.miniaturizable)
        }
    }

    func setWindowClosable(_ closable: Bool) {
        if closable {
            self.styleMask.insert(.closable)
        } else {
            self.styleMask.remove(.closable)
        }
    }

    func enableTitleBar(_ enabled: Bool) {
        if enabled {
            self.styleMask.insert(.titled)
        } else {
            self.styleMask.remove(.titled)
        }
    }

    func enableFullSizeContentView(_ enabled: Bool) {
        if enabled {
            self.styleMask.insert(.fullSizeContentView)
        } else {
            self.styleMask.remove(.fullSizeContentView)
        }
    }

    func setWindowShadow(_ hasShadow: Bool) {
        self.hasShadow = hasShadow
    }

    func setWindowBorderless(_ borderless: Bool) {
        if borderless {
            self.styleMask.insert(.borderless)
        } else {
            self.styleMask.remove(.borderless)
        }
    }
}
