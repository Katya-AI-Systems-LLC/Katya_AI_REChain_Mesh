# Developer Guide

## Quick Start

### 1. Environment Setup

#### Windows
```powershell
# Run setup script
.\setup.ps1

# Or manually
flutter pub get
flutter config --enable-web
flutter config --enable-windows-desktop
```

#### Linux/macOS
```bash
# Run setup script
bash setup.sh

# Or manually
flutter pub get
flutter config --enable-web
flutter config --enable-linux-desktop
```

### 2. Development Commands

```bash
# Run on connected device
flutter run

# Run web version
flutter run -d web

# Run on specific device
flutter run -d <device_id>

# Run tests
flutter test

# Code analysis
flutter analyze

# Format code
dart format .

# Check for issues
flutter doctor
```

### 3. Build Commands

```bash
# Clean and rebuild
flutter clean
flutter pub get

# Debug builds
flutter build apk --debug
flutter build ios --debug --simulator

# Release builds
flutter build apk --release
flutter build appbundle --release
flutter build ios --release
flutter build web --release
```

## Code Organization

### Architecture Pattern

The project follows **Clean Architecture** with separation of concerns:

```
lib/src/
├── models/           # Domain entities (business objects)
├── services/         # External services (API, database, etc.)
├── state/           # Application state (Provider pattern)
├── ui/              # Presentation layer (widgets, screens)
├── theme/           # Styling and theming
└── utils/           # Utilities and helpers
```

### Module Structure

Each major feature is organized as a separate module:

#### Blockchain Module
```
lib/src/
├── models/blockchain/     # Wallet, NFT, Transaction models
├── services/blockchain/   # Web3 integration, API clients
├── state/blockchain/     # Wallet management state
└── ui/blockchain/        # Wallet UI, transaction screens
```

#### Gaming Module
```
lib/src/
├── models/gaming/        # UserProgress, Achievement models
├── services/gaming/      # Gaming API, reward system
├── state/gaming/        # User progress state
└── ui/gaming/           # Achievement UI, stats screens
```

#### IoT Module
```
lib/src/
├── models/iot/          # Device, Sensor, Rule models
├── services/iot/        # BLE integration, device discovery
├── state/iot/          # Device connection state
└── ui/iot/             # Device management UI
```

#### Social Module
```
lib/src/
├── models/social/       # Profile, Message, Group models
├── services/social/     # Social API, mesh networking
├── state/social/       # Social interactions state
└── ui/social/          # Chat UI, profile screens
```

## State Management

### Provider Pattern

Each module uses Provider for state management:

```dart
class BlockchainState extends ChangeNotifier {
  final BlockchainRepository _repository;
  List<Wallet> _wallets = [];
  bool _isLoading = false;

  // Getters
  List<Wallet> get wallets => List.unmodifiable(_wallets);
  bool get isLoading => _isLoading;

  // Methods
  Future<void> loadWallets() async {
    _isLoading = true;
    notifyListeners();

    try {
      _wallets = await _repository.getWallets();
    } catch (error) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

### MultiProvider Setup

```dart
// lib/main.dart
return MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AppState()),
    ChangeNotifierProvider(create: (_) => BlockchainState()),
    ChangeNotifierProvider(create: (_) => GamingState()),
    ChangeNotifierProvider(create: (_) => IoTState()),
    ChangeNotifierProvider(create: (_) => SocialState()),
  ],
  child: MaterialApp(
    // ...
  ),
);
```

### Using State in UI

```dart
class WalletScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final blockchainState = context.watch<BlockchainState>();
    final wallets = blockchainState.wallets;

    return Scaffold(
      body: blockchainState.isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: wallets.length,
              itemBuilder: (context, index) => WalletCard(wallets[index]),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => blockchainState.createWallet(),
        child: Icon(Icons.add),
      ),
    );
  }
}
```

## API Integration

### Service Layer

All external API calls go through service classes:

```dart
abstract class BlockchainRepository {
  Future<List<Wallet>> getWallets();
  Future<Wallet> createWallet(CreateWalletRequest request);
  Future<TransactionResult> sendTransaction(SendTransactionRequest request);
  Stream<Transaction> getTransactionUpdates();
}

class BlockchainService implements BlockchainRepository {
  final Web3Client _client;
  final String _apiKey;

  @override
  Future<List<Wallet>> getWallets() async {
    final response = await _client.get('/api/wallets');
    return response.data.map((json) => Wallet.fromJson(json));
  }
}
```

### HTTP Client Setup

```dart
// lib/src/services/api_client.dart
class ApiClient {
  late final Dio _client;

  ApiClient() {
    _client = Dio(BaseOptions(
      baseUrl: 'https://api.katya-ai-rechain-mesh.com',
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ));

    _client.interceptors.add(AuthInterceptor());
    _client.interceptors.add(LoggingInterceptor());
  }

  Future<Response> get(String path) => _client.get(path);
  Future<Response> post(String path, dynamic data) => _client.post(path, data: data);
}
```

## Database Integration

### Local Storage (Hive)

```dart
// lib/src/services/storage_service.dart
class StorageService {
  late Box<UserProfile> _userBox;
  late Box<Wallet> _walletBox;

  Future<void> init() async {
    // Register adapters
    Hive.registerAdapter(UserProfileAdapter());
    Hive.registerAdapter(WalletAdapter());

    // Open boxes
    _userBox = await Hive.openBox('users');
    _walletBox = await Hive.openBox('wallets');
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    await _userBox.put(profile.userId, profile);
  }

  Stream<UserProfile?> watchUserProfile(String userId) {
    return _userBox.watch(key: userId).map((event) => event.value);
  }
}
```

### Backend Integration

```sql
-- PostgreSQL schema
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  display_name VARCHAR(100),
  bio TEXT,
  avatar_url TEXT,
  interests TEXT[],
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE wallets (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES user_profiles(id),
  address VARCHAR(42) NOT NULL,
  network VARCHAR(20) NOT NULL,
  balance DECIMAL(36,18),
  created_at TIMESTAMP DEFAULT NOW()
);
```

## Platform-Specific Code

### Android

#### Native Integration
```kotlin
// android/app/src/main/kotlin/com/katya/rechain/mesh/NativeBridge.kt
class NativeBridge : FlutterPlugin {
  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }
      "getBatteryLevel" -> {
        val batteryLevel = getBatteryLevel()
        result.success(batteryLevel)
      }
      else -> result.notImplemented()
    }
  }

  private fun getBatteryLevel(): Int {
    val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
    return batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
  }
}
```

#### Permissions
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.BLUETOOTH" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.CAMERA" />
</manifest>
```

### iOS

#### Native Integration
```swift
// ios/Runner/PlatformBridge.swift
import Flutter

public class PlatformBridge: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "katya.rechain.mesh/native", binaryMessenger: registrar.messenger())
        let instance = PlatformBridge()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "getBatteryLevel":
            result(getBatteryLevel())
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func getBatteryLevel() -> Int {
        UIDevice.current.isBatteryMonitoringEnabled = true
        return Int(UIDevice.current.batteryLevel * 100)
    }
}
```

### Web

#### Web-Specific Features
```dart
// lib/src/services/web_service.dart
class WebService implements PlatformService {
  @override
  Future<String> getPlatformInfo() async {
    final userAgent = html.window.navigator.userAgent;
    final platform = html.window.navigator.platform;
    return 'Web - $platform - $userAgent';
  }

  @override
  Future<void> shareContent(String content) async {
    final data = {'text': content};
    await html.window.navigator.share!(data);
  }
}
```

## Testing

### Unit Tests

```dart
// test/services/blockchain_service_test.dart
class MockBlockchainRepository extends Mock implements BlockchainRepository {}

void main() {
  late BlockchainService service;
  late MockBlockchainRepository mockRepository;

  setUp(() {
    mockRepository = MockBlockchainRepository();
    service = BlockchainService(mockRepository);
  });

  group('BlockchainService', () {
    test('should get wallets successfully', () async {
      // Arrange
      const wallets = [Wallet(id: '1', name: 'Test Wallet')];
      when(() => mockRepository.getWallets()).thenAnswer((_) async => wallets);

      // Act
      final result = await service.getWallets();

      // Assert
      expect(result, equals(wallets));
      verify(() => mockRepository.getWallets()).called(1);
    });

    test('should handle errors gracefully', () async {
      // Arrange
      when(() => mockRepository.getWallets()).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(() async => await service.getWallets(), throwsA(isA<Exception>()));
    });
  });
}
```

### Widget Tests

```dart
// test/ui/wallet_card_test.dart
void main() {
  group('WalletCard', () {
    testWidgets('should display wallet information', (WidgetTester tester) async {
      // Arrange
      const wallet = Wallet(
        id: '1',
        name: 'Main Wallet',
        address: '0x1234...',
        balance: 1.5,
        network: 'ethereum',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: WalletCard(wallet: wallet),
        ),
      );

      // Assert
      expect(find.text('Main Wallet'), findsOneWidget);
      expect(find.text('1.5 ETH'), findsOneWidget);
      expect(find.text('0x1234...'), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (WidgetTester tester) async {
      // Arrange
      var tapped = false;
      const wallet = Wallet(
        id: '1',
        name: 'Main Wallet',
        address: '0x1234...',
        balance: 1.5,
        network: 'ethereum',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: WalletCard(
            wallet: wallet,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(WalletCard));
      await tester.pump();

      // Assert
      expect(tapped, isTrue);
    });
  });
}
```

### Integration Tests

```dart
// integration_test/app_flow_test.dart
void main() {
  group('App Flow Integration Tests', () {
    testWidgets('should complete wallet creation flow', (WidgetTester tester) async {
      // Arrange
      app.main();

      // Act - Navigate to blockchain tab
      await tester.tap(find.byIcon(Icons.account_balance_wallet));
      await tester.pumpAndSettle();

      // Act - Tap create wallet button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Act - Fill wallet form
      await tester.enterText(find.byType(TextField).first, 'My Wallet');
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Assert - Wallet should be created
      expect(find.text('My Wallet'), findsOneWidget);
      expect(find.text('Wallet created successfully'), findsOneWidget);
    });
  });
}
```

## Performance Optimization

### Code Splitting

```dart
// lib/src/ui/lazy_screen.dart
class LazyScreen extends StatefulWidget {
  @override
  _LazyScreenState createState() => _LazyScreenState();
}

class _LazyScreenState extends State<LazyScreen> {
  late Future<void> _lazyLoadFuture;

  @override
  void initState() {
    super.initState();
    _lazyLoadFuture = _lazyLoad();
  }

  Future<void> _lazyLoad() async {
    // Load heavy resources only when needed
    await Future.delayed(Duration(milliseconds: 100));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _lazyLoadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return _buildContent();
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
```

### Memory Management

```dart
// lib/src/services/memory_service.dart
class MemoryService {
  static void cleanup() {
    // Clear image cache
    imageCache.clear();

    // Clear Hive boxes
    Hive.close();

    // Clear Provider state
    // (handled automatically by Provider)
  }

  static void optimizeImageCache() {
    imageCache.maximumSize = 100 * 1024 * 1024; // 100MB
    imageCache.maximumSizeBytes = 100 * 1024 * 1024;
  }
}
```

## Security Considerations

### Input Validation

```dart
// lib/src/utils/validation.dart
class Validation {
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      return 'Invalid email format';
    }

    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(password)) {
      return 'Password must contain uppercase, lowercase, and number';
    }

    return null;
  }
}
```

### Secure Storage

```dart
// lib/src/services/secure_storage_service.dart
class SecureStorageService {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }
}
```

## Deployment

### Development

```bash
# Run in debug mode
flutter run

# Run with debugging
flutter run --debug

# Enable performance overlay
flutter run --profile
```

### Production

```bash
# Build optimized release
flutter build apk --release --obfuscate --split-debug-info=build/debug-info

# Build for specific platforms
flutter build appbundle --release  # Google Play
flutter build ios --release       # App Store
flutter build web --release       # Web
```

### Code Signing

#### Android
```bash
# Generate keystore
keytool -genkey -v -keystore key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key

# Configure signing
flutter build apk --release --keystore=key.jks --keystore-password=your_password
```

#### iOS
```bash
# Configure certificates in Xcode
# Build with code signing
flutter build ios --release --codesign
```

## Debugging

### Flutter DevTools

```bash
# Launch DevTools
flutter pub global activate devtools
flutter pub global run devtools

# Or from VS Code/Android Studio
# Tools > Flutter DevTools
```

### Debugging Commands

```bash
# Show performance overlay
flutter run --profile

# Show widget rebuilds
flutter run --debug

# Memory profiling
flutter run --profile --dart-define=flutter.inspector.structuredErrors=true
```

### Common Issues

#### Build Issues
```bash
# Clear all caches
flutter clean
flutter pub cache repair
flutter doctor

# Reinstall dependencies
rm -rf .packages
rm pubspec.lock
flutter pub get
```

#### Performance Issues
```bash
# Profile performance
flutter run --profile

# Check memory usage
flutter run --debug --dart-define=flutter.inspector.structuredErrors=true
```

#### Platform Issues
```bash
# Check connected devices
flutter devices

# Restart ADB (Android)
adb kill-server
adb start-server

# Clear iOS simulator
xcrun simctl erase all
```

## Contributing

### Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `dart format` before committing
- Write comprehensive tests
- Update documentation for API changes

### Git Workflow

```bash
# Create feature branch
git checkout -b feature/amazing-feature

# Make changes
# Write tests
# Update documentation

# Commit with conventional format
git commit -m "feat: add amazing feature"

# Push and create PR
git push origin feature/amazing-feature
```

### Pull Request Process

1. Update README.md with changes
2. Update version numbers if needed
3. Ensure all tests pass
4. Add reviewers
5. Wait for approval

## Resources

### Documentation
- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [Material Design](https://material.io/design)
- [Provider Documentation](https://pub.dev/packages/provider)

### Communities
- [Flutter Community](https://flutter.dev/community)
- [Dart Community](https://dart.dev/community)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)

### Tools
- [Flutter DevTools](https://docs.flutter.dev/development/tools/devtools)
- [Dart DevTools](https://dart.dev/tools/dart-devtools)
- [Flutter Inspector](https://docs.flutter.dev/development/tools/inspector)

---

## Support

For development support:
- **Issues**: [GitHub Issues](https://github.com/katya-ai-rechain-mesh/issues)
- **Discussions**: [GitHub Discussions](https://github.com/katya-ai-rechain-mesh/discussions)
- **Email**: dev@katya-ai.com

*Happy coding! 🚀*
