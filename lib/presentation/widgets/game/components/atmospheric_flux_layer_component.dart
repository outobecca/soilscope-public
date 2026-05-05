import 'dart:ui';
import 'package:flame/components.dart';
import '../soil_scope_game.dart';
import '../../../../domain/models/biophysical_state.dart';
import 'gas_exchange_indicator.dart';
import 'scene_coordinate_mapper.dart';

/// Sub-layer responsible for rendering and positioning atmospheric flux pathways.
class AtmosphericFluxLayerComponent extends Component
    with HasGameReference<SoilScopeGame> {
  final List<AtmosphericFluxIndicator> _indicators = [];

  void updateState(BiophysicalState state) {
    _initAtmosphericIndicators(state);
  }

  void _initAtmosphericIndicators(BiophysicalState state) {
    for (final i in _indicators) {
      i.removeFromParent();
    }
    _indicators.clear();

    final soilColumnWidth = SoilScopeGame.soilColumnWidth;
    final surfaceY = game.soilSurfaceY;
    final soilX = game.soilLeftX;

    for (final plant in state.plants) {
      final plantBase = SceneCoordinateMapper.mapShootPosition(
        plant.baseX,
        soilColumnWidth,
        surfaceY,
      );
      plantBase.x += soilX;

      final visualHeight = SceneCoordinateMapper.plantVisualHeight(plant);
      final canopyY = surfaceY - (visualHeight * 0.8);
      final canopyPos = Vector2(plantBase.x, canopyY);

      // CO2 Uptake (Photosynthesis) - driven by stomatal conductance
      final co2In = AtmosphericFluxIndicator(
        type: FluxType.co2Uptake,
        isCurved: true,
        startOffset: Offset(plant.baseX > 0.5 ? 180 : -180, -60),
        endOffset: Offset.zero,
        position: canopyPos,
        size: Vector2(180, 80),
        fluxValue: plant.stomatalConductance * 2.0, // Scale for visibility
      )..priority = 110;

      // H2O Transpiration - driven by actual transpiration
      final h2oOut = AtmosphericFluxIndicator(
        type: FluxType.h2oTranspiration,
        isCurved: true,
        startOffset: Offset.zero,
        endOffset: Offset(plant.baseX > 0.5 ? 120 : -120, -120),
        position: canopyPos,
        size: Vector2(180, 80),
        fluxValue: plant.actualTranspiration * 1e6, // Scale m/s to visibility
      )..priority = 110;

      // Plant Respiration (CO2 Out)
      final plantCo2Out = AtmosphericFluxIndicator(
        type: FluxType.co2Emission,
        isCurved: true,
        startOffset: Offset.zero,
        endOffset: Offset(plant.baseX > 0.5 ? -120 : 120, -100),
        position: canopyPos,
        size: Vector2(180, 80),
        fluxValue: plant.stomatalConductance * 0.4, // Simplified respiration scaling
      )..priority = 110;

      _indicators.addAll([co2In, h2oOut, plantCo2Out]);
      add(co2In);
      add(h2oOut);
      add(plantCo2Out);
    }

    final co2Out = AtmosphericFluxIndicator(
      type: FluxType.co2Emission,
      isCurved: true,
      startOffset: Offset.zero,
      endOffset: const Offset(-80, -140),
      position: Vector2(soilX + soilColumnWidth * 0.30, surfaceY),
      size: Vector2(100, 140),
    )..priority = 110;

    final o2In = AtmosphericFluxIndicator(
      type: FluxType.o2Diffusion,
      isCurved: true,
      startOffset: const Offset(60, -140),
      endOffset: Offset.zero,
      position: Vector2(soilX + soilColumnWidth * 0.70, surfaceY),
      size: Vector2(100, 140),
    )..priority = 110;

    final n2oOut = AtmosphericFluxIndicator(
      type: FluxType.n2oEmission,
      isCurved: true,
      startOffset: Offset.zero,
      endOffset: const Offset(40, -140),
      position: Vector2(soilX + soilColumnWidth * 0.50, surfaceY),
      size: Vector2(100, 140),
    )..priority = 25;

    _indicators.addAll([co2Out, o2In, n2oOut]);
    add(co2Out);
    add(o2In);
    add(n2oOut);
  }
}
