import 'package:flutter/material.dart';
import 'package:soilscope/l10n/app_localizations.dart';

class SoilTextureTriangle extends StatelessWidget {
  final double sand; // 0..1
  final double silt; // 0..1
  final double clay; // 0..1
  final Function(double sand, double silt, double clay)? onProbe;

  const SoilTextureTriangle({
    super.key,
    required this.sand,
    required this.silt,
    required this.clay,
    this.onProbe,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final clayLabel = (l10n?.clay ?? 'Clay').toUpperCase();
    final sandLabel = (l10n?.sand ?? 'Sand').toUpperCase();
    final siltLabel = (l10n?.silt ?? 'Silt').toUpperCase();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Use the smaller dimension to keep it square and centered
        final double size =
            (constraints.maxWidth < constraints.maxHeight
                    ? constraints.maxWidth
                    : constraints.maxHeight)
                .clamp(200.0, 600.0);

        final double w = size;
        final double h = size * 0.9; // Standard triangle ratio

        // Define triangle vertices relative to our calculated size
        final Offset top = Offset(w / 2, 30);
        final Offset bottomLeft = Offset(50, h - 50);
        final Offset bottomRight = Offset(w - 50, h - 50);

        return Center(
          child: SizedBox(
            width: w,
            height: h,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (details) => _handleTouch(
                details.localPosition,
                top,
                bottomLeft,
                bottomRight,
              ),
              onTapDown: (details) => _handleTouch(
                details.localPosition,
                top,
                bottomLeft,
                bottomRight,
              ),
              child: CustomPaint(
                size: Size(w, h),
                painter: _TextureTrianglePainter(
                  sand: sand,
                  silt: silt,
                  clay: clay,
                  top: top,
                  bottomLeft: bottomLeft,
                  bottomRight: bottomRight,
                  clayLabel: clayLabel,
                  sandLabel: sandLabel,
                  siltLabel: siltLabel,
                  textColor: theme.colorScheme.onSurface,
                  lineColor: theme.colorScheme.outline,
                  getLocalizedClassName: (cl, sa, si) {
                    if (l10n == null) return "";
                    if (cl >= 0.6) return l10n.textureAS;
                    if (cl >= 0.3) {
                      if (si < 0.5) return l10n.textureHtS;
                      if (sa >= 0.15) return l10n.textureHeS;
                      return l10n.textureHsS;
                    }
                    if (si < 0.5) return l10n.textureHt;
                    if (sa >= 0.15) return l10n.textureHe;
                    return l10n.textureHs;
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleTouch(Offset localPos, Offset top, Offset bl, Offset br) {
    // Proper Barycentric coordinate calculation
    // Solving P = w1*top + w2*bl + w3*br for w1, w2, w3
    final double det =
        (bl.dy - br.dy) * (top.dx - br.dx) + (br.dx - bl.dx) * (top.dy - br.dy);
    if (det.abs() < 1e-6) return;

    final double w1 =
        ((bl.dy - br.dy) * (localPos.dx - br.dx) +
            (br.dx - bl.dx) * (localPos.dy - br.dy)) /
        det;
    final double w2 =
        ((br.dy - top.dy) * (localPos.dx - br.dx) +
            (top.dx - br.dx) * (localPos.dy - br.dy)) /
        det;
    final double w3 = 1.0 - w1 - w2;

    // We allow a small margin for touch ease
    if (w1 >= -0.1 && w2 >= -0.1 && w3 >= -0.1) {
      // Mapping: w1=clay, w2=sand, w3=silt
      double cl = w1.clamp(0.0, 1.0);
      double sa = w2.clamp(0.0, 1.0);
      double si = w3.clamp(0.0, 1.0);

      // Normalize so they sum to 1.0
      final sum = cl + sa + si;
      if (sum > 0) {
        onProbe?.call(sa / sum, si / sum, cl / sum);
      }
    }
  }
}

class _TextureTrianglePainter extends CustomPainter {
  final double sand;
  final double silt;
  final double clay;
  final Offset top;
  final Offset bottomLeft;
  final Offset bottomRight;
  final String clayLabel;
  final String sandLabel;
  final String siltLabel;
  final Color textColor;
  final Color lineColor;
  final String Function(double clay, double sand, double silt) getLocalizedClassName;

  _TextureTrianglePainter({
    required this.sand,
    required this.silt,
    required this.clay,
    required this.top,
    required this.bottomLeft,
    required this.bottomRight,
    required this.clayLabel,
    required this.sandLabel,
    required this.siltLabel,
    required this.textColor,
    required this.lineColor,
    required this.getLocalizedClassName,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas);
    _drawZones(canvas);
    _drawLabels(canvas);
    _drawCurrentPoint(canvas);
  }

  void _drawBackground(Canvas canvas) {
    final paint = Paint()
      ..color = lineColor.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(bottomLeft.dx, bottomLeft.dy)
      ..lineTo(bottomRight.dx, bottomRight.dy)
      ..close();
    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, borderPaint);
  }

  void _drawZones(Canvas canvas) {
    final zonePaint = Paint()
      ..color = lineColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw the 10% grid lines faintly
    for (int i = 1; i < 10; i++) {
      double p = i / 10.0;
      _drawLine(canvas, zonePaint, _toCords(1 - p, 0, p), _toCords(0, 1 - p, p));
      _drawLine(canvas, zonePaint, _toCords(p, 1 - p, 0), _toCords(p, 0, 1 - p));
      _drawLine(canvas, zonePaint, _toCords(1 - p, p, 0), _toCords(0, p, 1 - p));
    }

    // DRAW FINNISH BOUNDARIES (Green lines from the provided image)
    final finnishPaint = Paint()
      ..color = Colors.green.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final dashedPaint = Paint()
      ..color = Colors.green.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // 1. Horizontal line at Clay = 60%
    _drawLine(canvas, finnishPaint, _toCords(0.4, 0, 0.6), _toCords(0, 0.4, 0.6));
    
    // 2. Horizontal line at Clay = 30%
    _drawLine(canvas, finnishPaint, _toCords(0.7, 0, 0.3), _toCords(0, 0.7, 0.3));

    // 3. Silt = 50% boundary (Dashed slanted line)
    // From bottom axis (sa=0.5, si=0.5, cl=0) to (sa=0, si=0.5, cl=0.5)
    _drawLine(canvas, dashedPaint, _toCords(0.5, 0.5, 0), _toCords(0.2, 0.5, 0.3));
    _drawLine(canvas, dashedPaint, _toCords(0.2, 0.5, 0.3), _toCords(0, 0.5, 0.5));

    // 4. Sand = 15% boundary (Right vertical-ish line)
    // From bottom axis (sa=0.15, si=0.85, cl=0) to (sa=0.15, si=0, cl=0.85)
    _drawLine(canvas, finnishPaint, _toCords(0.15, 0.85, 0), _toCords(0.15, 0.55, 0.3));
    _drawLine(canvas, finnishPaint, _toCords(0.15, 0.55, 0.3), _toCords(0.15, 0.25, 0.6));
    
    _drawZoneLabels(canvas);
  }

  void _drawZoneLabels(Canvas canvas) {
    // Positioning labels roughly in the center of Finnish zones
    _drawText(canvas, "AS", _toCords(0.1, 0.1, 0.8), textColor.withValues(alpha: 0.6));
    
    _drawText(canvas, "HtS", _toCords(0.4, 0.15, 0.45), textColor.withValues(alpha: 0.6));
    _drawText(canvas, "HeS", _toCords(0.2, 0.35, 0.45), textColor.withValues(alpha: 0.6));
    _drawText(canvas, "HsS", _toCords(0.05, 0.5, 0.45), textColor.withValues(alpha: 0.6));
    
    _drawText(canvas, "Ht", _toCords(0.6, 0.25, 0.15), textColor.withValues(alpha: 0.6));
    _drawText(canvas, "He", _toCords(0.3, 0.55, 0.15), textColor.withValues(alpha: 0.6));
    _drawText(canvas, "Hs", _toCords(0.07, 0.78, 0.15), textColor.withValues(alpha: 0.6));
  }

  void _drawLine(Canvas canvas, Paint p, Offset p1, Offset p2) {
    if (p1.dx.isFinite && p1.dy.isFinite && p2.dx.isFinite && p2.dy.isFinite) {
      canvas.drawLine(p1, p2, p);
    }
  }

  void _drawCurrentPoint(Canvas canvas) {
    if (sand.isNaN || silt.isNaN || clay.isNaN) return;
    final pos = _toCords(sand, silt, clay);
    if (!pos.dx.isFinite || !pos.dy.isFinite) return;

    final paint = Paint()
      ..color = Colors.cyan.shade700
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      pos,
      10,
      Paint()..color = Colors.cyan.shade200.withValues(alpha: 0.5),
    );
    canvas.drawCircle(pos, 6, paint);
    canvas.drawCircle(
      pos,
      6,
      Paint()
        ..color = textColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    
    // Add current class name label near point
    final className = getLocalizedClassName(clay, sand, silt);
    _drawText(canvas, className, pos + const Offset(0, -20), textColor, bold: true);
  }

  Offset _toCords(double sa, double si, double cl) {
    return Offset(
      cl * top.dx + sa * bottomLeft.dx + si * bottomRight.dx,
      cl * top.dy + sa * bottomLeft.dy + si * bottomRight.dy,
    );
  }

  void _drawLabels(Canvas canvas) {
    // Labels based on Finnish triangle: 
    // Left: Savesta (Clay)
    // Right: Hiesua (Silt)
    // Bottom: Hietaa ja hiekkaa (Sand)
    _drawText(
      canvas,
      clayLabel,
      top + const Offset(0, -18),
      Colors.orange.shade800,
    );
    _drawText(
      canvas,
      sandLabel,
      bottomLeft + const Offset(-30, 18),
      Colors.amber.shade900,
    );
    _drawText(
      canvas,
      siltLabel,
      bottomRight + const Offset(30, 18),
      Colors.blue.shade800,
    );
  }

  void _drawText(Canvas canvas, String text, Offset pos, Color color, {bool bold = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: bold ? 12 : 10,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos - Offset(tp.width / 2, 0));
  }

  @override
  bool shouldRepaint(covariant _TextureTrianglePainter oldDelegate) =>
      oldDelegate.sand != sand ||
      oldDelegate.silt != silt ||
      oldDelegate.clay != clay;
}
