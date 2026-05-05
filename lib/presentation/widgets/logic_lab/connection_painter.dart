import 'package:flutter/material.dart';
import '../../../domain/logic_lab/models.dart';

class ConnectionPainter extends CustomPainter {
  final List<LogicNode> nodes;
  final List<NodeConnection> connections;

  ConnectionPainter({required this.nodes, required this.connections});

  @override
  void paint(Canvas canvas, Size size) {
    for (final conn in connections) {
      final fromNode = nodes.firstWhere((n) => n.id == conn.fromNodeId);
      final toNode = nodes.firstWhere((n) => n.id == conn.toNodeId);

      // Lasketaan porttien tarkat sijainnit
      // NodeWidget on 160px leveä, portit ovat reunoilla
      const nodeWidth = 160.0;
      const headerHeight = 30.0;
      const portSpacing = 26.0;

      // Output on aina oikealla
      final startX = fromNode.position.dx + nodeWidth;
      final startY =
          fromNode.position.dy +
          headerHeight +
          12 +
          conn.fromPortIndex * portSpacing;
      final start = Offset(startX, startY);

      // Input on vasemmalla, indeksin mukaan
      final endX = toNode.position.dx;
      final endY =
          toNode.position.dy +
          headerHeight +
          12 +
          conn.toPortIndex * portSpacing;
      final end = Offset(endX, endY);

      // Gradient-väri langan suunnan mukaan
      final gradient = LinearGradient(
        colors: [
          Colors.greenAccent.withValues(alpha: 0.8),
          Colors.cyan.withValues(alpha: 0.8),
        ],
      );
      final paint = Paint()
        ..shader = gradient.createShader(Rect.fromPoints(start, end))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      // Bezier-käyrä
      final path = Path()..moveTo(start.dx, start.dy);
      final controlOffset = (end.dx - start.dx).abs() * 0.5;
      path.cubicTo(
        start.dx + controlOffset,
        start.dy,
        end.dx - controlOffset,
        end.dy,
        end.dx,
        end.dy,
      );
      canvas.drawPath(path, paint);

      // Hehkuvat päätepisteet
      final glowPaint = Paint()
        ..color = Colors.greenAccent.withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(start, 5, glowPaint);
      canvas.drawCircle(end, 5, glowPaint);

      // Kiinteät pisteet
      canvas.drawCircle(start, 4, Paint()..color = Colors.greenAccent);
      canvas.drawCircle(end, 4, Paint()..color = Colors.cyan);

      // Animoitu "datapulssi" viiva (staattinen versio)
      _drawDataPulse(canvas, path);
    }
  }

  void _drawDataPulse(Canvas canvas, Path path) {
    // Piirretään pieniä pisteitä langan varrelle simuloimaan datavirtaa
    final metrics = path.computeMetrics().first;
    final totalLength = metrics.length;

    // 3 pulssia tasaisin välein
    for (int i = 0; i < 3; i++) {
      final t = (i / 3.0 + 0.1) % 1.0;
      final tangent = metrics.getTangentForOffset(totalLength * t);
      if (tangent != null) {
        canvas.drawCircle(
          tangent.position,
          3,
          Paint()..color = Colors.white.withValues(alpha: 0.7),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant ConnectionPainter oldDelegate) {
    // Repaint jos nodet tai yhteydet muuttuvat
    return oldDelegate.nodes != nodes || oldDelegate.connections != connections;
  }
}
