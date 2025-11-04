//
//  aurora_platform_service.h
//  Katya AI REChain Mesh
//
//  Aurora OS platform service header
//

#ifndef AURORA_PLATFORM_SERVICE_H_
#define AURORA_PLATFORM_SERVICE_H_

#include <QObject>
#include <QString>
#include <QTimer>

class AuroraPlatformServiceImpl;

class AuroraPlatformService : public QObject
{
    Q_OBJECT

public:
    static AuroraPlatformService* instance();

    ~AuroraPlatformService();

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

signals:
    void networkStateChanged(bool available);
    void backgroundTaskCompleted(const QString& taskName);
    void notificationReceived(const QString& title, const QString& message);

private:
    explicit AuroraPlatformService(QObject *parent = nullptr);

    static AuroraPlatformService* instance_;
    AuroraPlatformServiceImpl* impl_;
};

#endif  // AURORA_PLATFORM_SERVICE_H_
