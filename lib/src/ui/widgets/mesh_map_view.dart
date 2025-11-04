import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/mesh_service_ble.dart';

class MeshMapView extends StatefulWidget {
  const MeshMapView({super.key});

  @override
  State<MeshMapView> createState() => _MeshMapViewState();
}

class _MeshMapViewState extends State<MeshMapView> {
  final MeshServiceBLE _mesh = MeshServiceBLE.instance;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final peers = _mesh.peers;
    return CustomPaint(
      painter: _MeshPainter(peers.map((p) => p.id).toList()),
      child: Container(),
    );
  }
}

class _MeshPainter extends CustomPainter {
  final List<String> peerIds;
  _MeshPainter(this.peerIds);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paintNode = Paint()..color = Colors.blueAccent;
    final paintLink = Paint()
      ..color = Colors.blueGrey
      ..strokeWidth = 1.5;

    // draw center node (me)
    canvas.drawCircle(center, 8, paintNode);

    // arrange peers in a circle
    final r = min(size.width, size.height) * 0.35;
    for (var i = 0; i < peerIds.length; i++) {
      final angle = 2 * pi * i / max(1, peerIds.length);
      final pos = Offset(center.dx + r * cos(angle), center.dy + r * sin(angle));
      canvas.drawLine(center, pos, paintLink);
      canvas.drawCircle(pos, 6, paintNode);
    }
  }

  @override
  bool shouldRepaint(covariant _MeshPainter oldDelegate) {
    return oldDelegate.peerIds.length != peerIds.length ||
        oldDelegate.peerIds.toSet().difference(peerIds.toSet()).isNotEmpty;
  }
}
