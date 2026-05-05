import 'package:flutter/material.dart';
import '../../../../domain/models/soil_layer.dart';

/// Logic for calculating soil layer visual styles based on biophysical state.
class SoilLayerStyleEngine {
  /// Calculates the gradient paint for a soil layer.
  static Paint calculateLayerPaint(SoilLayer layer, Size size) {
    final baseTopColor = _getHorizonColor(layer.depth);
    final baseBottomColor = _getHorizonColor(layer.depth + layer.thickness);

    final saturation = (layer.waterContent / layer.porosity).clamp(0.0, 1.0);

    // 1. Redox Effect (Gleying)
    Color redoxTint;
    double redoxFactor = 0;
    if (layer.redoxPotential < 200) {
      redoxFactor = ((200 - layer.redoxPotential) / 400).clamp(0.0, 0.6);
      redoxTint = const Color(0xFF546E7A);
    } else if (layer.redoxPotential > 500) {
      redoxFactor = ((layer.redoxPotential - 500) / 500).clamp(0.0, 0.2);
      redoxTint = const Color(0xFFBF360C);
    } else {
      redoxTint = Colors.transparent;
    }

    // 2. Temperature Effect
    final tempC = layer.temperature - 273.15;
    Color tempTint = Colors.transparent;
    double tempFactor = 0;
    if (tempC > 30) {
      tempFactor = ((tempC - 30) / 20).clamp(0.0, 0.15);
      tempTint = Colors.orangeAccent;
    }

    // 3. pH Effect
    Color phTint = Colors.transparent;
    double phFactor = 0;
    if (layer.ph < 5.0) {
      phFactor = (5.0 - layer.ph) * 0.05;
      phTint = Colors.redAccent;
    } else if (layer.ph > 8.0) {
      phFactor = (layer.ph - 8.0) * 0.05;
      phTint = Colors.white;
    }

    // Apply color modifications
    Color topColor = Color.lerp(baseTopColor, Colors.black, saturation * 0.25)!;
    Color bottomColor = Color.lerp(
      baseBottomColor,
      Colors.black,
      saturation * 0.25,
    )!;

    if (redoxFactor > 0) {
      topColor = Color.lerp(topColor, redoxTint, redoxFactor)!;
      bottomColor = Color.lerp(bottomColor, redoxTint, redoxFactor)!;
    }

    if (tempFactor > 0) {
      topColor = Color.lerp(topColor, tempTint, tempFactor)!;
      bottomColor = Color.lerp(bottomColor, tempTint, tempFactor)!;
    }

    if (phFactor > 0) {
      topColor = Color.lerp(topColor, phTint, phFactor)!;
      bottomColor = Color.lerp(bottomColor, phTint, phFactor)!;
    }

    final paint = Paint()..isAntiAlias = false;
    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [topColor.withValues(alpha: 0.6), bottomColor.withValues(alpha: 0.6)],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    return paint;
  }

  static Color _getHorizonColor(double depth) {
    // Nordic Podzol / Arctic Soil Palette
    if (depth < 0.05) return const Color(0xFF1E1E1E); // O-Horizon (Organic/Mull)
    if (depth < 0.25) return const Color(0xFF332A25); // A-Horizon (Topsoil)
    if (depth < 0.60) return const Color(0xFF4A3C31); // B-Horizon (Illuvial)
    if (depth < 1.20) return const Color(0xFF645A52); // C-Horizon (Parent Material)
    return const Color(0xFF525C64); // Bedrock/Deep Stone
  }

  static Color getpHColor(double ph) {
    if (ph < 4.0) return const Color(0xFFDC2626); // Strong Acid
    if (ph < 5.5) return const Color(0xFFEA580C); // Acid
    if (ph < 6.5) return const Color(0xFFEAB308); // Slightly Acid
    if (ph < 7.5) return const Color(0xFF059669); // Neutral
    if (ph < 8.5) return const Color(0xFF2563EB); // Slightly Alkaline
    return const Color(0xFF7C3AED); // Alkaline
  }
}
