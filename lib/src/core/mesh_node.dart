import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:ffi/ffi.dart' as pkgffi;

/// Status of a mesh node
enum MeshNodeStatus {
  disconnected,
  connecting,
  connected,
}

/// FFI signatures (stubs)
typedef CConnect = ffi.Int32 Function(ffi.Pointer<pkgffi.Utf8> peerId);
typedef CDisconnect = ffi.Void Function();
typedef CSendMessage = ffi.Int32 Function(ffi.Pointer<pkgffi.Utf8> peerId, ffi.Pointer<pkgffi.Utf8> data);

class _NativeLib {
  final ffi.DynamicLibrary lib;
  _NativeLib(this.lib);

  static _NativeLib? tryOpen() {
    try {
      final lib = Platform.isAndroid
          ? ffi.DynamicLibrary.open('libmesh_native.so')
          : Platform.isWindows
              ? ffi.DynamicLibrary.open('mesh_native.dll')
              : Platform.isIOS || Platform.isMacOS
                  ? ffi.DynamicLibrary.process()
                  : ffi.DynamicLibrary.open('libmesh_native.so');
      return _NativeLib(lib);
    } catch (_) {
      return null;
    }
  }
}

class MeshNode {
  final String id;
  final String publicKey;
  MeshNodeStatus status;

  final _NativeLib? _native;

  MeshNode({required this.id, required this.publicKey, this.status = MeshNodeStatus.disconnected})
      : _native = _NativeLib.tryOpen();

  Future<bool> connect(String peerId) async {
    status = MeshNodeStatus.connecting;
    if (_native != null) {
      try {
        final fn = _native.lib
            .lookupFunction<CConnect, int Function(ffi.Pointer<pkgffi.Utf8>)>('mesh_connect');
        final res = fn(peerId.toNativeUtf8());
        status = res == 0 ? MeshNodeStatus.connected : MeshNodeStatus.disconnected;
        return res == 0;
      } catch (_) {}
    }
    status = MeshNodeStatus.connected;
    return true;
  }

  Future<void> disconnect() async {
    if (_native != null) {
      try {
        final fn = _native.lib
            .lookupFunction<CDisconnect, void Function()>('mesh_disconnect');
        fn();
      } catch (_) {}
    }
    status = MeshNodeStatus.disconnected;
  }

  Future<bool> sendMessage(String peerId, String data) async {
    if (status != MeshNodeStatus.connected) return false;
    if (_native != null) {
      try {
        final fn = _native.lib.lookupFunction<CSendMessage, int Function(ffi.Pointer<pkgffi.Utf8>, ffi.Pointer<pkgffi.Utf8>)>('mesh_send');
        final res = fn(peerId.toNativeUtf8(), data.toNativeUtf8());
        return res == 0;
      } catch (_) {}
    }
    return true;
  }
}
