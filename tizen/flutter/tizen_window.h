//
//  tizen_window.h
//  Katya AI REChain Mesh
//
//  Tizen platform window header
//

#ifndef TIZEN_WINDOW_H_
#define TIZEN_WINDOW_H_

#include <QObject>
#include <QQuickView>
#include <QQuickItem>
#include <QQmlEngine>
#include <QString>
#include <QRect>
#include <QSize>
#include <QPoint>

class FlutterView;

class TizenWindow : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int width READ Width WRITE SetSize NOTIFY geometryChanged)
    Q_PROPERTY(int height READ Height WRITE SetSize NOTIFY geometryChanged)
    Q_PROPERTY(QString title READ Title WRITE SetTitle NOTIFY titleChanged)
    Q_PROPERTY(bool visible READ IsVisible WRITE SetVisible NOTIFY visibleChanged)
    Q_PROPERTY(QString platformType READ PlatformType CONSTANT)

public:
    explicit TizenWindow(QObject *parent = nullptr);
    explicit TizenWindow(int width, int height, const QString& title, QObject *parent = nullptr);
    virtual ~TizenWindow();

    bool Initialize();

    // Window management
    Q_INVOKABLE void Show();
    Q_INVOKABLE void Hide();
    Q_INVOKABLE void Close();
    Q_INVOKABLE void SetTitle(const QString &title);
    Q_INVOKABLE void SetSize(int width, int height);
    Q_INVOKABLE void SetPosition(int x, int y);
    Q_INVOKABLE void SetGeometry(int x, int y, int width, int height);
    Q_INVOKABLE void CenterOnScreen();
    Q_INVOKABLE void Maximize();
    Q_INVOKABLE void Minimize();
    Q_INVOKABLE void Restore();
    Q_INVOKABLE void Activate();
    Q_INVOKABLE void SetFocus();

    // Window state
    Q_INVOKABLE bool IsVisible() const;
    Q_INVOKABLE bool IsMaximized() const;
    Q_INVOKABLE bool IsMinimized() const;
    Q_INVOKABLE bool HasFocus() const;

    // Window properties
    Q_INVOKABLE void SetWindowFlags(Qt::WindowFlags flags);
    Q_INVOKABLE Qt::WindowFlags WindowFlags() const;
    Q_INVOKABLE void SetWindowState(Qt::WindowState state);
    Q_INVOKABLE Qt::WindowState WindowState() const;
    Q_INVOKABLE void SetOpacity(qreal opacity);
    Q_INVOKABLE qreal Opacity() const;

    // Getters
    Q_INVOKABLE QRect Geometry() const;
    Q_INVOKABLE QSize Size() const;
    Q_INVOKABLE QPoint Position() const;
    Q_INVOKABLE QString Title() const;
    Q_INVOKABLE int Width() const;
    Q_INVOKABLE int Height() const;
    Q_INVOKABLE QString PlatformType() const;

    // Internal accessors
    QQuickView *GetQuickView() const;
    QQuickItem *GetRootObject() const;
    QQmlEngine *GetQmlEngine() const;
    FlutterView *GetFlutterView() const;
    void SetFlutterView(FlutterView *view);

signals:
    void geometryChanged();
    void titleChanged();
    void visibleChanged();
    void windowCloseRequested();
    void remoteKeyPressed(const QString& key);
    void samsungServicesReady();
    void bixbyCommandReceived(const QString& command);

private slots:
    void onSceneGraphInitialized();
    void onSceneGraphInvalidated();
    void onBeforeRendering();
    void onAfterRendering();
    void onFrameSwapped();
    void onWindowCloseRequested();
    void onRemoteKeyPressed(const QString& key);
    void onSamsungServicesReady();
    void onBixbyCommandReceived(const QString& command);

private:
    QString DetectTizenPlatform();
    void ConfigureQuickView();
    void SetupQmlContext();
    void LoadMainQml();
    void ConnectSignals();
    void InitializeFlutterRendering();
    void InitializeSamsungServices();
    void InitializeSamsungTVServices();
    void InitializeSamsungWearableServices();
    void InitializeSamsungMobileServices();
    void SetupSamsungFeatures();
    void PrepareFlutterFrame();
    void CleanupFlutterFrame();
    void HandleFrameSwap();
    void HandleTVRemoteInput(const QString& key);
    void HandleBixbyCommand(const QString& command);
    void UpdateGeometry();

    // Qt objects
    QQmlEngine *qml_engine_ = nullptr;
    QQuickView *quick_view_ = nullptr;
    QQuickItem *root_object_ = nullptr;

    // Flutter objects
    FlutterView *flutter_view_ = nullptr;

    // Window properties
    int width_;
    int height_;
    QString title_;
    QString platform_type_;
};

#endif  // TIZEN_WINDOW_H_
