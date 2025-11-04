# Скрипт для установки Katya AI REChain Mesh APK
# Автор: Katya AI REChain Mesh Team
# Версия: 1.0.0

Write-Host "🚀 Katya AI REChain Mesh - Установка APK" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# Проверяем наличие ADB
$adbPath = Get-Command adb -ErrorAction SilentlyContinue
if (-not $adbPath) {
    Write-Host "❌ ADB не найден. Убедитесь, что Android SDK установлен и добавлен в PATH." -ForegroundColor Red
    Write-Host "Скачайте Android SDK Platform Tools: https://developer.android.com/studio/releases/platform-tools" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ ADB найден: $($adbPath.Source)" -ForegroundColor Green

# Проверяем подключенные устройства
Write-Host "`n📱 Проверка подключенных устройств..." -ForegroundColor Yellow
$devices = adb devices | Select-String "device$"
if ($devices.Count -eq 0) {
    Write-Host "❌ Нет подключенных устройств." -ForegroundColor Red
    Write-Host "Подключите Android устройство и включите отладку по USB." -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Найдено устройств: $($devices.Count)" -ForegroundColor Green
foreach ($device in $devices) {
    $deviceId = $device.ToString().Split()[0]
    Write-Host "   - $deviceId" -ForegroundColor White
}

# Ищем APK файл
$apkPath = "build\app\outputs\flutter-apk\app-debug.apk"
if (-not (Test-Path $apkPath)) {
    Write-Host "❌ APK файл не найден: $apkPath" -ForegroundColor Red
    Write-Host "Сначала соберите APK: flutter build apk --debug" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ APK файл найден: $apkPath" -ForegroundColor Green

# Получаем информацию о приложении
$apkInfo = aapt dump badging $apkPath 2>$null
if ($apkInfo) {
    $packageName = ($apkInfo | Select-String "package:").ToString().Split("'")[1]
    $versionName = ($apkInfo | Select-String "versionName:").ToString().Split("'")[1]
    Write-Host "📦 Пакет: $packageName" -ForegroundColor White
    Write-Host "📋 Версия: $versionName" -ForegroundColor White
}

# Устанавливаем APK
Write-Host "`n📲 Установка APK..." -ForegroundColor Yellow
$installResult = adb install -r $apkPath 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ APK успешно установлен!" -ForegroundColor Green
    
    # Запускаем приложение
    Write-Host "`n🚀 Запуск приложения..." -ForegroundColor Yellow
    adb shell am start -n "$packageName/.MainActivity" 2>$null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Приложение запущено!" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Приложение установлено, но не удалось запустить автоматически." -ForegroundColor Yellow
        Write-Host "Запустите приложение вручную с рабочего стола." -ForegroundColor White
    }
    
    Write-Host "`n🎉 Установка завершена успешно!" -ForegroundColor Green
    Write-Host "Приложение 'Katya AI REChain Mesh' готово к использованию." -ForegroundColor White
    
} else {
    Write-Host "❌ Ошибка установки APK:" -ForegroundColor Red
    Write-Host $installResult -ForegroundColor Red
    
    if ($installResult -match "INSTALL_FAILED_ALREADY_EXISTS") {
        Write-Host "`n💡 Приложение уже установлено. Попробуйте:" -ForegroundColor Yellow
        Write-Host "   adb uninstall $packageName" -ForegroundColor White
        Write-Host "   Затем запустите скрипт снова." -ForegroundColor White
    }
}

Write-Host "`n📚 Дополнительная информация:" -ForegroundColor Cyan
Write-Host "- Руководство по тестированию: TESTING_GUIDE.md" -ForegroundColor White
Write-Host "- Исходный код: https://github.com/katya-ai/rechain-mesh" -ForegroundColor White
Write-Host "- Поддержка: support@katya-ai.com" -ForegroundColor White

Write-Host "`n✨ Спасибо за использование Katya AI REChain Mesh!" -ForegroundColor Magenta
