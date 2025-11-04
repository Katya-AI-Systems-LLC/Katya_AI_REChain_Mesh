import QtQuick 2.6
import Sailfish.Silica 1.0

CoverBackground {
    id: cover

    // Cover content
    Column {
        anchors.centerIn: parent
        spacing: Theme.paddingMedium

        Image {
            id: appIcon
            source: "/usr/share/icons/hicolor/86x86/apps/katya-ai-rechain-mesh.png"
            anchors.horizontalCenter: parent.horizontalCenter
            width: 86
            height: 86
        }

        Label {
            id: appName
            text: "Katya AI\nREChain Mesh"
            font.pixelSize: Theme.fontSizeSmall
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            color: Theme.primaryColor
        }

        Label {
            id: statusLabel
            text: "Ready"
            font.pixelSize: Theme.fontSizeExtraSmall
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            color: Theme.secondaryColor
        }
    }

    // Cover actions
    CoverActionList {
        id: coverActions

        CoverAction {
            iconSource: "image://theme/icon-cover-sync"
            onTriggered: {
                // Sync action
                console.log("Cover sync triggered")
                auroraPlatformService.syncData()
            }
        }

        CoverAction {
            iconSource: "image://theme/icon-cover-new"
            onTriggered: {
                // New window action
                console.log("Cover new window triggered")
                Qt.openUrlExternally("katya-ai-rechain-mesh://new-window")
            }
        }
    }

    // Update cover status
    Timer {
        interval: 30000 // 30 seconds
        running: true
        repeat: true
        onTriggered: {
            updateCoverStatus()
        }
    }

    function updateCoverStatus() {
        // Update cover status based on application state
        var networkAvailable = auroraPlatformService.isNetworkAvailable()
        var syncStatus = auroraPlatformService.getSyncStatus()

        if (networkAvailable) {
            if (syncStatus === "syncing") {
                statusLabel.text = "Syncing..."
                coverActions.enabled = false
            } else if (syncStatus === "error") {
                statusLabel.text = "Sync Error"
                statusLabel.color = Theme.errorColor
                coverActions.enabled = true
            } else {
                statusLabel.text = "Ready"
                statusLabel.color = Theme.secondaryColor
                coverActions.enabled = true
            }
        } else {
            statusLabel.text = "Offline"
            statusLabel.color = Theme.secondaryColor
            coverActions.enabled = false
        }
    }

    Component.onCompleted: {
        updateCoverStatus()
    }
}
