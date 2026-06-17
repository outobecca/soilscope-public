import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/cpk_standards.dart';
import '../../../../domain/solvers/particle_physics_solver.dart';

enum MoleculeType {
  ammonium,
  nitrate,
  labileCarbon,
  stableCarbon,
  water,
  oxygen,
  co2,
  organicNitrogen,
  carbon,
  methane,
  nitrousOxide,
  phosphate,
  potassium,
  calcium,
  magnesium,
  waterVapor,
}

/// A unified, high-fidelity renderer for all molecular entities in SoilScope.
/// Used by both the batch renderer (Field) and individual components (Hero).
class MoleculeRenderer {
  static final Paint _chargePaint = Paint()
    ..color = Colors.white.withValues(alpha: 0.9)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  /// Draws a molecule based on ParticleType (Isolate-based).
  static void drawParticle(
    Canvas canvas,
    Offset center,
    ParticleType type, {
    double opacity = 1.0,
    bool isLocked = false,
    double morphProgress = 0.0,
    bool isPaused = false,
    double zoom = 1.0,
    double phase = 0.0,
  }) {
    final mType = mapParticleToMolecule(type);
    drawMolecule(
      canvas,
      center,
      mType,
      opacity: opacity,
      isLocked: isLocked,
      morphProgress: morphProgress,
      isPaused: isPaused,
      zoom: zoom,
      phase: phase,
    );
  }

  /// Draws a molecule based on MoleculeType (Component-based).
  static void drawMolecule(
    Canvas canvas,
    Offset center,
    MoleculeType type, {
    double opacity = 1.0,
    bool isLocked = false,
    double morphProgress = 0.0,
    bool isPaused = false,
    double zoom = 1.0,
    double phase = 0.0,
  }) {
    if (zoom < 0.6 && !isLocked) {
      _drawSimplified(canvas, center, type, opacity, isLocked);
      return;
    }

    switch (type) {
      case MoleculeType.ammonium:
        _drawAmmonium(canvas, center, phase, opacity, isLocked, morphProgress, isPaused, zoom);
        break;
      case MoleculeType.nitrate:
        _drawNitrate(canvas, center, phase, opacity, isLocked, isPaused, zoom);
        break;
      case MoleculeType.water:
      case MoleculeType.waterVapor:
        _drawWater(canvas, center, phase, opacity, zoom);
        break;
      case MoleculeType.labileCarbon:
      case MoleculeType.carbon:
        _drawLabileCarbon(canvas, center, phase, opacity, zoom);
        break;
      case MoleculeType.stableCarbon:
        _drawStableCarbon(canvas, center, opacity);
        break;
      case MoleculeType.phosphate:
        _drawPhosphate(canvas, center, opacity, isLocked, zoom, phase);
        break;
      case MoleculeType.organicNitrogen:
        _drawOrganicNitrogen(canvas, center, opacity, zoom, phase);
        break;
      case MoleculeType.nitrousOxide:
        _drawNitrousOxide(canvas, center, opacity, zoom, phase);
        break;
      case MoleculeType.methane:
        _drawMethane(canvas, center, opacity, zoom, phase);
        break;
      case MoleculeType.co2:
        _drawCO2(canvas, center, opacity, zoom, phase);
        break;
      default:
        _drawDefaultAtom(canvas, center, type, opacity, zoom);
    }
  }

  static void _drawSimplified(Canvas canvas, Offset center, MoleculeType type, double opacity, bool isLocked) {
    final color = getMoleculeColor(type);
    if (isLocked) {
      canvas.drawCircle(center, 4.0, Paint()..color = Colors.white.withValues(alpha: 0.15 * opacity));
    }
    canvas.drawCircle(center, 3.0, Paint()..color = color.withValues(alpha: opacity));
  }

  static void _drawAmmonium(Canvas canvas, Offset center, double phase, double opacity, bool isLocked, double morphProgress, bool isPaused, double zoom) {
    final colorN = CPKStandards.colorN;
    final colorH = CPKStandards.colorH;

    _drawShadow(canvas, center, 4.5, opacity);
    _drawAtomCore(canvas, center, colorN, 4.5, opacity);

    final dist = 4.5 + morphProgress * 0.5;
    final atomCount = morphProgress > 0.5 ? 3 : 4;
    for (int i = 0; i < atomCount; i++) {
      final angle = phase * 0.01 + (i * (morphProgress > 0.5 ? 2.094 : 1.5707));
      final p = Offset(center.dx + dist * math.cos(angle), center.dy + dist * math.sin(angle));
      _drawAtomCore(canvas, p, colorH, 1.3 + morphProgress * 0.25, opacity * 0.9);
    }

    if (isLocked) _drawLockGlow(canvas, center, 6.0, opacity);
    if (isPaused && zoom > 2.0) _drawChargeLabel(canvas, center, '+', opacity, zoom);
  }

  static void _drawNitrate(Canvas canvas, Offset center, double phase, double opacity, bool isLocked, bool isPaused, double zoom) {
    final colorN = CPKStandards.colorN;
    final colorO = CPKStandards.colorO;

    _drawShadow(canvas, center, 4.5, opacity);
    _drawAtomCore(canvas, center, colorN, 4.5, opacity);

    const dist = 4.8;
    for (int i = 0; i < 3; i++) {
      final angle = phase * 0.008 + (i * 2.0943);
      final p = Offset(center.dx + dist * math.cos(angle), center.dy + dist * math.sin(angle));
      _drawAtomCore(canvas, p, colorO, 1.5, opacity * 0.9);
    }

    if (isLocked) _drawLockGlow(canvas, center, 6.0, opacity);
    if (isPaused && zoom > 2.0) _drawChargeLabel(canvas, center, '-', opacity, zoom);
  }

  static void _drawWater(Canvas canvas, Offset center, double phase, double opacity, double zoom) {
    final colorO = CPKStandards.colorO;
    final colorH = Colors.white;

    _drawShadow(canvas, center, 4.0, opacity);
    _drawAtomCore(canvas, center, colorO, 4.0, opacity);

    for (int i = 0; i < 2; i++) {
      final angle = phase * 0.02 + (i == 0 ? 0.8 : -0.8);
      final p = Offset(center.dx + 3.5 * math.cos(angle), center.dy + 3.5 * math.sin(angle));
      _drawAtomCore(canvas, p, colorH, 1.2, opacity * 0.8);
    }
  }

  static void _drawCO2(Canvas canvas, Offset center, double opacity, double zoom, double phase) {
    final colorC = CPKStandards.colorC;
    final colorO = CPKStandards.colorO;

    _drawShadow(canvas, center, 4.0, opacity);
    _drawAtomCore(canvas, center, colorC, 4.0, opacity);
    
    // Linear O=C=O
    final angle = phase * 0.01;
    final p1 = Offset(center.dx + 5.0 * math.cos(angle), center.dy + 5.0 * math.sin(angle));
    final p2 = Offset(center.dx - 5.0 * math.cos(angle), center.dy - 5.0 * math.sin(angle));
    
    _drawAtomCore(canvas, p1, colorO, 2.5, opacity * 0.9);
    _drawAtomCore(canvas, p2, colorO, 2.5, opacity * 0.9);
  }

  static void _drawLabileCarbon(Canvas canvas, Offset center, double phase, double opacity, double zoom) {
    final colorC = CPKStandards.colorLabileCarbon;
    _drawShadow(canvas, center, 4.0, opacity);
    _drawAtomCore(canvas, center, colorC, 4.0, opacity);
    
    // Labile carbon often has dangling bits (side chains)
    final p = Offset(center.dx + 3.0 * math.cos(phase * 0.05), center.dy + 3.0 * math.sin(phase * 0.05));
    _drawAtomCore(canvas, p, colorC.withValues(alpha: 0.7), 2.0, opacity * 0.6);
  }

  static void _drawStableCarbon(Canvas canvas, Offset center, double opacity) {
    _drawShadow(canvas, center, 3.5, opacity);
    _drawAtomCore(canvas, center, CPKStandards.colorStableCarbon, 3.5, opacity);
  }

  static void _drawPhosphate(Canvas canvas, Offset center, double opacity, bool isLocked, double zoom, double phase) {
    final colorP = CPKStandards.colorP;
    final colorO = CPKStandards.colorO;

    _drawShadow(canvas, center, 4.5, opacity);
    _drawAtomCore(canvas, center, colorP, 4.5, opacity);

    for (int i = 0; i < 4; i++) {
      final angle = (i * 1.5707) + (phase * 0.005);
      final p = Offset(center.dx + 4.5 * math.cos(angle), center.dy + 4.5 * math.sin(angle));
      _drawAtomCore(canvas, p, colorO, 1.5, opacity * 0.7);
    }
    if (isLocked) _drawLockGlow(canvas, center, 6.5, opacity);
  }

  static void _drawOrganicNitrogen(Canvas canvas, Offset center, double opacity, double zoom, double phase) {
    final colorN = CPKStandards.colorN;
    final colorC = CPKStandards.colorC;

    _drawShadow(canvas, center, 5.0, opacity);
    // Represented as a N atom attached to a generic organic chain (C)
    _drawAtomCore(canvas, center, colorN, 4.5, opacity);
    
    final p1 = Offset(center.dx + 4.0 * math.cos(phase * 0.02), center.dy + 4.0 * math.sin(phase * 0.02));
    _drawAtomCore(canvas, p1, colorC, 3.0, opacity * 0.7);
  }

  static void _drawNitrousOxide(Canvas canvas, Offset center, double opacity, double zoom, double phase) {
    final colorN = CPKStandards.colorN;
    final colorO = CPKStandards.colorO;

    _drawShadow(canvas, center, 4.5, opacity);
    // N=N=O
    final angle = phase * 0.015;
    final pN1 = center;
    final pN2 = Offset(center.dx + 4.5 * math.cos(angle), center.dy + 4.5 * math.sin(angle));
    final pO = Offset(center.dx - 4.5 * math.cos(angle), center.dy - 4.5 * math.sin(angle));

    _drawAtomCore(canvas, pN1, colorN, 4.0, opacity);
    _drawAtomCore(canvas, pN2, colorN, 3.5, opacity * 0.9);
    _drawAtomCore(canvas, pO, colorO, 4.0, opacity * 0.9);
  }

  static void _drawMethane(Canvas canvas, Offset center, double opacity, double zoom, double phase) {
    final colorC = CPKStandards.colorC;
    final colorH = CPKStandards.colorH;

    _drawShadow(canvas, center, 4.5, opacity);
    _drawAtomCore(canvas, center, colorC, 4.5, opacity);

    for (int i = 0; i < 4; i++) {
      final angle = (i * 1.5707) + (phase * 0.025);
      final p = Offset(center.dx + 4.5 * math.cos(angle), center.dy + 4.5 * math.sin(angle));
      _drawAtomCore(canvas, p, colorH, 1.5, opacity * 0.8);
    }
  }

  static void _drawDefaultAtom(Canvas canvas, Offset center, MoleculeType type, double opacity, double zoom) {
    final color = getMoleculeColor(type);
    _drawShadow(canvas, center, 4.0, opacity);
    _drawAtomCore(canvas, center, color, 4.0, opacity);
  }

  // --- Helpers ---

  static void _drawShadow(Canvas canvas, Offset center, double radius, double opacity) {
    canvas.drawCircle(center + const Offset(0.8, 0.8), radius, Paint()..color = Colors.black.withValues(alpha: 0.25 * opacity));
  }

  static void _drawAtomCore(Canvas canvas, Offset center, Color color, double radius, double opacity) {
    canvas.drawCircle(center, radius, Paint()..color = color.withValues(alpha: opacity));
    // 3D Highlight
    canvas.drawCircle(center - Offset(radius * 0.3, radius * 0.3), radius * 0.35, Paint()..color = Colors.white.withValues(alpha: opacity * 0.45));
  }

  static void _drawLockGlow(Canvas canvas, Offset center, double radius, double opacity) {
    canvas.drawCircle(center, radius, Paint()
      ..color = Colors.amber.withValues(alpha: 0.3 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2));
  }

  static void _drawChargeLabel(Canvas canvas, Offset center, String symbol, double opacity, double zoom) {
    final s = 4.0;
    final p = _chargePaint..color = Colors.white.withValues(alpha: 0.9 * opacity);
    canvas.drawLine(Offset(center.dx - s/2, center.dy), Offset(center.dx + s/2, center.dy), p);
    if (symbol == '+') {
      canvas.drawLine(Offset(center.dx, center.dy - s/2), Offset(center.dx, center.dy + s/2), p);
    }
  }

  static MoleculeType mapParticleToMolecule(ParticleType type) {
    switch (type) {
      case ParticleType.ammonium: return MoleculeType.ammonium;
      case ParticleType.nitrate: return MoleculeType.nitrate;
      case ParticleType.labileCarbon: return MoleculeType.labileCarbon;
      case ParticleType.stableCarbon: return MoleculeType.stableCarbon;
      case ParticleType.water: return MoleculeType.water;
      case ParticleType.organicNitrogen: return MoleculeType.organicNitrogen;
      case ParticleType.carbon: return MoleculeType.carbon;
      case ParticleType.phosphorus: return MoleculeType.phosphate;
      case ParticleType.organicPhosphorus: return MoleculeType.organicNitrogen; // Close enough for generic rendering
    }
  }

  static Color getMoleculeColor(MoleculeType t) {
    switch (t) {
      case MoleculeType.ammonium:
      case MoleculeType.nitrate:
      case MoleculeType.organicNitrogen:
      case MoleculeType.nitrousOxide:
        return CPKStandards.colorN;
      case MoleculeType.labileCarbon:
      case MoleculeType.carbon:
      case MoleculeType.methane:
      case MoleculeType.co2:
        return CPKStandards.colorC;
      case MoleculeType.stableCarbon:
        return CPKStandards.colorStableCarbon;
      case MoleculeType.water:
      case MoleculeType.waterVapor:
        return Colors.cyan;
      case MoleculeType.oxygen:
        return CPKStandards.colorO;
      case MoleculeType.phosphate:
        return CPKStandards.colorP;
      case MoleculeType.potassium:
        return CPKStandards.colorK;
      case MoleculeType.calcium:
        return CPKStandards.colorCa;
      case MoleculeType.magnesium:
        return CPKStandards.colorMg;
    }
  }

  static String getMoleculeFormula(MoleculeType t) {
    switch (t) {
      case MoleculeType.ammonium: return "NH4+";
      case MoleculeType.nitrate: return "NO3-";
      case MoleculeType.labileCarbon:
      case MoleculeType.carbon:
        return "C-lab";
      case MoleculeType.stableCarbon: return "C-sta";
      case MoleculeType.water: return "H2O";
      case MoleculeType.oxygen: return "O2";
      case MoleculeType.co2: return "CO2";
      case MoleculeType.organicNitrogen: return "DON";
      case MoleculeType.methane: return "CH4";
      case MoleculeType.nitrousOxide: return "N2O";
      case MoleculeType.phosphate: return "PO4";
      case MoleculeType.potassium: return "K+";
      case MoleculeType.calcium: return "Ca2+";
      case MoleculeType.magnesium: return "Mg2+";
      case MoleculeType.waterVapor: return "H2O(v)";
    }
  }
}
