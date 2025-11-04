# Suggested PR-ready commits and commands

Suggested commit structure (atomic commits):

1. feat(scaffold): initial Flutter scaffold and UI (main, home, chat, devices)
2. feat(storage): add Hive-based message storage and app state
3. feat(mesh): add BLE prototype (MeshServiceBLE) and integrate into Devices UI
4. feat(chat): integrate BLE send/receive in ConversationPage
5. feat(ai): add simple AIService (smart replies)
6. feat(security): add CryptoHelper (AES-GCM) and integrate encryption in mesh service
7. feat(handshake): add X25519 ECDH helper and handshake demo
8. feat(ci): add GitHub Actions CI for APK and RPM build
9. docs: add screencast script, narrator, and Aurora packaging docs
10. test: add unit test for fake mesh service

Example git commands:
git checkout -b feature/meshapp-final
git add .
git commit -m "feat(scaffold): initial Flutter scaffold and UI"
git commit -m "feat(storage): add Hive-based message storage and app state"
... repeat commits per logical chunk ...
git push origin feature/meshapp-final
Open a PR from feature/meshapp-final into main and include CHANGELOG.md and README updates.
