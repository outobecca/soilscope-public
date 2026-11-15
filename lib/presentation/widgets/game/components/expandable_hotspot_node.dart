import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:material_ui/material_ui.dart' hide PointerMoveEvent;
import '../soil_scope_game.dart';
import 'data_hotspot_component.dart';
import 'canvas_hit_testing.dart';
import '../../../../core/cpk_standards.dart';

/// A consolidated, expandable hotspot node that anchors multiple soil metrics.
/// Initial state is a neutral indicator. Tapping expands it to reveal specific metrics.
class ExpandableHotspotNode extends PositionComponent
    with HasGameReference<SoilScopeGame>, TapCallbacks {
  final String layerId;
  final List<String> metrics;

  /// Position inside the owning layer, normalised to 0..1. The layer's world
  /// rect can change when the scenario or viewport changes; keeping the
  /// anchor relative lets the node follow its layer instead of staying where
  /// it was spawned and opening another layer's data.
  final Vector2 layerAnchor;

  bool _isExpanded = false;
  final List<DataHotspotComponent> _childHotspots = [];

  late final CircleComponent _baseIndicator;

  ExpandableHotspotNode({
    required this.layerId,
    required this.metrics,
    required Vector2 position,
    Vector2? layerAnchor,
  }) : layerAnchor = layerAnchor ?? Vector2(0.5, 0.5),
       super(
         position: position,
         size: Vector2.all(80), // Increased container size for touch ergonomics
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
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isExpanded) return;

    // Drive the breathing highlight from the visual clock instead of an
    // infinite Flame effect. The effect kept pulsing while the simulation was
    // paused; a clock-based alpha is fixed whenever visual time is frozen.
    final time = game.currentTime();
    final alpha = 0.575 + 0.275 * math.cos(time * 2 * math.pi / 3);
    _baseIndicator.paint.color = Colors.white.withValues(alpha: alpha);
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    final center = size / 2;
    if (_isExpanded) {
      // Expanded state: capture taps within the cluster radius.
      return (point - center).length <= 85.0;
    }
    // Collapsed state: keep the target stable on screen instead of letting
    // the world-space radius balloon at high zoom.
    final hitRadius = CanvasHitTesting.worldRadius(
      zoom: game.camera.viewfinder.zoom,
      screenRadius: 26,
      visualWorldRadius: 12,
      minWorld: 10,
      maxWorld: 36,
    );
    return (point - center).length <= hitRadius;
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
    final immediate = game.isInspectionPaused;

    final double radius = 60.0;
    final double angleStep = (2 * math.pi) / metrics.length;

    for (int i = 0; i < metrics.length; i++) {
      final label = metrics[i];
      final angle = i * angleStep - math.pi / 2;
      final targetPos =
          (size / 2) +
          Vector2(math.cos(angle) * radius, math.sin(angle) * radius);

      final hotspot = DataHotspotComponent(
        layerId: layerId,
        label: label,
        color: _getMetricColor(label),
        type: _getHotspotType(label),
        // A paused canvas cannot run the opening animation, so place the
        // metric directly at its final position and make it visible/tappable.
        position: immediate ? targetPos : size / 2,
      );
      if (immediate) hotspot.opacity = 1.0;

      add(hotspot);
      _childHotspots.add(hotspot);

      if (!immediate) {
        // Animate out only while the visual clock is running.
        hotspot.add(
          MoveToEffect(
            targetPos,
            EffectController(duration: 0.4, curve: Curves.easeOutBack),
          ),
        );

        hotspot.add(OpacityEffect.fadeIn(EffectController(duration: 0.3)));
      }
    }
  }

  void _collapse() {
    _baseIndicator.paint.color = Colors.white.withValues(alpha: 0.2);
    if (game.isInspectionPaused) {
      // Removal effects cannot complete while time is frozen. Drop the metric
      // hotspots immediately so a collapsed cluster really is collapsed.
      for (final hotspot in _childHotspots) {
        hotspot.removeFromParent();
      }
      _childHotspots.clear();
      return;
    }

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
        case 'pH':
          return Colors.pinkAccent;
        case 'W':
          return Colors.blueAccent;
        case 'T':
          return Colors.orange;
        case 'O2':
          return Colors.cyanAccent;
        default:
          return Colors.grey;
      }
    }
    if (label == 'CEC') return Colors.amber;
    return CPKStandards.getColor(label);
  }

  HotspotType _getHotspotType(String label) {
    // Treat all quantitative soil metrics as "sensors" to use the high-fidelity circular meter
    if ([
      'pH',
      'W',
      'T',
      'O2',
      'CEC',
      'NO3-',
      'NH4+',
      'NO₃⁻',
      'NH₄⁺',
      'P',
      'K',
      'SOM',
      'MAOM-N',
    ].contains(label)) {
      return HotspotType.sensor;
    }
    return HotspotType.nutrient;
  }
}
