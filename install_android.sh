#!/bin/bash

# Скрипт для установки Katya AI REChain Mesh на Android устройство

echo "📱 Установка Katya AI REChain Mesh на Android устройство..."

# Проверяем подключение устройства
echo "🔍 Проверка подключения устройства..."
adb devices

# Проверяем наличие APK
APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
if [ ! -f "$APK_PATH" ]; then
    echo "❌ APK файл не найден. Сначала соберите приложение:"
    echo "   ./build_android.sh"
    exit 1
fi

# Устанавливаем APK
echo "📦 Установка APK..."
adb install -r "$APK_PATH"

if [ $? -eq 0 ]; then
    echo "✅ Приложение установлено успешно!"
    
    # Запускаем приложение
    echo "🚀 Запуск приложения..."
    adb shell am start -n com.katya.rechain.mesh/.MainActivity
    
    if [ $? -eq 0 ]; then
        echo "✅ Приложение запущено!"
    else
        echo "❌ Ошибка при запуске приложения"
    fi
else
    echo "❌ Ошибка при установке приложения"
    exit 1
fi

echo ""
echo "🎉 Katya AI REChain Mesh установлен и запущен!"
echo ""
echo "📋 Полезные команды:"
echo "   adb logcat | grep 'Katya'     # Просмотр логов"
echo "   adb shell pm list packages | grep katya  # Проверка установки"
echo "   adb uninstall com.katya.rechain.mesh     # Удаление приложения"
echo ""
echo "🚀 Наслаждайтесь использованием Katya AI REChain Mesh!"
