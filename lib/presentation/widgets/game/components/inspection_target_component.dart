import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide PointerMoveEvent;
import '../soil_scope_game.dart';
import '../../../providers/simulation_provider.dart';
import '../../../providers/simulation_session_provider.dart';
import '../../../providers/ui_state_provider.dart';
import 'process_magnifier_component.dart';


class InspectionTargetComponent extends PositionComponent
    with HasGameReference<SoilScopeGame>, TapCallbacks {
  final MagnifierType type;
  final ProcessMagnifierComponent magnifier;
  double opacity = 1.0;
  bool _isPinned = false;

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
    final isHighlighted = _isPinned || magnifier.isVisible || isTutorialTarget;

    // Only render if microscope is on or it's been clicked or tutorial target
    if (!isMicroscopeMode && !isHighlighted) return;

    final baseColor = const Color(0xFF38BDF8);
    final paint = Paint()
      ..color = (isTutorialTarget ? Colors.orange : (isHighlighted ? Colors.white : baseColor))
          .withValues(alpha: (isHighlighted ? 0.9 : 0.6) * opacity)
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
            .withValues(alpha: (isHighlighted ? 1.0 : 0.4) * opacity),
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



  @override
  void onTapUp(TapUpEvent event) {
    if (opacity <= 0) return;
    _isPinned = !_isPinned;
    magnifier.isVisible = _isPinned;
    if (_isPinned) {
      _showInspectionInfo(pinned: true);
    } else {
      game.ref.read(uIStateProvider.notifier).setHoverInfo(null);
    }
    event.handled = true;
  }

  void _showInspectionInfo({bool pinned = false}) {
    final l = game.l10n;
    final state = game.ref.read(simulationProvider);
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
            accentColor: Colors.cyanAccent,
            screenPosition: game.worldToScreen(absolutePosition).toOffset(),
          ),
        );
  }
}
