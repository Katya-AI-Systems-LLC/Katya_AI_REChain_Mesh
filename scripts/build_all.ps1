param(
  [switch]$Android,
  [switch]$IOS,
  [switch]$MacOS,
  [switch]$Windows,
  [switch]$Linux,
  [switch]$Web
)

flutter pub get

if ($Android) { flutter build apk --release }
if ($Windows) { flutter build windows --release }
if ($Linux) { flutter build linux --release }
if ($Web) { flutter build web --release }
if ($MacOS) { flutter build macos --release }
if ($IOS) { flutter build ios --release }


