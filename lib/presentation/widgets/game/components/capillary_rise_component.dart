import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:material_ui/material_ui.dart' hide PointerMoveEvent;
import '../soil_scope_game.dart';
import '../../../providers/ui_state_provider.dart';
import 'canvas_hit_testing.dart';
import 'cycle_highlight_mixin.dart';

/// Visualizes upward water movement via capillary forces from groundwater.
/// Represents hydraulic connectivity from the deep soil/groundwater table.
///
/// Pedagogy: Shows water moving AGAINST gravity due to matric potential.
class CapillaryRiseComponent extends Component
    with
        HasGameReference<SoilScopeGame>,
        TapCallbacks,
        HoverCallbacks,
        CycleHighlightMixin {
  @override
  Set<ObservationCycle> get memberOfCycles => {ObservationCycle.water};
  CapillaryRiseComponent() : super(priority: 11);

  bool _isPinned = false;
  bool _isHovered = false;

  static const int _fingerCount = 10;

  /// The animated fingers at [time].
  ///
  /// Rendering and picking share this geometry. The previous hit test accepted
  /// any point within 22 px of a finger's start column, at every depth, so
  /// shallow taps meant for roots, hotspots or the soil layer were claimed by
  /// capillary rise. Only the visible advancing droplet is a target now.
  List<_CapillaryFinger> _fingers(double time) {
    final surfaceY = game.soilSurfaceY;
    final soilHeight = game.soilColumnHeight;
    final soilX = game.soilLeftX;
    final soilWidth = SoilScopeGame.soilColumnWidth;

    final fingers = <_CapillaryFinger>[];
    for (int i = 0; i < _fingerCount; i++) {
      final startX = soilX + 40 + i * (soilWidth / 11) + math.sin(i * 123) * 15;
      final phase = (time * 0.25 + i * 0.35) % 1.0;
      final startY = surfaceY + soilHeight;
      final maxRiseHeight =
          soilHeight * 0.7 * (0.4 + 0.6 * math.cos(i * 0.8).abs());

      double currentX = startX;
      double currentY = startY;
      for (double step = 0; step < phase; step += 0.04) {
        currentY = startY - step * maxRiseHeight;
        currentX = startX + math.sin(step * 20 + time * 1.5 + i) * 10;
      }

      fingers.add(
        _CapillaryFinger(
          index: i,
          startX: startX,
          startY: startY,
          maxRiseHeight: maxRiseHeight,
          phase: phase,
          tip: Vector2(currentX, currentY),
        ),
      );
    }
    return fingers;
  }

  /// World-space centres of the droplets that are currently visible.
  ///
  /// Public so the hit-test regression can pick a point away from every
  /// meniscus; the renderer and [containsLocalPoint] use the same samples.
  List<Vector2> meniscusPointsAt(double time) => [
    for (final finger in _fingers(time))
      if (finger.phase > 0.02) finger.tip,
  ];

  @override
  void render(Canvas canvas) {
    final state = game.displayedState;
    final double zoom = game.camera.viewfinder.zoom;
    final double time = game.currentTime();

    if (state.profile.layers.isEmpty) return;

    // Only visible when surface is relatively dry (capillary forces dominate over gravity)
    final topLayer = state.profile.layers.first;
    if (topLayer.waterContent > 0.3) return;

    final currentOpacity = cycleOpacity;
    final isHighlighted = _isPinned || _isHovered;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = (isHighlighted ? 3.2 : 2.2) / zoom
      ..strokeCap = StrokeCap.round;

    // Render rising capillary "fingers" from the bottom groundwater upwards
    for (final finger in _fingers(time)) {
      final phase = finger.phase;

      final path = Path()..moveTo(finger.startX, finger.startY);

      double currentX = finger.startX;
      double currentY = finger.startY;

      for (double step = 0; step < phase; step += 0.04) {
        currentY = finger.startY - step * finger.maxRiseHeight;

        // Organic wandering through hypothetical pore network
        final drift = math.sin(step * 20 + time * 1.5 + finger.index) * 10;
        currentX = finger.startX + drift;

        path.lineTo(currentX, currentY);
      }

      // Draw the path with fading opacity as it moves higher (evaporation/adsorption)
      canvas.drawPath(
        path,
        paint
          ..color = const Color(
            0xFF38BDF8,
          ).withValues(alpha: (1.0 - phase) * 0.35 * currentOpacity),
      );

      // Meniscus/Droplet at the advancing tip
      if (phase > 0.02) {
        final pos = finger.tip.toOffset();
        final radius = 2.8 / zoom;

        // Shadow
        canvas.drawCircle(
          pos + const Offset(1, 1),
          radius,
          Paint()
            ..color = Colors.black.withValues(
              alpha: 0.1 * (1.0 - phase) * currentOpacity,
            ),
        );
        // Body
        canvas.drawCircle(
          pos,
          radius,
          Paint()
            ..color = const Color(
              0xFF7DD3FC,
            ).withValues(alpha: (1.0 - phase) * 0.7 * currentOpacity),
        );
        // Highlight
        canvas.drawCircle(
          pos - Offset(radius * 0.3, radius * 0.3),
          radius * 0.4,
          Paint()
            ..color = Colors.white.withValues(
              alpha: 0.5 * (1.0 - phase) * currentOpacity,
            ),
        );
      }
    }
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    // Match the drawn scene: the animation is hidden when the surface is wet.
    final state = game.displayedState;
    if (state.profile.layers.isEmpty) return false;
    if (state.profile.layers.first.waterContent > 0.3) return false;

    final tips = meniscusPointsAt(game.currentTime());
    if (tips.isEmpty) return false;

    final hitRadius = CanvasHitTesting.worldRadius(
      zoom: game.camera.viewfinder.zoom,
      screenRadius: 12,
      visualWorldRadius: 3,
      minWorld: 3,
      maxWorld: 15,
    );

    for (final tip in tips) {
      if (point.distanceTo(tip) <= hitRadius) return true;
    }
    return false;
  }

  /// The droplet closest to [point], used to anchor the card on the element
  /// the user actually tapped instead of a fixed point in the column.
  Vector2? _nearestMeniscus(Vector2 point) {
    Vector2? nearest;
    var nearestDistanceSq = double.infinity;
    for (final tip in meniscusPointsAt(game.currentTime())) {
      final distanceSq = tip.distanceToSquared(point);
      if (distanceSq < nearestDistanceSq) {
        nearestDistanceSq = distanceSq;
        nearest = tip;
      }
    }
    return nearest;
  }

  @override
  void onTapUp(TapUpEvent event) {
    _isPinned = !_isPinned;
    _showInfo(
      pinned: _isPinned,
      anchorWorld: _nearestMeniscus(event.localPosition),
    );
    event.handled = true;
  }

  @override
  void onHoverEnter() {
    _isHovered = true;
    final current = game.ref.read(uIStateProvider);
    if (current == null || !current.isPinned) _showInfo(pinned: false);
  }

  @override
  void onHoverExit() {
    _isHovered = false;
    if (!_isPinned) {
      game.ref.read(uIStateProvider.notifier).clearUnpinnedHover();
    }
  }

  void _showInfo({bool pinned = false, Vector2? anchorWorld}) {
    final l = game.l10n;
    final soilX = game.soilLeftX;
    final soilWidth = SoilScopeGame.soilColumnWidth;
    final surfaceY = game.soilSurfaceY;
    final soilHeight = game.soilColumnHeight;
    final anchor =
        anchorWorld ??
        Vector2(soilX + soilWidth / 2, surfaceY + soilHeight * 0.7);

    game.ref
        .read(uIStateProvider.notifier)
        .setHoverInfo(
          HoverInfo(
            title: l.capillaryRiseTitle.toUpperCase(),
            description: l.capillaryRiseDesc,
            stats: {
              l.processLabel: l.hydraulicLift,
              l.driverLabel: l.matricPotential,
              l.sourceLabel: l.groundwaterLabel,
            },
            isPinned: pinned,
            sourceId: 'capillary-rise',
            onDismiss: () => _isPinned = false,
            accentColor: const Color(0xFF38BDF8),
            screenPosition: game.worldToScreen(anchor).toOffset(),
          ),
        );
  }
}

class _CapillaryFinger {
  const _CapillaryFinger({
    required this.index,
    required this.startX,
    required this.startY,
    required this.maxRiseHeight,
    required this.phase,
    required this.tip,
  });

  final int index;
  final double startX;
  final double startY;
  final double maxRiseHeight;
  final double phase;
  final Vector2 tip;
}
