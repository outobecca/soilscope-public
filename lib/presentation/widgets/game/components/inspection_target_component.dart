import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:material_ui/material_ui.dart' hide PointerMoveEvent;
import '../soil_scope_game.dart';
import '../../../providers/simulation_session_provider.dart';
import '../../../providers/ui_state_provider.dart';
import 'canvas_hit_testing.dart';
import 'process_magnifier_component.dart';


class InspectionTargetComponent extends PositionComponent
    with HasGameReference<SoilScopeGame>, HoverCallbacks {
  final MagnifierType type;
  final ProcessMagnifierComponent magnifier;
  double opacity = 1.0;
  bool _isHovered = false;

  /// Derived from the shared session so opening/closing the microscope from
  /// the HUD or quick actions cannot leave a target stuck in a stale pinned
  /// state (which used to make the next tap close instead of open the view).
  bool get _isPinned {
    final session = game.ref.read(simulationSessionProvider);
    return session.isMicroscopeEnabled &&
        session.selectedInspectorType == type.name;
  }

  InspectionTargetComponent({
    required this.type,
    required this.magnifier,
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2.all(56.0),
          anchor: Anchor.center,
        );

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = Vector2.all(56.0);
  }

  @override
  void render(Canvas canvas) {
    if (opacity <= 0) return;

    final state = game.simulationState;
    final session = game.ref.read(simulationSessionProvider);
    if (state == null) return;

    final bool isMicroscopeMode = session.isMicroscopeEnabled;
    final activeTutorial = game.ref.read(activeTutorialStepProvider);
    final isTutorialTarget = activeTutorial != null && activeTutorial.targetId == type.name;
    final isHighlighted = _isPinned || _isHovered || magnifier.isVisible || isTutorialTarget;

    final baseColor = const Color(0xFF38BDF8);
    final double alphaMultiplier = isHighlighted ? 0.95 : (isMicroscopeMode ? 0.65 : 0.35);

    final paint = Paint()
      ..color = (isTutorialTarget ? Colors.orange : (isHighlighted ? Colors.white : baseColor))
          .withValues(alpha: alphaMultiplier * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isHighlighted ? 2.5 : 1.5;

    final center = Offset(size.x / 2, size.y / 2);
    canvas.drawCircle(center, 7, paint);
    
    // Crosshair or dot
    canvas.drawCircle(
      center,
      1.5,
      Paint()
        ..color = (isHighlighted ? Colors.white : baseColor)
            .withValues(alpha: (isHighlighted ? 1.0 : (isMicroscopeMode ? 0.5 : 0.3)) * opacity),
    );

    // Subtle pulsing ring when highlighted
    if (isHighlighted) {
      final pulse = (1.0 + 0.2 * math.sin(game.currentTime() * 4.0));
      canvas.drawCircle(
        center,
        10 * pulse,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.2 * opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }
  }

  /// The router checks this before claiming a tap. A target that has been
  /// faded out must not keep stealing taps from the soil underneath it.
  bool get isInteractive => opacity > 0 && isMounted;

  /// Radius used by the shared router when claiming a tap. Keep this close
  /// to the drawn ring instead of the larger touch radius: a tap 20 px away
  /// from a ring belongs to whatever is visibly drawn there (for example the
  /// plant canopy), not to the tiny target beside it.
  double get hitRadius => CanvasHitTesting.worldRadius(
        zoom: game.camera.viewfinder.zoom,
        screenRadius: 12,
        visualWorldRadius: 10,
        minWorld: 5,
        maxWorld: 22,
      );

  double distanceToWorldPoint(Vector2 worldPoint) {
    final center = absolutePositionOf(size / 2);
    return (center - worldPoint).length;
  }

  /// Hover keeps the previous, more forgiving radius; only taps use the
  /// drawn-ring radius so nearby plant/soil taps keep their owners.
  @override
  bool containsLocalPoint(Vector2 point) {
    final center = size / 2;
    final hoverRadius = CanvasHitTesting.worldRadius(
      zoom: game.camera.viewfinder.zoom,
      screenRadius: 24,
      visualWorldRadius: 10,
      minWorld: 6,
      maxWorld: 40,
    );
    return point.distanceTo(center) <= hoverRadius;
  }

  /// Opens or closes this target's microscope. Called by the shared tap
  /// router so overlapping targets can be resolved in one place.
  void activateFromTap() {
    if (!isInteractive) return;
    final wasPinned = _isPinned;
    magnifier.isVisible = !wasPinned;
    if (!wasPinned) {
      if (!game.ref.read(simulationSessionProvider).isMicroscopeEnabled) {
        game.ref.read(simulationSessionProvider.notifier).toggleMicroscope();
      }
      game.ref.read(simulationSessionProvider.notifier).selectInspector(type.name);
      _showInspectionInfo(pinned: true);
    } else {
      game.ref.read(simulationSessionProvider.notifier).selectInspector(null);
      game.ref.read(uIStateProvider.notifier).setHoverInfo(null);
    }
  }

  @override
  void onHoverEnter() {
    if (opacity <= 0) return;
    _isHovered = true;
    final current = game.ref.read(uIStateProvider);
    if (current == null || !current.isPinned) {
      _showInspectionInfo(pinned: false);
    }
  }

  @override
  void onHoverExit() {
    _isHovered = false;
    if (!_isPinned) {
      final current = game.ref.read(uIStateProvider);
      if (current == null || !current.isPinned) {
        game.ref.read(uIStateProvider.notifier).setHoverInfo(null);
      }
    }
  }

  void _showInspectionInfo({bool pinned = false}) {
    final l = game.l10n;
    final state = game.displayedState;
    final topLayer = state.profile.layers.first;

    String title = "";
    String desc = "";
    Map<String, String> stats = {};

    switch (type) {
      case MagnifierType.apicalMeristem:
        title = l.apicalMeristem;
        desc = l.meristemDesc;
        stats = {
          l.tissueLabel: l.meristematic,
          l.stateLabel: l.undifferentiated,
          l.rateLabel: l.highDivision,
        };
        break;
      case MagnifierType.leaf:
        title = l.plantCanopy.toUpperCase();
        desc = l.plantCanopyDesc;
        stats = {
          l.typeLabel: l.leaf,
          l.turgorLabel: '${(state.plant.turgorPressure * 100).toStringAsFixed(0)}%',
          l.heightLabel: '${(state.plant.height * 100).toStringAsFixed(1)} cm',
          l.laiLabel: state.plant.lai.toStringAsFixed(2),
          l.processLabel: l.transpiration,
        };
        break;
      case MagnifierType.stem:
        title = l.stemCrossSection.toUpperCase();
        desc = l.stemDesc;
        final suction = (state.plant.waterUptake * 1000).toStringAsFixed(2);
        stats = {
          l.typeLabel: l.vascularTissue,
          l.fluxLabel: '$suction µl/s',
          l.roleLabel: l.transport,
        };
        break;
      case MagnifierType.root:
        title = l.rootTissue.toUpperCase();
        desc = l.rootTissueDesc;
        stats = {
          l.typeLabel: l.root,
          l.rootNodes: state.plant.rootSystem.length.toString(),
          l.processLabel: l.uptake,
        };
        break;
      case MagnifierType.rhizosphere:
        title = l.rhizosphere.toUpperCase();
        desc = l.rhizosphereDesc;
        stats = {
          l.locationLabel: l.rhizosphereLocation,
          l.microbialBiomassLabel:
              '${topLayer.microbialBiomass.toStringAsFixed(1)} kg/m³',
          l.bioActivityLabel: topLayer.redoxPotential > 400 ? l.active : l.inhibited,
        };
        break;
      case MagnifierType.microbe:
        title = l.microbialCell.toUpperCase();
        desc = l.microbialCellDesc;
        stats = {
          l.typeLabel: l.microbialCell,
          l.co2Label: '${topLayer.co2Content.toStringAsFixed(3)} mol/m³',
          l.processLabel: l.metabolismLabel,
        };
        break;
      case MagnifierType.soilStructure:
        title = l.soilStructure.toUpperCase();
        desc = l.soilStructureTexture;
        stats = {
          l.typeLabel: l.hexMatrix,
          l.stabilityLabel(''):
              '${(topLayer.aggregateStability * 100).toStringAsFixed(0)}%',
          l.clayFractionLabel:
              '${(topLayer.clayFraction * 100).toStringAsFixed(0)}%',
        };
        break;
    }

    game.ref
        .read(uIStateProvider.notifier)
        .setHoverInfo(
          HoverInfo(
            title: title,
            description: desc,
            stats: stats,
            isPinned: pinned,
            sourceId: 'inspection-${type.name}',
            layerId: switch (type) {
              MagnifierType.leaf || MagnifierType.apicalMeristem => null,
              MagnifierType.stem ||
              MagnifierType.root ||
              MagnifierType.rhizosphere ||
              MagnifierType.microbe ||
              MagnifierType.soilStructure => topLayer.id,
            },
            isAtmosphere:
                type == MagnifierType.leaf ||
                type == MagnifierType.apicalMeristem,
            logicLabModel: switch (type) {
              MagnifierType.apicalMeristem || MagnifierType.leaf =>
                'photosynthesis',
              MagnifierType.stem || MagnifierType.soilStructure =>
                'waterRetention',
              MagnifierType.root || MagnifierType.rhizosphere => 'diffusion',
              MagnifierType.microbe => 'nitrification',
            },
            onDismiss: () {
              magnifier.isVisible = false;
              final selected = game
                  .ref
                  .read(simulationSessionProvider)
                  .selectedInspectorType;
              if (selected == type.name) {
                game
                    .ref
                    .read(simulationSessionProvider.notifier)
                    .selectInspector(null);
              }
            },
            accentColor: Colors.cyanAccent,
            screenPosition: game
                .worldToScreen(absolutePositionOf(size / 2))
                .toOffset(),
          ),
        );
  }
}
