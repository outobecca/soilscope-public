import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../soil_scope_game.dart';
import '../../../providers/simulation_session_provider.dart';
import '../../../../domain/models/biophysical_state.dart';

enum MagnifierType { leaf, stem, root, rhizosphere, microbe, soilStructure, apicalMeristem }

/// High-fidelity microscope (Nanovision) component.
/// Provides detailed cross-sectional visualization of biophysical processes.
class ProcessMagnifier extends PositionComponent
    with HasGameReference<SoilScopeGame> {
  final MagnifierType type;
  final double radius = 120.0;
  double _opacity = 0.0;
  double _scale = 0.0;
  bool isVisible = false;
  
  // Reference to the world hotspot for orientation
  Vector2? _hotspotWorldPosition;

  ProcessMagnifier({
    required this.type,
    required Vector2 position,
    Vector2? hotspotWorldPosition,
  }) : _hotspotWorldPosition = hotspotWorldPosition,
       super(
         position: position,
         size: Vector2.all(300.0),
         anchor: Anchor.center,
         priority: 200,
       );

  void setHotspot(Vector2 worldPosition) {
    _hotspotWorldPosition = worldPosition;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = Vector2.all(300.0);
  }

  @override
  void render(Canvas canvas) {
    if (_opacity <= 0) return;

    final center = Offset(size.x / 2, size.y / 2);

    // 0. Projection Beam (Orientation Linkage)
    if (_opacity > 0.1 && _hotspotWorldPosition != null) {
      _drawProjectionBeam(canvas, center, _hotspotWorldPosition!);
    }

    // 1. Outer Glow
    final glowPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: _opacity * 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);
    canvas.drawCircle(center, (radius + 15) * _scale, glowPaint);

    // 2. Main Glass Circle
    final circleRect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius * _scale,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E293B).withValues(alpha: _opacity * 0.98),
            const Color(0xFF0F172A).withValues(alpha: _opacity * 0.98),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    
    // Backdrop blur effect (Simulation)
    // In Flame, we can't easily use BackdropFilter inside canvas clip, 
    // but we can simulate it with a darker, slightly textured base.
    final blurSimPaint = Paint()
      ..color = Colors.black.withValues(alpha: _opacity * 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center, radius * _scale, blurSimPaint);
    
    // Magnification Level Badge
    final magLevel = switch (type) {
      MagnifierType.leaf => '400x',
      MagnifierType.stem => '200x',
      MagnifierType.root => '400x',
      MagnifierType.rhizosphere => '600x',
      MagnifierType.microbe => '1200x',
      MagnifierType.soilStructure => '250x',
      MagnifierType.apicalMeristem => '800x',
    };
    _drawMagnificationBadge(canvas, center, magLevel);

    // Glossy shine
    canvas.drawCircle(
      center,
      (radius - 5) * _scale,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withValues(alpha: 0.1), Colors.transparent],
        ).createShader(circleRect),
    );

    // Premium Border
    final borderPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF38BDF8).withValues(alpha: _opacity),
          const Color(0xFF0EA5E9).withValues(alpha: _opacity * 0.5),
          const Color(0xFF38BDF8).withValues(alpha: _opacity),
        ],
      ).createShader(circleRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;
    canvas.drawCircle(center, radius * _scale, borderPaint);

    // 3. Detailed Anatomy (Clipped)
    canvas.save();
    final clipPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius * _scale));
    canvas.clipPath(clipPath);
    // Scale anatomy with the magnifier
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(_scale);
    canvas.translate(-center.dx, -center.dy);
    _drawDetailedAnatomy(canvas, center);
    canvas.restore();
    canvas.restore();

    // 4. Labels & Pointers
    if (_scale > 0.8) {
      _drawAnatomyLabels(canvas, center);
    }

    // Scanning line effect
    if (_opacity > 0.1) {
       final scanlinePaint = Paint()..color = Colors.cyanAccent.withValues(alpha: 0.1 * _opacity)..style = PaintingStyle.stroke..strokeWidth = 2.0;
       final yPos = center.dy - (radius * _scale) + (_scanlineOffset / 240) * (radius * 2 * _scale);
       canvas.drawLine(
         Offset(center.dx - radius * _scale * 0.8, yPos), 
         Offset(center.dx + radius * _scale * 0.8, yPos), 
         scanlinePaint,
       );
    }
  }

  void _drawDetailedAnatomy(Canvas canvas, Offset center) {
    final double time = game.currentTime();
    final state = game.simulationState;
    if (state == null) return;

    switch (type) {
      case MagnifierType.leaf:
        _drawLeafDetail(canvas, center, time, state);
        break;
      case MagnifierType.stem:
        _drawStemDetail(canvas, center, time, state);
        break;
      case MagnifierType.root:
        _drawRootDetail(canvas, center, time, state);
        break;
      case MagnifierType.rhizosphere:
        _drawRhizosphereDetail(canvas, center, time, state);
        break;
      case MagnifierType.microbe:
        _drawMicrobeDetail(canvas, center, time, state);
        break;
      case MagnifierType.soilStructure:
        _drawSoilStructureDetail(canvas, center, time, state);
        break;
      case MagnifierType.apicalMeristem:
        _drawApicalMeristemDetail(canvas, center, time, state);
        break;
    }
  }

  void _drawLeafDetail(Canvas canvas, Offset center, double time, BiophysicalState state) {
    final plant = state.plants.isNotEmpty ? state.plants.first : state.plant;
    // activity is currently unused, but kept logic for potential future use if needed
    // final activity = plant.turgorPressure.clamp(0.1, 1.0);
    final double w = radius * 1.8;

    final nContent = state.profile.layers.first.nitrateContent + state.profile.layers.first.ammoniumContent;
    final isDeficient = nContent < 15.0;
    final isLowPar = state.solarRadiation < 200.0;

    // 1. Upper Epidermis
    final epiPaint = Paint()
      ..color = isDeficient 
        ? Colors.amber.shade100.withValues(alpha: _opacity * 0.8)
        : (isLowPar ? Colors.lightGreen.shade100.withValues(alpha: _opacity * 0.6) : const Color(0xFFC8E6C9).withValues(alpha: _opacity * 0.8))
      ..style = PaintingStyle.fill;
    final wallPaint = Paint()
      ..color = const Color(0xFF4CAF50).withValues(alpha: _opacity * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = -6; i <= 6; i++) {
      final r = Rect.fromCenter(center: center + Offset(i * 20.0, -85), width: 18, height: 12);
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(3)), epiPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(3)), wallPaint);
    }

    // 2. Palisade Mesophyll (Tall cells)
    final palisadePaint = Paint()
      ..color = isDeficient 
        ? Colors.amber.shade300.withValues(alpha: _opacity * 0.9)
        : (isLowPar ? Colors.lightGreen.shade200.withValues(alpha: _opacity * 0.7) : const Color(0xFF81C784).withValues(alpha: _opacity * 0.9));
    
    final photoPulse = (state.solarRadiation / 1000.0).clamp(0.2, 1.0);

    for (int i = -10; i <= 10; i++) {
      final r = Rect.fromCenter(center: center + Offset(i * 12.0, -55), width: 10, height: 45);
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(4)), palisadePaint);
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(4)), wallPaint);
      
      // Chloroplasts (Active Photosynthesis)
      final cpPaint = Paint()
        ..color = isDeficient 
          ? Colors.amber.shade900.withValues(alpha: _opacity * 0.6)
          : const Color(0xFF1B5E20).withValues(alpha: _opacity * (0.5 + 0.3 * photoPulse));
      
      for (int j = 0; j < 5; j++) {
        final cpY = r.top + 6 + j * 8;
        // Subtle vibration of chloroplasts based on activity
        final vibX = math.sin(time * 5 + i + j) * 0.5 * photoPulse;
        canvas.drawCircle(Offset(r.center.dx + vibX, cpY), 1.8, cpPaint);
      }
    }

    // 3. Spongy Mesophyll (Loose cells)
    final spongyPaint = Paint()
      ..color = isDeficient 
        ? Colors.amber.shade200.withValues(alpha: _opacity * 0.7)
        : (isLowPar ? Colors.lightGreen.shade100.withValues(alpha: _opacity * 0.5) : const Color(0xFFAED581).withValues(alpha: _opacity * 0.7));
    final rand = math.Random(42);
    for (int i = 0; i < 25; i++) {
      final p = center + Offset(-w/2 + rand.nextDouble() * w, -10 + rand.nextDouble() * 50);
      final r = 8.0 + rand.nextDouble() * 4;
      canvas.drawCircle(p, r, spongyPaint);
      canvas.drawCircle(p, r, wallPaint);
    }

    // 4. Central Vascular Bundle (Vein)
    final bundleCenter = center + const Offset(0, 20);
    canvas.drawCircle(bundleCenter, 35, Paint()..color = const Color(0xFFF1F8E9).withValues(alpha: _opacity)..style = PaintingStyle.fill);
    canvas.drawCircle(bundleCenter, 35, Paint()..color = const Color(0xFF4CAF50).withValues(alpha: _opacity * 0.5)..style = PaintingStyle.stroke..strokeWidth = 2.0);
    
    // Xylem (Top half of bundle, red)
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(bundleCenter.dx - 40, bundleCenter.dy - 40, 80, 40));
    canvas.drawCircle(bundleCenter, 32, Paint()..color = const Color(0xFFFFCDD2).withValues(alpha: _opacity));
    canvas.restore();
    
    // Phloem (Bottom half, teal)
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(bundleCenter.dx - 40, bundleCenter.dy, 80, 40));
    canvas.drawCircle(bundleCenter, 32, Paint()..color = const Color(0xFFB2DFDB).withValues(alpha: _opacity));
    canvas.restore();

    // 5. Lower Epidermis & Stomata
    for (int i = -6; i <= 6; i++) {
      if (i == 0) {
        continue; // Gap for stoma
      }
      final r = Rect.fromCenter(center: center + Offset(i * 20.0, 85), width: 18, height: 12);
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(3)), epiPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(3)), wallPaint);
    }

    final stomaOpening = (1.0 + 9.0 * plant.turgorPressure).clamp(1.0, 10.0);
    final guardPaint = Paint()..color = const Color(0xFF81C784).withValues(alpha: _opacity);
    canvas.drawOval(Rect.fromCenter(center: center + Offset(-6 - stomaOpening/2, 85), width: 12, height: 18), guardPaint);
    canvas.drawOval(Rect.fromCenter(center: center + Offset(6 + stomaOpening/2, 85), width: 12, height: 18), guardPaint);

    _drawValueLabel(canvas, center, '${(plant.turgorPressure * 100).toStringAsFixed(0)}% Turgor');
  }

  void _drawStemDetail(Canvas canvas, Offset center, double time, BiophysicalState state) {
    final plant = state.plants.isNotEmpty ? state.plants.first : state.plant;
    final flowSpeed = (plant.waterUptake * 50).clamp(0.5, 5.0);

    final nContent = state.profile.layers.first.nitrateContent + state.profile.layers.first.ammoniumContent;
    final isDeficient = nContent < 15.0;
    final isLowPar = state.solarRadiation < 200.0;

    // 1. Epidermis (Outer ring)
    canvas.drawCircle(center, 100, Paint()..color = const Color(0xFF1B5E20).withValues(alpha: _opacity)..style = PaintingStyle.stroke..strokeWidth = 3.0);
    
    // 2. Cortex (Inner light ring)
    final cortexColor = isDeficient 
      ? Colors.amber.shade300 
      : (isLowPar ? Colors.lightGreen.shade200 : const Color(0xFF81C784));
    canvas.drawCircle(center, 96, Paint()..color = cortexColor.withValues(alpha: _opacity * 0.3)..style = PaintingStyle.stroke..strokeWidth = 8.0);

    // 3. Pith (Center area with cellular texture)
    final pithColor = isDeficient 
      ? Colors.amber.shade100 
      : (isLowPar ? Colors.lightGreen.shade50 : const Color(0xFFF1F8E9));
    canvas.drawCircle(center, 88, Paint()..color = pithColor.withValues(alpha: _opacity * 0.8));
    final rand = math.Random(42);
    for (int i = 0; i < 40; i++) {
      final a = rand.nextDouble() * math.pi * 2;
      final d = rand.nextDouble() * 70;
      canvas.drawCircle(center + Offset(math.cos(a) * d, math.sin(a) * d), 10, Paint()..color = const Color(0xFFC8E6C9).withValues(alpha: _opacity * 0.2)..style = PaintingStyle.stroke);
    }

    // 4. Vascular Bundles arranged in a ring
    for (int i = 0; i < 8; i++) {
      final angle = i * (math.pi * 2 / 8) + time * 0.1;
      final bundlePos = center + Offset(math.cos(angle) * 75, math.sin(angle) * 75);
      
      canvas.save();
      canvas.translate(bundlePos.dx, bundlePos.dy);
      canvas.rotate(angle);
      
      // Phloem (Outer, Teal)
      canvas.drawPath(
        Path()..moveTo(-10, -5)..quadraticBezierTo(0, -15, 10, -5)..lineTo(8, 5)..lineTo(-8, 5)..close(),
        Paint()..color = const Color(0xFF4DB6AC).withValues(alpha: _opacity),
      );
      
      // Xylem (Inner, Red, Upward flow)
      final xylemPulse = 0.8 + 0.2 * math.sin(time * flowSpeed + i);
      canvas.drawPath(
        Path()..moveTo(-8, 8)..lineTo(8, 8)..lineTo(5, 20)..quadraticBezierTo(0, 25, -5, 20)..close(),
        Paint()..color = const Color(0xFFE57373).withValues(alpha: _opacity * xylemPulse),
      );
      
      // Xylem flow particles
      final pPos = (time * flowSpeed * 2 + i * 5) % 30;
      canvas.drawCircle(Offset(0, 20 - pPos), 2, Paint()..color = Colors.white.withValues(alpha: _opacity * 0.5));
      
      canvas.restore();
    }
    
    _drawValueLabel(canvas, center, '${(plant.waterUptake * 1000).toStringAsFixed(2)} µl/s Flux');
  }

  void _drawRootDetail(Canvas canvas, Offset center, double time, BiophysicalState state) {
    final plant = state.plants.isNotEmpty ? state.plants.first : state.plant;
    final health = plant.turgorPressure;

    final nContent = state.profile.layers.first.nitrateContent + state.profile.layers.first.ammoniumContent;
    final isDeficient = nContent < 15.0;
    
    // 1. Cortex (Outer cellular area)
    final rootCortexColor = isDeficient 
      ? Colors.amber.shade100 
      : const Color(0xFFF5F5F5);
    canvas.drawCircle(center, 110, Paint()..color = rootCortexColor.withValues(alpha: _opacity));
    canvas.drawCircle(center, 110, Paint()..color = const Color(0xFF795548).withValues(alpha: _opacity * 0.7)..style = PaintingStyle.stroke..strokeWidth = 3.0);
    
    // Cortex cellular rings
    for (int r = 1; r <= 3; r++) {
      canvas.drawCircle(center, 110 - r * 25.0, Paint()..color = Colors.black12.withValues(alpha: _opacity * 0.1)..style = PaintingStyle.stroke..strokeWidth = 1.0);
    }

    // 2. Endodermis (Casparian Strip ring)
    canvas.drawCircle(center, 45, Paint()..color = const Color(0xFF388E3C).withValues(alpha: _opacity)..style = PaintingStyle.stroke..strokeWidth = 5.0);

    // 3. Stele (Center)
    canvas.drawCircle(center, 40, Paint()..color = const Color(0xFFF1F8E9).withValues(alpha: _opacity));

    // 4. Xylem Tetrarch Star (Red)
    final xylemPath = Path();
    for (int i = 0; i < 4; i++) {
      final a = i * math.pi / 2;
      final p1 = center + Offset(math.cos(a) * 35, math.sin(a) * 35);
      final aNext = a + math.pi / 4;
      final p2 = center + Offset(math.cos(aNext) * 10, math.sin(aNext) * 10);
      if (i == 0) {
        xylemPath.moveTo(p1.dx, p1.dy);
      } else {
        xylemPath.lineTo(p1.dx, p1.dy);
      }
      xylemPath.lineTo(p2.dx, p2.dy);
    }
    xylemPath.close();
    canvas.drawPath(xylemPath, Paint()..color = const Color(0xFFE57373).withValues(alpha: _opacity));

    // 5. Phloem Clusters (Blue, between xylem arms)
    for (int i = 0; i < 4; i++) {
      final a = i * math.pi / 2 + math.pi / 4;
      final p = center + Offset(math.cos(a) * 25, math.sin(a) * 25);
      canvas.drawCircle(p, 8, Paint()..color = const Color(0xFF4FC3F7).withValues(alpha: _opacity));
    }

    // 6. Root Hairs (Lateral view simulation at 200x)
    final hairPaint = Paint()
      ..color = Colors.white.withValues(alpha: _opacity * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    for (int i = 0; i < 12; i++) {
      final a = (i / 12) * math.pi * 2 + time * 0.2;
      canvas.drawLine(
        center + Offset(math.cos(a) * 110, math.sin(a) * 110),
        center + Offset(math.cos(a) * 145, math.sin(a) * 145),
        hairPaint,
      );
    }

    // 7. Symplastic Flow (Water moving through cells to xylem)
    final flowColor = const Color(0xFF38BDF8).withValues(alpha: _opacity * 0.6);
    for (int i = 0; i < 6; i++) {
      final t = (time * 0.4 + i * 0.2) % 1.0;
      final d = 110 - t * 75;
      final a = i * math.pi / 3 + time * 0.1;
      canvas.drawCircle(center + Offset(math.cos(a) * d, math.sin(a) * d), 2.5, Paint()..color = flowColor);
    }

    _drawValueLabel(canvas, center, 'ROOT TIP: ${health > 0.8 ? "ACTIVE GROWTH" : "STRESSED"}');
  }

  void _drawRhizosphereDetail(Canvas canvas, Offset center, double time, BiophysicalState state) {
    // 1. Clay Platelets (Negative matrix)
    final clayPaint = Paint()..color = const Color(0xFF78350F).withValues(alpha: _opacity * 0.9);
    final rand = math.Random(101);
    for (int i = 0; i < 12; i++) {
      final px = center.dx - 60 + rand.nextDouble() * 120;
      final py = center.dy - 80 + rand.nextDouble() * 160;
      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(rand.nextDouble() * math.pi);
      final platPath = Path();
      const double r = 18.0;
      for (int j = 0; j < 6; j++) {
        final a = j * math.pi / 3;
        final x = math.cos(a) * r;
        final y = math.sin(a) * r;
        if (j == 0) {
          platPath.moveTo(x, y);
        } else {
          platPath.lineTo(x, y);
        }
      }
      platPath.close();
      canvas.drawPath(platPath, clayPaint);
      final cp = Paint()..color = Colors.white.withValues(alpha: _opacity * 0.5)..style = PaintingStyle.stroke..strokeWidth = 1.5;
      canvas.drawLine(const Offset(-4, 0), const Offset(4, 0), cp);
      canvas.restore();
    }

    // 2. Ion Adsorption (NH4+ to clay)
    final ammoniumPaint = Paint()..color = const Color(0xFF8F40AD).withValues(alpha: _opacity);
    for (int i = 0; i < 6; i++) {
      final ax = center.dx - 30 + math.sin(time + i) * 50;
      final ay = center.dy - 40 + math.cos(time * 0.8 + i) * 60;
      canvas.drawCircle(Offset(ax, ay), 4.5, ammoniumPaint);
      _drawGlow(canvas, Offset(ax, ay), 8, Colors.purple.withValues(alpha: 0.3));
    }

    // 3. Root Exudation & Ion Migration
    final ionPaint = Paint()..color = Colors.white.withValues(alpha: _opacity * 0.4);
    for (int i = 0; i < 15; i++) {
      final p = (time * 0.8 + i * 0.2) % 1.0;
      final start = center + Offset(-100 + i * 15, -100);
      final end = center + const Offset(0, 0);
      final pos = start + (end - start) * p;
      canvas.drawCircle(pos, 2, ionPaint);
    }
    _drawValueLabel(canvas, center, game.l10n.ionExchangePriming);
  }

  void _drawMicrobeDetail(Canvas canvas, Offset center, double time, BiophysicalState state) {
    final layer = state.profile.layers.first;
    final activity = (layer.microbialBiomass / 100.0).clamp(0.1, 5.0);
    final stretch = math.cos(time * (2 + activity)) * 10;
    final bacRect = Rect.fromCenter(center: center, width: 140 + stretch, height: 60 - stretch / 2);

    canvas.drawRRect(RRect.fromRectAndRadius(bacRect, const Radius.circular(30)), Paint()..color = const Color(0xFF0EA5E9).withValues(alpha: _opacity * 0.9));

    // Flagella
    final fPath = Path()..moveTo(center.dx - 70 - stretch/2, center.dy);
    for (int i = 0; i < 4; i++) {
      fPath.quadraticBezierTo(
        center.dx - 90 - i * 15, center.dy + math.sin(time * 10 + i) * 20,
        center.dx - 110 - i * 15, center.dy,
      );
    }
    canvas.drawPath(fPath, Paint()..color = Colors.white.withValues(alpha: _opacity * 0.4)..style = PaintingStyle.stroke..strokeWidth = 2.0);

    // DNA / Nucleoid area
    final dnaPaint = Paint()
      ..color = Colors.purpleAccent.withValues(alpha: _opacity * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final dnaPath = Path()..moveTo(center.dx - 30, center.dy);
    for (int i = 0; i < 20; i++) {
      dnaPath.lineTo(center.dx - 30 + i * 3, center.dy + math.sin(i * 1.2 + time * 2) * 8);
    }
    canvas.drawPath(dnaPath, dnaPaint);

    final enzymeP = Paint()..color = const Color(0xFFFACC15).withValues(alpha: _opacity * 0.8);
    for (int i = 0; i < 5; i++) {
      final phase = (time * activity + i) % (math.pi * 2);
      canvas.drawCircle(center + Offset(70 + stretch / 2 + (phase / (math.pi * 2)) * 80, math.sin(i * 1.5) * 20), 3, enzymeP);
    }
    _drawValueLabel(canvas, center, '${layer.co2Content.toStringAsFixed(3)} mol CO₂');
  }

  void _drawApicalMeristemDetail(Canvas canvas, Offset center, double time, BiophysicalState state) {
    final domePaint = Paint()
      ..color = const Color(0xFFBEF264).withValues(alpha: _opacity * 0.9)
      ..style = PaintingStyle.fill;
    final wallPaint = Paint()
      ..color = const Color(0xFF65A30D).withValues(alpha: _opacity * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = Path()
      ..moveTo(center.dx - 40, center.dy + 60)
      ..cubicTo(center.dx - 40, center.dy - 30, center.dx + 40, center.dy - 30, center.dx + 40, center.dy + 60)
      ..close();
    canvas.drawPath(path, domePaint);
    canvas.drawPath(path, wallPaint);

    final primPaint = Paint()
      ..color = const Color(0xFF84CC16).withValues(alpha: _opacity * 0.8);
    final leftPrim = Path()
      ..moveTo(center.dx - 35, center.dy + 30)
      ..cubicTo(center.dx - 70, center.dy - 10, center.dx - 50, center.dy - 40, center.dx - 25, center.dy + 10)
      ..close();
    canvas.drawPath(leftPrim, primPaint);
    canvas.drawPath(leftPrim, wallPaint);

    final rightPrim = Path()
      ..moveTo(center.dx + 35, center.dy + 30)
      ..cubicTo(center.dx + 70, center.dy - 10, center.dx + 50, center.dy - 40, center.dx + 25, center.dy + 10)
      ..close();
    canvas.drawPath(rightPrim, primPaint);
    canvas.drawPath(rightPrim, wallPaint);

    final rand = math.Random(123);
    for (int i = 0; i < 30; i++) {
      final dx = (rand.nextDouble() - 0.5) * 50;
      final dy = (rand.nextDouble() - 0.5) * 40 + 20;
      final r = Rect.fromCenter(center: center + Offset(dx, dy), width: 8, height: 8);
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(2)), Paint()..color = const Color(0xFFD9F99D).withValues(alpha: _opacity * 0.9));
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(2)), wallPaint);
      
      canvas.drawCircle(center + Offset(dx, dy), 1.5, Paint()..color = const Color(0xFF4D7C0F).withValues(alpha: _opacity * 0.8));
    }

    _drawValueLabel(canvas, center, 'ACTIVE CELL DIVISION');
  }

  void _drawSoilStructureDetail(Canvas canvas, Offset center, double time, BiophysicalState state) {
    final layer = state.profile.layers.first;
    final rand = math.Random(42);
    final stability = layer.aggregateStability;
    
    // 1. Aggregates
    final ap = Paint()..color = Color.lerp(const Color(0xFF78350F), const Color(0xFF451A03), stability)!.withValues(alpha: _opacity);
    for (int i = 0; i < 6; i++) {
      canvas.drawCircle(center + Offset(-70 + rand.nextDouble() * 140, -70 + rand.nextDouble() * 140), (15 + rand.nextDouble() * 15) * (0.5 + stability), ap);
    }

    // 2. Clay Platelets (Hexagons)
    final clayPaint = Paint()..color = const Color(0xFF94A3B8).withValues(alpha: _opacity * 0.6)..style = PaintingStyle.stroke..strokeWidth = 1.0;
    for (int i = 0; i < 10; i++) {
      final pos = center + Offset(-90 + rand.nextDouble() * 180, -90 + rand.nextDouble() * 180);
      final path = Path();
      const r = 12.0;
      for (int j = 0; j < 6; j++) {
        final angle = j * math.pi / 3;
        final pt = Offset(pos.dx + math.cos(angle) * r, pos.dy + math.sin(angle) * r);
        if (j == 0) {
          path.moveTo(pt.dx, pt.dy);
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }
      path.close();
      canvas.drawPath(path, clayPaint);
    }

    // 3. Sand Grains (Jagged)
    final sandPaint = Paint()..color = const Color(0xFFFDE68A).withValues(alpha: _opacity * 0.4);
    for (int i = 0; i < 4; i++) {
       canvas.drawRect(Rect.fromLTWH(center.dx - 100 + rand.nextDouble() * 200, center.dy - 100 + rand.nextDouble() * 200, 15, 15), sandPaint);
    }

    _drawValueLabel(canvas, center, '${game.l10n.stability}: ${(stability * 100).toStringAsFixed(0)}%');
  }

  void _drawGlow(Canvas canvas, Offset pos, double radius, Color color) {
    canvas.drawCircle(pos, radius, Paint()..color = color..maskFilter = MaskFilter.blur(BlurStyle.normal, radius));
  }

  void _drawValueLabel(Canvas canvas, Offset center, String text) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.cyanAccent.withValues(alpha: _opacity),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final labelCenter = Offset(
      center.dx.roundToDouble(),
      (center.dy + radius - 20).roundToDouble(),
    );
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: labelCenter,
        width: (tp.width + 16).roundToDouble(),
        height: 20,
      ),
      const Radius.circular(4),
    );

    // Drop shadow
    canvas.drawRRect(
      bgRect.shift(const Offset(0, 1)),
      Paint()
        ..color = Colors.black.withValues(alpha: _opacity * 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    // Background
    canvas.drawRRect(
      bgRect,
      Paint()..color = Colors.black.withValues(alpha: _opacity * 0.85),
    );
    // Border
    canvas.drawRRect(
      bgRect,
      Paint()
        ..color = Colors.cyanAccent.withValues(alpha: _opacity * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );
    // Pixel-snap text position
    tp.paint(
      canvas,
      Offset(
        (labelCenter.dx - tp.width / 2).roundToDouble(),
        (labelCenter.dy - tp.height / 2).roundToDouble(),
      ),
    );
  }

  void _drawMagnificationBadge(Canvas canvas, Offset center, String level) {
    final tp = TextPainter(
      text: TextSpan(
        text: level,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final badgePos = Offset(center.dx + radius - 35, center.dy - radius + 25);
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: badgePos, width: tp.width + 12, height: 16),
      const Radius.circular(8),
    );

    canvas.drawRRect(rect, Paint()..color = const Color(0xFF0EA5E9).withValues(alpha: _opacity));
    tp.paint(canvas, badgePos - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawAnatomyLabels(Canvas canvas, Offset center) {
    final l = game.l10n;
    final labels = switch (type) {
      MagnifierType.leaf => [{'text': l.cuticle, 'pos': const Offset(130, -100)}, {'text': l.palisade, 'pos': const Offset(130, -40)}, {'text': l.vein, 'pos': const Offset(130, 30)}, {'text': l.stoma, 'pos': const Offset(130, 95)}],
      MagnifierType.stem => [{'text': l.epidermis, 'pos': const Offset(-160, -100)}, {'text': l.phloem, 'pos': const Offset(-160, -40)}, {'text': l.cambium, 'pos': const Offset(-160, 20)}, {'text': l.xylem, 'pos': const Offset(-160, 80)}],
      MagnifierType.root => [{'text': l.rootHair, 'pos': const Offset(130, -100)}, {'text': l.cortex, 'pos': const Offset(130, 0)}, {'text': l.casparianStrip, 'pos': const Offset(130, 80)}],
      MagnifierType.rhizosphere => [{'text': l.root, 'pos': const Offset(-160, -80)}, {'text': l.exudates, 'pos': const Offset(130, -50)}, {'text': l.microbes, 'pos': const Offset(130, 20)}, {'text': l.nutrient, 'pos': const Offset(130, 80)}],
      MagnifierType.microbe => [{'text': l.flagella, 'pos': const Offset(-160, -20)}, {'text': l.cellWall, 'pos': const Offset(-160, 50)}, {'text': l.dna, 'pos': const Offset(130, -30)}, {'text': l.enzymes, 'pos': const Offset(130, 50)}],
      MagnifierType.soilStructure => [{'text': l.aggregates, 'pos': const Offset(-160, -40)}, {'text': l.sandGrains, 'pos': const Offset(130, -40)}, {'text': l.cracks, 'pos': const Offset(130, 40)}, {'text': l.porosity, 'pos': const Offset(-160, 40)}],
      MagnifierType.apicalMeristem => [{'text': 'PRIMORDIA', 'pos': const Offset(-160, -60)}, {'text': 'STEM CELLS', 'pos': const Offset(130, -30)}, {'text': 'APICAL DOME', 'pos': const Offset(130, 40)}],
    };

    final textStyle = TextStyle(
      color: Colors.white.withValues(alpha: _opacity),
      fontSize: 11,
      fontFamily: 'monospace',
      fontWeight: FontWeight.bold,
    );
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: _opacity * 0.4)
      ..strokeWidth = 1.0;

    for (final label in labels) {
      final pos = label['pos'] as Offset;
      final text = label['text'] as String;
      final tp = TextPainter(
        text: TextSpan(text: text, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      // Pixel-snap label position
      final labelPos = Offset(
        (center.dx + pos.dx).roundToDouble(),
        (center.dy + pos.dy).roundToDouble(),
      );

      // Background pill for readability
      final bgRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          labelPos.dx - 4,
          labelPos.dy - 2,
          tp.width + 8,
          tp.height + 4,
        ),
        const Radius.circular(3),
      );
      canvas.drawRRect(
        bgRect,
        Paint()..color = const Color(0xFF0F172A).withValues(alpha: _opacity * 0.7),
      );

      tp.paint(canvas, labelPos);
      canvas.drawLine(
        labelPos + Offset(pos.dx > 0 ? -5 : tp.width + 5, tp.height / 2),
        center + Offset(pos.dx > 0 ? 80.0 : -80.0, pos.dy + tp.height / 2),
        linePaint,
      );
    }

    // Title badge
    final title = switch (type) {
      MagnifierType.leaf => l.plantCanopy.toUpperCase(),
      MagnifierType.stem => l.stemCrossSection.toUpperCase(),
      MagnifierType.root => l.rootTissue.toUpperCase(),
      MagnifierType.rhizosphere => l.rhizosphere.toUpperCase(),
      MagnifierType.microbe => l.microbialCell.toUpperCase(),
      MagnifierType.soilStructure => l.soilStructure.toUpperCase(),
      MagnifierType.apicalMeristem => "APICAL MERISTEM",
    };
    final titleTp = TextPainter(
      text: TextSpan(
        text: title,
        style: textStyle.copyWith(fontSize: 12, letterSpacing: 1.5),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final titleCenter = Offset(
      center.dx.roundToDouble(),
      (center.dy - radius - 25).roundToDouble(),
    );
    final titleBg = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: titleCenter,
        width: (titleTp.width + 24).roundToDouble(),
        height: 28,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(
      titleBg,
      Paint()..color = const Color(0xFF1E293B).withValues(alpha: _opacity * 0.95),
    );
    canvas.drawRRect(
      titleBg,
      Paint()
        ..color = const Color(0xFF38BDF8).withValues(alpha: _opacity * 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
    titleTp.paint(
      canvas,
      Offset(
        (titleCenter.dx - titleTp.width / 2).roundToDouble(),
        (titleCenter.dy - titleTp.height / 2).roundToDouble(),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isVisible) {
      _opacity = (_opacity + dt * 4).clamp(0.0, 1.0);
      _scale = (_scale + dt * 3).clamp(0.0, 1.0);
    } else {
      _opacity = (_opacity - dt * 4).clamp(0.0, 1.0);
      _scale = (_scale - dt * 5).clamp(0.0, 0.0);
    }

    // High-tech scanning flicker
    if (_opacity > 0) {
      _scanlineOffset = (_scanlineOffset + dt * 150) % 240;
    }

    // Dynamic positioning near hotspot
    if (_opacity > 0 && _hotspotWorldPosition != null) {
      _updateViewportPosition();
    }
  }

  void _updateViewportPosition() {
    final camera = game.camera;
    final zoom = camera.viewfinder.zoom;
    final camPos = camera.viewfinder.position;
    final viewportSize = camera.viewport.size;
    
    // World-to-Viewport transformation
    final screenX = (_hotspotWorldPosition!.x - camPos.x) * zoom + viewportSize.x / 2;
    final screenY = (_hotspotWorldPosition!.y - camPos.y) * zoom + viewportSize.y / 2;

    // Smart positioning:
    // Try to stay on the same side as the plant, but offset to avoid covering the hotspot
    final double xOffset = screenX > viewportSize.x / 2 ? -radius - 80 : radius + 80;
    
    // Vertical bias: prefer staying above the hotspot to avoid the gamebar
    double targetX = screenX + xOffset;
    double targetY = screenY - radius - 60;

    // CONSTRAINTS: Avoid off-screen, gamebar, and right action bar
    final session = game.ref.read(simulationSessionProvider);
    final panelHeight = session.isMicroscopeEnabled ? 170.0 : 120.0; 
    const rightBarWidth = 100.0; // Buffer for quick actions
    
    // Keep within horizontal bounds, avoiding right bar
    targetX = targetX.clamp(radius + 20, viewportSize.x - radius - rightBarWidth);
    
    // Keep within vertical bounds, avoiding the bottom panel
    targetY = targetY.clamp(radius + 40, viewportSize.y - panelHeight - radius - 20);

    position = Vector2(targetX, targetY);
  }

  void _drawProjectionBeam(Canvas canvas, Offset center, Vector2 hotspot) {
    final camera = game.camera;
    final zoom = camera.viewfinder.zoom;
    final camPos = camera.viewfinder.position;
    final viewportSize = camera.viewport.size;
    
    // Manual World-to-Viewport transformation for CameraComponent
    final screenX = (hotspot.x - camPos.x) * zoom + viewportSize.x / 2;
    final screenY = (hotspot.y - camPos.y) * zoom + viewportSize.y / 2;
    
    // Magnifier's center in viewport coordinates (Now dynamic)
    final magViewportX = position.x; 
    final magViewportY = position.y; 

    final offsetToHotspot = Offset(screenX - magViewportX, screenY - magViewportY);
    final distance = offsetToHotspot.distance;

    if (distance < 0.1) return;
    
    final beamPaint = Paint()
      ..color = const Color(0xFF06B6D4).withValues(alpha: _opacity * 0.4)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final direction = math.atan2(offsetToHotspot.dy, offsetToHotspot.dx);
    const dashLength = 5.0;
    const gapLength = 3.0;
    double currentDistance = 0;

    final dx = math.cos(direction);
    final dy = math.sin(direction);

    while (currentDistance < distance) {
      final startDist = currentDistance;
      final endDist = (currentDistance + dashLength).clamp(0.0, distance);

      final start = center + Offset(dx * startDist, dy * startDist);
      final end = center + Offset(dx * endDist, dy * endDist);

      canvas.drawLine(start, end, beamPaint);
      currentDistance = endDist + gapLength;
    }
    
    // Small target circle at the hotspot (Screen space)
    canvas.drawCircle(
      center + offsetToHotspot, 
      4.0, 
      Paint()..color = const Color(0xFF38BDF8).withValues(alpha: _opacity)..style = PaintingStyle.stroke..strokeWidth = 1.0,
    );
  }

  double _scanlineOffset = 0;
}
