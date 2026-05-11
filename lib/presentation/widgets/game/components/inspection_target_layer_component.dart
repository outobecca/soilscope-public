import 'dart:math' as math;
import 'package:flame/components.dart';
import '../soil_scope_game.dart';
import '../../../../domain/models/biophysical_state.dart';
import 'inspection_target.dart';
import 'magnifier_group_component.dart';
import 'process_magnifier.dart';
import 'scene_coordinate_mapper.dart';

/// Sub-layer responsible for managing the positions of logical Inspection Targets.
class InspectionTargetLayerComponent extends Component
    with HasGameReference<SoilScopeGame> {
  final List<InspectionTarget> _inspectionTargets = [];
  bool _inspectorInitialized = false;

  void updateState(BiophysicalState state) {
    if (!_inspectorInitialized) {
      _initInspectionTargets();
    }
    _updateInspectionTargetPositions(state);
  }

  void _initInspectionTargets() {
    final magnifierGroup =
        game.camera.viewport.children.query<MagnifierGroupComponent>().firstOrNull;
    if (magnifierGroup == null) return;

    for (final type in MagnifierType.values) {
      final magnifier = magnifierGroup.getMagnifier(type);
      if (magnifier != null) {
        final target = InspectionTarget(
          type: type,
          magnifier: magnifier,
          position: Vector2.zero(),
        )..priority = 1200;
        _inspectionTargets.add(target);
        add(target);
      }
    }
    _inspectorInitialized = true;
  }

  void _updateInspectionTargetPositions(BiophysicalState state) {
    final plant = state.plants.isNotEmpty ? state.plants.first : state.plant;
    final soilX = game.soilLeftX;
    final surfaceY = game.soilSurfaceY;
    final worldWidth = SoilScopeGame.soilColumnWidth;
    final soilHeight = game.soilColumnHeight;

    final currentHeight = SceneCoordinateMapper.plantVisualHeight(plant);
    // Movement is disabled to maintain sync with the static AnimatedPlantComponent
    const totalAngle = 0.0;
    
    for (final target in _inspectionTargets) {
      target.opacity = 1.0;
      
      // Calculate top position
      final topX = math.sin(totalAngle) * currentHeight * 0.4;
      final topY = -currentHeight;
      final plantBaseX = SceneCoordinateMapper.mapRootX(0.5, worldWidth, baseX: plant.baseX) + soilX;
      final plantBaseY = surfaceY;

      switch (target.type) {
        case MagnifierType.apicalMeristem:
          // TOP: The very tip of the stem
          target.position = Vector2(plantBaseX + topX, plantBaseY + topY);
          break;
        case MagnifierType.leaf:
          // LEAF BOTTOM: Junction of the lowest major leaf with the stem
          final t = 0.2; // Lower position on the stem for the "bottom of leaf" request
          final cp1X = math.sin(totalAngle) * currentHeight * 0.1;
          final cp1Y = -currentHeight * 0.4;
          final cp2X = topX * 0.8;
          final cp2Y = topY * 0.7;
          final lX = _cubicBezier(0, cp1X, cp2X, topX, t);
          final lY = _cubicBezier(0, cp1Y, cp2Y, topY, t);
          target.position = Vector2(plantBaseX + lX, plantBaseY + lY);
          break;
        case MagnifierType.stem:
          // MIDDLE OF SHOOT: Center of the main stem
          final t = 0.5;
          final cp1X = math.sin(totalAngle) * currentHeight * 0.1;
          final cp1Y = -currentHeight * 0.4;
          final cp2X = topX * 0.8;
          final cp2Y = topY * 0.7;
          final sX = _cubicBezier(0, cp1X, cp2X, topX, t);
          final sY = _cubicBezier(0, cp1Y, cp2Y, topY, t);
          target.position = Vector2(plantBaseX + sX, plantBaseY + sY);
          break;
        case MagnifierType.root:
          // BOTTOM OF THE ROOT: The deepest active root tip
          RootNode? deepestTip;
          for (final node in plant.rootSystem) {
            if (node.isTip) {
              if (deepestTip == null || node.z > deepestTip.z) {
                deepestTip = node;
              }
            }
          }

          if (deepestTip != null) {
            target.position = Vector2(
              SceneCoordinateMapper.mapRootX(deepestTip.x, worldWidth, baseX: plant.baseX) + soilX,
              SceneCoordinateMapper.mapRootY(deepestTip.z, surfaceY, soilHeight),
            );
          }
          break;
        case MagnifierType.rhizosphere:
          // MIDDLE OF THE ROOT: A central node in the taproot
          int validNodeCount = 0;
          for (final node in plant.rootSystem) {
            if (node.radius > 0.01) {
              validNodeCount++;
            }
          }

          if (validNodeCount > 5) {
            final middleIndex = validNodeCount ~/ 2;
            int currentIndex = 0;
            for (final node in plant.rootSystem) {
              if (node.radius > 0.01) {
                if (currentIndex == middleIndex) {
                  target.position = Vector2(
                    SceneCoordinateMapper.mapRootX(node.x, worldWidth, baseX: plant.baseX) + soilX,
                    SceneCoordinateMapper.mapRootY(node.z, surfaceY, soilHeight),
                  );
                  break;
                }
                currentIndex++;
              }
            }
          }
          break;
        case MagnifierType.microbe:
          // Soil micro-zone near the top layer
          target.position = Vector2(
            SceneCoordinateMapper.mapRootX(0.2, worldWidth, baseX: plant.baseX) + soilX,
            surfaceY + 80,
          );
          break;
        case MagnifierType.soilStructure:
          // Static soil aggregate position
          target.position = Vector2(soilX + worldWidth * 0.15, surfaceY + 220);
          break;
      }
      
      // Update orientation linkage for the projection beam
      target.magnifier.setHotspot(target.position);
    }
  }

  double _cubicBezier(double p0, double p1, double p2, double p3, double t) {
    final u = 1 - t;
    return u * u * u * p0 + 3 * u * u * t * p1 + 3 * u * t * t * p2 + t * t * t * p3;
  }
}
