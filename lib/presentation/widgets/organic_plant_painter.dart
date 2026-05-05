import 'dart:math';
import 'package:flutter/material.dart';
import '../../domain/models/plant.dart';

/// A CustomPainter-based plant component for SoilScope.
/// This provides organic, procedural growth for roots, stems, and leaves.
class OrganicPlantPainter extends CustomPainter {
  final double growth;
  final double rootGrowth;
  final int leafCount;

  OrganicPlantPainter({
    required this.growth,
    required this.rootGrowth,
    this.leafCount = 5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.7);

    // Soil background
    final groundPaint = Paint()
      ..color = const Color(0xFF3E2723).withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(0, center.dy, size.width, size.height - center.dy),
      groundPaint,
    );

    // Draw complex root system
    _drawComplexRoots(canvas, center, rootGrowth);

    // Draw stem and leaves
    if (growth > 0) {
      _drawStemAndLeaves(canvas, center, growth, size.height * 0.5);
    }
  }

  void _drawComplexRoots(Canvas canvas, Offset start, double progress) {
    // Create 3 primary roots in different directions
    for (int i = 0; i < 3; i++) {
      double angle = pi / 2 + (i - 1) * 0.4; // Downward-facing fan
      _drawRootBranch(
        canvas: canvas,
        start: start,
        angle: angle,
        length: 80.0,
        thickness: 3.0,
        depth: 0,
        maxDepth: 2, // How many times the root branches
        progress: progress,
      );
    }
  }

  void _drawRootBranch({
    required Canvas canvas,
    required Offset start,
    required double angle,
    required double length,
    required double thickness,
    required int depth,
    required int maxDepth,
    required double progress,
  }) {
    if (progress <= 0) return;

    // Calculate end point
    final currentLength = length * progress;
    final end = Offset(
      start.dx + cos(angle) * currentLength,
      start.dy + sin(angle) * currentLength,
    );

    final paint = Paint()
      ..color = Color.lerp(Colors.brown[700], Colors.orangeAccent[100], 0.3)!
          .withValues(alpha: (0.8 - (depth * 0.2)).clamp(0.0, 1.0))
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw curvature (Quadratic Bezier) for organic feel
    final path = Path();
    path.moveTo(start.dx, start.dy);

    // Control point for curvature
    final controlPoint = Offset(
      start.dx + cos(angle + 0.2 * (depth + 1)) * (currentLength / 2),
      start.dy + sin(angle + 0.2 * (depth + 1)) * (currentLength / 2),
    );
    path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, end.dx, end.dy);
    canvas.drawPath(path, paint);

    // If max depth not reached and sufficiently grown, branch out
    if (depth < maxDepth && progress > 0.4) {
      // Branch 1: Starts halfway
      _drawRootBranch(
        canvas: canvas,
        start: Offset.lerp(start, end, 0.6)!,
        angle: angle - 0.5,
        length: length * 0.7,
        thickness: thickness * 0.6,
        depth: depth + 1,
        maxDepth: maxDepth,
        progress: (progress - 0.4) * 1.6, // Delayed growth for branches
      );

      // Branch 2: Starts further down
      _drawRootBranch(
        canvas: canvas,
        start: Offset.lerp(start, end, 0.8)!,
        angle: angle + 0.5,
        length: length * 0.6,
        thickness: thickness * 0.5,
        depth: depth + 1,
        maxDepth: maxDepth,
        progress: (progress - 0.5) * 2.0,
      );
    }
  }

  void _drawStemAndLeaves(
    Canvas canvas,
    Offset start,
    double progress,
    double maxHeight,
  ) {
    final stemPaint = Paint()
      ..color = Colors.green[800]!
      ..strokeWidth = 4.0 * (0.5 + progress * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final stemPath = Path();
    stemPath.moveTo(start.dx, start.dy);

    final endY = start.dy - (maxHeight * progress);
    stemPath.quadraticBezierTo(
      start.dx + 5 * sin(progress * 5),
      start.dy - (maxHeight * progress / 2),
      start.dx,
      endY,
    );

    canvas.drawPath(stemPath, stemPaint);

    // Draw leaves
    final leafPaint = Paint()
      ..color = Colors.green[400]!
      ..style = PaintingStyle.fill;

    for (int i = 1; i <= leafCount; i++) {
      double leafTrigger = i / (leafCount + 1);
      if (progress > leafTrigger) {
        double leafY = start.dy - (maxHeight * leafTrigger);
        double side = i % 2 == 0 ? 1 : -1;
        double leafScale = (progress - leafTrigger) * 4;
        _drawLeaf(
          canvas,
          Offset(start.dx, leafY),
          side,
          leafScale.clamp(0.0, 1.0),
          leafPaint,
        );
      }
    }
  }

  void _drawLeaf(
    Canvas canvas,
    Offset pos,
    double side,
    double scale,
    Paint paint,
  ) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(side * pi / 4);
    canvas.scale(scale);

    final leafPath = Path();
    leafPath.moveTo(0, 0);
    leafPath.quadraticBezierTo(15, -15, 30, 0);
    leafPath.quadraticBezierTo(15, 15, 0, 0);

    // Leaf vein
    final veinPaint = Paint()
      ..color = Colors.green[900]!.withValues(alpha: 0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawPath(leafPath, paint);
    canvas.drawLine(const Offset(0, 0), const Offset(25, 0), veinPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant OrganicPlantPainter oldDelegate) =>
      oldDelegate.growth != growth || oldDelegate.rootGrowth != rootGrowth;
}

/// A widget wrapper for the [OrganicPlantPainter].
class OrganicPlantWidget extends StatelessWidget {
  final double growth;
  final double rootGrowth;
  final int leafCount;
  final Size size;

  const OrganicPlantWidget({
    super.key,
    required this.growth,
    required this.rootGrowth,
    this.leafCount = 5,
    this.size = const Size(200, 400),
  });

  /// Creates an [OrganicPlantWidget] from a [Plant] model.
  factory OrganicPlantWidget.fromPlant(
    Plant plant, {
    Size size = const Size(200, 400),
  }) {
    // Basic mapping of biomass/age to growth parameters
    final double growth = (plant.totalBiomass / 1000.0).clamp(0.0, 1.0);
    final double rootGrowth = (plant.rootBiomass / 500.0).clamp(0.0, 1.0);
    final int leafCount =
        (2 + (plant.totalBiomass / 150.0).floor()).clamp(2, 10).toInt();

    return OrganicPlantWidget(
      growth: growth,
      rootGrowth: rootGrowth,
      leafCount: leafCount,
      size: size,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: size,
      painter: OrganicPlantPainter(
        growth: growth,
        rootGrowth: rootGrowth,
        leafCount: leafCount,
      ),
    );
  }
}
