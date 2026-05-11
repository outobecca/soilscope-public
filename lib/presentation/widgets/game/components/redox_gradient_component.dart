import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide PointerMoveEvent;
import '../soil_scope_game.dart';
import '../../../providers/simulation_provider.dart';
import '../../../providers/ui_state_provider.dart';
import 'soil_component_mixin.dart';

/// Renders a dynamic color gradient representing soil redox potential (Eh).
/// Visualizes the "breathing state" from aerobic (blue/green) to anaerobic (gray/black).
class RedoxGradientComponent extends Component
    with
        HasGameReference<SoilScopeGame>,
        TapCallbacks,
        HoverCallbacks,
        SoilComponentMixin {
  RedoxGradientComponent() : super(priority: 2);


  final _paint = Paint();

  @override
  void render(Canvas canvas) {
    final state = game.ref.read(simulationProvider);
    if (state.profile.layers.isEmpty) return;

    final double scaleY = calculateVerticalScale(
      state.profile.layers.fold(0.0, (sum, l) => sum + l.thickness),
    );

    double currentY = surfaceY;
    for (final layer in state.profile.layers) {
      final layerHeight = layer.thickness * scaleY;

      // Eh mapping to colors: 600mV (aerobic) -> -200mV (anaerobic)
      final Color ehColor = _getColorForEh(layer.redoxPotential);

      _paint.shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ehColor.withValues(alpha: 0.15),
              ehColor.withValues(alpha: 0.08),
            ],
          ).createShader(
            Rect.fromLTWH(backgroundX, currentY, backgroundWidth, layerHeight),
          );

      drawFullWidthSoilRect(
        canvas,
        Rect.fromLTWH(0, currentY, 0, layerHeight),
        _paint,
      );
      currentY += layerHeight;
    }
  }

  Color _getColorForEh(double eh) {
    if (eh > 400) return const Color(0xFF0EA5E9); // Aerobic
    if (eh > 200) return const Color(0xFF64748B); // Slightly reduced
    if (eh > 0) return const Color(0xFF475569); // Reduced
    return const Color(0xFF1E293B); // Anoxic / Black
  }

  @override
  bool containsLocalPoint(Vector2 point) => isInsideSimulation(point);

  @override
  void onTapUp(TapUpEvent event) {
    _showRedoxInfo(pinned: true);
    event.handled = true;
  }

  @override
  void onHoverEnter() {
    _showRedoxInfo(pinned: false);
  }

  @override
  void onHoverExit() {
    game.ref.read(uIStateProvider.notifier).setHoverInfo(null);
  }

  void _showRedoxInfo({bool pinned = false}) {
    final l = game.l10n;
    game.ref
        .read(uIStateProvider.notifier)
        .setHoverInfo(
          HoverInfo(
            title: l.redoxPotentialTitle.toUpperCase(),
            description: l.redoxLadderDesc,
            stats: {
              "Scale": "600 to -200 mV",
              "Significance": "O₂ Availability",
            },
            isPinned: pinned,
          ),
        );
  }
}
