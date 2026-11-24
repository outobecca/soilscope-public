import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:material_ui/material_ui.dart';
import '../soil_scope_game.dart';
import '../../../providers/ui_state_provider.dart';
import '../../../../core/nitrogen_forms.dart';

/// Mixin for components that participate in biogeochemical cycle highlighting.
/// Allows components to define which cycles they belong to and automatically 
/// handles dimming/glow based on the active observation mode.
mixin CycleHighlightMixin on Component, HasGameReference<SoilScopeGame> {
  
  /// The biogeochemical cycles this component belongs to.
  Set<ObservationCycle> get memberOfCycles;

  /// Whether this component should currently be highlighted.
  bool get isCycleHighlighted {
    final activeCycle = game.ref.read(activeCycleProvider);
    if (activeCycle == ObservationCycle.none) return false;
    return memberOfCycles.contains(activeCycle);
  }

  /// Whether the simulation is currently focusing on a DIFFERENT cycle.
  bool get isCycleDimmed {
    final activeCycle = game.ref.read(activeCycleProvider);
    if (activeCycle == ObservationCycle.none) return false;
    return !memberOfCycles.contains(activeCycle);
  }

  /// Utility to get the appropriate opacity for rendering.
  double get cycleOpacity => isCycleDimmed ? 0.15 : 1.0;

  /// Utility to get the glow color if highlighted.
  Color? get cycleGlowColor {
    if (!isCycleHighlighted) return null;
    final activeCycle = game.ref.read(activeCycleProvider);
    switch (activeCycle) {
      case ObservationCycle.nitrogen: return NitrogenForm.nitrate.color;
      case ObservationCycle.carbon: return Colors.amberAccent;
      case ObservationCycle.water: return Colors.cyanAccent;
      case ObservationCycle.phosphorus: return Colors.orangeAccent;
      default: return null;
    }
  }

  /// Renders the active-cycle emphasis around [center].
  ///
  /// The previous treatment was a single 8 px blur at 40 % alpha, which the
  /// soil texture visually swallowed. A pulsing halo plus two crisp rings is
  /// legible on top of the layered texture while still staying translucent.
  /// The pulse runs on the visual clock, so it freezes with the canvas.
  void renderCycleGlow(Canvas canvas, Offset center, double radius) {
    final glowColor = cycleGlowColor;
    if (glowColor == null) return;

    final pulse = 0.9 + 0.1 * math.sin(game.currentTime() * math.pi);
    canvas.drawCircle(
      center,
      radius * 2.4 * pulse,
      Paint()
        ..color = glowColor.withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawCircle(
      center,
      radius * 1.5 * pulse,
      Paint()
        ..color = glowColor.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }
}
