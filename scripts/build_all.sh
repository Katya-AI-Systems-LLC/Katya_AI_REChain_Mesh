#!/usr/bin/env bash
set -euo pipefail

flutter pub get

for target in "$@"; do
  case "$target" in
    android) flutter build apk --release ;;
    windows) flutter build windows --release ;;
    linux) flutter build linux --release ;;
    web) flutter build web --release ;;
    macos) flutter build macos --release ;;
    ios) flutter build ios --release ;;
  esac
done


