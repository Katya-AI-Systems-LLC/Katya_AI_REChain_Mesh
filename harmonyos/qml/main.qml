import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import Qt.labs.platform 1.1
import HarmonyOS 1.0

ApplicationWindow {
    id: root
    width: 1080
    height: 1920
    visible: true
    title: qsTr("Katya AI REChain Mesh")

    // HarmonyOS specific properties
    property bool hmsServicesReady: false
    property bool huaweiAccountSignedIn: false
    property string currentOrientation: "portrait"
    property string harmonyOSVersion: "4.0.0"
    property string hmsCoreVersion: "6.12.0.300"

    // Colors and styling for HarmonyOS
    Material.theme: Material.Light
    Material.accent: Material.color(Material.Blue, Material.Shade600)

    // Background gradient
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#E3F2FD" }
            GradientStop { position: 1.0; color: "#BBDEFB" }
        }
    }

    // Main content area
    Flickable {
        id: mainFlickable
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: mainColumn.height + 100

        Column {
            id: mainColumn
            width: parent.width - 40
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20
            padding: 20

            // Header
            Rectangle {
                width: parent.width
                height: 120
                color: "white"
                border.color: "#E0E0E0"
                border.width: 1
                radius: 12

                Column {
                    anchors.centerIn: parent
                    spacing: 5

                    Text {
                        text: "卡佳AI区块链网格"
                        font.pixelSize: 28
                        font.bold: true
                        color: "#1976D2"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: "HarmonyOS 版本"
                        font.pixelSize: 14
                        color: "#666666"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: "HMS Core: " + hmsCoreVersion
                        font.pixelSize: 12
                        color: "#888888"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }

            // HMS Services Status
            GroupBox {
                title: qsTr("HMS 服务状态")
                width: parent.width
                padding: 20

                Column {
                    spacing: 15
                    width: parent.width

                    HMSServiceStatus {
                        serviceName: "HMS Core"
                        serviceIcon: "🔧"
                        isReady: hmsServicesReady
                    }

                    HMSServiceStatus {
                        serviceName: "华为账号"
                        serviceIcon: "👤"
                        isReady: huaweiAccountSignedIn
                    }

                    HMSServiceStatus {
                        serviceName: "推送服务"
                        serviceIcon: "📱"
                        isReady: hmsServicesReady
                    }

                    HMSServiceStatus {
                        serviceName: "位置服务"
                        serviceIcon: "📍"
                        isReady: hmsServicesReady
                    }

                    HMSServiceStatus {
                        serviceName: "支付服务"
                        serviceIcon: "💳"
                        isReady: hmsServicesReady
                    }
                }
            }

            // Blockchain Features
            GroupBox {
                title: qsTr("区块链功能")
                width: parent.width
                padding: 20

                Column {
                    spacing: 15
                    width: parent.width

                    BlockchainFeature {
                        title: "比特币集成"
                        description: "完整的比特币钱包和交易功能"
                        icon: "₿"
                        enabled: true
                    }

                    BlockchainFeature {
                        title: "以太坊支持"
                        description: "智能合约和DApp浏览器"
                        icon: "◆"
                        enabled: true
                    }

                    BlockchainFeature {
                        title: "REChain网络"
                        description: "专有的AI区块链网络"
                        icon: "🔗"
                        enabled: true
                    }

                    BlockchainFeature {
                        title: "跨链桥接"
                        description: "多链资产互操作"
                        icon: "🌉"
                        enabled: true
                    }
                }
            }

            // Chinese Services Integration
            GroupBox {
                title: qsTr("中国服务集成")
                width: parent.width
                padding: 20

                Column {
                    spacing: 15
                    width: parent.width

                    ChineseService {
                        name: "华为支付"
                        description: "Huawei Pay集成"
                        icon: "💰"
                        available: hmsServicesReady
                    }

                    ChineseService {
                        name: "支付宝"
                        description: "Alipay支付支持"
                        icon: "💸"
                        available: true
                    }

                    ChineseService {
                        name: "微信支付"
                        description: "WeChat Pay集成"
                        icon: "💚"
                        available: true
                    }

                    ChineseService {
                        name: "微信分享"
                        description: "WeChat社交分享"
                        icon: "📱"
                        available: true
                    }

                    ChineseService {
                        name: "微博集成"
                        description: "Weibo社交平台"
                        icon: "🐦"
                        available: true
                    }
                }
            }

            // Device Information
            GroupBox {
                title: qsTr("设备信息")
                width: parent.width
                padding: 20

                GridLayout {
                    width: parent.width
                    columns: 2
                    rowSpacing: 10
                    columnSpacing: 20

                    Text { text: "操作系统:"; font.bold: true }
                    Text { text: "HarmonyOS " + harmonyOSVersion }

                    Text { text: "设备型号:"; font.bold: true }
                    Text { text: harmonyOSPlatformService.deviceModel }

                    Text { text: "设备ID:"; font.bold: true }
                    Text {
                        text: harmonyOSPlatformService.deviceId
                        font.family: "monospace"
                        font.pixelSize: 12
                    }

                    Text { text: "网络状态:"; font.bold: true }
                    Text {
                        text: harmonyOSPlatformService.isNetworkAvailable ? "已连接" : "未连接"
                        color: harmonyOSPlatformService.isNetworkAvailable ? "green" : "red"
                    }

                    Text { text: "华为设备:"; font.bold: true }
                    Text {
                        text: harmonyOSPlatformService.isHuaweiDevice ? "是" : "否"
                        color: harmonyOSPlatformService.isHuaweiDevice ? "green" : "orange"
                    }
                }
            }

            // Security Features
            GroupBox {
                title: qsTr("安全功能")
                width: parent.width
                padding: 20

                Column {
                    spacing: 15
                    width: parent.width

                    SecurityFeature {
                        name: "生物识别认证"
                        description: "指纹/面部识别"
                        icon: "🔐"
                        enabled: true
                    }

                    SecurityFeature {
                        name: "安全存储"
                        description: "加密数据存储"
                        icon: "💾"
                        enabled: true
                    }

                    SecurityFeature {
                        name: "端到端加密"
                        description: "通信加密"
                        icon: "🔒"
                        enabled: true
                    }

                    SecurityFeature {
                        name: "安全通信"
                        description: "HTTPS/TLS"
                        icon: "🌐"
                        enabled: true
                    }
                }
            }
        }
    }

    // Pull-down menu for HarmonyOS
    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("设置")
                onClicked: {
                    var component = Qt.createComponent("SettingsPage.qml")
                    if (component.status === Component.Ready) {
                        var settingsPage = component.createObject(root)
                        settingsPage.open()
                    }
                }
            }

            MenuItem {
                text: qsTr("关于")
                onClicked: {
                    var component = Qt.createComponent("AboutPage.qml")
                    if (component.status === Component.Ready) {
                        var aboutPage = component.createObject(root)
                        aboutPage.open()
                    }
                }
            }

            MenuItem {
                text: qsTr("同步")
                onClicked: {
                    harmonyOSPlatformService.syncBlockchain()
                }
            }
        }
    }

    // Status bar
    Rectangle {
        id: statusBar
        anchors.top: parent.top
        width: parent.width
        height: 40
        color: "#1976D2"
        z: 100

        Row {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 15

            Text {
                text: "📶"
                font.pixelSize: 16
                color: "white"
                visible: harmonyOSPlatformService.isNetworkAvailable
            }

            Text {
                text: "🔒"
                font.pixelSize: 16
                color: "white"
                visible: hmsServicesReady
            }

            Text {
                text: "📍"
                font.pixelSize: 16
                color: "white"
                visible: hmsServicesReady
            }

            Text {
                text: "💳"
                font.pixelSize: 16
                color: "white"
                visible: hmsServicesReady
            }

            Text {
                text: new Date().toLocaleTimeString()
                font.pixelSize: 14
                color: "white"
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    // Main content area adjusted for status bar
    Rectangle {
        anchors.top: statusBar.bottom
        anchors.bottom: parent.bottom
        width: parent.width

        // Content here
    }

    // Orientation change handling
    onWidthChanged: {
        if (width > height) {
            currentOrientation = "landscape"
        } else {
            currentOrientation = "portrait"
        }
    }

    // Initialize HMS services when window becomes visible
    onVisibleChanged: {
        if (visible && !hmsServicesReady) {
            initializeHMSServices()
        }
    }

    function initializeHMSServices() {
        // Initialize HMS services
        console.log("Initializing HMS services...")

        // Simulate HMS initialization
        hmsTimer.start()
    }

    Timer {
        id: hmsTimer
        interval: 3000
        running: false
        repeat: false

        onTriggered: {
            hmsServicesReady = true
            console.log("HMS services ready")

            // Check Huawei account status
            huaweiAccountSignedIn = harmonyOSPlatformService.isHuaweiAccountAvailable
        }
    }

    // Connections to platform service signals
    Connections {
        target: harmonyOSPlatformService

        onNetworkStateChanged: {
            console.log("Network state changed:", available)
        }

        onBackgroundTaskCompleted: {
            console.log("Background task completed:", taskName)
        }

        onNotificationReceived: {
            showNotification(title, message)
        }

        onHmsServicesReady: {
            hmsServicesReady = true
            console.log("HMS services are ready")
        }

        onHuaweiAccountSignedIn: {
            huaweiAccountSignedIn = true
            console.log("Huawei account signed in")
        }

        onPaymentCompleted: {
            console.log("Payment completed:", orderId, success)
            if (success) {
                showNotification("支付成功", "订单 " + orderId + " 已完成")
            } else {
                showNotification("支付失败", "订单 " + orderId + " 失败")
            }
        }
    }

    function showNotification(title, message) {
        var component = Qt.createComponent("Notification.qml")
        if (component.status === Component.Ready) {
            var notification = component.createObject(root, {
                "title": title,
                "message": message
            })
            notification.show()
        }
    }
}
