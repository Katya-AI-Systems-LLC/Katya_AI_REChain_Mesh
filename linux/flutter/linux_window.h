//
//  linux_window.h
//  Katya AI REChain Mesh
//
//  Linux platform window header
//

#ifndef LINUX_WINDOW_H_
#define LINUX_WINDOW_H_

#include <string>
#include <X11/Xlib.h>
#include <gtk/gtk.h>

class FlutterView;

class LinuxWindow {
 public:
  LinuxWindow(int width, int height, const std::string& title);
  virtual ~LinuxWindow();

  bool Initialize();
  void Run();

  // Window management
  void SetTitle(const std::string& title);
  void SetSize(int width, int height);
  void SetPosition(int x, int y);
  void Show();
  void Hide();
  void Close();
  void Maximize();
  void Minimize();
  void Restore();

  // Window state
  bool IsMaximized();
  bool IsMinimized();
  bool IsVisible();

  // Window properties
  void SetResizable(bool resizable);
  void SetDecorated(bool decorated);
  void SetKeepAbove(bool keep_above);
  void SetSkipTaskbar(bool skip);
  void SetOpacity(double opacity);

  // Getters
  Display* GetDisplay() const;
  Window GetWindow() const;
  int GetWidth() const;
  int GetHeight() const;
  std::string GetTitle() const;

 private:
  // GTK callbacks
  void OnActivate();
  void OnShutdown();
  void OnWindowDestroy();
  gboolean OnWindowDelete();
  void OnWindowConfigure(GdkEventConfigure* event);
  void OnWindowFocusIn();
  void OnWindowFocusOut();
  void OnKeyPress(GdkEventKey* event);
  void OnKeyRelease(GdkEventKey* event);
  void OnButtonPress(GdkEventButton* event);
  void OnButtonRelease(GdkEventButton* event);
  void OnMotionNotify(GdkEventMotion* event);
  void OnScroll(GdkEventScroll* event);
  void OnDraw(cairo_t* cr);
  void OnFlutterViewConfigure(GdkEventConfigure* event);

  // Internal methods
  void CreateMainWindow();
  void SetWindowIcon();
  void SetupFlutterView();
  void InitializeFlutter();
  void HandleKeyEvent(GdkEventKey* event, bool is_press);
  void HandlePointerEvent(GdkEventButton* event, bool is_down);
  void HandleScrollEvent(GdkEventScroll* event);

  // GTK objects
  GtkApplication* gtk_application_ = nullptr;
  GtkWidget* gtk_window_ = nullptr;
  GtkWidget* flutter_view_container_ = nullptr;

  // X11 objects
  Display* display_ = nullptr;
  Window window_ = 0;

  // Flutter objects
  FlutterView* flutter_view_ = nullptr;

  // Window properties
  int width_;
  int height_;
  std::string title_;
};

#endif  // LINUX_WINDOW_H_
