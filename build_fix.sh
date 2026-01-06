#!/bin/bash
# Flutter Android Build Fix Script for Mac/Linux
# This script will clean and rebuild the Flutter APK

echo ""
echo "============================================"
echo "Flutter Android Build Fix Script"
echo "============================================"
echo ""

# Navigate to project directory
PROJECT_DIR="$HOME/Documents/GitHub/Katya_AI_REChain_Mesh"
if [ ! -d "$PROJECT_DIR" ]; then
    PROJECT_DIR="$(pwd)"
fi

cd "$PROJECT_DIR" || exit 1

# Step 1: Clean Flutter cache
echo "[1/5] Cleaning Flutter cache..."
flutter clean
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to clean Flutter cache"
    exit 1
fi
echo "[DONE] Flutter cache cleaned"
echo ""

# Step 2: Clean Gradle cache
echo "[2/5] Cleaning Gradle cache..."
cd android || exit 1
./gradlew clean
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to clean Gradle cache"
    cd ..
    exit 1
fi
cd .. || exit 1
echo "[DONE] Gradle cache cleaned"
echo ""

# Step 3: Remove .gradle folder
echo "[3/5] Removing .gradle folder..."
rm -rf android/.gradle
echo "[DONE] .gradle folder removed"
echo ""

# Step 4: Get dependencies
echo "[4/5] Getting Flutter dependencies..."
flutter pub get
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to get dependencies"
    exit 1
fi
echo "[DONE] Dependencies updated"
echo ""

# Step 5: Build APK
echo "[5/5] Building APK..."
flutter build apk --release
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to build APK"
    exit 1
fi
echo "[DONE] APK built successfully"
echo ""

echo "============================================"
echo "Build completed successfully!"
echo "============================================"
echo ""
echo "APK location:"
echo "build/app/outputs/apk/release/app-release.apk"
echo ""
