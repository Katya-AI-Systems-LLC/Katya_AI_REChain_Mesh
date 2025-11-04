# Changelog

## 0.1.0 - Final contest submission
- Initial Flutter scaffold (UI, models, services)
- Added BLE prototype (flutter_blue_plus) with scanning and connect
- Integrated BLE into Devices and Conversation UI
- Added Hive storage for messages
- Added AI service (rule-based smart replies)
- Added CryptoHelper (AES-GCM) for encryption
- Added X25519 ECDH helper and HKDF key derivation (crypto_handshake.dart)
- Added handshake demo (host encrypts session key using passphrase-derived key)
- Added Android manifest & permissions, build.gradle snippets
- Added docs: screencast script, narrator script
- Added CI workflow for APK and Linux RPM build
- Added packaging support/instructions for Aurora OS (RPM and Qt/QML notes)
- Added unit test to simulate MeshService behavior
