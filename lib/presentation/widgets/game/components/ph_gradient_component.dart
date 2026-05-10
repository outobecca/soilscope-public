import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide PointerMoveEvent;
import '../soil_scope_game.dart';
import '../../../providers/simulation_provider.dart';
import '../../../providers/ui_state_provider.dart';
import 'soil_component_mixin.dart';

/// Renders a color gradient representing soil pH levels.
/// Visualizes acidity (red/yellow) to alkalinity (blue/purple).
class PHGradientComponent extends Component
    with HasGameReference<SoilScopeGame>, TapCallbacks, HoverCallbacks, SoilComponentMixin {
  final Paint _gradientPaint = Paint();

  PHGradientComponent() : super(priority: 3);

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
      
      // pH mapping: 4 (acidic) -> 10 (alkaline)
      final Color phColor = _getColorForPH(layer.ph);

      final paint = _gradientPaint
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            phColor.withValues(alpha: 0.12),
            phColor.withValues(alpha: 0.05),
          ],
        ).createShader(Rect.fromLTWH(backgroundX, currentY, backgroundWidth, layerHeight));

      drawFullWidthSoilRect(canvas, Rect.fromLTWH(0, currentY, 0, layerHeight), paint);
      currentY += layerHeight;
    }
  }

  Color _getColorForPH(double ph) {
    if (ph < 5.0) return Colors.redAccent;
    if (ph < 6.5) return Colors.orangeAccent;
    if (ph < 7.5) return Colors.greenAccent;
    if (ph < 8.5) return Colors.blueAccent;
    return Colors.deepPurpleAccent;
  }

  @override
  bool containsLocalPoint(Vector2 point) => isInsideSimulation(point);

  @override
  void onTapUp(TapUpEvent event) {
    _showPHInfo(pinned: true);
    event.handled = true;
  }

  @override
  void onHoverEnter() {
    _showPHInfo(pinned: false);
  }

  @override
  void onHoverExit() {
    game.ref.read(uIStateProvider.notifier).setHoverInfo(null);
  }

  void _showPHInfo({bool pinned = false}) {
    final l = game.l10n;
    game.ref.read(uIStateProvider.notifier).setHoverInfo(
      HoverInfo(
        title: l.phTitle.toUpperCase(),
        description: l.phDescription,
        stats: {
          l.optimalLabel: "6.0 - 7.2",
          l.significanceLabel: l.nutrientAvailability,
        },
        isPinned: pinned,
      ),
    );
  }
}
