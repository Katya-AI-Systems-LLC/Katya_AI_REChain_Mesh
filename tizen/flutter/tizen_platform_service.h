//
//  tizen_platform_service.h
//  Katya AI REChain Mesh
//
//  Tizen platform service header
//

#ifndef TIZEN_PLATFORM_SERVICE_H_
#define TIZEN_PLATFORM_SERVICE_H_

#include <QObject>
#include <QString>
#include <QTimer>

class TizenPlatformServiceImpl;

class TizenPlatformService : public QObject
{
    Q_OBJECT

public:
    static TizenPlatformService* instance();

    ~TizenPlatformService();

    // System information
    Q_INVOKABLE QString getSystemInfo();
    Q_INVOKABLE QString getDeviceInfo();
    Q_INVOKABLE QString getDeviceId();

    // Secure storage
    Q_INVOKABLE bool storeSecureData(const QString& key, const QString& data);
    Q_INVOKABLE QString retrieveSecureData(const QString& key);

    // Authentication
    Q_INVOKABLE bool authenticateWithSamsung();
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

    // Tizen specific
    Q_INVOKABLE bool isSamsungDevice();
    Q_INVOKABLE bool isTizenOS();
    Q_INVOKABLE QString getSamsungAccountInfo();
    Q_INVOKABLE bool signInWithSamsung();

    // Payment services
    Q_INVOKABLE bool processSamsungPay(const QString& orderId, double amount);
    Q_INVOKABLE bool processKakaoPay(const QString& orderId, double amount);
    Q_INVOKABLE bool processNaverPay(const QString& orderId, double amount);

    // Social media integration
    Q_INVOKABLE bool shareToKakaoTalk(const QString& title, const QString& description, const QString& url);
    Q_INVOKABLE bool shareToNaver(const QString& title, const QString& description, const QString& url);

    // Voice assistant integration
    Q_INVOKABLE bool executeBixbyCommand(const QString& command);

    // IoT integration
    Q_INVOKABLE bool connectSmartThings();

    // Security
    Q_INVOKABLE bool enableKnoxSecurity();

    // Korean localization
    Q_INVOKABLE QString getKoreanTime();
    Q_INVOKABLE QString getKoreanDate();

signals:
    void networkStateChanged(bool available);
    void backgroundTaskCompleted(const QString& taskName);
    void notificationReceived(const QString& title, const QString& message);
    void samsungServicesReady();
    void samsungAccountSignedIn();
    void paymentCompleted(const QString& orderId, bool success);
    void bixbyCommandExecuted(const QString& command, bool success);
    void smartThingsConnected();
    void knoxSecurityEnabled();

private:
    explicit TizenPlatformService(QObject *parent = nullptr);

    static TizenPlatformService* instance_;
    TizenPlatformServiceImpl* impl_;
};

#endif  // TIZEN_PLATFORM_SERVICE_H_
