import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import '../../../../domain/models/soil_layer.dart';
import '../soil_scope_game.dart';

/// A dynamic visual representation of a rhizosphere hotspot.
/// Shows metabolic activity (acidification and exudation) around root tips.
class RhizosphereHotspotComponent extends PositionComponent with HasGameReference<SoilScopeGame> {
  final String hotspotId;
  final String layerId;
  double intensity;
  final HotspotType type;

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
}
