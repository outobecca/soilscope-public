import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide PointerMoveEvent;
import '../soil_scope_game.dart';
import '../../../../domain/models/plant.dart';
import '../../../providers/simulation_provider.dart';
import '../../../providers/ui_state_provider.dart';
import 'scene_coordinate_mapper.dart';
import 'data_packet_component.dart';

/// Draws photosynthesis light absorption indicators at leaves for all plants.
/// Anchors rays to the actual sun position in the atmosphere.
class PhotosynthesisIndicatorComponent extends Component
    with HasGameReference<SoilScopeGame>, TapCallbacks, HoverCallbacks {
  PhotosynthesisIndicatorComponent() : super(priority: 44);

  bool _isPinned = false;

  @override
  void update(double dt) {
    super.update(dt);
    final state = game.ref.read(simulationProvider);
    if (!state.isRunning) return;

    final double radiation = state.solarRadiation;
    const double solarConstant = 800.0;
    final intensity = (radiation / solarConstant).clamp(0.0, 1.0);
    final time = game.currentTime();

    if (intensity > 0.6 && time % 2.5 < dt * 2) {
      for (final plant in state.plants) {
        final pg = _getPlantGeometry(plant);
        _spawnCarbonPacket(plant, pg);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final double zoom = game.camera.viewfinder.zoom;
    final double time = game.currentTime();
    final state = game.ref.read(simulationProvider);

    const double solarConstant = 800.0;
    final double radiation = state.solarRadiation;
    if (radiation < 100) return;

    final intensity = (radiation / solarConstant).clamp(0.0, 1.0);
    
    // SUN position is synchronized with SunIndicatorComponent placement in world space
    final soilRight = game.soilLeftX + SoilScopeGame.soilColumnWidth;
    final sunWorldPos = Offset(soilRight - 80, 80);

    for (final plant in state.plants) {
      final pg = _getPlantGeometry(plant);
      _drawLightRays(canvas, zoom, time, intensity, pg.leafPositions, sunWorldPos);
    }
  }

  void _spawnCarbonPacket(Plant plant, _PlantGeometry pg) {
    // Path from top leaf to root collar (node 0)
    final shootTop = pg.leafPositions.last;
    final collar = Vector2(pg.plantCenterX, pg.surfaceY);
    
    game.world.add(
      DataPacket(
        type: FluxType.carbon,
        path: [Vector2(shootTop.dx, shootTop.dy), collar],
        speed: 120.0,
        color: const Color(0xFF475569), // Slate/Grey for Carbon
      ),
    );
  }

  void _drawLightRays(
    Canvas canvas,
    double zoom,
    double time,
    double intensity,
    List<Offset> leafPositions,
    Offset sunPos,
  ) {
    final rayPaint = Paint()
      ..color = const Color(0xFFFCD34D).withValues(alpha: 0.12 * intensity)
      ..strokeWidth = 1.2 / zoom
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < leafPositions.length; i++) {
      final leaf = leafPositions[i];
      final phase = time * 2 + i * 0.5;
      final flicker = 0.7 + 0.3 * math.sin(phase);

      rayPaint.color = const Color(0xFFFCD34D).withValues(alpha: 0.12 * intensity * flicker);

      final dir = leaf - sunPos;
      final dist = dir.distance;
      if (dist < 5) continue;

      final rayStart = sunPos + (dir / dist) * 80; 
      canvas.drawLine(rayStart, leaf, rayPaint);

      final glowPaint = Paint()
        ..color = const Color(0xFF22C55E).withValues(alpha: 0.25 * intensity * flicker)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(leaf, 10 / zoom, glowPaint);

      if (intensity > 0.4) {
        _drawCO2Absorption(canvas, zoom, time, leaf, flicker);
      }
    }
  }

  void _drawCO2Absorption(
    Canvas canvas,
    double zoom,
    double time,
    Offset leaf,
    double flicker,
  ) {
    final co2Paint = Paint()..color = const Color(0xFFEC4899);
    for (int j = 0; j < 3; j++) {
      final particlePhase = (time + j * 0.3) % 1.0;
      final particleX = leaf.dx - 20 + particlePhase * 25;
      final particleY = leaf.dy + math.sin(particlePhase * math.pi) * 5;
      final particleAlpha = 1.0 - particlePhase;
      final pos = Offset(particleX, particleY);
      final radius = 2.0 / zoom;
      
      // Shadow
      canvas.drawCircle(pos + const Offset(0.5, 0.5), radius, Paint()..color = Colors.black.withValues(alpha: 0.1 * particleAlpha));
      // Body
      canvas.drawCircle(pos, radius, co2Paint..color = const Color(0xFFEC4899).withValues(alpha: 0.5 * particleAlpha));
      // Highlight
      canvas.drawCircle(pos - Offset(radius * 0.3, radius * 0.3), radius * 0.35, Paint()..color = Colors.white.withValues(alpha: 0.4 * particleAlpha));
    }
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    final state = game.ref.read(simulationProvider);
    for (final plant in state.plants) {
      final pg = _getPlantGeometry(plant);
      if ((point.y - (pg.surfaceY - pg.plantHeight / 2)).abs() < pg.plantHeight / 2 &&
          (point.x - pg.plantCenterX).abs() < 25) {
        return true;
      }
    }
    return false;
  }

  @override
  void onTapUp(TapUpEvent event) {
    _isPinned = !_isPinned;
    _showPhotoInfo(pinned: _isPinned);
    event.handled = true;
  }

  @override
  void onHoverEnter() {
    final current = game.ref.read(uIStateProvider);
    if (current == null || !current.isPinned) _showPhotoInfo(pinned: false);
  }

  @override
  void onHoverExit() {
    if (!_isPinned) {
      final current = game.ref.read(uIStateProvider);
      if (current == null || !current.isPinned) {
        game.ref.read(uIStateProvider.notifier).setHoverInfo(null);
      }
    }
  }

  void _showPhotoInfo({bool pinned = false}) {
    final l = game.l10n;
    game.ref.read(uIStateProvider.notifier).setHoverInfo(
      HoverInfo(
        title: l.photosynthesis.toUpperCase(),
        description: l.photosynthesisDesc,
        stats: {
          l.processLabel: l.c3Pathway,
          l.efficiencyLabel: l.rubiscoLimited,
          l.productLabel: l.sugarCompound,
        },
        isPinned: pinned,
      ),
    );
  }

  _PlantGeometry _getPlantGeometry(Plant plant) {
    final surfaceY = game.soilSurfaceY;
    final soilWidth = SoilScopeGame.soilColumnWidth;
    final plantPos = SceneCoordinateMapper.mapShootPosition(plant.baseX, soilWidth, surfaceY);
    plantPos.x += game.soilLeftX; // Shift by soil column offset
    final plantCenterX = plantPos.x;

    final atmosphereHeight = surfaceY;
    final maxPlantHeight = atmosphereHeight * 0.8;
    final hFactor = (plant.height / 1.5).clamp(0.25, 1.0);
    final plantHeight = hFactor * maxPlantHeight;

    final healthFactor = plant.turgorPressure.clamp(0.0, 1.0);
    final double wiltSway = (1.0 - healthFactor) * 15 * math.pi / 180;
    final double windSway = math.sin(game.currentTime() * 1.5) * 0.03;

    final leafTs = [0.40, 0.55, 0.70, 0.85, 0.95];
    final leafPositions =
        leafTs.map((t) {
          return Offset(
            plantCenterX +
                math.sin(wiltSway + windSway) * plantHeight * t +
                (t < 0.6 ? -25 : 25) * hFactor,
            surfaceY - math.cos(wiltSway + windSway) * plantHeight * t,
          );
        }).toList();

    return _PlantGeometry(
      plantCenterX: plantCenterX,
      surfaceY: surfaceY,
      plantHeight: plantHeight,
      leafPositions: leafPositions,
    );
  }
}

class _PlantGeometry {
  final double plantCenterX;
  final double surfaceY;
  final double plantHeight;
  final List<Offset> leafPositions;

  _PlantGeometry({
    required this.plantCenterX,
    required this.surfaceY,
    required this.plantHeight,
    required this.leafPositions,
  });
}
