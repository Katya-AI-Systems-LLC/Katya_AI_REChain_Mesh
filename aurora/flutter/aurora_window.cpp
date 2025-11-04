//
//  aurora_window.cpp
//  Katya AI REChain Mesh
//
//  Aurora OS platform window implementation
//

#include "aurora_window.h"

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

AuroraWindow::AuroraWindow(QObject *parent)
    : QObject(parent)
    , width_(kDefaultWindowWidth)
    , height_(kDefaultWindowHeight)
    , title_(kFlutterWindowTitle)
{
    Initialize();
}

AuroraWindow::~AuroraWindow()
{
    if (quick_view_) {
        quick_view_->deleteLater();
    }
}

bool AuroraWindow::Initialize()
{
    // Create QML application engine
    qml_engine_ = new QQmlApplicationEngine(this);

    // Create quick view for Flutter content
    quick_view_ = new QQuickView(qml_engine_, nullptr);

    if (!quick_view_) {
        qWarning() << "Failed to create QQuickView";
        return false;
    }

    // Configure quick view
    ConfigureQuickView();

    // Set up QML context
    SetupQmlContext();

    // Load main QML file
    LoadMainQml();

    // Connect signals
    ConnectSignals();

    return true;
}

void AuroraWindow::ConfigureQuickView()
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

    // Configure OpenGL context
    QSurfaceFormat format = quick_view_->format();
    format.setDepthBufferSize(24);
    format.setStencilBufferSize(8);
    format.setVersion(3, 3);
    format.setProfile(QSurfaceFormat::CoreProfile);
    quick_view_->setFormat(format);

    // Set window flags for Aurora OS
    quick_view_->setFlags(quick_view_->flags() | Qt::Window | Qt::WindowTitleHint | Qt::WindowCloseButtonHint);

    // Enable high DPI support
    quick_view_->setAttribute(Qt::WA_AlwaysShowToolTips);
    quick_view_->setAttribute(Qt::WA_AcceptTouchEvents);
}

void AuroraWindow::SetupQmlContext()
{
    // Expose window object to QML
    qml_engine_->rootContext()->setContextProperty("auroraWindow", this);

    // Expose platform service to QML
    qml_engine_->rootContext()->setContextProperty("auroraPlatformService", AuroraPlatformService::instance());
}

void AuroraWindow::LoadMainQml()
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
    }
}

void AuroraWindow::ConnectSignals()
{
    // Connect quick view signals
    connect(quick_view_, &QQuickView::sceneGraphInitialized,
            this, &AuroraWindow::onSceneGraphInitialized);
    connect(quick_view_, &QQuickView::sceneGraphInvalidated,
            this, &AuroraWindow::onSceneGraphInvalidated);
    connect(quick_view_, &QQuickView::beforeRendering,
            this, &AuroraWindow::onBeforeRendering);
    connect(quick_view_, &QQuickView::afterRendering,
            this, &AuroraWindow::onAfterRendering);
    connect(quick_view_, &QQuickView::frameSwapped,
            this, &AuroraWindow::onFrameSwapped);
}

void AuroraWindow::onSceneGraphInitialized()
{
    qDebug() << "Scene graph initialized";
    // Initialize Flutter rendering context
    InitializeFlutterRendering();
}

void AuroraWindow::onSceneGraphInvalidated()
{
    qDebug() << "Scene graph invalidated";
    // Handle scene graph invalidation
}

void AuroraWindow::onBeforeRendering()
{
    // Prepare for rendering
    PrepareFlutterFrame();
}

void AuroraWindow::onAfterRendering()
{
    // Post-rendering cleanup
    CleanupFlutterFrame();
}

void AuroraWindow::onFrameSwapped()
{
    // Frame swap completed
    HandleFrameSwap();
}

void AuroraWindow::InitializeFlutterRendering()
{
    // Initialize Flutter OpenGL context
    // Set up texture rendering
    // Configure framebuffers
    // Initialize input handling

    qDebug() << "Flutter rendering initialized";
}

void AuroraWindow::PrepareFlutterFrame()
{
    // Prepare Flutter frame for rendering
    // Update animations
    // Process input events
    // Update platform channels

    if (flutter_view_) {
        // Update Flutter view
    }
}

void AuroraWindow::CleanupFlutterFrame()
{
    // Clean up after frame rendering
    // Release resources
    // Handle frame completion

    if (flutter_view_) {
        // Complete Flutter frame
    }
}

void AuroraWindow::HandleFrameSwap()
{
    // Handle frame swap completion
    // Update display
    // Handle vsync

    if (flutter_view_) {
        // Notify Flutter about frame completion
    }
}

void AuroraWindow::onWindowCloseRequested()
{
    qDebug() << "Window close requested";
    Close();
}

void AuroraWindow::onOrientationChanged(int orientation)
{
    qDebug() << "Orientation changed:" << orientation;

    // Handle orientation change
    HandleOrientationChange(static_cast<Qt::ScreenOrientation>(orientation));
}

void AuroraWindow::HandleOrientationChange(Qt::ScreenOrientation orientation)
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

void AuroraWindow::SetPortraitOrientation()
{
    quick_view_->resize(height_, width_);

    if (root_object_) {
        root_object_->setProperty("width", height_);
        root_object_->setProperty("height", width_);
    }
}

void AuroraWindow::SetLandscapeOrientation()
{
    quick_view_->resize(width_, height_);

    if (root_object_) {
        root_object_->setProperty("width", width_);
        root_object_->setProperty("height", height_);
    }
}

void AuroraWindow::SetInvertedPortraitOrientation()
{
    SetPortraitOrientation();
}

void AuroraWindow::SetInvertedLandscapeOrientation()
{
    SetLandscapeOrientation();
}

void AuroraWindow::Show()
{
    if (quick_view_) {
        quick_view_->show();
        quick_view_->raise();
        quick_view_->requestActivate();
    }
}

void AuroraWindow::Hide()
{
    if (quick_view_) {
        quick_view_->hide();
    }
}

void AuroraWindow::Close()
{
    if (quick_view_) {
        quick_view_->close();
    }
}

void AuroraWindow::SetTitle(const QString &title)
{
    title_ = title;
    if (quick_view_) {
        quick_view_->setTitle(title);
    }
}

void AuroraWindow::SetSize(int width, int height)
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

void AuroraWindow::SetPosition(int x, int y)
{
    if (quick_view_) {
        quick_view_->setPosition(x, y);
    }
}

void AuroraWindow::SetGeometry(int x, int y, int width, int height)
{
    SetPosition(x, y);
    SetSize(width, height);
}

bool AuroraWindow::IsVisible() const
{
    return quick_view_ && quick_view_->isVisible();
}

QRect AuroraWindow::Geometry() const
{
    if (quick_view_) {
        return quick_view_->geometry();
    }
    return QRect(0, 0, width_, height_);
}

QSize AuroraWindow::Size() const
{
    if (quick_view_) {
        return quick_view_->size();
    }
    return QSize(width_, height_);
}

QPoint AuroraWindow::Position() const
{
    if (quick_view_) {
        return quick_view_->position();
    }
    return QPoint(0, 0);
}

QString AuroraWindow::Title() const
{
    return title_;
}

int AuroraWindow::Width() const
{
    return width_;
}

int AuroraWindow::Height() const
{
    return height_;
}

void AuroraWindow::UpdateGeometry()
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

void AuroraWindow::CenterOnScreen()
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

void AuroraWindow::Maximize()
{
    QScreen *screen = QApplication::primaryScreen();
    if (screen && quick_view_) {
        QRect screenGeometry = screen->geometry();
        SetGeometry(screenGeometry.x(), screenGeometry.y(),
                   screenGeometry.width(), screenGeometry.height());
    }
}

void AuroraWindow::Minimize()
{
    if (quick_view_) {
        quick_view_->showMinimized();
    }
}

void AuroraWindow::Restore()
{
    if (quick_view_) {
        quick_view_->showNormal();
    }
}

bool AuroraWindow::IsMaximized() const
{
    if (quick_view_) {
        return quick_view_->windowState() & Qt::WindowMaximized;
    }
    return false;
}

bool AuroraWindow::IsMinimized() const
{
    if (quick_view_) {
        return quick_view_->windowState() & Qt::WindowMinimized;
    }
    return false;
}

void AuroraWindow::SetWindowFlags(Qt::WindowFlags flags)
{
    if (quick_view_) {
        quick_view_->setFlags(flags);
    }
}

Qt::WindowFlags AuroraWindow::WindowFlags() const
{
    if (quick_view_) {
        return quick_view_->flags();
    }
    return Qt::WindowFlags();
}

void AuroraWindow::SetWindowState(Qt::WindowState state)
{
    if (quick_view_) {
        quick_view_->setWindowState(state);
    }
}

Qt::WindowState AuroraWindow::WindowState() const
{
    if (quick_view_) {
        return quick_view_->windowState();
    }
    return Qt::WindowNoState;
}

void AuroraWindow::Activate()
{
    if (quick_view_) {
        quick_view_->requestActivate();
        quick_view_->raise();
    }
}

void AuroraWindow::SetFocus()
{
    if (quick_view_) {
        quick_view_->setFocus();
    }
}

bool AuroraWindow::HasFocus() const
{
    if (quick_view_) {
        return quick_view_->hasFocus();
    }
    return false;
}

void AuroraWindow::SetOpacity(qreal opacity)
{
    if (quick_view_) {
        quick_view_->setOpacity(opacity);
    }
}

qreal AuroraWindow::Opacity() const
{
    if (quick_view_) {
        return quick_view_->opacity();
    }
    return 1.0;
}

void AuroraWindow::SetVisible(bool visible)
{
    if (quick_view_) {
        if (visible) {
            quick_view_->show();
        } else {
            quick_view_->hide();
        }
    }
}

void AuroraWindow::Update()
{
    if (quick_view_) {
        quick_view_->update();
    }
}

void AuroraWindow::Repaint()
{
    if (quick_view_) {
        quick_view_->repaint();
    }
}

QQuickView *AuroraWindow::GetQuickView() const
{
    return quick_view_;
}

QQuickItem *AuroraWindow::GetRootObject() const
{
    return root_object_;
}

QQmlEngine *AuroraWindow::GetQmlEngine() const
{
    return qml_engine_;
}

FlutterView *AuroraWindow::GetFlutterView() const
{
    return flutter_view_;
}

void AuroraWindow::SetFlutterView(FlutterView *view)
{
    flutter_view_ = view;
}
