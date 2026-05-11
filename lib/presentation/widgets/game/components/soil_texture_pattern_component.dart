import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide PointerMoveEvent;
import '../soil_scope_game.dart';
import '../../../providers/simulation_provider.dart';
import '../../../providers/ui_state_provider.dart';
import '../../../providers/simulation_session_provider.dart';
import 'soil_component_mixin.dart';

/// High-fidelity soil texture component that visualizes physical composition
/// (sand, silt, clay) and biological hotspots.
class SoilTexturePatternComponent extends Component
    with HasGameReference<SoilScopeGame>, TapCallbacks, SoilComponentMixin {
  final Paint _overlayPaint = Paint();
  final Paint _sandPaint = Paint();
  final Paint _siltPaint = Paint()..style = PaintingStyle.stroke;
  final Paint _clayPaint = Paint()..style = PaintingStyle.stroke;
  final Paint _clayLinePaint = Paint();
  final Paint _hotspotPaint = Paint();

  SoilTexturePatternComponent() : super(priority: 4);

  
  @override
  void render(Canvas canvas) {
    final double zoom = game.camera.viewfinder.zoom;
    final state = game.ref.read(simulationProvider);
    if (state.profile.layers.isEmpty) return;

    final double scaleY = calculateVerticalScale(
      state.profile.layers.fold(0.0, (sum, l) => sum + l.thickness),
    );

    final rand = math.Random(12345);
    double currentY = surfaceY;

    for (final layer in state.profile.layers) {
      final layerHeight = layer.thickness * scaleY;
      final endY = currentY + layerHeight;
      final saturation = (layer.waterContent / layer.porosity).clamp(0.0, 1.0);
      final session = game.ref.read(simulationSessionProvider);
      
      // Highlight Overlay
      if (session.selectedInspectorType == 'Soil') {
        final pulse = 0.5 + 0.5 * math.sin(game.currentTime() * 4);
        canvas.drawRect(
          Rect.fromLTRB(backgroundX, currentY, backgroundX + backgroundWidth, endY),
          _overlayPaint..color = Colors.white.withValues(alpha: 0.05 * pulse),
        );
      }

      // 1. Draw Physical Texture
      if (layer.sandFraction > 0.5) {
        _drawSandTexture(canvas, currentY, endY, backgroundX, backgroundWidth, zoom, rand, saturation);
      } else if (layer.clayFraction > 0.35) {
        _drawClayTexture(canvas, currentY, endY, backgroundX, backgroundWidth, zoom, rand, saturation);
      } else {
        _drawSiltTexture(canvas, currentY, endY, backgroundX, backgroundWidth, zoom, rand, saturation);
      }

      // 2. Draw Biological Microsites (Hotspots)
      if (layer.microbialBiomass > 20) {
        _drawBioHotspots(canvas, currentY, endY, backgroundX, backgroundWidth, zoom, rand, layer.microbialBiomass);
      }

      currentY = endY;
    }
  }

  void _drawSandTexture(Canvas canvas, double startY, double endY, double xStart, double width, double zoom, math.Random rand, double saturation) {
    final grainCount = ((endY - startY) * width / 50).toInt().clamp(500, 5000); // Drastically reduced
    for (int i = 0; i < grainCount; i++) {
      final x = xStart + rand.nextDouble() * width;
      final y = startY + rand.nextDouble() * (endY - startY);
      final radius = (1.2 + rand.nextDouble() * 2.2) / zoom;
      final isWhite = rand.nextDouble() > 0.6;
      final color = isWhite ? Colors.white : const Color(0xFFFFC107);
      canvas.drawCircle(Offset(x, y), radius, _sandPaint..color = color.withValues(alpha: 0.08 + rand.nextDouble() * 0.12));
    }
  }

  void _drawSiltTexture(Canvas canvas, double startY, double endY, double xStart, double width, double zoom, math.Random rand, double saturation) {
    final rowCount = ((endY - startY) / 10).toInt().clamp(10, 100);
    final paint = _siltPaint..strokeWidth = 1.0 / zoom;
    for (int i = 0; i < rowCount; i++) {
      final y = startY + (i + 0.5) * (endY - startY) / rowCount;
      paint.color = (i % 2 == 0 ? Colors.white : Colors.black).withValues(alpha: 0.1);
      final path = Path()..moveTo(xStart, y);
      for (double x = xStart; x <= xStart + width; x += 20) {
        path.lineTo(x, y + math.sin(x * 0.1 + i) * 3);
      }
      canvas.drawPath(path, paint);
    }
  }

  void _drawClayTexture(Canvas canvas, double startY, double endY, double xStart, double width, double zoom, math.Random rand, double saturation) {
    final pedCount = ((endY - startY) * width / 250).toInt().clamp(100, 20000);
    final paint = _clayPaint..strokeWidth = 1.2 / zoom;
    for (int i = 0; i < pedCount; i++) {
      final cx = xStart + rand.nextDouble() * width;
      final cy = startY + rand.nextDouble() * (endY - startY);
      final size = (20 + rand.nextDouble() * 40) / zoom;
      paint.color = Colors.black.withValues(alpha: 0.12);
      final path = Path();
      path.moveTo(cx - size/2, cy - size/3);
      path.lineTo(cx + size/3, cy - size/2);
      path.lineTo(cx + size/2, cy + size/4);
      path.lineTo(cx - size/4, cy + size/2);
      path.close();
      canvas.drawPath(path, paint);
      canvas.drawLine(
        Offset(cx - size/2, cy),
        Offset(cx + size/2, cy + size/10),
        _clayLinePaint
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2 / zoom
          ..color = Colors.white.withValues(alpha: 0.04),
      );
    }
  }

  void _drawBioHotspots(Canvas canvas, double startY, double endY, double xStart, double width, double zoom, math.Random rand, double biomass) {
    final spotCount = (biomass / 15).toInt().clamp(2, 10);
    // CRITICAL: Blur should not explode at low zoom. Clamp it.
    final blurValue = (8.0 / zoom).clamp(4.0, 15.0);
    final spotPaint = _hotspotPaint..maskFilter = MaskFilter.blur(BlurStyle.normal, blurValue);
    
    for (int i = 0; i < spotCount; i++) {
      final x = xStart + rand.nextDouble() * width;
      final y = startY + rand.nextDouble() * (endY - startY);
      // Fixed size in screen space or constrained in world space
      final radius = (8.0 + rand.nextDouble() * 12.0); 
      spotPaint.color = const Color(0xFF689F38).withValues(alpha: 0.1); // Increased alpha for visibility but kept small
      canvas.drawCircle(Offset(x, y), radius, spotPaint);
    }
  }

  @override
  bool containsLocalPoint(Vector2 point) => isInsideSimulation(point);

  @override
  void onTapUp(TapUpEvent event) {
    final state = game.ref.read(simulationProvider);
    final double scaleY = calculateVerticalScale(
      state.profile.layers.fold(0.0, (sum, l) => sum + l.thickness),
    );
    double currentY = surfaceY;
    for (final layer in state.profile.layers) {
      final layerHeight = layer.thickness * scaleY;
      if (event.localPosition.y >= currentY && event.localPosition.y <= currentY + layerHeight) {
        _showTextureInfo(layer, pinned: true);
        break;
      }
      currentY += layerHeight;
    }
    event.handled = true;
  }

  void _showTextureInfo(dynamic layer, {bool pinned = false}) {
    final l = game.l10n;
    game.ref.read(uIStateProvider.notifier).setHoverInfo(
      HoverInfo(
        title: l.soilStructureTexture.toUpperCase(),
        description: l.soilStructureTexture,
        stats: {
          l.sand: '${(layer.sandFraction * 100).toStringAsFixed(0)}%',
          l.silt: '${(layer.siltFraction * 100).toStringAsFixed(0)}%',
          l.clay: '${(layer.clayFraction * 100).toStringAsFixed(0)}%',
        },
        isPinned: pinned,
      ),
    );
  }
}
