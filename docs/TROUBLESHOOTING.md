# Troubleshooting

**Build errors**
- Run `flutter doctor`, fix all warnings.
- Try `flutter clean` then `flutter pub get`.
- For C++/userver: check Docker is running.

**Mesh: devices not connected**
- Enable all permissions; on iOS update device settings;
- On Android: ensure Location, Bluetooth, Wi-Fi enabled.

**Push to mirrors fails**
- Проверьте, что у вас есть доступ (token/SSH) — иначе используйте импорт в интерфейсе SourceCraft/GitFlic;

**Backend issues**
- Check backend with `docker-compose logs`; restart container if crashed.

For any issues, open an issue on GitHub or ask @katya_mesh Telegram.
