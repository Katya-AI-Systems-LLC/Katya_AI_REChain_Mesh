//
//  harmonyos_window.h
//  Katya AI REChain Mesh
//
//  HarmonyOS platform window header
//

#ifndef HARMONYOS_WINDOW_H_
#define HARMONYOS_WINDOW_H_

#include <QObject>
#include <QQuickView>
#include <QQuickItem>
#include <QQmlEngine>
#include <QString>
#include <QRect>
#include <QSize>
#include <QPoint>

class FlutterView;

class HarmonyOSWindow : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int width READ Width WRITE SetSize NOTIFY geometryChanged)
    Q_PROPERTY(int height READ Height WRITE SetSize NOTIFY geometryChanged)
    Q_PROPERTY(QString title READ Title WRITE SetTitle NOTIFY titleChanged)
    Q_PROPERTY(bool visible READ IsVisible WRITE SetVisible NOTIFY visibleChanged)

public:
    explicit HarmonyOSWindow(QObject *parent = nullptr);
    virtual ~HarmonyOSWindow();

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
    void orientationChanged(int orientation);
    void hmsServicesReady();

private slots:
    void onSceneGraphInitialized();
    void onSceneGraphInvalidated();
    void onBeforeRendering();
    void onAfterRendering();
    void onFrameSwapped();
    void onWindowCloseRequested();
    void onOrientationChanged(int orientation);
    void onHMSServicesReady();

private:
    void ConfigureQuickView();
    void SetupQmlContext();
    void LoadMainQml();
    void ConnectSignals();
    void InitializeFlutterRendering();
    void InitializeHMSServices();
    void SetupHuaweiFeatures();
    void PrepareFlutterFrame();
    void CleanupFlutterFrame();
    void HandleFrameSwap();
    void HandleOrientationChange(Qt::ScreenOrientation orientation);
    void SetPortraitOrientation();
    void SetLandscapeOrientation();
    void SetInvertedPortraitOrientation();
    void SetInvertedLandscapeOrientation();
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
};

#endif  // HARMONYOS_WINDOW_H_
