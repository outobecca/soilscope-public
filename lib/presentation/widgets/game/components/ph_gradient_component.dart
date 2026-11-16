import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:material_ui/material_ui.dart' hide PointerMoveEvent;
import '../soil_scope_game.dart';
import '../../../providers/ui_state_provider.dart';
import 'soil_component_mixin.dart';

/// Renders a color gradient representing soil pH levels.
/// Visualizes acidity (red/yellow) to alkalinity (blue/purple).
class PHGradientComponent extends Component
    with
        HasGameReference<SoilScopeGame>,
        TapCallbacks,
        HoverCallbacks,
        SoilComponentMixin {
  PHGradientComponent() : super(priority: 3);


  final _paint = Paint();
  bool _isPinned = false;

  @override
  void render(Canvas canvas) {
    final state = game.displayedState;
    if (state.profile.layers.isEmpty) return;

    final totalThickness = state.profile.layers.fold(
      0.0,
      (sum, l) => sum + l.thickness,
    );
    final double scaleY = calculateVerticalScale(totalThickness);
    final totalHeight = totalThickness * scaleY;
    if (totalHeight <= 0) return;

    // One column gradient instead of one shader and rect per layer.
    final colors = <Color>[];
    final stops = <double>[];
    double currentY = surfaceY;
    for (final layer in state.profile.layers) {
      final phColor = _getColorForPH(layer.ph);
      final layerHeight = layer.thickness * scaleY;
      colors
        ..add(phColor.withValues(alpha: 0.12))
        ..add(phColor.withValues(alpha: 0.05));
      stops
        ..add(((currentY - surfaceY) / totalHeight).clamp(0.0, 1.0))
        ..add(
          ((currentY + layerHeight - surfaceY) / totalHeight).clamp(0.0, 1.0),
        );
      currentY += layerHeight;
    }

    _paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: colors,
      stops: stops,
    ).createShader(
      Rect.fromLTWH(backgroundX, surfaceY, backgroundWidth, totalHeight),
    );
    drawFullWidthSoilRect(
      canvas,
      Rect.fromLTWH(0, surfaceY, 0, totalHeight),
      _paint,
    );
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
    _isPinned = !_isPinned;
    if (_isPinned) {
      _showPHInfo(pinned: true);
    } else {
      game.ref.read(uIStateProvider.notifier).setHoverInfo(null);
    }
    event.handled = true;
  }

  @override
  void onHoverEnter() {
    final current = game.ref.read(uIStateProvider);
    if (current == null || !current.isPinned) _showPHInfo(pinned: false);
  }

  @override
  void onHoverExit() {
    if (!_isPinned) {
      final current = game.ref.read(uIStateProvider);
      if (current == null || !current.isPinned) {
        game.ref.read(uIStateProvider.notifier).setHoverInfo(null);
      }
    }
  }

  void _showPHInfo({bool pinned = false}) {
    final l = game.l10n;
    final anchorWorld = Vector2(
      game.soilLeftX + SoilScopeGame.soilColumnWidth / 2,
      surfaceY + soilHeight / 2,
    );

    game.ref
        .read(uIStateProvider.notifier)
        .setHoverInfo(
          HoverInfo(
            title: l.phTitle.toUpperCase(),
            description: l.phDescription,
            stats: {
              l.optimalLabel: "6.0 - 7.2",
              l.significanceLabel: l.nutrientAvailability,
            },
            isPinned: pinned,
            sourceId: 'ph-gradient',
            onDismiss: () => _isPinned = false,
            accentColor: Colors.greenAccent,
            screenPosition: game.worldToScreen(anchorWorld).toOffset(),
          ),
        );
  }
}
