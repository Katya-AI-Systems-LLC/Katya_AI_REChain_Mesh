@echo off
REM Clean and rebuild script for Flutter Android build
REM This script will:
REM 1. Clean Flutter cache
REM 2. Clean Gradle cache
REM 3. Update dependencies
REM 4. Rebuild the APK

echo.
echo ============================================
echo Flutter Android Build Fix Script
echo ============================================
echo.

REM Step 1: Navigate to project directory
cd /d "C:\Users\sorydev\Documents\GitHub\Katya_AI_REChain_Mesh"

echo [1/5] Cleaning Flutter cache...
call flutter clean
if errorlevel 1 (
    echo ERROR: Failed to clean Flutter cache
    exit /b 1
)
echo [DONE] Flutter cache cleaned
echo.

echo [2/5] Cleaning Gradle cache...
cd android
call gradlew clean
if errorlevel 1 (
    echo ERROR: Failed to clean Gradle cache
    cd ..
    exit /b 1
)
cd ..
echo [DONE] Gradle cache cleaned
echo.

echo [3/5] Downloading Gradle 8.9...
REM The gradle wrapper will automatically download the new version
echo [DONE] Gradle wrapper configured
echo.

echo [4/5] Getting Flutter dependencies...
call flutter pub get
if errorlevel 1 (
    echo ERROR: Failed to get dependencies
    exit /b 1
)
echo [DONE] Dependencies updated
echo.

echo [5/5] Building APK...
call flutter build apk --release
if errorlevel 1 (
    echo ERROR: Failed to build APK
    exit /b 1
)
echo [DONE] APK built successfully
echo.

echo ============================================
echo Build completed successfully!
echo ============================================
echo.
echo APK location:
echo build\app\outputs\apk\release\app-release.apk
echo.
pause
