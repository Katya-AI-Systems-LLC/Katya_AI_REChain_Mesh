# Скрипт для сборки и установки Katya AI REChain Mesh
# Автор: Katya AI REChain Mesh Team
# Версия: 1.0.0

param(
    [switch]$BuildOnly,
    [switch]$InstallOnly,
    [switch]$Clean
)

Write-Host "🚀 Katya AI REChain Mesh - Сборка и установка" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

# Функция для очистки проекта
function Clean-Project {
    Write-Host "🧹 Очистка проекта..." -ForegroundColor Yellow
    flutter clean
    flutter pub get
    Write-Host "✅ Проект очищен" -ForegroundColor Green
}

# Функция для сборки APK
function Build-APK {
    Write-Host "🔨 Сборка APK..." -ForegroundColor Yellow
    
    # Проверяем Flutter
    $flutterVersion = flutter --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Flutter не найден. Убедитесь, что Flutter установлен и добавлен в PATH." -ForegroundColor Red
        exit 1
    }
    
    Write-Host "✅ Flutter найден" -ForegroundColor Green
    
    # Собираем APK
    flutter build apk --debug
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ APK успешно собран!" -ForegroundColor Green
        
        # Показываем информацию о APK
        $apkPath = "build\app\outputs\flutter-apk\app-debug.apk"
        if (Test-Path $apkPath) {
            $apkSize = (Get-Item $apkPath).Length / 1MB
            Write-Host "📦 Размер APK: $([math]::Round($apkSize, 2)) MB" -ForegroundColor White
            Write-Host "📁 Путь: $apkPath" -ForegroundColor White
        }
    } else {
        Write-Host "❌ Ошибка сборки APK" -ForegroundColor Red
        exit 1
    }
}

# Функция для установки APK
function Install-APK {
    Write-Host "📲 Установка APK..." -ForegroundColor Yellow
    
    # Проверяем ADB
    $adbPath = Get-Command adb -ErrorAction SilentlyContinue
    if (-not $adbPath) {
        Write-Host "❌ ADB не найден. Убедитесь, что Android SDK установлен." -ForegroundColor Red
        exit 1
    }
    
    # Проверяем устройства
    $devices = adb devices | Select-String "device$"
    if ($devices.Count -eq 0) {
        Write-Host "❌ Нет подключенных устройств." -ForegroundColor Red
        Write-Host "Подключите Android устройство и включите отладку по USB." -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host "✅ Найдено устройств: $($devices.Count)" -ForegroundColor Green
    
    # Устанавливаем APK
    $apkPath = "build\app\outputs\flutter-apk\app-debug.apk"
    if (-not (Test-Path $apkPath)) {
        Write-Host "❌ APK файл не найден. Сначала соберите APK." -ForegroundColor Red
        exit 1
    }
    
    adb install -r $apkPath
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ APK успешно установлен!" -ForegroundColor Green
        
        # Запускаем приложение
        Write-Host "🚀 Запуск приложения..." -ForegroundColor Yellow
        adb shell am start -n "com.katya.rechain.mesh/.MainActivity" 2>$null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Приложение запущено!" -ForegroundColor Green
        } else {
            Write-Host "⚠️ Приложение установлено, но не удалось запустить автоматически." -ForegroundColor Yellow
        }
    } else {
        Write-Host "❌ Ошибка установки APK" -ForegroundColor Red
        exit 1
    }
}

# Основная логика
try {
    if ($Clean) {
        Clean-Project
    }
    
    if ($InstallOnly) {
        Install-APK
    } elseif ($BuildOnly) {
        Build-APK
    } else {
        # Полный цикл: сборка + установка
        Build-APK
        Install-APK
    }
    
    Write-Host "`n🎉 Операция завершена успешно!" -ForegroundColor Green
    Write-Host "Приложение 'Katya AI REChain Mesh' готово к использованию." -ForegroundColor White
    
} catch {
    Write-Host "❌ Ошибка: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Показываем справку
Write-Host "`n📚 Использование скрипта:" -ForegroundColor Cyan
Write-Host "  .\build_and_install.ps1           # Сборка + установка" -ForegroundColor White
Write-Host "  .\build_and_install.ps1 -BuildOnly # Только сборка" -ForegroundColor White
Write-Host "  .\build_and_install.ps1 -InstallOnly # Только установка" -ForegroundColor White
Write-Host "  .\build_and_install.ps1 -Clean    # Очистка + сборка + установка" -ForegroundColor White

Write-Host "`n📖 Документация:" -ForegroundColor Cyan
Write-Host "  - Руководство по тестированию: TESTING_GUIDE.md" -ForegroundColor White
Write-Host "  - Отчет о разработке: DEVELOPMENT_REPORT.md" -ForegroundColor White
Write-Host "  - Исходный код: README.md" -ForegroundColor White

Write-Host "`n✨ Спасибо за использование Katya AI REChain Mesh!" -ForegroundColor Magenta
