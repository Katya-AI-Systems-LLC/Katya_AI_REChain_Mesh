#!/usr/bin/env bash
set -e
echo "Building Android APK (release)..."
flutter clean
flutter pub get
flutter build apk --release
echo "APK built at build/app/outputs/flutter-apk/app-release.apk"
