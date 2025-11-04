# Скрипт для сборки Android APK
# Katya AI REChain Mesh

Write-Host "🚀 Сборка Katya AI REChain Mesh для Android..." -ForegroundColor Green

# Проверяем наличие Flutter
try {
    $flutterVersion = flutter --version
    Write-Host "📱 Flutter версия:" -ForegroundColor Blue
    Write-Host $flutterVersion
} catch {
    Write-Host "❌ Flutter не найден. Установите Flutter: https://flutter.dev/docs/get-started/install" -ForegroundColor Red
    exit 1
}

# Очищаем предыдущие сборки
Write-Host "🧹 Очистка предыдущих сборок..." -ForegroundColor Yellow
flutter clean

# Получаем зависимости
Write-Host "📦 Установка зависимостей..." -ForegroundColor Blue
flutter pub get

# Проверяем конфигурацию
Write-Host "🔍 Проверка конфигурации..." -ForegroundColor Blue
flutter doctor

# Собираем APK для debug
Write-Host "🔨 Сборка debug APK..." -ForegroundColor Yellow
flutter build apk --debug

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Debug APK собран успешно!" -ForegroundColor Green
    Write-Host "📁 Файл: build/app/outputs/flutter-apk/app-debug.apk" -ForegroundColor Cyan
} else {
    Write-Host "❌ Ошибка при сборке debug APK" -ForegroundColor Red
    exit 1
}

# Собираем APK для release
Write-Host "🔨 Сборка release APK..." -ForegroundColor Yellow
flutter build apk --release

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Release APK собран успешно!" -ForegroundColor Green
    Write-Host "📁 Файл: build/app/outputs/flutter-apk/app-release.apk" -ForegroundColor Cyan
} else {
    Write-Host "❌ Ошибка при сборке release APK" -ForegroundColor Red
    exit 1
}

# Собираем App Bundle для Google Play
Write-Host "🔨 Сборка App Bundle..." -ForegroundColor Yellow
flutter build appbundle --release

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ App Bundle собран успешно!" -ForegroundColor Green
    Write-Host "📁 Файл: build/app/outputs/bundle/release/app-release.aab" -ForegroundColor Cyan
} else {
    Write-Host "❌ Ошибка при сборке App Bundle" -ForegroundColor Red
    exit 1
}

Write-Host "🎉 Сборка завершена!" -ForegroundColor Green
Write-Host ""
Write-Host "📱 Установка на устройство:" -ForegroundColor Blue
Write-Host "   flutter install" -ForegroundColor Cyan
Write-Host ""
Write-Host "📊 Анализ APK:" -ForegroundColor Blue
Write-Host "   flutter build apk --analyze" -ForegroundColor Cyan
Write-Host ""
Write-Host "🔍 Проверка зависимостей:" -ForegroundColor Blue
Write-Host "   flutter pub deps" -ForegroundColor Cyan
Write-Host ""
Write-Host "🚀 Katya AI REChain Mesh готов к использованию!" -ForegroundColor Green
