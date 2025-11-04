#!/bin/bash

# Скрипт для сборки Android APK
# Katya AI REChain Mesh

echo "🚀 Сборка Katya AI REChain Mesh для Android..."

# Проверяем наличие Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter не найден. Установите Flutter: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Проверяем версию Flutter
echo "📱 Flutter версия:"
flutter --version

# Очищаем предыдущие сборки
echo "🧹 Очистка предыдущих сборок..."
flutter clean

# Получаем зависимости
echo "📦 Установка зависимостей..."
flutter pub get

# Проверяем конфигурацию
echo "🔍 Проверка конфигурации..."
flutter doctor

# Собираем APK для debug
echo "🔨 Сборка debug APK..."
flutter build apk --debug

if [ $? -eq 0 ]; then
    echo "✅ Debug APK собран успешно!"
    echo "📁 Файл: build/app/outputs/flutter-apk/app-debug.apk"
else
    echo "❌ Ошибка при сборке debug APK"
    exit 1
fi

# Собираем APK для release
echo "🔨 Сборка release APK..."
flutter build apk --release

if [ $? -eq 0 ]; then
    echo "✅ Release APK собран успешно!"
    echo "📁 Файл: build/app/outputs/flutter-apk/app-release.apk"
else
    echo "❌ Ошибка при сборке release APK"
    exit 1
fi

# Собираем App Bundle для Google Play
echo "🔨 Сборка App Bundle..."
flutter build appbundle --release

if [ $? -eq 0 ]; then
    echo "✅ App Bundle собран успешно!"
    echo "📁 Файл: build/app/outputs/bundle/release/app-release.aab"
else
    echo "❌ Ошибка при сборке App Bundle"
    exit 1
fi

echo "🎉 Сборка завершена!"
echo ""
echo "📱 Установка на устройство:"
echo "   flutter install"
echo ""
echo "📊 Анализ APK:"
echo "   flutter build apk --analyze"
echo ""
echo "🔍 Проверка зависимостей:"
echo "   flutter pub deps"
echo ""
echo "🚀 Katya AI REChain Mesh готов к использованию!"
