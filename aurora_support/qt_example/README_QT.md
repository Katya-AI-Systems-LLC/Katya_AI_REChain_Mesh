# Qt/QML example for native Aurora port (concept)

This folder outlines a simple Qt/QML UI that replicates the main screens: Chats, Devices, Polls.
The idea: implement UI in QML, and port business logic (mesh, storage) using C++ or call into
a local microservice. If you want to run Flutter UI directly, consider embedding Flutter engine.

Example components:
- Main.qml: TabView with Chats, Devices, Polls pages
- Chats.qml: ListView bound to local JSON store
- DeviceScanner.qml: uses QtBluetooth for scanning/advertising
- PollDialog.qml: host poll creation UI and result view

Notes:
- Use QtBluetooth (QtConnectivity) for BLE and local networking.
- Package as RPM with specfile in ../specfile.spec
