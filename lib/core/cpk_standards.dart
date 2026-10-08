import 'package:flutter/material.dart';

/// CPK (Corey-Pauling-Koltun) standards for chemical visualization.
/// These constants ensure scientific accuracy and pedagogical consistency.
class CPKStandards {
  // Colors (Refined Nordic Academic Palette)
  static const Color colorN = Color(0xFF2563EB); // Royal Blue
  static const Color colorO = Color(0xFFDC2626); // Crimson Red
  static const Color colorH = Color(0xFFF1F5F9); // Snow White
  static const Color colorC = Color(0xFF1E293B); // Slate Night
  static const Color colorP = Color(0xFFD97706); // Amber Orange
  static const Color colorS = Color(0xFFEAB308); // Golden Yellow
  static const Color colorK = Color(0xFF7C3AED); // Deep Violet
  static const Color colorCa = Color(0xFF059669); // Emerald Green
  static const Color colorMg = Color(0xFF16A34A); // Forest Green

  // App-specific semantic colors
  static const Color colorLabileCarbon = Color(0xFF334155); // Muted Slate
  static const Color colorStableCarbon = Color(0xFF0F172A); // Deep Navy
  static const Color colorRhizosphere = Color(0x2210B981); // Subtle Emerald Glow
  static const Color colorMicrobeZone = Color(0x33FACC15); // Subtle Golden Pulse

  // Relative Atomic Radii (pm - picometers, used for scaling)
  static const double radiusH = 37.0;
  static const double radiusC = 77.0;
  static const double radiusN = 75.0;
  static const double radiusO = 73.0;
  static const double radiusP = 110.0;
  static const double radiusS = 102.0;

  /// Returns the CPK color for a given element symbol.
  static Color getColor(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'H':
        return colorH;
      case 'C':
        return colorC;
      case 'N':
        return colorN;
      case 'O':
        return colorO;
      case 'P':
        return colorP;
      case 'S':
        return colorS;
      case 'K':
        return colorK;
      case 'CA':
        return colorCa;
      case 'MG':
        return colorMg;
      case 'NA':
        return const Color(0xFF8B5CF6); // Purple
      case 'CL':
        return const Color(0xFF22C55E); // Green
      case 'FE':
        return const Color(0xFFEA580C); // Rust Orange
      case 'CU':
        return const Color(0xFFC2410C); // Copper Bronze
      case 'ZN':
        return const Color(0xFF64748B); // Slate Blue
      case 'MN':
        return const Color(0xFF9333EA); // Manganese Purple
      case 'B':
        return const Color(0xFFF472B6); // Peach Pink
      case 'AL':
        return const Color(0xFF94A3B8); // Aluminum Silver
      case 'SI':
        return const Color(0xFF0F766E); // Silicate Teal
      case 'MO':
        return const Color(0xFF06B6D4); // Cyan
      case 'CO':
        return const Color(0xFF1E40AF); // Cobalt Blue
      case 'NI':
        return const Color(0xFF10B981); // Emerald Nickel
      case 'SE':
        return const Color(0xFFD97706); // Amber Selenium
      case 'PB':
        return const Color(0xFF475569); // Dark Lead Slate
      case 'CD':
        return const Color(0xFFF59E0B); // Cadmium Orange
      case 'AS':
        return const Color(0xFFF97316); // Arsenic Warning
      case 'F':
        return const Color(0xFF86EFAC); // Pale Green
      case 'I':
        return const Color(0xFF7E22CE); // Dark Violet
      case 'HE':
      case 'NE':
      case 'AR':
      case 'KR':
      case 'XE':
        return const Color(0xFF38BDF8); // Noble Gas Cyan
      default:
        return const Color(0xFF64748B);
    }
  }

  /// Returns a relative scale factor based on atomic radius.
  static double getRelativeScale(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'H':
        return radiusH / radiusN;
      case 'C':
        return radiusC / radiusN;
      case 'N':
        return 1.0;
      case 'O':
        return radiusO / radiusN;
      case 'P':
        return radiusP / radiusN;
      case 'S':
        return radiusS / radiusN;
      default:
        return 1.0;
    }
  }
}
