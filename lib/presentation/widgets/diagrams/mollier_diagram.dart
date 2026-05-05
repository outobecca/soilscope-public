import 'dart:math' as math;
import 'package:flutter/material.dart' hide TextStyle;
import 'package:flutter/painting.dart';
import '../../../core/biophysics_utils.dart';
import '../../../l10n/app_localizations.dart';

/// Psychrometric Mollier-style diagram for atmospheric monitoring.
/// 
/// Displays Dry-Bulb Temperature vs Humidity Ratio (ω), with constant RH curves.
/// Includes a strict physical clamp to the saturation line (RH = 100%).
class MollierDiagram extends StatelessWidget {
  final double temperature; // Kelvin
  final double relativeHumidity; // 0..1
  final Function(double tempK, double rh)? onProbe;

  const MollierDiagram({
    super.key,
    required this.temperature,
    required this.relativeHumidity,
    this.onProbe,
  });

  static const double paddingLeft = 50.0;
  static const double paddingBottom = 40.0;
  static const double paddingRight = 20.0;
  static const double paddingTop = 20.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AspectRatio(
      aspectRatio: 1.4,
      child: GestureDetector(
        onPanUpdate: (details) => _handleTouch(context, details.localPosition),
        onTapDown: (details) => _handleTouch(context, details.localPosition),
        child: CustomPaint(
          painter: _MollierPainter(
            temp: temperature,
            rh: relativeHumidity,
            textColor: theme.colorScheme.onSurface,
            lineColor: theme.colorScheme.outline,
            labelTemp: l10n.dryBulbTemp,
            labelRatio: l10n.humidityRatio,
          ),
        ),
      ),
    );
  }

  /// Handles touch input and applies the SATURATION CLAMP.
  ///
  /// Thermodynamics dictate that Relative Humidity cannot exceed 100% (1.0).
  /// If the user attempts to drag the probe above the saturation curve, 
  /// the state is clamped to RH = 1.0, effectively sliding along the curve.
  void _handleTouch(BuildContext context, Offset localPos) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final double w = box.size.width;
    final double h = box.size.height;

    const double minTC = 0.0;
    const double maxTC = 50.0;
    const double maxRatioCoord = 0.03; // Maximum displayable ratio on Y axis

    final double chartW = w - paddingLeft - paddingRight;
    final double chartH = h - paddingTop - paddingBottom;

    if (chartW <= 0 || chartH <= 0) return;

    // 1. Map pixel coordinates to physical variables (Dry-bulb Temp and Humidity Ratio)
    double tc = minTC + ((localPos.dx - paddingLeft) / chartW) * (maxTC - minTC);
    double ratio = maxRatioCoord - ((localPos.dy - paddingTop) / chartH) * maxRatioCoord;

    // 2. Clamp to display bounds
    tc = tc.clamp(minTC, maxTC);
    ratio = ratio.clamp(0.0, maxRatioCoord);

    final double tempK = tc + 273.15;
    
    // 3. APPLY SATURATION CLAMP (Task 6/6)
    // pSat = Saturation Vapor Pressure (Tetens formula)
    final pSat = BiophysicsUtils.getSaturationVaporPressure(tempK);
    const double pAtm = 101.325; // Standard atmospheric pressure in kPa
    
    // Calculate RH: rh = (omega * pAtm) / (pSat * (0.622 + omega))
    // Derived from: omega = 0.622 * p_act / (pAtm - p_act) where p_act = rh * pSat
    double rh = (ratio * pAtm) / (pSat * (0.622 + ratio));

    // If calculated RH > 1.0, the state is physically impossible (supersaturation).
    // We clamp it to 1.0. This ensures that even if the user drags "too high", 
    // the probe will follow the saturation curve (the blue line).
    final clampedRH = rh.clamp(0.0, 1.0);

    onProbe?.call(tempK, clampedRH);
  }
}

class _MollierPainter extends CustomPainter {
  final double temp;
  final double rh;
  final Color textColor;
  final Color lineColor;
  final String labelTemp;
  final String labelRatio;

  _MollierPainter({
    required this.temp,
    required this.rh,
    required this.textColor,
    required this.lineColor,
    required this.labelTemp,
    required this.labelRatio,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    const double minTC = 0.0;
    const double maxTC = 50.0;
    const double maxRatio = 0.03;

    final double chartW = w - MollierDiagram.paddingLeft - MollierDiagram.paddingRight;
    final double chartH = h - MollierDiagram.paddingTop - MollierDiagram.paddingBottom;

    if (chartW <= 0 || chartH <= 0) return;

    final chartRect = Rect.fromLTWH(
      MollierDiagram.paddingLeft,
      MollierDiagram.paddingTop,
      chartW,
      chartH,
    );

    // 1. Draw Grid and Background
    _drawGrid(canvas, chartRect, minTC, maxTC, maxRatio);

    // CLIP for curves to keep drawing within the chart area
    canvas.save();
    canvas.clipRect(chartRect);

    // 2. Draw Saturation Curve (100% RH) - The physical limit
    _drawSaturationCurve(canvas, chartRect, minTC, maxTC, maxRatio);

    // 3. Draw RH Isobars (20%, 40%, 60%, 80%)
    for (double rhVal in [0.2, 0.4, 0.6, 0.8]) {
      _drawRHCurve(canvas, chartRect, minTC, maxTC, maxRatio, rhVal);
    }

    // 4. Draw Constant Enthalpy Lines (diagonal guidelines)
    _drawEnthalpyLines(canvas, chartRect, minTC, maxTC, maxRatio);

    // 5. Draw Current State Probe
    _drawCurrentPoint(canvas, chartRect, minTC, maxTC, maxRatio);

    canvas.restore();

    // 6. Axis Labels
    _drawLabels(canvas, size, chartRect);
  }

  void _drawGrid(
    Canvas canvas,
    Rect rect,
    double minT,
    double maxT,
    double maxR,
  ) {
    final paint = Paint()
      ..color = lineColor.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    // Vertical Temp lines (every 10°C)
    for (double t = 0; t <= 50; t += 10) {
      final x = _map(t, minT, maxT, rect.left, rect.right);
      canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), paint);
    }
    // Horizontal Ratio lines (every 0.005 kg/kg)
    for (double r = 0; r <= 0.03; r += 0.005) {
      final y = _map(r, 0, maxR, rect.bottom, rect.top);
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), paint);
    }
  }

  void _drawSaturationCurve(
    Canvas canvas,
    Rect rect,
    double minT,
    double maxT,
    double maxR,
  ) {
    final path = Path();
    for (double tc = minT; tc <= maxT; tc += 0.5) {
      final x = _map(tc, minT, maxT, rect.left, rect.right);
      final ratio = BiophysicsUtils.getHumidityRatio(tc + 273.15, 1.0);
      final y = _map(ratio, 0, maxR, rect.bottom, rect.top);
      if (tc == minT) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.blue.shade700
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  void _drawRHCurve(
    Canvas canvas,
    Rect rect,
    double minT,
    double maxT,
    double maxR,
    double rhVal,
  ) {
    final path = Path();
    for (double tc = minT; tc <= maxT; tc += 1.0) {
      final x = _map(tc, minT, maxT, rect.left, rect.right);
      final ratio = BiophysicsUtils.getHumidityRatio(tc + 273.15, rhVal);
      final y = _map(ratio, 0, maxR, rect.bottom, rect.top);
      if (tc == minT) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _drawEnthalpyLines(
    Canvas canvas,
    Rect rect,
    double minT,
    double maxT,
    double maxR,
  ) {
    final paint = Paint()
      ..color = Colors.green.shade700.withValues(alpha: 0.2)
      ..strokeWidth = 1;
    // Approximation of constant enthalpy lines (h = c_p*T + ω*h_g)
    for (double hVal in [20, 40, 60, 80, 100]) {
      final r0 = hVal / 2501;
      final r40 = (hVal - 1.006 * 40) / (2501 + 1.86 * 40);

      canvas.drawLine(
        Offset(_map(0, minT, maxT, rect.left, rect.right), _map(r0, 0, maxR, rect.bottom, rect.top)),
        Offset(_map(40, minT, maxT, rect.left, rect.right), _map(r40, 0, maxR, rect.bottom, rect.top)),
        paint,
      );
    }
  }

  void _drawCurrentPoint(
    Canvas canvas,
    Rect rect,
    double minT,
    double maxT,
    double maxR,
  ) {
    final tc = temp - 273.15;
    final x = _map(tc, minT, maxT, rect.left, rect.right);
    
    // Use the central helper to ensure visual consistency
    final ratio = BiophysicsUtils.getHumidityRatio(temp, rh.clamp(0.0, 1.0));
    final y = _map(ratio, 0, maxR, rect.bottom, rect.top);

    final paint = Paint()
      ..color = Colors.orange.shade800
      ..style = PaintingStyle.fill;
    
    // Outer glow
    canvas.drawCircle(
      Offset(x, y),
      10,
      Paint()..color = Colors.orange.shade200.withValues(alpha: 0.5),
    );
    
    // Core dot
    canvas.drawCircle(Offset(x, y), 6, paint);
    
    // Contrast border
    canvas.drawCircle(
      Offset(x, y),
      6,
      Paint()
        ..color = textColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  double _map(double val, double min1, double max1, double min2, double max2) {
    return min2 + (val - min1) * (max2 - min2) / (max1 - min1);
  }

  void _drawLabels(Canvas canvas, Size size, Rect rect) {
    _drawText(
      canvas,
      labelTemp,
      Offset(rect.center.dx, rect.bottom + 25),
      textColor.withValues(alpha: 0.8),
    );
    _drawText(
      canvas,
      labelRatio,
      Offset(rect.left - 40, rect.center.dy),
      textColor.withValues(alpha: 0.8),
      rotate: true,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset pos,
    Color color, {
    bool rotate = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    if (rotate) {
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(-math.pi / 2);
      tp.paint(canvas, Offset(-tp.width / 2, 0));
      canvas.restore();
    } else {
      tp.paint(canvas, pos - Offset(tp.width / 2, 0));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
