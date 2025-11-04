# Screencast Script — MeshApp demo (2.5 - 3.5 minutes)

## Equipment
- Two Android devices (or one Android + one Aurora with Android runtime)
- USB for screen recording or device built-in recorder
- Optional: tripod or screen capture via adb

## Scenes timeline
0:00 - 0:05 — Title slide: "MeshApp — Offline Mesh Messenger & Voting"
0:05 - 0:20 — Show Home screen (Chats / Devices / Polls)
0:20 - 0:50 — Devices tab: start scan, show discovered device list (explain BLE prototype limitations)
0:50 - 1:10 — Connect to peer on device B (show connect action)
1:10 - 1:40 — Conversation: send a text from device A to B (show "Sent via BLE" toast)
1:40 - 2:00 — On device B show incoming message received and stored in chat history
2:00 - 2:30 — Polls: Host creates poll (question + options) — other device receives and votes (show realtime update)
2:30 - 2:50 — AI smart replies: show suggested replies when typing a message
2:50 - 3:10 — Security note: show Manifest & permissions, mention encryption TODOs
3:10 - 3:30 — How to build & run: `flutter pub get` -> `flutter run` -> `flutter build apk` and mention Aurora packaging options
3:30 - 3:40 — Closing slide: link to repository and contest submission instructions

## Recording tips
- Keep video short and focused (2.5–3.5 minutes)
- Use captions for important steps
- If possible, include a small terminal window showing `flutter build apk` success
