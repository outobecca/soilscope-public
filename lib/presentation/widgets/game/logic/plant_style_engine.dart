import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../domain/models/plant.dart';

/// Logic for calculating plant visual styles (colors, wilting, sizes).
class PlantStyleEngine {
  static Color getStemTopColor(Plant plant, double healthFactor) {
    return Color.lerp(
      Colors.orange.shade900,
      const Color(0xFF4CAF50),
      healthFactor,
    )!;
  }

  static Color getStemBottomColor(Plant plant, double healthFactor) {
    return Color.lerp(
      Colors.orange.shade900,
      const Color(0xFF2E7D32),
      healthFactor,
    )!;
  }

  static Color getLeafTopColor(Plant plant, double healthFactor) {
    return Color.lerp(
      Colors.orange.shade700,
      const Color(0xFF66BB6A),
      healthFactor,
    )!;
  }

  static Color getLeafBottomColor(Plant plant, double healthFactor) {
    return Color.lerp(
      Colors.orange.shade900,
      const Color(0xFF2E7D32),
      healthFactor,
    )!;
  }

  static double calculateWiltSway(double healthFactor) {
    return (1.0 - healthFactor) * 15 * math.pi / 180;
  }

  static double calculateVisualHeight(Plant plant, double surfaceY) {
    final double maxPlantHeight = surfaceY * 0.8;
    final double hFactor = (plant.height / 1.5).clamp(0.25, 1.0);
    return hFactor * maxPlantHeight;
  }

  static Color getStressColor(double turgorPressure) {
    if (turgorPressure > 0.8) return Colors.green;
    if (turgorPressure > 0.5) return Colors.orange;
    return Colors.red;
  }
}
