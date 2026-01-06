#!/usr/bin/env powershell
# Flutter Android Build Fix Script
# This script will clean and rebuild the Flutter APK

Write-Host ""
Write-Host "============================================"
Write-Host "Flutter Android Build Fix Script"
Write-Host "============================================"
Write-Host ""

# Navigate to project directory
$projectDir = "C:\Users\sorydev\Documents\GitHub\Katya_AI_REChain_Mesh"
Set-Location $projectDir

# Step 1: Clean Flutter cache
Write-Host "[1/5] Cleaning Flutter cache..." -ForegroundColor Green
flutter clean
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to clean Flutter cache" -ForegroundColor Red
    exit 1
}
Write-Host "[DONE] Flutter cache cleaned" -ForegroundColor Green
Write-Host ""

# Step 2: Clean Gradle cache
Write-Host "[2/5] Cleaning Gradle cache..." -ForegroundColor Green
Set-Location "$projectDir\android"
.\gradlew clean
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to clean Gradle cache" -ForegroundColor Red
    Set-Location $projectDir
    exit 1
}
Set-Location $projectDir
Write-Host "[DONE] Gradle cache cleaned" -ForegroundColor Green
Write-Host ""

# Step 3: Delete .gradle folder
Write-Host "[3/5] Removing .gradle folder..." -ForegroundColor Green
Remove-Item -Path "$projectDir\android\.gradle" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "[DONE] .gradle folder removed" -ForegroundColor Green
Write-Host ""

# Step 4: Get dependencies
Write-Host "[4/5] Getting Flutter dependencies..." -ForegroundColor Green
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to get dependencies" -ForegroundColor Red
    exit 1
}
Write-Host "[DONE] Dependencies updated" -ForegroundColor Green
Write-Host ""

# Step 5: Build APK
Write-Host "[5/5] Building APK..." -ForegroundColor Green
flutter build apk --release
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to build APK" -ForegroundColor Red
    exit 1
}
Write-Host "[DONE] APK built successfully" -ForegroundColor Green
Write-Host ""

Write-Host "============================================"
Write-Host "Build completed successfully!" -ForegroundColor Green
Write-Host "============================================"
Write-Host ""
Write-Host "APK location:"
Write-Host "build\app\outputs\apk\release\app-release.apk"
Write-Host ""
