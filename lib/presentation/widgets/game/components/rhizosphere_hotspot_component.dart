import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../../../../domain/models/soil_layer.dart';
import '../../../providers/ui_state_provider.dart';
import '../soil_scope_game.dart';

/// A dynamic visual representation of a rhizosphere hotspot.
/// Shows metabolic activity (acidification and exudation) around root tips.
class RhizosphereHotspotComponent extends PositionComponent
    with HasGameReference<SoilScopeGame>, TapCallbacks, HoverCallbacks {
  final String hotspotId;
  final String layerId;
  double intensity;
  final HotspotType type;
  bool _isPinned = false;

  RhizosphereHotspotComponent({
    required this.hotspotId,
    required this.layerId,
    required this.intensity,
    required this.type,
    required Vector2 position,
    required double radius,
  }) : super(
          position: position,
          size: Vector2.all(radius * 200), // Scale to world units
          anchor: Anchor.center,
          priority: 950, // Below plant roots, above soil base
        );

  late final CircleComponent _glow;
  late final List<CircleComponent> _particles = [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final color = _getColor();

    _glow = CircleComponent(
      radius: size.x / 2,
      anchor: Anchor.center,
      position: size / 2,
      paint: Paint()
        ..color = color.withValues(alpha: 0.15 * intensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    add(_glow);

    // Pulse effect
    _glow.add(
      OpacityEffect.to(
        0.05 * intensity,
        EffectController(duration: 2.0, reverseDuration: 2.0, infinite: true),
      ),
    );

    // Add some "metabolic particles"
    for (int i = 0; i < 5; i++) {
      final p = CircleComponent(
        radius: 2,
        anchor: Anchor.center,
        position: size / 2,
        paint: Paint()..color = color.withValues(alpha: 0.6),
      );
      add(p);
      _particles.add(p);
      
      final angle = (i / 5) * 2 * math.pi;
      final dist = (size.x / 4) * (0.5 + 0.5 * math.Random().nextDouble());
      
      p.add(
        MoveByEffect(
          Vector2(math.cos(angle) * dist, math.sin(angle) * dist),
          EffectController(
            duration: 1.0 + math.Random().nextDouble(), 
            reverseDuration: 1.0 + math.Random().nextDouble(), 
            infinite: true,
            curve: Curves.easeInOutSine,
          ),
        ),
      );
    }
  }

  void updateIntensity(double newIntensity) {
    intensity = newIntensity;
    _glow.paint.color = _getColor().withValues(alpha: 0.15 * intensity);
  }

  Color _getColor() {
    switch (type) {
      case HotspotType.rhizosphere:
        return const Color(0xFFD946EF); // Fuchsia (Acidification)
      case HotspotType.decomposition:
        return const Color(0xFFFBBF24); // Amber (Labile C)
      case HotspotType.fungalHub:
        return const Color(0xFF2DD4BF); // Teal (Mycorrhiza)
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Draw a small core
    final paint = Paint()
      ..color = _getColor().withValues(alpha: 0.4 * intensity)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), 4, paint);
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    // Generous touch & hover target (at least 35px radius)
    final center = size / 2;
    final r = math.max(size.x / 2, 35.0);
    return point.distanceTo(center) <= r;
  }

  @override
  void onTapUp(TapUpEvent event) {
    _isPinned = !_isPinned;
    _showRhizosphereInfo(pinned: _isPinned);
    event.handled = true;
  }

  @override
  void onHoverEnter() {
    _glow.paint.color = _getColor().withValues(alpha: 0.35 * intensity);
    final current = game.ref.read(uIStateProvider);
    if (current == null || !current.isPinned) {
      _showRhizosphereInfo(pinned: false);
    }
  }

  @override
  void onHoverExit() {
    _glow.paint.color = _getColor().withValues(alpha: 0.15 * intensity);
    if (!_isPinned) {
      final current = game.ref.read(uIStateProvider);
      if (current == null || !current.isPinned) {
        game.ref.read(uIStateProvider.notifier).setHoverInfo(null);
      }
    }
  }

  void _showRhizosphereInfo({bool pinned = false}) {
    final l = game.l10n;
    String title;
    String desc;
    Map<String, String> stats;

    switch (type) {
      case HotspotType.rhizosphere:
        title = l.rhizosphere.toUpperCase();
        desc = l.rhizosphereDesc;
        stats = {
          l.processLabel: l.rootExudation,
          l.dynamicsLabel: 'pH -0.5 - 1.0',
          l.activity: '${(intensity * 100).toStringAsFixed(0)}%',
        };
        break;
      case HotspotType.decomposition:
        title = l.organicHorizon.toUpperCase();
        desc = l.decompositionDesc;
        stats = {
          l.processLabel: l.mineralization,
          l.activity: '${(intensity * 100).toStringAsFixed(0)}%',
        };
        break;
      case HotspotType.fungalHub:
        title = "MYCORRHIZAL HUB";
        desc = "Dense hyphal contact zone facilitating nutrient exchange with root cells.";
        stats = {
          "Symbiont": "Glomeromycota",
          "Exchange": "C ↔ P",
          l.activity: '${(intensity * 100).toStringAsFixed(0)}%',
        };
        break;
    }

    game.ref.read(uIStateProvider.notifier).setHoverInfo(
      HoverInfo(
        title: title,
        description: desc,
        stats: stats,
        isPinned: pinned,
        accentColor: _getColor(),
        screenPosition: game.worldToScreen(absolutePosition).toOffset(),
      ),
    );
  }

  void triggerPulse() {
    _glow.add(
      SequenceEffect([
        ScaleEffect.by(Vector2.all(1.4), EffectController(duration: 0.1, reverseDuration: 0.1)),
        OpacityEffect.to(0.5, EffectController(duration: 0.1, reverseDuration: 0.2)),
      ]),
    );
  }
}
