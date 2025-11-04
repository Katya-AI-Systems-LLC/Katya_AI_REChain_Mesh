# UWP (Stub) Guidance

Flutter dropped official UWP target. Options:
- WinUI 3 + Rust/C#/Dart FFI host bridge
- Use `go-flutter` or community forks for UWP (experimental)
- Ship Windows desktop (Win32) as primary on Windows
 
Setup notes:
- Prefer Win32 desktop unless UWP is mandatory.
- If UWP is required, implement a thin WinRT host and embed a webview for Flutter web build as a workaround.
