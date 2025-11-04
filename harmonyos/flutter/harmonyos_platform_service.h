//
//  harmonyos_platform_service.h
//  Katya AI REChain Mesh
//
//  HarmonyOS platform service header
//

#ifndef HARMONYOS_PLATFORM_SERVICE_H_
#define HARMONYOS_PLATFORM_SERVICE_H_

#include <QObject>
#include <QString>
#include <QTimer>

class HarmonyOSPlatformServiceImpl;

class HarmonyOSPlatformService : public QObject
{
    Q_OBJECT

public:
    static HarmonyOSPlatformService* instance();

    ~HarmonyOSPlatformService();

    // System information
    Q_INVOKABLE QString getSystemInfo();
    Q_INVOKABLE QString getDeviceInfo();
    Q_INVOKABLE QString getDeviceId();

    // Secure storage
    Q_INVOKABLE bool storeSecureData(const QString& key, const QString& data);
    Q_INVOKABLE QString retrieveSecureData(const QString& key);

    // Authentication
    Q_INVOKABLE bool authenticateWithBiometrics();

    // Permissions
    Q_INVOKABLE bool requestLocationPermission();
    Q_INVOKABLE bool requestCameraPermission();
    Q_INVOKABLE bool requestMicrophonePermission();
    Q_INVOKABLE bool requestStoragePermission();

    // Network
    Q_INVOKABLE bool isNetworkAvailable();
    Q_INVOKABLE QString getNetworkInfo();

    // Background tasks
    Q_INVOKABLE bool scheduleBackgroundTask(const QString& taskName, int intervalSeconds);
    Q_INVOKABLE bool cancelBackgroundTask(const QString& taskName);

    // Notifications
    Q_INVOKABLE bool sendNotification(const QString& title, const QString& message);

    // Paths
    Q_INVOKABLE QString getAppDataPath();
    Q_INVOKABLE QString getCachePath();
    Q_INVOKABLE QString getConfigPath();
    Q_INVOKABLE QString getDocumentsPath();
    Q_INVOKABLE QString getPicturesPath();
    Q_INVOKABLE QString getDownloadsPath();

    // HarmonyOS specific
    Q_INVOKABLE bool isHuaweiDevice();
    Q_INVOKABLE bool isHarmonyOS();
    Q_INVOKABLE QString getHuaweiAccountInfo();
    Q_INVOKABLE bool signInWithHuawei();

    // Payment services
    Q_INVOKABLE bool processHuaweiPay(const QString& orderId, double amount);
    Q_INVOKABLE bool processAlipay(const QString& orderId, double amount);
    Q_INVOKABLE bool processWeChatPay(const QString& orderId, double amount);

    // Social media integration
    Q_INVOKABLE bool shareToWeChat(const QString& title, const QString& description, const QString& url);
    Q_INVOKABLE bool shareToWeibo(const QString& title, const QString& description, const QString& url);

signals:
    void networkStateChanged(bool available);
    void backgroundTaskCompleted(const QString& taskName);
    void notificationReceived(const QString& title, const QString& message);
    void hmsServicesReady();
    void huaweiAccountSignedIn();
    void paymentCompleted(const QString& orderId, bool success);

private:
    explicit HarmonyOSPlatformService(QObject *parent = nullptr);

    static HarmonyOSPlatformService* instance_;
    HarmonyOSPlatformServiceImpl* impl_;
};

#endif  // HARMONYOS_PLATFORM_SERVICE_H_
