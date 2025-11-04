//
//  harmonyos_window.cpp
//  Katya AI REChain Mesh
//
//  HarmonyOS platform window implementation
//

#include "harmonyos_window.h"

#include <QQuickView>
#include <QQuickItem>
#include <QQmlEngine>
#include <QQmlContext>
#include <QScreen>
#include <QApplication>
#include <QDesktopWidget>
#include <QWindow>
#include <QSurfaceFormat>

#include <flutter/flutter_view.h>
#include <flutter/plugin_registry.h>

namespace {

const QString kFlutterWindowTitle = "Katya AI REChain Mesh";
const int kDefaultWindowWidth = 1080;
const int kDefaultWindowHeight = 1920;

}  // namespace

HarmonyOSWindow::HarmonyOSWindow(QObject *parent)
    : QObject(parent)
    , width_(kDefaultWindowWidth)
    , height_(kDefaultWindowHeight)
    , title_(kFlutterWindowTitle)
{
    Initialize();
}

HarmonyOSWindow::~HarmonyOSWindow()
{
    if (quick_view_) {
        quick_view_->deleteLater();
    }
}

bool HarmonyOSWindow::Initialize()
{
    // Create QML application engine
    qml_engine_ = new QQmlApplicationEngine(this);

    // Create quick view for Flutter content
    quick_view_ = new QQuickView(qml_engine_, nullptr);

    if (!quick_view_) {
        qWarning() << "Failed to create QQuickView";
        return false;
    }

    // Configure quick view for HarmonyOS
    ConfigureQuickView();

    // Set up QML context
    SetupQmlContext();

    // Load main QML file
    LoadMainQml();

    // Connect signals
    ConnectSignals();

    return true;
}

void HarmonyOSWindow::ConfigureQuickView()
{
    // Set window properties
    quick_view_->setTitle(title_);
    quick_view_->setResizeMode(QQuickView::SizeRootObjectToView);
    quick_view_->setPersistentOpenGLContext(true);
    quick_view_->setPersistentSceneGraph(true);

    // Set window size
    quick_view_->resize(width_, height_);

    // Set window position (center on screen)
    QScreen *screen = QApplication::primaryScreen();
    if (screen) {
        QRect screenGeometry = screen->geometry();
        int x = (screenGeometry.width() - width_) / 2;
        int y = (screenGeometry.height() - height_) / 2;
        quick_view_->setPosition(x, y);
    }

    // Configure OpenGL context for HarmonyOS
    QSurfaceFormat format = quick_view_->format();
    format.setDepthBufferSize(24);
    format.setStencilBufferSize(8);
    format.setVersion(3, 3);
    format.setProfile(QSurfaceFormat::CoreProfile);

    // Enable HarmonyOS specific features
    format.setOption(QSurfaceFormat::ResetNotification);

    quick_view_->setFormat(format);

    // Set window flags for HarmonyOS
    quick_view_->setFlags(quick_view_->flags() | Qt::Window | Qt::WindowTitleHint | Qt::WindowCloseButtonHint);

    // Enable high DPI support
    quick_view_->setAttribute(Qt::WA_AlwaysShowToolTips);
    quick_view_->setAttribute(Qt::WA_AcceptTouchEvents);

    // HarmonyOS specific attributes
    quick_view_->setAttribute(Qt::WA_AcceptNativeGestureEvents);
    quick_view_->setAttribute(Qt::WA_NativeWindow);
}

void HarmonyOSWindow::SetupQmlContext()
{
    // Expose window object to QML
    qml_engine_->rootContext()->setContextProperty("harmonyOSWindow", this);

    // Expose platform service to QML
    qml_engine_->rootContext()->setContextProperty("harmonyOSPlatformService", HarmonyOSPlatformService::instance());
}

void HarmonyOSWindow::LoadMainQml()
{
    // Load main QML file
    qml_engine_->load(QUrl("qrc:/qml/main.qml"));

    if (qml_engine_->rootObjects().isEmpty()) {
        qWarning() << "Failed to load main.qml";
        return;
    }

    // Get root object
    root_object_ = qml_engine_->rootObjects().first();

    // Set up root object
    if (root_object_) {
        // Configure root object properties
        root_object_->setProperty("width", width_);
        root_object_->setProperty("height", height_);

        // Connect to root object signals
        connect(root_object_, SIGNAL(windowCloseRequested()),
                this, SLOT(onWindowCloseRequested()));
        connect(root_object_, SIGNAL(orientationChanged(int)),
                this, SLOT(onOrientationChanged(int)));
        connect(root_object_, SIGNAL(hmsServicesReady()),
                this, SLOT(onHMSServicesReady()));
    }
}

void HarmonyOSWindow::ConnectSignals()
{
    // Connect quick view signals
    connect(quick_view_, &QQuickView::sceneGraphInitialized,
            this, &HarmonyOSWindow::onSceneGraphInitialized);
    connect(quick_view_, &QQuickView::sceneGraphInvalidated,
            this, &HarmonyOSWindow::onSceneGraphInvalidated);
    connect(quick_view_, &QQuickView::beforeRendering,
            this, &HarmonyOSWindow::onBeforeRendering);
    connect(quick_view_, &QQuickView::afterRendering,
            this, &HarmonyOSWindow::onAfterRendering);
    connect(quick_view_, &QQuickView::frameSwapped,
            this, &HarmonyOSWindow::onFrameSwapped);
}

void HarmonyOSWindow::onSceneGraphInitialized()
{
    qDebug() << "HarmonyOS Scene graph initialized";
    // Initialize Flutter rendering context
    InitializeFlutterRendering();
    // Initialize HMS services
    InitializeHMSServices();
}

void HarmonyOSWindow::onSceneGraphInvalidated()
{
    qDebug() << "Scene graph invalidated";
    // Handle scene graph invalidation
}

void HarmonyOSWindow::onBeforeRendering()
{
    // Prepare for rendering
    PrepareFlutterFrame();
}

void HarmonyOSWindow::onAfterRendering()
{
    // Post-rendering cleanup
    CleanupFlutterFrame();
}

void HarmonyOSWindow::onFrameSwapped()
{
    // Frame swap completed
    HandleFrameSwap();
}

void HarmonyOSWindow::InitializeFlutterRendering()
{
    // Initialize Flutter OpenGL context
    // Set up texture rendering
    // Configure framebuffers
    // Initialize input handling

    qDebug() << "Flutter rendering initialized";
}

void HarmonyOSWindow::InitializeHMSServices()
{
    // Initialize Huawei Mobile Services
    // Set up HMS Core
    // Configure push notifications
    // Initialize analytics
    // Set up location services

    qDebug() << "HMS services initialized";
}

void HarmonyOSWindow::PrepareFlutterFrame()
{
    // Prepare Flutter frame for rendering
    // Update animations
    // Process input events
    // Update platform channels

    if (flutter_view_) {
        // Update Flutter view
    }
}

void HarmonyOSWindow::CleanupFlutterFrame()
{
    // Clean up after frame rendering
    // Release resources
    // Handle frame completion

    if (flutter_view_) {
        // Complete Flutter frame
    }
}

void HarmonyOSWindow::HandleFrameSwap()
{
    // Handle frame swap completion
    // Update display
    // Handle vsync

    if (flutter_view_) {
        // Notify Flutter about frame completion
    }
}

void HarmonyOSWindow::onWindowCloseRequested()
{
    qDebug() << "Window close requested";
    Close();
}

void HarmonyOSWindow::onOrientationChanged(int orientation)
{
    qDebug() << "Orientation changed:" << orientation;

    // Handle orientation change
    HandleOrientationChange(static_cast<Qt::ScreenOrientation>(orientation));
}

void HarmonyOSWindow::onHMSServicesReady()
{
    qDebug() << "HMS services ready";

    // HMS services are ready
    // Set up Huawei-specific features
    SetupHuaweiFeatures();
}

void HarmonyOSWindow::SetupHuaweiFeatures()
{
    // Set up Huawei-specific features
    // Configure Huawei Account
    // Set up Huawei Pay
    // Configure Huawei Cloud
    // Initialize Huawei Analytics

    qDebug() << "Huawei features configured";
}

void HarmonyOSWindow::HandleOrientationChange(Qt::ScreenOrientation orientation)
{
    // Update window orientation
    switch (orientation) {
        case Qt::PortraitOrientation:
            SetPortraitOrientation();
            break;
        case Qt::LandscapeOrientation:
            SetLandscapeOrientation();
            break;
        case Qt::InvertedPortraitOrientation:
            SetInvertedPortraitOrientation();
            break;
        case Qt::InvertedLandscapeOrientation:
            SetInvertedLandscapeOrientation();
            break;
        default:
            break;
    }

    // Notify Flutter about orientation change
    if (flutter_view_) {
        // Update Flutter orientation
    }
}

void HarmonyOSWindow::SetPortraitOrientation()
{
    quick_view_->resize(height_, width_);

    if (root_object_) {
        root_object_->setProperty("width", height_);
        root_object_->setProperty("height", width_);
    }
}

void HarmonyOSWindow::SetLandscapeOrientation()
{
    quick_view_->resize(width_, height_);

    if (root_object_) {
        root_object_->setProperty("width", width_);
        root_object_->setProperty("height", height_);
    }
}

void HarmonyOSWindow::SetInvertedPortraitOrientation()
{
    SetPortraitOrientation();
}

void HarmonyOSWindow::SetInvertedLandscapeOrientation()
{
    SetLandscapeOrientation();
}

void HarmonyOSWindow::Show()
{
    if (quick_view_) {
        quick_view_->show();
        quick_view_->raise();
        quick_view_->requestActivate();
    }
}

void HarmonyOSWindow::Hide()
{
    if (quick_view_) {
        quick_view_->hide();
    }
}

void HarmonyOSWindow::Close()
{
    if (quick_view_) {
        quick_view_->close();
    }
}

void HarmonyOSWindow::SetTitle(const QString &title)
{
    title_ = title;
    if (quick_view_) {
        quick_view_->setTitle(title);
    }
}

void HarmonyOSWindow::SetSize(int width, int height)
{
    width_ = width;
    height_ = height;

    if (quick_view_) {
        quick_view_->resize(width, height);
    }

    if (root_object_) {
        root_object_->setProperty("width", width);
        root_object_->setProperty("height", height);
    }
}

void HarmonyOSWindow::SetPosition(int x, int y)
{
    if (quick_view_) {
        quick_view_->setPosition(x, y);
    }
}

void HarmonyOSWindow::SetGeometry(int x, int y, int width, int height)
{
    SetPosition(x, y);
    SetSize(width, height);
}

bool HarmonyOSWindow::IsVisible() const
{
    return quick_view_ && quick_view_->isVisible();
}

QRect HarmonyOSWindow::Geometry() const
{
    if (quick_view_) {
        return quick_view_->geometry();
    }
    return QRect(0, 0, width_, height_);
}

QSize HarmonyOSWindow::Size() const
{
    if (quick_view_) {
        return quick_view_->size();
    }
    return QSize(width_, height_);
}

QPoint HarmonyOSWindow::Position() const
{
    if (quick_view_) {
        return quick_view_->position();
    }
    return QPoint(0, 0);
}

QString HarmonyOSWindow::Title() const
{
    return title_;
}

int HarmonyOSWindow::Width() const
{
    return width_;
}

int HarmonyOSWindow::Height() const
{
    return height_;
}

void HarmonyOSWindow::UpdateGeometry()
{
    if (quick_view_) {
        QRect geometry = quick_view_->geometry();
        width_ = geometry.width();
        height_ = geometry.height();

        if (root_object_) {
            root_object_->setProperty("width", width_);
            root_object_->setProperty("height", height_);
        }
    }
}

void HarmonyOSWindow::CenterOnScreen()
{
    QScreen *screen = QApplication::primaryScreen();
    if (screen && quick_view_) {
        QRect screenGeometry = screen->geometry();
        QRect windowGeometry = quick_view_->geometry();

        int x = (screenGeometry.width() - windowGeometry.width()) / 2;
        int y = (screenGeometry.height() - windowGeometry.height()) / 2;

        quick_view_->setPosition(x, y);
    }
}

void HarmonyOSWindow::Maximize()
{
    QScreen *screen = QApplication::primaryScreen();
    if (screen && quick_view_) {
        QRect screenGeometry = screen->geometry();
        SetGeometry(screenGeometry.x(), screenGeometry.y(),
                   screenGeometry.width(), screenGeometry.height());
    }
}

void HarmonyOSWindow::Minimize()
{
    if (quick_view_) {
        quick_view_->showMinimized();
    }
}

void HarmonyOSWindow::Restore()
{
    if (quick_view_) {
        quick_view_->showNormal();
    }
}

bool HarmonyOSWindow::IsMaximized() const
{
    if (quick_view_) {
        return quick_view_->windowState() & Qt::WindowMaximized;
    }
    return false;
}

bool HarmonyOSWindow::IsMinimized() const
{
    if (quick_view_) {
        return quick_view_->windowState() & Qt::WindowMinimized;
    }
    return false;
}

void HarmonyOSWindow::SetWindowFlags(Qt::WindowFlags flags)
{
    if (quick_view_) {
        quick_view_->setFlags(flags);
    }
}

Qt::WindowFlags HarmonyOSWindow::WindowFlags() const
{
    if (quick_view_) {
        return quick_view_->flags();
    }
    return Qt::WindowFlags();
}

void HarmonyOSWindow::SetWindowState(Qt::WindowState state)
{
    if (quick_view_) {
        quick_view_->setWindowState(state);
    }
}

Qt::WindowState HarmonyOSWindow::WindowState() const
{
    if (quick_view_) {
        return quick_view_->windowState();
    }
    return Qt::WindowNoState;
}

void HarmonyOSWindow::Activate()
{
    if (quick_view_) {
        quick_view_->requestActivate();
        quick_view_->raise();
    }
}

void HarmonyOSWindow::SetFocus()
{
    if (quick_view_) {
        quick_view_->setFocus();
    }
}

bool HarmonyOSWindow::HasFocus() const
{
    if (quick_view_) {
        return quick_view_->hasFocus();
    }
    return false;
}

void HarmonyOSWindow::SetOpacity(qreal opacity)
{
    if (quick_view_) {
        quick_view_->setOpacity(opacity);
    }
}

qreal HarmonyOSWindow::Opacity() const
{
    if (quick_view_) {
        return quick_view_->opacity();
    }
    return 1.0;
}

void HarmonyOSWindow::SetVisible(bool visible)
{
    if (quick_view_) {
        if (visible) {
            quick_view_->show();
        } else {
            quick_view_->hide();
        }
    }
}

void HarmonyOSWindow::Update()
{
    if (quick_view_) {
        quick_view_->update();
    }
}

void HarmonyOSWindow::Repaint()
{
    if (quick_view_) {
        quick_view_->repaint();
    }
}

QQuickView *HarmonyOSWindow::GetQuickView() const
{
    return quick_view_;
}

QQuickItem *HarmonyOSWindow::GetRootObject() const
{
    return root_object_;
}

QQmlEngine *HarmonyOSWindow::GetQmlEngine() const
{
    return qml_engine_;
}

FlutterView *HarmonyOSWindow::GetFlutterView() const
{
    return flutter_view_;
}

void HarmonyOSWindow::SetFlutterView(FlutterView *view)
{
    flutter_view_ = view;
}
