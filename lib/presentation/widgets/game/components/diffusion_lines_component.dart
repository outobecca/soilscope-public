import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide PointerMoveEvent;
import '../soil_scope_game.dart';
import '../../../providers/simulation_provider.dart';
import '../../../providers/simulation_session_provider.dart';
import '../../../providers/ui_state_provider.dart';
import '../../../../core/cpk_standards.dart';

class _DiffusionLine {
  final Vector2 start;
  final Vector2 end;
  final Color color;
  final double lifeTime = 5.0;
  double _elapsed = 0;

  _DiffusionLine({required this.start, required this.end, required this.color});

  bool update(double dt) {
    _elapsed += dt;
    return _elapsed < lifeTime;
  }

  void render(Canvas canvas, double zoom) {
    final double opacity = (1.0 - _elapsed / lifeTime).clamp(0.0, 1.0);
    final paint = Paint()
      ..color = color.withValues(alpha: 0.25 * opacity)
      ..strokeWidth = 1.0 / zoom
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double distance = start.distanceTo(end);
    if (distance < 5) return;

    final path = Path();
    path.moveTo(start.x, start.y);

    final mid = (start + end) / 2;
    final driftX = math.sin(_elapsed * 1.5 + start.x) * 15.0;
    final driftY = math.cos(_elapsed * 1.2 + start.y) * 10.0;

    path.quadraticBezierTo(mid.x + driftX, mid.y + driftY, end.x, end.y);

    final dashWidth = 5.0 / zoom;
    final dashSpace = 5.0 / zoom;

    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double currentDist = (_elapsed * 25.0) % (dashWidth + dashSpace);
      currentDist -= (dashWidth + dashSpace);

      while (currentDist < metric.length) {
        if (currentDist > 0) {
          final extract = metric.extractPath(
            currentDist,
            (currentDist + dashWidth).clamp(0.0, metric.length),
          );
          canvas.drawPath(extract, paint);
        }
        currentDist += dashWidth + dashSpace;
      }
    }

    final endOpacity = 0.4 * opacity;
    final pos = end.toOffset();
    final radius = 2.5 / zoom;
    
    // Shadow
    canvas.drawCircle(pos + const Offset(1, 1), radius, Paint()..color = Colors.black.withValues(alpha: 0.1 * opacity));
    // Body
    canvas.drawCircle(
      pos,
      radius,
      Paint()..color = color.withValues(alpha: endOpacity),
    );
    // Highlight
    canvas.drawCircle(
      pos - Offset(radius * 0.3, radius * 0.3),
      radius * 0.4,
      Paint()..color = Colors.white.withValues(alpha: 0.5 * opacity),
    );
  }
}

class DiffusionLinesComponent extends Component
    with HasGameReference<SoilScopeGame>, TapCallbacks, HoverCallbacks {
  final List<_DiffusionLine> _lines = [];
  final math.Random _rand = math.Random();
  bool _isPinned = false;

  DiffusionLinesComponent() : super(priority: 5);

  @override
  void update(double dt) {
    super.update(dt);
    final sim = game.simulationState;
    if (sim == null || !sim.isRunning) return;

    final flowMode = game.ref.read(particleFlowModeProvider);
    final boost = flowMode ? 2.5 : 1.0;

    final state = game.ref.read(simulationProvider);
    if (state.profile.layers.isEmpty) return;

    if (_lines.length < 15 && _rand.nextDouble() < 0.05 * boost) {
      final layerIndex = _rand.nextInt(state.profile.layers.length);
      final layer = state.profile.layers[layerIndex];
      final soilHeight = game.soilColumnHeight;
      final surfaceY = game.soilSurfaceY;
      final worldWidth = game.size.x;

      final startY =
          surfaceY + (layer.depth / game.activeProfileThickness) * soilHeight;
      final endY =
          startY + (layer.thickness / game.activeProfileThickness) * soilHeight;

      final start = Vector2(
        _rand.nextDouble() * worldWidth,
        startY + _rand.nextDouble() * (endY - startY),
      );
      final end =
          start +
          Vector2(
            (_rand.nextDouble() - 0.5) * 100,
            (_rand.nextDouble() - 0.5) * 50,
          );

      _lines.add(
        _DiffusionLine(
          start: start,
          end: end,
          color: _getNutrientColor(game.ref.read(simulationSessionProvider).selectedElementSymbol),
        ),
      );
    }

    _lines.removeWhere((line) => !line.update(dt * boost));
  }

  Color _getNutrientColor(String? symbol) {
    if (symbol == null) return Colors.white;
    return CPKStandards.getColor(symbol);
  }

  @override
  void render(Canvas canvas) {
    final double zoom = game.camera.viewfinder.zoom;
    for (final line in _lines) {
      line.render(canvas, zoom);
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    _isPinned = !_isPinned;
    _showDiffusionInfo(pinned: _isPinned);
    event.handled = true;
  }

  @override
  void onHoverEnter() {
    final current = game.ref.read(uIStateProvider);
    if (current == null || !current.isPinned) _showDiffusionInfo(pinned: false);
  }

  @override
  void onHoverExit() {
    if (!_isPinned) {
      game.ref.read(uIStateProvider.notifier).setHoverInfo(null);
    }
  }

  void _showDiffusionInfo({bool pinned = false}) {
    final l = game.l10n;
    game.ref
        .read(uIStateProvider.notifier)
        .setHoverInfo(
          HoverInfo(
            title: l.diffusionTitle.toUpperCase(),
            description: l.moleculeNitrateDesc,
            stats: {
              l.type: l.molecularDiffusion,
              l.forceLabel: l.concentrationDifference,
              l.speedLabel: l.slow,
            },
            isPinned: pinned,
          ),
        );
  }
}
