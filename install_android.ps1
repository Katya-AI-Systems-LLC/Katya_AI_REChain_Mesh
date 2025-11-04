# Скрипт для установки Katya AI REChain Mesh на Android устройство

Write-Host "📱 Установка Katya AI REChain Mesh на Android устройство..." -ForegroundColor Green

# Проверяем подключение устройства
Write-Host "🔍 Проверка подключения устройства..." -ForegroundColor Blue
adb devices

# Проверяем наличие APK
$APK_PATH = "build/app/outputs/flutter-apk/app-release.apk"
if (-not (Test-Path $APK_PATH)) {
    Write-Host "❌ APK файл не найден. Сначала соберите приложение:" -ForegroundColor Red
    Write-Host "   .\build_android.ps1" -ForegroundColor Cyan
    exit 1
}

# Устанавливаем APK
Write-Host "📦 Установка APK..." -ForegroundColor Yellow
adb install -r $APK_PATH

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Приложение установлено успешно!" -ForegroundColor Green
    
    # Запускаем приложение
    Write-Host "🚀 Запуск приложения..." -ForegroundColor Blue
    adb shell am start -n com.katya.rechain.mesh/.MainActivity
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Приложение запущено!" -ForegroundColor Green
    } else {
        Write-Host "❌ Ошибка при запуске приложения" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Ошибка при установке приложения" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🎉 Katya AI REChain Mesh установлен и запущен!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Полезные команды:" -ForegroundColor Blue
Write-Host "   adb logcat | findstr 'Katya'     # Просмотр логов" -ForegroundColor Cyan
Write-Host "   adb shell pm list packages | findstr katya  # Проверка установки" -ForegroundColor Cyan
Write-Host "   adb uninstall com.katya.rechain.mesh     # Удаление приложения" -ForegroundColor Cyan
Write-Host ""
Write-Host "🚀 Наслаждайтесь использованием Katya AI REChain Mesh!" -ForegroundColor Green
