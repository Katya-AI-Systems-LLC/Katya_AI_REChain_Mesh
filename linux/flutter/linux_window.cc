//
//  linux_window.cc
//  Katya AI REChain Mesh
//
//  Linux platform window implementation
//

#include "linux_window.h"

#include <flutter/flutter_view.h>
#include <flutter/plugin_registry.h>

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/extensions/XInput2.h>
#include <gtk/gtk.h>
#include <gdk/gdkx.h>

#include "flutter/generated_plugin_registrant.h"

namespace {

const char* kFlutterWindowTitle = "Katya AI REChain Mesh";
const int kDefaultWindowWidth = 1280;
const int kDefaultWindowHeight = 720;

// Helper function to convert Flutter key codes to X11 key codes
KeySym FlutterKeyToX11KeyCode(uint32_t flutter_key) {
  // Key code mapping table
  switch (flutter_key) {
    case 0x00000020: return XK_space;
    case 0x00000021: return XK_exclam;
    case 0x00000022: return XK_quotedbl;
    case 0x00000023: return XK_numbersign;
    case 0x00000024: return XK_dollar;
    case 0x00000025: return XK_percent;
    case 0x00000026: return XK_ampersand;
    case 0x00000027: return XK_apostrophe;
    case 0x00000028: return XK_parenleft;
    case 0x00000029: return XK_parenright;
    case 0x0000002A: return XK_asterisk;
    case 0x0000002B: return XK_plus;
    case 0x0000002C: return XK_comma;
    case 0x0000002D: return XK_minus;
    case 0x0000002E: return XK_period;
    case 0x0000002F: return XK_slash;
    case 0x00000030: return XK_0;
    case 0x00000031: return XK_1;
    case 0x00000032: return XK_2;
    case 0x00000033: return XK_3;
    case 0x00000034: return XK_4;
    case 0x00000035: return XK_5;
    case 0x00000036: return XK_6;
    case 0x00000037: return XK_7;
    case 0x00000038: return XK_8;
    case 0x00000039: return XK_9;
    case 0x0000003A: return XK_colon;
    case 0x0000003B: return XK_semicolon;
    case 0x0000003C: return XK_less;
    case 0x0000003D: return XK_equal;
    case 0x0000003E: return XK_greater;
    case 0x0000003F: return XK_question;
    case 0x00000040: return XK_at;
    case 0x00000041: return XK_A;
    case 0x00000042: return XK_B;
    case 0x00000043: return XK_C;
    case 0x00000044: return XK_D;
    case 0x00000045: return XK_E;
    case 0x00000046: return XK_F;
    case 0x00000047: return XK_G;
    case 0x00000048: return XK_H;
    case 0x00000049: return XK_I;
    case 0x0000004A: return XK_J;
    case 0x0000004B: return XK_K;
    case 0x0000004C: return XK_L;
    case 0x0000004D: return XK_M;
    case 0x0000004E: return XK_N;
    case 0x0000004F: return XK_O;
    case 0x00000050: return XK_P;
    case 0x00000051: return XK_Q;
    case 0x00000052: return XK_R;
    case 0x00000053: return XK_S;
    case 0x00000054: return XK_T;
    case 0x00000055: return XK_U;
    case 0x00000056: return XK_V;
    case 0x00000057: return XK_W;
    case 0x00000058: return XK_X;
    case 0x00000059: return XK_Y;
    case 0x0000005A: return XK_Z;
    case 0x0000005B: return XK_bracketleft;
    case 0x0000005C: return XK_backslash;
    case 0x0000005D: return XK_bracketright;
    case 0x0000005E: return XK_asciicircum;
    case 0x0000005F: return XK_underscore;
    case 0x00000060: return XK_grave;
    case 0x00000061: return XK_a;
    case 0x00000062: return XK_b;
    case 0x00000063: return XK_c;
    case 0x00000064: return XK_d;
    case 0x00000065: return XK_e;
    case 0x00000066: return XK_f;
    case 0x00000067: return XK_g;
    case 0x00000068: return XK_h;
    case 0x00000069: return XK_i;
    case 0x0000006A: return XK_j;
    case 0x0000006B: return XK_k;
    case 0x0000006C: return XK_l;
    case 0x0000006D: return XK_m;
    case 0x0000006E: return XK_n;
    case 0x0000006F: return XK_o;
    case 0x00000070: return XK_p;
    case 0x00000071: return XK_q;
    case 0x00000072: return XK_r;
    case 0x00000073: return XK_s;
    case 0x00000074: return XK_t;
    case 0x00000075: return XK_u;
    case 0x00000076: return XK_v;
    case 0x00000077: return XK_w;
    case 0x00000078: return XK_x;
    case 0x00000079: return XK_y;
    case 0x0000007A: return XK_z;
    case 0x0000007B: return XK_braceleft;
    case 0x0000007C: return XK_bar;
    case 0x0000007D: return XK_braceright;
    case 0x0000007E: return XK_asciitilde;
    case 0x0000007F: return XK_Delete;
    case 0x000000FF: return XK_Delete;
    case 0x00000100: return XK_BackSpace;
    case 0x00000101: return XK_Tab;
    case 0x00000102: return XK_Linefeed;
    case 0x00000103: return XK_Clear;
    case 0x00000104: return XK_Return;
    case 0x00000105: return XK_Pause;
    case 0x00000106: return XK_Scroll_Lock;
    case 0x00000107: return XK_Sys_Req;
    case 0x00000108: return XK_Escape;
    case 0x00000109: return XK_Delete;
    case 0x0000010A: return XK_Home;
    case 0x0000010B: return XK_Left;
    case 0x0000010C: return XK_Up;
    case 0x0000010D: return XK_Right;
    case 0x0000010E: return XK_Down;
    case 0x0000010F: return XK_Prior;
    case 0x00000110: return XK_Next;
    case 0x00000111: return XK_End;
    case 0x00000112: return XK_Begin;
    case 0x00000113: return XK_Select;
    case 0x00000114: return XK_Print;
    case 0x00000115: return XK_Execute;
    case 0x00000116: return XK_Insert;
    case 0x00000117: return XK_Undo;
    case 0x00000118: return XK_Redo;
    case 0x00000119: return XK_Menu;
    case 0x0000011A: return XK_Find;
    case 0x0000011B: return XK_Cancel;
    case 0x0000011C: return XK_Help;
    case 0x0000011D: return XK_Break;
    case 0x0000011E: return XK_Mode_switch;
    case 0x0000011F: return XK_script_switch;
    case 0x00000120: return XK_Num_Lock;
    case 0x00000121: return XK_KP_Space;
    case 0x00000122: return XK_KP_Tab;
    case 0x00000123: return XK_KP_Enter;
    case 0x00000124: return XK_KP_F1;
    case 0x00000125: return XK_KP_F2;
    case 0x00000126: return XK_KP_F3;
    case 0x00000127: return XK_KP_F4;
    case 0x00000128: return XK_KP_Home;
    case 0x00000129: return XK_KP_Left;
    case 0x0000012A: return XK_KP_Up;
    case 0x0000012B: return XK_KP_Right;
    case 0x0000012C: return XK_KP_Down;
    case 0x0000012D: return XK_KP_Prior;
    case 0x0000012E: return XK_KP_Next;
    case 0x0000012F: return XK_KP_End;
    case 0x00000130: return XK_KP_Begin;
    case 0x00000131: return XK_KP_Insert;
    case 0x00000132: return XK_KP_Delete;
    case 0x00000133: return XK_KP_Equal;
    case 0x00000134: return XK_KP_Multiply;
    case 0x00000135: return XK_KP_Add;
    case 0x00000136: return XK_KP_Separator;
    case 0x00000137: return XK_KP_Subtract;
    case 0x00000138: return XK_KP_Decimal;
    case 0x00000139: return XK_KP_Divide;
    case 0x0000013A: return XK_KP_0;
    case 0x0000013B: return XK_KP_1;
    case 0x0000013C: return XK_KP_2;
    case 0x0000013D: return XK_KP_3;
    case 0x0000013E: return XK_KP_4;
    case 0x0000013F: return XK_KP_5;
    case 0x00000140: return XK_KP_6;
    case 0x00000141: return XK_KP_7;
    case 0x00000142: return XK_KP_8;
    case 0x00000143: return XK_KP_9;
    case 0x00000144: return XK_F1;
    case 0x00000145: return XK_F2;
    case 0x00000146: return XK_F3;
    case 0x00000147: return XK_F4;
    case 0x00000148: return XK_F5;
    case 0x00000149: return XK_F6;
    case 0x0000014A: return XK_F7;
    case 0x0000014B: return XK_F8;
    case 0x0000014C: return XK_F9;
    case 0x0000014D: return XK_F10;
    case 0x0000014E: return XK_F11;
    case 0x0000014F: return XK_F12;
    case 0x00000150: return XK_F13;
    case 0x00000151: return XK_F14;
    case 0x00000152: return XK_F15;
    case 0x00000153: return XK_F16;
    case 0x00000154: return XK_F17;
    case 0x00000155: return XK_F18;
    case 0x00000156: return XK_F19;
    case 0x00000157: return XK_F20;
    case 0x00000158: return XK_F21;
    case 0x00000159: return XK_F22;
    case 0x0000015A: return XK_F23;
    case 0x0000015B: return XK_F24;
    case 0x0000015C: return XK_F25;
    case 0x0000015D: return XK_F26;
    case 0x0000015E: return XK_F27;
    case 0x0000015F: return XK_F28;
    case 0x00000160: return XK_F29;
    case 0x00000161: return XK_F30;
    case 0x00000162: return XK_F31;
    case 0x00000163: return XK_F32;
    case 0x00000164: return XK_F33;
    case 0x00000165: return XK_F34;
    case 0x00000166: return XK_F35;
    case 0x00000167: return XK_Shift_L;
    case 0x00000168: return XK_Shift_R;
    case 0x00000169: return XK_Control_L;
    case 0x0000016A: return XK_Control_R;
    case 0x0000016B: return XK_Caps_Lock;
    case 0x0000016C: return XK_Shift_Lock;
    case 0x0000016D: return XK_Meta_L;
    case 0x0000016E: return XK_Meta_R;
    case 0x0000016F: return XK_Alt_L;
    case 0x00000170: return XK_Alt_R;
    case 0x00000171: return XK_Super_L;
    case 0x00000172: return XK_Super_R;
    case 0x00000173: return XK_Hyper_L;
    case 0x00000174: return XK_Hyper_R;
    default: return XK_VoidSymbol;
  }
}

}  // namespace

LinuxWindow::LinuxWindow(int width, int height, const std::string& title)
    : width_(width), height_(height), title_(title) {
  Initialize();
}

LinuxWindow::~LinuxWindow() {
  if (display_) {
    XCloseDisplay(display_);
  }
  if (gtk_window_) {
    gtk_widget_destroy(gtk_window_);
  }
  if (gtk_application_) {
    g_object_unref(gtk_application_);
  }
}

bool LinuxWindow::Initialize() {
  // Initialize GTK
  if (!gtk_init_check(nullptr, nullptr)) {
    return false;
  }

  // Create GTK application
  gtk_application_ = gtk_application_new("com.katyaairechainmesh.app",
                                        G_APPLICATION_FLAGS_NONE);
  if (!gtk_application_) {
    return false;
  }

  // Connect application signals
  g_signal_connect(gtk_application_, "activate",
                   G_CALLBACK(+[](GtkApplication* app, gpointer data) {
                     static_cast<LinuxWindow*>(data)->OnActivate();
                   }), this);

  g_signal_connect(gtk_application_, "shutdown",
                   G_CALLBACK(+[](GtkApplication* app, gpointer data) {
                     static_cast<LinuxWindow*>(data)->OnShutdown();
                   }), this);

  return true;
}

void LinuxWindow::OnActivate() {
  // Create main window
  CreateMainWindow();

  // Show window
  gtk_widget_show_all(gtk_window_);

  // Set up Flutter view
  SetupFlutterView();
}

void LinuxWindow::CreateMainWindow() {
  // Create GTK window
  gtk_window_ = gtk_application_window_new(gtk_application_);
  gtk_window_set_title(GTK_WINDOW(gtk_window_), title_.c_str());
  gtk_window_set_default_size(GTK_WINDOW(gtk_window_), width_, height_);

  // Set window properties
  gtk_window_set_position(GTK_WINDOW(gtk_window_), GTK_WIN_POS_CENTER);
  gtk_window_set_resizable(GTK_WINDOW(gtk_window_), TRUE);
  gtk_window_set_decorated(GTK_WINDOW(gtk_window_), TRUE);

  // Set window icon
  SetWindowIcon();

  // Connect window signals
  g_signal_connect(gtk_window_, "destroy",
                   G_CALLBACK(+[](GtkWidget* widget, gpointer data) {
                     static_cast<LinuxWindow*>(data)->OnWindowDestroy();
                   }), this);

  g_signal_connect(gtk_window_, "delete-event",
                   G_CALLBACK(+[](GtkWidget* widget, GdkEvent* event, gpointer data) {
                     return static_cast<LinuxWindow*>(data)->OnWindowDelete();
                   }), this);

  g_signal_connect(gtk_window_, "configure-event",
                   G_CALLBACK(+[](GtkWidget* widget, GdkEventConfigure* event, gpointer data) {
                     static_cast<LinuxWindow*>(data)->OnWindowConfigure(event);
                     return FALSE;
                   }), this);

  g_signal_connect(gtk_window_, "focus-in-event",
                   G_CALLBACK(+[](GtkWidget* widget, GdkEventFocus* event, gpointer data) {
                     static_cast<LinuxWindow*>(data)->OnWindowFocusIn();
                     return FALSE;
                   }), this);

  g_signal_connect(gtk_window_, "focus-out-event",
                   G_CALLBACK(+[](GtkWidget* widget, GdkEventFocus* event, gpointer data) {
                     static_cast<LinuxWindow*>(data)->OnWindowFocusOut();
                     return FALSE;
                   }), this);

  g_signal_connect(gtk_window_, "key-press-event",
                   G_CALLBACK(+[](GtkWidget* widget, GdkEventKey* event, gpointer data) {
                     static_cast<LinuxWindow*>(data)->OnKeyPress(event);
                     return FALSE;
                   }), this);

  g_signal_connect(gtk_window_, "key-release-event",
                   G_CALLBACK(+[](GtkWidget* widget, GdkEventKey* event, gpointer data) {
                     static_cast<LinuxWindow*>(data)->OnKeyRelease(event);
                     return FALSE;
                   }), this);

  g_signal_connect(gtk_window_, "button-press-event",
                   G_CALLBACK(+[](GtkWidget* widget, GdkEventButton* event, gpointer data) {
                     static_cast<LinuxWindow*>(data)->OnButtonPress(event);
                     return FALSE;
                   }), this);

  g_signal_connect(gtk_window_, "button-release-event",
                   G_CALLBACK(+[](GtkWidget* widget, GdkEventButton* event, gpointer data) {
                     static_cast<LinuxWindow*>(data)->OnButtonRelease(event);
                     return FALSE;
                   }), this);

  g_signal_connect(gtk_window_, "motion-notify-event",
                   G_CALLBACK(+[](GtkWidget* widget, GdkEventMotion* event, gpointer data) {
                     static_cast<LinuxWindow*>(data)->OnMotionNotify(event);
                     return FALSE;
                   }), this);

  g_signal_connect(gtk_window_, "scroll-event",
                   G_CALLBACK(+[](GtkWidget* widget, GdkEventScroll* event, gpointer data) {
                     static_cast<LinuxWindow*>(data)->OnScroll(event);
                     return FALSE;
                   }), this);

  // Enable motion events
  gtk_widget_add_events(gtk_window_,
                       GDK_BUTTON_PRESS_MASK |
                       GDK_BUTTON_RELEASE_MASK |
                       GDK_BUTTON_MOTION_MASK |
                       GDK_SCROLL_MASK |
                       GDK_SMOOTH_SCROLL_MASK |
                       GDK_KEY_PRESS_MASK |
                       GDK_KEY_RELEASE_MASK |
                       GDK_FOCUS_CHANGE_MASK |
                       GDK_STRUCTURE_MASK);

  // Realize window
  gtk_widget_realize(gtk_window_);

  // Get X11 display and window
  GdkWindow* gdk_window = gtk_widget_get_window(gtk_window_);
  if (gdk_window) {
    display_ = GDK_WINDOW_XDISPLAY(gdk_window);
    window_ = GDK_WINDOW_XID(gdk_window);
  }
}

void LinuxWindow::SetWindowIcon() {
  // Set window icon from embedded resources or file
  // This would typically load an icon from the application's resources
  // For now, use default GTK icon
}

void LinuxWindow::SetupFlutterView() {
  // Create Flutter view container
  flutter_view_container_ = gtk_drawing_area_new();
  gtk_widget_set_size_request(flutter_view_container_, width_, height_);

  // Add to window
  gtk_container_add(GTK_CONTAINER(gtk_window_), flutter_view_container_);

  // Connect drawing area signals
  g_signal_connect(flutter_view_container_, "draw",
                   G_CALLBACK(+[](GtkWidget* widget, cairo_t* cr, gpointer data) {
                     return static_cast<LinuxWindow*>(data)->OnDraw(cr);
                   }), this);

  g_signal_connect(flutter_view_container_, "configure-event",
                   G_CALLBACK(+[](GtkWidget* widget, GdkEventConfigure* event, gpointer data) {
                     static_cast<LinuxWindow*>(data)->OnFlutterViewConfigure(event);
                     return FALSE;
                   }), this);

  // Show drawing area
  gtk_widget_show(flutter_view_container_);

  // Initialize Flutter view
  InitializeFlutter();
}

void LinuxWindow::InitializeFlutter() {
  // Initialize Flutter rendering context
  // Set up OpenGL context or software rendering
  // Configure input handling
  // Start Flutter engine
}

void LinuxWindow::Run() {
  // Start GTK main loop
  g_application_run(G_APPLICATION(gtk_application_), 0, nullptr);
}

void LinuxWindow::OnShutdown() {
  // Application shutdown
  if (gtk_window_) {
    gtk_widget_destroy(gtk_window_);
    gtk_window_ = nullptr;
  }
}

void LinuxWindow::OnWindowDestroy() {
  // Window destroyed
  gtk_main_quit();
}

gboolean LinuxWindow::OnWindowDelete() {
  // Window close requested
  return FALSE;  // Allow window to close
}

void LinuxWindow::OnWindowConfigure(GdkEventConfigure* event) {
  // Window configuration changed
  width_ = event->width;
  height_ = event->height;

  // Notify Flutter about size change
  if (flutter_view_) {
    // Update Flutter view size
  }
}

void LinuxWindow::OnWindowFocusIn() {
  // Window gained focus
  if (flutter_view_) {
    // Notify Flutter about focus change
  }
}

void LinuxWindow::OnWindowFocusOut() {
  // Window lost focus
  if (flutter_view_) {
    // Notify Flutter about focus change
  }
}

void LinuxWindow::OnKeyPress(GdkEventKey* event) {
  // Key press event
  HandleKeyEvent(event, true);
}

void LinuxWindow::OnKeyRelease(GdkEventKey* event) {
  // Key release event
  HandleKeyEvent(event, false);
}

void LinuxWindow::HandleKeyEvent(GdkEventKey* event, bool is_press) {
  // Convert GDK key event to Flutter key event
  if (flutter_view_) {
    // Send key event to Flutter
  }
}

void LinuxWindow::OnButtonPress(GdkEventButton* event) {
  // Button press event
  HandlePointerEvent(event, true);
}

void LinuxWindow::OnButtonRelease(GdkEventButton* event) {
  // Button release event
  HandlePointerEvent(event, false);
}

void LinuxWindow::OnMotionNotify(GdkEventMotion* event) {
  // Motion notify event
  HandlePointerEvent(event, true);
}

void LinuxWindow::OnScroll(GdkEventScroll* event) {
  // Scroll event
  HandleScrollEvent(event);
}

void LinuxWindow::HandlePointerEvent(GdkEventButton* event, bool is_down) {
  // Convert GDK pointer event to Flutter pointer event
  if (flutter_view_) {
    // Send pointer event to Flutter
  }
}

void LinuxWindow::HandleScrollEvent(GdkEventScroll* event) {
  // Convert GDK scroll event to Flutter scroll event
  if (flutter_view_) {
    // Send scroll event to Flutter
  }
}

gboolean LinuxWindow::OnDraw(cairo_t* cr) {
  // Drawing callback
  if (flutter_view_) {
    // Render Flutter content
  }
  return FALSE;
}

void LinuxWindow::OnFlutterViewConfigure(GdkEventConfigure* event) {
  // Flutter view configuration changed
  if (flutter_view_) {
    // Update Flutter view size and position
  }
}

void LinuxWindow::SetTitle(const std::string& title) {
  title_ = title;
  if (gtk_window_) {
    gtk_window_set_title(GTK_WINDOW(gtk_window_), title.c_str());
  }
}

void LinuxWindow::SetSize(int width, int height) {
  width_ = width;
  height_ = height;
  if (gtk_window_) {
    gtk_window_resize(GTK_WINDOW(gtk_window_), width, height);
  }
}

void LinuxWindow::SetPosition(int x, int y) {
  if (gtk_window_) {
    gtk_window_move(GTK_WINDOW(gtk_window_), x, y);
  }
}

void LinuxWindow::Show() {
  if (gtk_window_) {
    gtk_widget_show_all(gtk_window_);
  }
}

void LinuxWindow::Hide() {
  if (gtk_window_) {
    gtk_widget_hide(gtk_window_);
  }
}

void LinuxWindow::Close() {
  if (gtk_window_) {
    gtk_window_close(GTK_WINDOW(gtk_window_));
  }
}

void LinuxWindow::Maximize() {
  if (gtk_window_) {
    gtk_window_maximize(GTK_WINDOW(gtk_window_));
  }
}

void LinuxWindow::Minimize() {
  if (gtk_window_) {
    gtk_window_iconify(GTK_WINDOW(gtk_window_));
  }
}

void LinuxWindow::Restore() {
  if (gtk_window_) {
    gtk_window_unmaximize(GTK_WINDOW(gtk_window_));
  }
}

bool LinuxWindow::IsMaximized() {
  if (gtk_window_) {
    return gtk_window_is_maximized(GTK_WINDOW(gtk_window_));
  }
  return false;
}

bool LinuxWindow::IsMinimized() {
  if (gtk_window_) {
    return gtk_window_is_iconified(GTK_WINDOW(gtk_window_));
  }
  return false;
}

bool LinuxWindow::IsVisible() {
  if (gtk_window_) {
    return gtk_widget_get_visible(gtk_window_);
  }
  return false;
}

void LinuxWindow::SetResizable(bool resizable) {
  if (gtk_window_) {
    gtk_window_set_resizable(GTK_WINDOW(gtk_window_), resizable);
  }
}

void LinuxWindow::SetDecorated(bool decorated) {
  if (gtk_window_) {
    gtk_window_set_decorated(GTK_WINDOW(gtk_window_), decorated);
  }
}

void LinuxWindow::SetKeepAbove(bool keep_above) {
  if (gtk_window_) {
    gtk_window_set_keep_above(GTK_WINDOW(gtk_window_), keep_above);
  }
}

void LinuxWindow::SetSkipTaskbar(bool skip) {
  if (gtk_window_) {
    gtk_window_set_skip_taskbar_hint(GTK_WINDOW(gtk_window_), skip);
  }
}

void LinuxWindow::SetOpacity(double opacity) {
  if (gtk_window_) {
    gtk_widget_set_opacity(gtk_window_, opacity);
  }
}

Display* LinuxWindow::GetDisplay() const {
  return display_;
}

Window LinuxWindow::GetWindow() const {
  return window_;
}

int LinuxWindow::GetWidth() const {
  return width_;
}

int LinuxWindow::GetHeight() const {
  return height_;
}

std::string LinuxWindow::GetTitle() const {
  return title_;
}
