import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide PointerMoveEvent;
import '../soil_scope_game.dart';
import 'data_hotspot_component.dart';
import '../../../../core/cpk_standards.dart';

/// A consolidated, expandable hotspot node that anchors multiple soil metrics.
/// Initial state is a neutral indicator. Tapping expands it to reveal specific metrics.
class ExpandableHotspotNode extends PositionComponent
    with HasGameReference<SoilScopeGame>, TapCallbacks {
  final String layerId;
  final List<String> metrics;
  
  bool _isExpanded = false;
  final List<DataHotspotComponent> _childHotspots = [];
  
  late final CircleComponent _baseIndicator;

  ExpandableHotspotNode({
    required this.layerId,
    required this.metrics,
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2.all(60),
          anchor: Anchor.center,
          priority: 1001,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Neutral base indicator
    _baseIndicator = CircleComponent(
      radius: 10,
      anchor: Anchor.center,
      position: size / 2,
      paint: Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
    );
    add(_baseIndicator);
    
    // Pulse effect for the base
    _baseIndicator.add(
      OpacityEffect.to(
        0.3,
        EffectController(duration: 1.5, reverseDuration: 1.5, infinite: true),
      ),
    );
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    if (_isExpanded) {
      // Reduced hit area for better selectability of neighboring nodes
      return (point - size / 2).length < 75.0;
    }
    return super.containsLocalPoint(point);
  }

  @override
  void onTapUp(TapUpEvent event) {
    _toggleExpansion();
    event.handled = true;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Draw a visual indicator in the center of the hotspot
    // This represents the "core" or main function of the node.
    final center = Offset(size.x / 2, size.y / 2);
    final coreRadius = 6.0;
    
    // 1. Core color based on the first metric (usually indicative of function)
    final coreColor = _getMetricColor(metrics.isNotEmpty ? metrics.first : 'C');
    
    // 2. Glow effect
    canvas.drawCircle(
      center,
      coreRadius * 1.5,
      Paint()
        ..color = coreColor.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0),
    );
    
    // 3. Solid core
    canvas.drawCircle(
      center,
      coreRadius,
      Paint()
        ..color = coreColor.withValues(alpha: 0.9)
        ..style = PaintingStyle.fill,
    );
    
    // 4. Contrast Ring
    canvas.drawCircle(
      center,
      coreRadius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
    
    // 5. Subtle inner highlight
    canvas.drawCircle(
      center - const Offset(1.5, 1.5),
      coreRadius * 0.4,
      Paint()..color = Colors.white.withValues(alpha: 0.5),
    );
  }

  void _toggleExpansion() {
    _isExpanded = !_isExpanded;
    
    // Boost priority when expanded to sit above neighboring unexpanded hotspots
    priority = _isExpanded ? 1100 : 1001;
    
    if (_isExpanded) {
      _expand();
    } else {
      _collapse();
    }
  }

  void _expand() {
    _baseIndicator.paint.color = Colors.white.withValues(alpha: 0.95);
    
    final double radius = 60.0;
    final double angleStep = (2 * math.pi) / metrics.length;

    for (int i = 0; i < metrics.length; i++) {
      final label = metrics[i];
      final angle = i * angleStep - math.pi / 2;
      final targetPos = (size / 2) + Vector2(math.cos(angle) * radius, math.sin(angle) * radius);
      
      final hotspot = DataHotspotComponent(
        layerId: layerId,
        label: label,
        color: _getMetricColor(label),
        type: _getHotspotType(label),
        position: size / 2, // Start from center
      );
      
      add(hotspot);
      _childHotspots.add(hotspot);
      
      // Animate out
      hotspot.add(
        MoveToEffect(
          targetPos,
          EffectController(duration: 0.4, curve: Curves.easeOutBack),
        ),
      );
      
      hotspot.add(
        OpacityEffect.fadeIn(
          EffectController(duration: 0.3),
        ),
      );
    }
  }

  void _collapse() {
    _baseIndicator.paint.color = Colors.white.withValues(alpha: 0.2);
    
    for (final hotspot in _childHotspots) {
      hotspot.add(
        MoveToEffect(
          size / 2,
          EffectController(duration: 0.3, curve: Curves.easeInBack),
        ),
      );
      hotspot.add(
        OpacityEffect.fadeOut(
          EffectController(duration: 0.25),
          onComplete: () => hotspot.removeFromParent(),
        ),
      );
    }
    _childHotspots.clear();
  }

  Color _getMetricColor(String label) {
    if (['pH', 'W', 'T', 'O2'].contains(label)) {
      switch (label) {
        case 'pH': return Colors.pinkAccent;
        case 'W': return Colors.blueAccent;
        case 'T': return Colors.orange;
        case 'O2': return Colors.cyanAccent;
        default: return Colors.grey;
      }
    }
    if (label == 'CEC') return Colors.amber;
    return CPKStandards.getColor(label);
  }

  HotspotType _getHotspotType(String label) {
    // Treat all quantitative soil metrics as "sensors" to use the high-fidelity circular meter
    if (['pH', 'W', 'T', 'O2', 'CEC', 'NO3-', 'NH4+', 'NO₃⁻', 'NH₄⁺', 'P', 'K', 'SOM', 'MAOM-N'].contains(label)) {
      return HotspotType.sensor;
    }
    return HotspotType.nutrient;
  }
}
