import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide PointerMoveEvent;
import '../soil_scope_game.dart';
import '../../../../domain/models/biophysical_state.dart';
import '../../../providers/ui_state_provider.dart';
import '../../../providers/simulation_provider.dart';
import 'molecule_particle_component.dart';

/// Gas types representing different biogeochemical processes
enum BubbleType {
  /// CO₂ from aerobic respiration (healthy soil sign)
  co2,

  /// N₂O from denitrification (anaerobic, climate concern)
  n2o,

  /// CH₄ from methanogenesis (highly anaerobic)
  ch4,

  /// O₂ diffusing into soil (oxygen input)
  o2,
}

/// Interactive gas bubble component representing soil respiration and gas emissions.
/// Tap to pin detailed information about the biogeochemical process.
class BubbleComponent extends CircleComponent
    with HasGameReference<SoilScopeGame>, TapCallbacks, HoverCallbacks {
  final BubbleType type;
  final int seed;
  final double speed;
  bool _isPinned = false;

  BubbleComponent({
    required this.type,
    required this.seed,
    required this.speed,
    required Vector2 position,
  }) : super(
         position: position,
         radius: _getRadiusForType(type),
         anchor: Anchor.center,
         paint: Paint()..color = _getColorForType(type).withValues(alpha: 0.5),
       );

  static double _getRadiusForType(BubbleType type) {
    switch (type) {
      case BubbleType.co2:
        return 2.5;
      case BubbleType.n2o:
        return 3.0;
      case BubbleType.ch4:
        return 3.5; // Larger for visibility
      case BubbleType.o2:
        return 2.0; // Smaller, moving down
    }
  }

  static Color _getColorForType(BubbleType type) {
    switch (type) {
      case BubbleType.co2:
        return Colors.white70;
      case BubbleType.n2o:
        return Colors.deepPurpleAccent;
      case BubbleType.ch4:
        return Colors.orange;
      case BubbleType.o2:
        return Colors.cyanAccent;
    }
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    // Increase hit area for easier tapping
    final center = size / 2;
    return (point - center).length < 20.0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!(game.simulationState?.isRunning ?? false)) return;
    final time = game.currentTime();

    // O₂ moves DOWN (diffusion into soil), others rise UP
    if (type == BubbleType.o2) {
      position.y += speed * dt;
      // Remove if past the soil column bottom
      if (position.y > game.soilSurfaceY + game.soilColumnHeight) {
        removeFromParent();
      }
    } else {
      // Rise upwards
      position.y -= speed * dt;
      // Remove if above the soil surface and release atmospheric particles
      if (position.y < game.soilSurfaceY) {
        _releaseGas();
        removeFromParent();
      }
    }

    // Enhanced Wobble: sine wave drift simulates fluid dynamics in soil pores
    position.x += math.sin(time * 3.5 + seed) * 0.3;
    
    // Subtle size pulse representing gas expansion
    final double pulse = 0.95 + 0.1 * math.sin(time * 5.0 + seed);
    radius = _getRadiusForType(type) * pulse;
  }

  @override
  void render(Canvas canvas) {
    final alphaScale = paint.color.a;
    final center = Offset.zero;
    
    // 1. Shadow for depth
    canvas.drawCircle(
      center + const Offset(0.8, 0.8),
      radius,
      Paint()..color = Colors.black.withValues(alpha: 0.1 * alphaScale),
    );

    // 2. Main Bubble Body
    final bodyPaint = Paint()..color = paint.color;
    canvas.drawCircle(center, radius, bodyPaint);
    
    // Contrast halo
    canvas.drawCircle(
      center, 
      radius * 1.1, 
      Paint()..color = Colors.white.withValues(alpha: 0.15 * alphaScale)..style = PaintingStyle.stroke..strokeWidth = 0.5
    );

    // 3. Shading Highlight (Gas bubble shine)
    canvas.drawCircle(
      center - Offset(radius * 0.3, radius * 0.3),
      radius * 0.4,
      Paint()..color = Colors.white.withValues(alpha: 0.5 * alphaScale),
    );

    // Selection highlight when pinned
    if (_isPinned) {
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawCircle(center, radius + 2, highlightPaint);
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    _isPinned = true;
    _showBubbleInfo(pinned: true);
    event.handled = true;
  }

  @override
  void onHoverEnter() {
    final currentInfo = game.ref.read(uIStateProvider);
    if (currentInfo == null || !currentInfo.isPinned) {
      _showBubbleInfo(pinned: false);
    }
  }

  @override
  void onHoverExit() {
    if (!_isPinned) {
      final currentInfo = game.ref.read(uIStateProvider);
      if (currentInfo == null || !currentInfo.isPinned) {
        game.ref.read(uIStateProvider.notifier).setHoverInfo(null);
      }
    }
  }

  void _releaseGas() {
    final MoleculeType mType;
    switch (type) {
      case BubbleType.co2: mType = MoleculeType.co2; break;
      case BubbleType.n2o: mType = MoleculeType.nitrousOxide; break;
      case BubbleType.ch4: mType = MoleculeType.methane; break;
      case BubbleType.o2: mType = MoleculeType.oxygen; break;
    }
    
    // Spawn a small cluster of molecules drifting up
    for (int i = 0; i < 4; i++) {
      game.moleculePool?.spawn(
        position: position.clone(),
        type: mType,
        velocity: Vector2((math.Random().nextDouble() - 0.5) * 40, -60 - math.Random().nextDouble() * 60),
        lifeTime: 8.0,
        opacity: 0.8,
        isInteractionEnabled: false,
      );
    }
  }

  void _showBubbleInfo({bool pinned = false}) {
    final state = game.ref.read(simulationProvider);
    final info = _getGasInfo(state);

    game.ref
        .read(uIStateProvider.notifier)
        .setHoverInfo(
          HoverInfo(
            title: info['title'] as String,
            description: info['description'] as String,
            stats: info['stats'] as Map<String, String>,
            isPinned: pinned,
            legends: info['legends'] as List<LegendItem>?,
          ),
        );
  }

  Map<String, dynamic> _getGasInfo(BiophysicalState state) {
    final l = game.l10n;
    switch (type) {
      case BubbleType.co2:
        return {
          'title': 'CO₂ ${l.soilRespiration.toUpperCase()}',
          'description': l.bubbleCo2Description,
          'stats': {
            l.gasLabel: 'CO₂',
            l.process: l.aerobicRespiration,
            l.source: l.heterotrophicMicrobes,
            l.stateLabel: l.aerobicStatus,
            l.climateEffect: 'GWP=1',
          },
        };
      case BubbleType.n2o:
        return {
          'title': 'N₂O ${l.denitrifiers.toUpperCase()}',
          'description': l.bubbleN2oDescription,
          'stats': {
            l.gasLabel: 'N₂O',
            l.process: l.denitrifiers,
            l.source: l.anaerobicDenitrification,
            l.stateLabel: l.anaerobicState,
            l.climateEffect: 'GWP=298',
            l.nitrogenLoss: l.nitrogenAtmosphereLoss,
          },
        };
      case BubbleType.ch4:
        return {
          'title': 'CH₄ ${l.methaneDescription.split(' ').first.toUpperCase()}',
          'description': l.methaneDescription,
          'stats': {
            l.gasLabel: 'CH₄',
            l.process: 'Methanogenesis',
            l.stateLabel: l.anoxic,
            l.climateEffect: 'GWP=28',
          },
        };
      case BubbleType.o2:
        return {
          'title': 'O₂ ${l.diffusionTitle.toUpperCase()}',
          'description': l.oxygenDiffusionDesc,
          'stats': {
            l.gasLabel: 'O₂',
            l.process: l.diffusionTitle,
            l.source: l.atmosphere,
            l.stateLabel: l.aerobicState,
          },
        };
    }
  }
}
