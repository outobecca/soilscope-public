import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A Flutter widget that displays an interactive PAR (Photosynthetically Active Radiation) Chart.
class PARChart extends StatefulWidget {
  final double intensity;
  final ValueChanged<double>? onChanged;

  const PARChart({
    super.key,
    required this.intensity,
    this.onChanged,
  });

  @override
  State<PARChart> createState() => _PARChartState();
}

class _PARChartState extends State<PARChart> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (widget.onChanged == null) return;
        final RenderBox box = context.findRenderObject() as RenderBox;
        final localPos = box.globalToLocal(details.globalPosition);
        final double padding = 15.0;
        final double innerH = box.size.height - padding * 2;
        final double spectrumBottom = box.size.height - padding;

        final double yRatio =
            (spectrumBottom - localPos.dy).clamp(0.0, innerH) / innerH;
        widget.onChanged!(yRatio * 2000.0);
      },
      child: CustomPaint(
        size: Size.infinite,
        painter: _PARPainter(
          intensity: widget.intensity,
          label: "PAR",
        ),
      ),
    );
  }
}

class _PARPainter extends CustomPainter {
  final double intensity;
  final String label;

  _PARPainter({required this.intensity, required this.label});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Background with glass effect
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E293B).withValues(alpha: 0.95),
            const Color(0xFF0F172A).withValues(alpha: 0.95),
          ],
        ).createShader(rect),
    );

    // Subtle border
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      Paint()
        ..color = Colors.yellowAccent.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    final double padding = 15.0;
    final double innerW = size.width - padding * 2;
    final double innerH = size.height - padding * 2;

    // Spectrum Gradient
    final spectrumRect = Rect.fromLTWH(
      padding,
      padding + 10,
      innerW,
      innerH - 10,
    );
    final gradient = LinearGradient(
      colors: [Colors.blue, Colors.green, Colors.yellow, Colors.red],
      stops: const [0.0, 0.4, 0.7, 1.0],
    );

    final mccreePath = Path()..moveTo(spectrumRect.left, spectrumRect.bottom);
    for (double i = 0; i <= 1.0; i += 0.1) {
      final x = spectrumRect.left + i * innerW;
      final y =
          spectrumRect.bottom - (0.3 + 0.7 * math.sin(i * math.pi)) * innerH;
      mccreePath.lineTo(x, y);
    }
    mccreePath.lineTo(spectrumRect.right, spectrumRect.bottom);
    mccreePath.close();

    canvas.drawPath(
      mccreePath,
      Paint()
        ..shader = gradient.createShader(spectrumRect)
        ..style = PaintingStyle.fill
        ..color = Colors.white.withValues(alpha: 0.3),
    );

    // Intensity line
    final intensityY =
        spectrumRect.bottom -
        (intensity / 2000.0).clamp(0, 1) * (innerH - 10);
    canvas.drawLine(
      Offset(spectrumRect.left, intensityY),
      Offset(spectrumRect.right, intensityY),
      Paint()
        ..color = Colors.yellowAccent
        ..strokeWidth = 2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    _drawLabel(
      canvas,
      "$label: ${intensity.toStringAsFixed(0)} µmol/m²s",
      Offset(size.width / 2, padding / 2),
    );
  }

  void _drawLabel(Canvas canvas, String text, Offset pos) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos - Offset(tp.width / 2, 0));
  }

  @override
  bool shouldRepaint(covariant _PARPainter oldDelegate) =>
      oldDelegate.intensity != intensity;
}
