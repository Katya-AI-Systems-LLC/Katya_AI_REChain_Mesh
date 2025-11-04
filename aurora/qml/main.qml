import QtQuick 2.6
import QtQuick.Window 2.2
import Sailfish.Silica 1.0

import Flutter 1.0

ApplicationWindow {
    id: mainWindow

    property int flutterWidth: 1080
    property int flutterHeight: 1920
    property string windowTitle: "Katya AI REChain Mesh"

    width: flutterWidth
    height: flutterHeight
    visible: true
    title: windowTitle

    // Aurora OS specific properties
    allowedOrientations: Orientation.All
    _defaultPageOrientations: Orientation.All
    cover: Qt.resolvedUrl("CoverPage.qml")

    // Flutter view container
    Rectangle {
        id: flutterContainer
        anchors.fill: parent
        color: "white"

        // Flutter rendering area
        FlutterView {
            id: flutterView
            anchors.fill: parent
            focus: true

            // Flutter properties
            width: flutterWidth
            height: flutterHeight

            // Connect to Flutter signals
            onFlutterReady: {
                console.log("Flutter is ready")
            }

            onFlutterError: {
                console.log("Flutter error:", error)
            }
        }
    }

    // Pull-down menu for Aurora OS
    SilicaFlickable {
        id: flickable
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("Settings")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
                }
            }

            MenuItem {
                text: qsTr("About")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
                }
            }

            MenuItem {
                text: qsTr("Refresh")
                onClicked: {
                    flutterView.refresh()
                }
            }
        }
    }

    // Handle orientation changes
    onOrientationChanged: {
        if (orientation === Orientation.Portrait ||
            orientation === Orientation.PortraitInverted) {
            flutterWidth = 1080
            flutterHeight = 1920
        } else {
            flutterWidth = 1920
            flutterHeight = 1080
        }

        flutterView.updateGeometry()
    }

    // Handle window state changes
    onWindowStateChanged: {
        if (windowState === Qt.WindowMinimized) {
            console.log("Window minimized")
        } else if (windowState === Qt.WindowMaximized) {
            console.log("Window maximized")
        } else if (windowState === Qt.WindowFullScreen) {
            console.log("Window fullscreen")
        }
    }

    // Handle focus changes
    onActiveFocusItemChanged: {
        if (activeFocusItem === flutterView) {
            flutterView.forceActiveFocus()
        }
    }

    // Handle close events
    onClosing: {
        console.log("Window closing")
        // Save application state
        // Clean up resources
        close.accepted = true
    }

    // Initialize application
    Component.onCompleted: {
        console.log("Main window created")
        console.log("Screen size:", Screen.width, "x", Screen.height)
        console.log("Window size:", width, "x", height)

        // Initialize platform services
        auroraPlatformService.initialize()

        // Set up window properties
        setupWindowProperties()
    }

    function setupWindowProperties() {
        // Set up Aurora OS specific window properties
        // Configure window behavior
        // Set up gesture recognition
        // Configure cover actions

        console.log("Window properties configured")
    }
}
