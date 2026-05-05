import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../soil_scope_game.dart';
import '../../../providers/ui_state_provider.dart';

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
      case ObservationCycle.nitrogen: return Colors.blueAccent;
      case ObservationCycle.carbon: return Colors.amberAccent;
      case ObservationCycle.water: return Colors.cyanAccent;
      case ObservationCycle.phosphorus: return Colors.orangeAccent;
      default: return null;
    }
  }

  /// Renders a standard cycle glow if active.
  void renderCycleGlow(Canvas canvas, Offset center, double radius) {
    final glowColor = cycleGlowColor;
    if (glowColor != null) {
      canvas.drawCircle(
        center,
        radius * 1.3,
        Paint()
          ..color = glowColor.withValues(alpha: 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }
  }
}
