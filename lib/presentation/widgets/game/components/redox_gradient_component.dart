import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:material_ui/material_ui.dart' hide PointerMoveEvent;
import '../soil_scope_game.dart';
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

    // One column gradient instead of one shader and rect per layer. Each
    // horizon keeps its own colour at the correct depth, with a smooth
    // transition across the boundary.
    final colors = <Color>[];
    final stops = <double>[];
    double currentY = surfaceY;
    for (final layer in state.profile.layers) {
      final ehColor = _getColorForEh(layer.redoxPotential);
      final layerHeight = layer.thickness * scaleY;
      colors
        ..add(ehColor.withValues(alpha: 0.15))
        ..add(ehColor.withValues(alpha: 0.08));
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
    _isPinned = !_isPinned;
    if (_isPinned) {
      _showRedoxInfo(pinned: true);
    } else {
      game.ref.read(uIStateProvider.notifier).setHoverInfo(null);
    }
    event.handled = true;
  }

  @override
  void onHoverEnter() {
    final current = game.ref.read(uIStateProvider);
    if (current == null || !current.isPinned) _showRedoxInfo(pinned: false);
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

  void _showRedoxInfo({bool pinned = false}) {
    final l = game.l10n;
    final anchorWorld = Vector2(
      game.soilLeftX + SoilScopeGame.soilColumnWidth / 2,
      surfaceY + soilHeight / 2,
    );

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
            sourceId: 'redox-gradient',
            onDismiss: () => _isPinned = false,
            accentColor: const Color(0xFF0EA5E9),
            screenPosition: game.worldToScreen(anchorWorld).toOffset(),
          ),
        );
  }
}
