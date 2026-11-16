import 'dart:ui';
import 'package:flame/components.dart';
import '../soil_scope_game.dart';
import '../../../../domain/models/biophysical_state.dart';
import 'gas_exchange_indicator.dart';
import 'scene_coordinate_mapper.dart';

/// Sub-layer responsible for rendering and positioning atmospheric flux
/// pathways. Indicators are reconciled by stable key so their particle timers,
/// hover state and pinned cards survive the 5 Hz state stream.
class AtmosphericFluxLayerComponent extends Component
    with HasGameReference<SoilScopeGame> {
  final Map<String, AtmosphericFluxIndicator> _indicators = {};

  void updateState(BiophysicalState state) {
    _syncAtmosphericIndicators(state);
  }

  void _syncAtmosphericIndicators(BiophysicalState state) {
    final soilColumnWidth = SoilScopeGame.soilColumnWidth;
    final surfaceY = game.soilSurfaceY;
    final soilX = game.soilLeftX;
    final desiredKeys = <String>{};

    for (final plant in state.plants) {
      final plantBase = SceneCoordinateMapper.mapShootPosition(
        soilColumnWidth,
        surfaceY,
      );
      plantBase.x += soilX;

      final visualHeight = SceneCoordinateMapper.plantVisualHeight(plant);
      final canopyY = surfaceY - (visualHeight * 0.8);
      final canopyPos = Vector2(plantBase.x, canopyY);
      final keyPrefix = 'plant:${plant.id}';

      _upsert(
        desiredKeys,
        '$keyPrefix:co2-in',
        type: FluxType.co2Uptake,
        isCurved: true,
        startOffset: Offset(plant.baseX > 0.5 ? 180 : -180, -60),
        endOffset: Offset.zero,
        position: canopyPos,
        size: Vector2(180, 80),
        fluxValue: plant.stomatalConductance * 2.0,
        priority: 110,
      );
      _upsert(
        desiredKeys,
        '$keyPrefix:h2o-out',
        type: FluxType.h2oTranspiration,
        isCurved: true,
        startOffset: Offset.zero,
        endOffset: Offset(plant.baseX > 0.5 ? 120 : -120, -120),
        position: canopyPos,
        size: Vector2(180, 80),
        fluxValue: plant.actualTranspiration * 1e6,
        priority: 110,
      );
      _upsert(
        desiredKeys,
        '$keyPrefix:co2-out',
        type: FluxType.co2Emission,
        isCurved: true,
        startOffset: Offset.zero,
        endOffset: Offset(plant.baseX > 0.5 ? -120 : 120, -100),
        position: canopyPos,
        size: Vector2(180, 80),
        fluxValue: plant.stomatalConductance * 0.4,
        priority: 110,
      );
    }

    _upsert(
      desiredKeys,
      'soil:co2-out',
      type: FluxType.co2Emission,
      isCurved: true,
      startOffset: Offset.zero,
      endOffset: const Offset(-80, -140),
      position: Vector2(soilX + soilColumnWidth * 0.30, surfaceY),
      size: Vector2(100, 140),
      fluxValue: 0.5,
      priority: 110,
    );
    _upsert(
      desiredKeys,
      'soil:o2-in',
      type: FluxType.o2Diffusion,
      isCurved: true,
      startOffset: const Offset(60, -140),
      endOffset: Offset.zero,
      position: Vector2(soilX + soilColumnWidth * 0.70, surfaceY),
      size: Vector2(100, 140),
      fluxValue: 0.5,
      priority: 110,
    );
    _upsert(
      desiredKeys,
      'soil:n2o-out',
      type: FluxType.n2oEmission,
      isCurved: true,
      startOffset: Offset.zero,
      endOffset: const Offset(40, -140),
      position: Vector2(soilX + soilColumnWidth * 0.50, surfaceY),
      size: Vector2(100, 140),
      fluxValue: 0.5,
      priority: 25,
    );

    for (final key in _indicators.keys.toList()) {
      if (desiredKeys.contains(key)) continue;
      _indicators.remove(key)?.removeFromParent();
    }
  }

  void _upsert(
    Set<String> desiredKeys,
    String key, {
    required FluxType type,
    required bool isCurved,
    required Offset startOffset,
    required Offset endOffset,
    required Vector2 position,
    required Vector2 size,
    required double fluxValue,
    required int priority,
  }) {
    desiredKeys.add(key);
    final existing = _indicators[key];
    if (existing != null) {
      existing.updateFlux(
        position: position,
        fluxValue: fluxValue,
        startOffset: startOffset,
        endOffset: endOffset,
      );
      return;
    }

    final indicator = AtmosphericFluxIndicator(
      type: type,
      isCurved: isCurved,
      startOffset: startOffset,
      endOffset: endOffset,
      position: position,
      size: size,
      fluxValue: fluxValue,
    )..priority = priority;
    _indicators[key] = indicator;
    add(indicator);
  }
}
