import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../soil_scope_game.dart';

/// Visualizes the surface greenery of a cover crop (e.g. clover, rye).
/// Appears when state.hasCoverCrop is true.
class CoverCropComponent extends Component with HasGameReference<SoilScopeGame> {
  final math.Random _random = math.Random(1337);
  final List<_CoverPlant> _plants = [];
  bool _initialized = false;

  @override
  void render(Canvas canvas) {
    final state = game.simulationState;
    if (state == null || !state.hasCoverCrop) return;

    if (!_initialized) {
      _initializePlants();
    }

    final double time = game.currentTime();
    final double zoom = game.camera.viewfinder.zoom;
    final surfaceY = game.soilSurfaceY;
    final soilX = game.soilLeftX;
    final worldWidth = SoilScopeGame.soilColumnWidth;

    for (final plant in _plants) {
      final x = soilX + plant.relativeX * worldWidth;
      
      // Skip area near the main plants (assuming they are centered)
      // Actually, we can check state.plants baseX
      bool nearMainPlant = false;
      for (final p in state.plants) {
         if ((x - (soilX + p.baseX * worldWidth)).abs() < 40) {
           nearMainPlant = true;
           break;
         }
      }
      if (nearMainPlant) continue;

      _drawCoverPlant(canvas, x, surfaceY, plant, time, zoom);
    }
  }

  void _initializePlants() {
    _plants.clear();
    const int count = 40;
    for (int i = 0; i < count; i++) {
      _plants.add(_CoverPlant(
        relativeX: _random.nextDouble(),
        height: 12 + _random.nextDouble() * 15,
        type: _random.nextInt(2), // 0: clover, 1: rye/grass
        phase: _random.nextDouble() * math.pi * 2,
        color: Color.lerp(
          const Color(0xFF4ADE80), // Green 400
          const Color(0xFF166534), // Green 800
          _random.nextDouble(),
        )!,
      ));
    }
    _initialized = true;
  }

  void _drawCoverPlant(Canvas canvas, double x, double y, _CoverPlant plant, double time, double zoom) {
    final sway = math.sin(time * 0.8 + plant.phase) * 3;
    
    if (plant.type == 0) {
      // Clover-like
      final paint = Paint()..color = plant.color;
      final stemPaint = Paint()
        ..color = plant.color.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 / zoom;

      // Stem
      canvas.drawLine(Offset(x, y), Offset(x + sway * 0.5, y - plant.height), stemPaint);
      
      // Leaves
      final leafCenter = Offset(x + sway * 0.5, y - plant.height);
      for (int i = 0; i < 3; i++) {
        final angle = (i * 2 * math.pi / 3) + time * 0.2;
        final leafPos = leafCenter + Offset(math.cos(angle) * 4, math.sin(angle) * 4);
        canvas.drawCircle(leafPos, 3 / zoom, paint);
      }
    } else {
      // Rye/Grass-like
      final paint = Paint()
        ..color = plant.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0 / zoom;

      final path = Path();
      path.moveTo(x, y);
      path.quadraticBezierTo(
        x + sway, 
        y - plant.height * 0.5, 
        x + sway * 1.5, 
        y - plant.height
      );
      canvas.drawPath(path, paint);
      
      // Small seeds/spikelet at top
      if (zoom > 1.2) {
        canvas.drawCircle(Offset(x + sway * 1.5, y - plant.height), 1.5 / zoom, Paint()..color = Colors.yellow.withValues(alpha: 0.5));
      }
    }
  }
}

class _CoverPlant {
  final double relativeX;
  final double height;
  final int type;
  final double phase;
  final Color color;

  _CoverPlant({
    required this.relativeX,
    required this.height,
    required this.type,
    required this.phase,
    required this.color,
  });
}
