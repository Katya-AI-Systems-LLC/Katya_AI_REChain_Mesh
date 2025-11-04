import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

CoverBackground {
    id: cover

    // Cover properties
    property string appName: "Katya AI\nREChain Mesh"
    property string statusText: "就绪"
    property string networkStatus: "在线"
    property int blockHeight: 1234567
    property double balance: 0.0

    // Background gradient
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#1976D2" }
            GradientStop { position: 1.0; color: "#0D47A1" }
        }
    }

    // Main content
    Column {
        anchors.centerIn: parent
        spacing: 20
        width: parent.width - 40

        // App icon
        Image {
            source: "qrc:/icons/cover-icon.png"
            width: 120
            height: 120
            anchors.horizontalCenter: parent.horizontalCenter
            fillMode: Image.PreserveAspectFit
        }

        // App name
        Text {
            text: appName
            font.pixelSize: 24
            font.bold: true
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            lineHeight: 1.2
        }

        // Status information
        Column {
            spacing: 8
            width: parent.width

            // Network status
            Row {
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    text: "📶"
                    font.pixelSize: 16
                }

                Text {
                    text: networkStatus
                    font.pixelSize: 16
                    color: "white"
                }
            }

            // Block height
            Row {
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    text: "🔗"
                    font.pixelSize: 16
                }

                Text {
                    text: "区块高度: " + blockHeight.toLocaleString()
                    font.pixelSize: 14
                    color: "#E3F2FD"
                }
            }

            // Balance
            Row {
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    text: "💰"
                    font.pixelSize: 16
                }

                Text {
                    text: "余额: " + balance.toFixed(4) + " BTC"
                    font.pixelSize: 14
                    color: "#E3F2FD"
                }
            }

            // Status
            Text {
                text: "状态: " + statusText
                font.pixelSize: 16
                font.bold: true
                color: "#4CAF50"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    // Cover actions
    CoverActionList {
        id: coverActionList

        CoverAction {
            iconSource: "image://theme/icon-cover-sync"
            onTriggered: {
                // Trigger sync
                harmonyOSPlatformService.syncBlockchain()
                statusText = "同步中..."
            }
        }

        CoverAction {
            iconSource: "image://theme/icon-cover-new"
            onTriggered: {
                // Open new window
                Qt.openUrlExternally("katya-ai-rechain-mesh://new")
            }
        }

        CoverAction {
            iconSource: "image://theme/icon-cover-settings"
            onTriggered: {
                // Open settings
                var component = Qt.createComponent("SettingsPage.qml")
                if (component.status === Component.Ready) {
                    var settingsPage = component.createObject(null)
                    settingsPage.open()
                }
            }
        }
    }

    // Update timer for live data
    Timer {
        interval: 30000 // Update every 30 seconds
        running: true
        repeat: true

        onTriggered: {
            updateCoverData()
        }
    }

    // Connections to platform service
    Connections {
        target: harmonyOSPlatformService

        onNetworkStateChanged: {
            networkStatus = available ? "在线" : "离线"
        }

        onBackgroundTaskCompleted: {
            if (taskName === "blockchain_sync") {
                statusText = "已同步"
                // Update block height and balance
                updateCoverData()
            }
        }
    }

    function updateCoverData() {
        // Update block height
        blockHeight += Math.floor(Math.random() * 10) + 1

        // Update balance (simulate)
        balance += (Math.random() - 0.5) * 0.001

        // Update status based on network
        if (harmonyOSPlatformService.isNetworkAvailable) {
            statusText = "就绪"
        } else {
            statusText = "离线"
        }
    }

    Component.onCompleted: {
        // Initialize cover data
        updateCoverData()

        // Set up periodic updates
        updateTimer.start()
    }

    Timer {
        id: updateTimer
        interval: 60000 // Update every minute
        running: false
        repeat: true

        onTriggered: {
            updateCoverData()
        }
    }
}
