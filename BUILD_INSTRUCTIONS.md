# 🚀 Инструкции по сборке Katya AI REChain Mesh

## 📱 Android-приложение

### Предварительные требования

1. **Flutter SDK** (>= 2.18.0)
   ```bash
   # Скачайте с https://flutter.dev/docs/get-started/install
   flutter doctor
   ```

2. **Android Studio** или **Android SDK**
   - Android SDK API 21+ (Android 5.0+)
   - Android SDK Build-Tools
   - Android SDK Platform-Tools

3. **Java Development Kit (JDK)**
   - JDK 8 или выше

### Установка зависимостей

```bash
# Клонируйте репозиторий
git clone https://github.com/katya-ai/rechain-mesh.git
cd rechain-mesh

# Установите зависимости Flutter
flutter pub get

# Проверьте конфигурацию
flutter doctor
```

### Сборка APK

#### Автоматическая сборка

**Windows:**
```powershell
# Запустите PowerShell от имени администратора
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\build_android.ps1
```

**Linux/macOS:**
```bash
chmod +x build_android.sh
./build_android.sh
```

#### Ручная сборка

```bash
# Debug сборка
flutter build apk --debug

# Release сборка
flutter build apk --release

# App Bundle для Google Play
flutter build appbundle --release
```

### Установка на устройство

#### Автоматическая установка

**Windows:**
```powershell
.\install_android.ps1
```

**Linux/macOS:**
```bash
./install_android.sh
```

#### Ручная установка

```bash
# Подключите устройство и включите отладку по USB
adb devices

# Установите APK
adb install build/app/outputs/flutter-apk/app-release.apk

# Запустите приложение
adb shell am start -n com.katya.rechain.mesh/.MainActivity
```

### Структура Android-проекта

```
android/
├── app/
│   ├── src/main/
│   │   ├── kotlin/com/katya/rechain/mesh/
│   │   │   ├── MainActivity.kt          # Главная активность
│   │   │   ├── MeshService.kt           # Фоновый сервис
│   │   │   ├── NotificationService.kt   # Уведомления
│   │   │   └── BootReceiver.kt          # Автозапуск
│   │   ├── res/                         # Ресурсы
│   │   └── AndroidManifest.xml          # Манифест
│   └── build.gradle                     # Конфигурация сборки
├── build.gradle                         # Настройки проекта
└── settings.gradle                      # Настройки Gradle
```

### Разрешения Android

Приложение запрашивает следующие разрешения:

- **Bluetooth** - для mesh-сети
- **Location** - требуется для Bluetooth на Android 6+
- **Camera** - для QR-кодов
- **Microphone** - для голосовых сообщений
- **Notifications** - для уведомлений
- **Storage** - для файлов

### Настройка подписи

Для release сборки настройте подпись:

1. Создайте keystore:
```bash
keytool -genkey -v -keystore katya-release-key.keystore -alias katya -keyalg RSA -keysize 2048 -validity 10000
```

2. Создайте `android/key.properties`:
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=katya
storeFile=../katya-release-key.keystore
```

3. Обновите `android/app/build.gradle`:
```gradle
android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### Отладка

#### Просмотр логов

```bash
# Flutter логи
flutter logs

# Android логи
adb logcat | grep "Katya"

# Фильтр по процессу
adb logcat | grep "com.katya.rechain.mesh"
```

#### Проверка разрешений

```bash
# Список разрешений
adb shell dumpsys package com.katya.rechain.mesh | grep permission

# Проверка Bluetooth
adb shell dumpsys bluetooth_manager
```

#### Тестирование

```bash
# Запуск тестов
flutter test

# Интеграционные тесты
flutter drive --target=test_driver/app.dart
```

### Публикация в Google Play

1. **Создайте App Bundle:**
```bash
flutter build appbundle --release
```

2. **Загрузите в Google Play Console:**
   - Войдите в [Google Play Console](https://play.google.com/console)
   - Создайте новое приложение
   - Загрузите `app-release.aab`
   - Заполните описание и скриншоты
   - Отправьте на модерацию

### Troubleshooting

#### Ошибки сборки

1. **Gradle sync failed:**
   ```bash
   cd android
   ./gradlew clean
   cd ..
   flutter clean
   flutter pub get
   ```

2. **Build failed:**
   ```bash
   flutter doctor -v
   flutter clean
   flutter pub get
   flutter build apk --debug
   ```

3. **Permission denied:**
   ```bash
   chmod +x build_android.sh
   chmod +x install_android.sh
   ```

#### Проблемы с устройством

1. **Device not found:**
   ```bash
   adb kill-server
   adb start-server
   adb devices
   ```

2. **Installation failed:**
   ```bash
   adb uninstall com.katya.rechain.mesh
   adb install build/app/outputs/flutter-apk/app-release.apk
   ```

### Производительность

#### Оптимизация APK

```bash
# Анализ размера APK
flutter build apk --analyze

# Минификация
flutter build apk --release --obfuscate --split-debug-info=debug-info
```

#### Мониторинг

- Используйте Android Studio Profiler
- Проверяйте использование памяти
- Мониторьте производительность Bluetooth

### Безопасность

#### Проверка безопасности

1. **Анализ APK:**
```bash
# Используйте Android Studio APK Analyzer
# Или online инструменты типа VirusTotal
```

2. **Проверка разрешений:**
   - Убедитесь, что запрашиваются только необходимые разрешения
   - Проверьте, что Bluetooth используется только для mesh-сети

### Поддержка

- **GitHub Issues**: [Создать issue](https://github.com/katya-ai/rechain-mesh/issues)
- **Email**: support@katya-ai.com
- **Telegram**: @katya_ai_support

---

**Katya AI REChain Mesh** - Будущее оффлайн общения! 🚀👽
