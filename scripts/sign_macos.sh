#!/usr/bin/env bash
set -euo pipefail

APP_PATH="$1" # e.g., build/macos/Build/Products/Release/Runner.app
IDENTITY="$2" # Developer ID Application: Your Name (TEAMID)

codesign --deep --force --options runtime --sign "$IDENTITY" "$APP_PATH"

