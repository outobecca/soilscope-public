import 'dart:async';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide PointerMoveEvent;
import '../soil_scope_game.dart';
import '../../../../core/cpk_standards.dart';
import '../../../../domain/solvers/particle_physics_solver.dart';
import '../../../providers/simulation_provider.dart';
import '../../../providers/simulation_session_provider.dart';
import '../../../providers/ui_state_provider.dart';
import 'riverpod_lifecycle_mixin.dart';
import 'visual_time_mixin.dart';
import 'lod_render_mixin.dart';

/// Renders a large field of molecular particles from the physics isolate.
/// Optimization: Uses LOD and batch rendering logic.
/// Interactive: Tap anywhere to select the nearest particle.
class MolecularParticleFieldComponent extends Component
    with
        HasGameReference<SoilScopeGame>,
        TapCallbacks,
        HoverCallbacks,
        PointerMoveCallbacks,
        VisualTimeMixin,
        RiverpodLifecycleMixin,
        LODRenderMixin {
  @override
  bool containsLocalPoint(Vector2 point) {
    const double threshold = 20.0;
    const double thresholdSq = threshold * threshold;
    const int stride = 10;

    for (int i = 1; i < _particleData.length; i += stride) {
      final dx = point.x - _particleData[i];
      final dy = point.y - _particleData[i + 1];
      final distSq = dx * dx + dy * dy;

      if (distSq < thresholdSq) return true;
    }
    return false;
  }

  Float32List _particleData = Float32List(0);
  Float32List get particleData => _particleData;
  int? _pinnedParticleId;
  int? _hoveredParticleId;

  late final Paint _chargePaint;
  late final Paint _ammoniumPaint;
  late final Paint _nitratePaint;
  late final Paint _labileCarbonPaint;
  late final Paint _stableCarbonPaint;
  late final Paint _waterPaint;
  late final Paint _nPaint;
  late final Paint _cPaint;
  late final Paint _pPaint;
  late final Paint _immobilizedPaint;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _chargePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;
    _ammoniumPaint = Paint()..color = CPKStandards.colorN;
    _nitratePaint = Paint()..color = CPKStandards.colorN;
    _labileCarbonPaint = Paint()..color = CPKStandards.colorLabileCarbon;
    _stableCarbonPaint = Paint()..color = CPKStandards.colorStableCarbon;
    _waterPaint = Paint()..color = CPKStandards.colorO; // Central Oxygen
    _nPaint = Paint()..color = CPKStandards.colorN;
    _cPaint = Paint()..color = CPKStandards.colorC;
    _pPaint = Paint()..color = CPKStandards.colorP;
    _immobilizedPaint = Paint()..color = const Color(0xFFF59E0B);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.simulationState?.isRunning == true) {
      // Decouple visual movement from global simulation speed for pedagogical clarity
      final vdt = getPerceptualDt(dt);

      for (int i = 0; i < _particleData.length; i += 10) {
        _particleData[i + 1] += _particleData[i + 3] * vdt;
        _particleData[i + 2] += _particleData[i + 4] * vdt;
      }
    }
  }

  @override
  void onMount() {
    super.onMount();
    final isolateManager = game.ref
        .read(simulationProvider.notifier)
        .particleIsolate;
    addStreamSubscription<Float32List>(isolateManager.particleStream, (data) {
      _particleData = data;
      _updatePinnedInfo();
    });
  }

  bool _isPartOfActiveCycle(ParticleType type, ObservationCycle activeCycle) {
    switch (activeCycle) {
      case ObservationCycle.nitrogen:
        return type == ParticleType.nitrate ||
            type == ParticleType.ammonium ||
            type == ParticleType.organicNitrogen;
      case ObservationCycle.carbon:
        return type == ParticleType.carbon ||
            type == ParticleType.labileCarbon ||
            type == ParticleType.stableCarbon;
      case ObservationCycle.water:
        return type == ParticleType.water;
      case ObservationCycle.phosphorus:
        return type == ParticleType.phosphorus ||
            type == ParticleType.organicPhosphorus;
      case ObservationCycle.none:
        return true;
    }
  }

  bool _isElementHighlighted(
    ParticleType type,
    ObservationCycle activeCycle,
    bool isPartOfActiveCycle,
    String? highlightedSymbol,
  ) {
    if (activeCycle != ObservationCycle.none && isPartOfActiveCycle) {
      return true;
    } else if (highlightedSymbol != null && highlightedSymbol.isNotEmpty) {
      final s = highlightedSymbol;
      if (s == 'N' || s == 'NITROGEN') {
        return type == ParticleType.nitrate ||
            type == ParticleType.ammonium ||
            type == ParticleType.organicNitrogen;
      } else if (s == 'NH4' || s == 'NH4+' || s == 'NH₄⁺' || s == 'AMMONIUM') {
        return type == ParticleType.ammonium;
      } else if (s == 'NO3' || s == 'NO3-' || s == 'NO₃⁻' || s == 'NITRATE') {
        return type == ParticleType.nitrate;
      } else if (s == 'C' || s == 'CARBON') {
        return type == ParticleType.carbon ||
            type == ParticleType.labileCarbon ||
            type == ParticleType.stableCarbon;
      } else if (s == 'H' || s == 'HYDROGEN') {
        return type == ParticleType.water;
      } else if (s == 'O' || s == 'OXYGEN') {
        return type == ParticleType.water ||
            type == ParticleType.nitrate ||
            type == ParticleType.phosphorus ||
            type == ParticleType.organicPhosphorus;
      } else if (s == 'P' || s == 'PHOSPHORUS' || s == 'PO4') {
        return type == ParticleType.phosphorus ||
            type == ParticleType.organicPhosphorus;
      }
    }
    return false;
  }

  double _calculateBaseOpacity(
    bool isImmobilized,
    double life,
    bool inXylem,
    bool flowMode,
  ) {
    double baseOpacity =
        (isImmobilized ? 0.35 : 0.55) * (life > 0 ? life : 1.0).clamp(0.0, 1.0);
    if (inXylem) {
      baseOpacity = 1.0;
    } // Fully opaque when traveling up the plant stem

    // BOOST: Flow Mode increases overall particle presence
    if (flowMode) {
      baseOpacity = math.min(1.0, baseOpacity * 1.5);
    }
    return baseOpacity;
  }

  void _drawHighlight(
    Canvas canvas,
    Offset pos,
    ObservationCycle activeCycle,
    String? highlightedSymbol,
    bool isPinned,
    bool isHovered,
    bool isElementHighlighted,
  ) {
    String symbol = 'N';
    if (activeCycle == ObservationCycle.carbon) {
      symbol = 'C';
    } else if (activeCycle == ObservationCycle.water) {
      symbol = 'H';
    } else if (activeCycle == ObservationCycle.phosphorus) {
      symbol = 'P';
    } else if (highlightedSymbol != null) {
      symbol = highlightedSymbol;
    }

    final highlightColor = isElementHighlighted
        ? (CPKStandards.getColor(symbol).withValues(alpha: 0.8))
        : (isPinned ? Colors.white : Colors.white70);

    final double pulse = isElementHighlighted
        ? (0.8 + 0.4 * math.sin(game.currentTime() * 8))
        : 1.0;

    // Constrain highlight size to prevent massive blobs at low zoom
    final double baseHighlightRadius = isElementHighlighted ? 10.0 : 8.0;
    final double scaledRadius = (baseHighlightRadius / renderZoom).clamp(
      baseHighlightRadius,
      25.0,
    );

    canvas.drawCircle(
      pos,
      scaledRadius * pulse,
      Paint()
        ..color = highlightColor.withValues(alpha: 0.3 * pulse)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (isElementHighlighted ? 2.0 : 1.2) / renderZoom,
    );
  }

  void _drawSimplifiedParticle(
    Canvas canvas,
    Offset pos,
    int pTypeIdx,
    bool isImmobilized,
    double baseOpacity,
  ) {
    final Paint basePaint = _getSimplifiedPaint(
      pTypeIdx,
      isImmobilized,
      baseOpacity,
    );
    // Add contrast ring for dark molecules (N, C) at low zoom to ensure visibility
    final isDark =
        pTypeIdx == ParticleType.carbon.index ||
        pTypeIdx == ParticleType.nitrate.index ||
        pTypeIdx == ParticleType.ammonium.index;

    if (isDark) {
      canvas.drawCircle(
        pos,
        (isImmobilized ? 4.5 : 4.0),
        Paint()..color = Colors.white.withValues(alpha: 0.15),
      );
    }
    canvas.drawCircle(pos, isImmobilized ? 3.5 : 3.0, basePaint);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final state = game.simulationState;
    if (state == null) return;

    final bool isPaused = !state.isRunning;

    if (_particleData.isEmpty) return;
    final activeCycle = game.ref.read(activeCycleProvider);
    final visibleRect = game.camera.visibleWorldRect.inflate(50.0);
    final flowMode = game.ref.read(particleFlowModeProvider);
    final session = game.ref.read(simulationSessionProvider);
    final highlightedSymbol = session.selectedElementSymbol?.toUpperCase();

    canvas.save();
    try {
      for (int i = 0; i < _particleData.length; i += 10) {
        final pId = _particleData[i].toInt();
        final px = _particleData[i + 1];
        final py = _particleData[i + 2];

        if (px < visibleRect.left ||
            px > visibleRect.right ||
            py < visibleRect.top ||
            py > visibleRect.bottom) {
          continue; // Cull rendering
        }

        final pvx = _particleData[i + 3];
        final pvy = _particleData[i + 4];
        final pTypeIdx = _particleData[i + 5].toInt();
        final pState = _particleData[i + 6];

        final isImmobilized = pState < 0;
        double stateValue = pState.abs();

        bool inXylem = stateValue >= 100.0;
        double life = stateValue % 1.0;
        double morphProgress = (stateValue / 10.0).floorToDouble() / 10.0;
        if (inXylem) {
          morphProgress = 0.0;
        }

        if (stateValue == 0) continue;
        if (life == 0 && stateValue < 1.0) continue;

        final pos = Offset(px, py);
        double baseOpacity = _calculateBaseOpacity(
          isImmobilized,
          life,
          inXylem,
          flowMode,
        );

        final isPinned = pId == _pinnedParticleId;
        final isHovered = pId == _hoveredParticleId;

        final type = ParticleType.values[pTypeIdx];

        // Cycle Membership Check
        bool isPartOfActiveCycle = _isPartOfActiveCycle(type, activeCycle);

        if (activeCycle != ObservationCycle.none && !isPartOfActiveCycle) {
          baseOpacity *= 0.15; // High-contrast dimming
        }

        // Element Highlighting Logic (for manual selection or specific cycle focus)
        bool isElementHighlighted = _isElementHighlighted(
          type,
          activeCycle,
          isPartOfActiveCycle,
          highlightedSymbol,
        );

        if (isPinned || isHovered || isElementHighlighted) {
          _drawHighlight(
            canvas,
            pos,
            activeCycle,
            highlightedSymbol,
            isPinned,
            isHovered,
            isElementHighlighted,
          );
        }

        // LOD Optimization: Draw simple dots at very low zoom
        if (renderZoom < 0.6 && !isPaused && !isPinned && !isHovered) {
          _drawSimplifiedParticle(
            canvas,
            pos,
            pTypeIdx,
            isImmobilized,
            baseOpacity,
          );
          continue;
        }

        if (pTypeIdx == ParticleType.ammonium.index) {
          _drawAmmonium(
            canvas,
            pos,
            px + py,
            opacity: baseOpacity,
            isLocked: isImmobilized,
            morphProgress: morphProgress,
            isPaused: isPaused,
            zoom: renderZoom,
          );
        } else if (pTypeIdx == ParticleType.nitrate.index) {
          _drawNitrate(
            canvas,
            pos,
            px - py,
            opacity: baseOpacity,
            isLocked: isImmobilized,
            isPaused: isPaused,
            zoom: renderZoom,
          );
        } else if (pTypeIdx == ParticleType.labileCarbon.index ||
            pTypeIdx == ParticleType.carbon.index) {
          _drawLabileCarbon(
            canvas,
            pos,
            px + py,
            opacity: baseOpacity,
            zoom: renderZoom,
          );
        } else if (pTypeIdx == ParticleType.stableCarbon.index) {
          canvas.drawCircle(
            pos,
            3.2,
            _stableCarbonPaint
              ..color = _stableCarbonPaint.color.withValues(
                alpha: baseOpacity * 0.7,
              ),
          );
        } else if (pTypeIdx == ParticleType.water.index) {
          _drawWater(
            canvas,
            pos,
            px - py,
            opacity: baseOpacity,
            zoom: renderZoom,
          );
        } else if (pTypeIdx == ParticleType.organicNitrogen.index) {
          _drawOrganicNitrogen(
            canvas,
            pos,
            px + py,
            opacity: baseOpacity,
            zoom: renderZoom,
          );
        } else if (pTypeIdx == ParticleType.phosphorus.index) {
          _drawPhosphorus(
            canvas,
            pos,
            opacity: baseOpacity,
            isLocked: isImmobilized,
            zoom: renderZoom,
          );
        } else if (pTypeIdx == ParticleType.organicPhosphorus.index) {
          canvas.drawCircle(
            pos,
            2.5,
            _pPaint..color = _pPaint.color.withValues(alpha: baseOpacity),
          );
          canvas.drawCircle(
            pos + const Offset(2, 2),
            1.8,
            _cPaint..color = _cPaint.color.withValues(alpha: baseOpacity * 0.7),
          );
        }

        // Draw movement trails for non-immobilized particles
        if (!isImmobilized && !isPaused && renderZoom > 1.2) {
          _drawParticleTrail(canvas, px, py, pvx, pvy, pTypeIdx, renderZoom);
        }
      }
    } catch (e) {
      // Robustness
    }
    canvas.restore();
  }

  @override
  void onPointerMove(PointerMoveEvent event) {
    final worldPos = game.camera.globalToLocal(event.canvasPosition);
    _hoveredParticleId = null;

    if (game.camera.viewfinder.zoom < 1.0) return; // Reduced from 1.5

    double minHoverDist = 15.0;
    for (int i = 0; i < _particleData.length; i += 10) {
      final px = _particleData[i + 1];
      final py = _particleData[i + 2];
      final dist = (worldPos - Vector2(px, py)).length;
      if (dist < minHoverDist) {
        minHoverDist = dist;
        _hoveredParticleId = _particleData[i].toInt();
      }
    }
  }

  @override
  void onHoverExit() {
    _hoveredParticleId = null;
  }

  @override
  void onTapUp(TapUpEvent event) {
    final worldPos = game.camera.globalToLocal(event.canvasPosition);
    int? nearestIndex;
    double minTapDist = 20.0;

    for (int i = 0; i < _particleData.length; i += 10) {
      final px = _particleData[i + 1];
      final py = _particleData[i + 2];
      final dist = (worldPos - Vector2(px, py)).length;
      if (dist < minTapDist) {
        minTapDist = dist;
        nearestIndex = i;
      }
    }

    if (nearestIndex != null) {
      _pinnedParticleId = _particleData[nearestIndex].toInt();
      _showParticleInfoFromIndex(nearestIndex, pinned: true);
      event.handled = true;
    } else {
      _pinnedParticleId = null;
      game.ref.read(uIStateProvider.notifier).setHoverInfo(null);
    }
  }

  void _updatePinnedInfo() {
    if (_pinnedParticleId == null) return;
    for (int i = 0; i < _particleData.length; i += 10) {
      if (_particleData[i].toInt() == _pinnedParticleId) {
        _showParticleInfoFromIndex(i, pinned: true);
        return;
      }
    }
    _pinnedParticleId = null;
  }

  void _showParticleInfoFromIndex(int index, {bool pinned = false}) {
    final l = game.l10n;
    final typeIndex = _particleData[index + 5].toInt();
    final pState = _particleData[index + 6];
    final pvx = _particleData[index + 3];
    final pvy = _particleData[index + 4];
    final type = ParticleType.values[typeIndex];

    String title = "";
    String desc = "";
    Map<String, String> stats = {
      l.stateLabel: pState < 0 ? l.immobilized : l.active,
      l.velocityLabel: '${Vector2(pvx, pvy).length.toStringAsFixed(1)} px/s',
    };

    switch (type) {
      case ParticleType.nitrate:
        title = l.moleculeNitrateTitle.toUpperCase();
        desc = l.moleculeNitrateDesc;
        break;
      case ParticleType.ammonium:
        title = l.moleculeAmmoniumTitle.toUpperCase();
        desc = l.moleculeAmmoniumDesc;
        break;
      case ParticleType.labileCarbon:
      case ParticleType.carbon:
        title = l.moleculeCarbonLabileTitle.toUpperCase();
        desc = l.moleculeCarbonLabileDesc;
        break;
      case ParticleType.stableCarbon:
        title = l.moleculeCarbonStableTitle.toUpperCase();
        desc = l.moleculeCarbonStableDesc;
        break;
      case ParticleType.water:
        title = l.moleculeWaterTitle.toUpperCase();
        desc = l.moleculeWaterDesc;
        break;
      case ParticleType.organicNitrogen:
        title = l.organicN.toUpperCase();
        desc = l.biogeochemical;
        break;
      case ParticleType.phosphorus:
        title = "PHOSPHATE";
        desc =
            "Essential nutrient for plant growth, transferred by mycorrhizae.";
        break;
      case ParticleType.organicPhosphorus:
        title = "ORGANIC PHOSPHORUS";
        desc =
            "Phosphorus bound in organic matter. Requires phosphatase enzymes to unlock.";
        break;
    }

    game.ref
        .read(uIStateProvider.notifier)
        .setHoverInfo(
          HoverInfo(
            title: title,
            description: desc,
            stats: stats,
            isPinned: pinned,
          ),
        );
  }

  void _drawGlow(Canvas canvas, Offset pos, double radius, Color color) {
    final paint = Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius);
    canvas.drawCircle(pos, radius, paint);
  }

  Paint _getSimplifiedPaint(int typeIndex, bool isImmobilized, double alpha) {
    if (isImmobilized) {
      return _immobilizedPaint
        ..color = _immobilizedPaint.color.withValues(alpha: alpha);
    }
    final type = ParticleType.values[typeIndex];
    switch (type) {
      case ParticleType.ammonium:
        return _ammoniumPaint
          ..color = _ammoniumPaint.color.withValues(alpha: alpha);
      case ParticleType.nitrate:
        return _nitratePaint
          ..color = _nitratePaint.color.withValues(alpha: alpha);
      case ParticleType.labileCarbon:
      case ParticleType.carbon:
        return _labileCarbonPaint
          ..color = _labileCarbonPaint.color.withValues(alpha: alpha);
      case ParticleType.stableCarbon:
        return _stableCarbonPaint
          ..color = _stableCarbonPaint.color.withValues(alpha: alpha);
      case ParticleType.water:
        return _waterPaint..color = _waterPaint.color.withValues(alpha: alpha);
      case ParticleType.organicNitrogen:
        return _nPaint..color = _nPaint.color.withValues(alpha: alpha);
      case ParticleType.phosphorus:
      case ParticleType.organicPhosphorus:
        return _pPaint..color = _pPaint.color.withValues(alpha: alpha);
    }
  }

  void _drawAmmonium(
    Canvas canvas,
    Offset center,
    double phase, {
    double opacity = 1.0,
    bool isLocked = false,
    double morphProgress = 0.0,
    bool isPaused = false,
    required double zoom,
  }) {
    final currentColor = CPKStandards.colorN;
    final hColor = CPKStandards.colorH;

    // 1. Shadow for depth
    canvas.drawCircle(
      center + const Offset(0.5, 0.5),
      4.5,
      Paint()..color = Colors.black.withValues(alpha: 0.2 * opacity),
    );

    // 2. Main Nitrogen Core
    canvas.drawCircle(
      center,
      4.5,
      Paint()..color = currentColor.withValues(alpha: opacity),
    );

    // 3. Highlight for 3D look
    canvas.drawCircle(
      center - const Offset(1.2, 1.2),
      1.8,
      Paint()..color = Colors.white.withValues(alpha: opacity * 0.4),
    );

    final dist = 4.5 + morphProgress * 0.5;
    for (int i = 0; i < 4; i++) {
      if (i == 3 && morphProgress > 0.5) continue;
      final angle = phase * 0.01 + (i * (morphProgress > 0.5 ? 2.094 : 1.5707));
      final p = Offset(
        center.dx + dist * math.cos(angle),
        center.dy + dist * math.sin(angle),
      );

      // Hydrogen atoms with shading
      canvas.drawCircle(
        p,
        1.3 + morphProgress * 0.25,
        Paint()..color = hColor.withValues(alpha: opacity * 0.9),
      );
      canvas.drawCircle(
        p - const Offset(0.3, 0.3),
        0.4,
        Paint()..color = Colors.white.withValues(alpha: opacity * 0.6),
      );
    }

    if (isLocked) {
      canvas.drawCircle(
        center,
        6.0,
        Paint()
          ..color = Colors.amber.withValues(alpha: 0.25 * opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }

    if (isPaused && zoom > 2.0) {
      _drawChargeLabel(canvas, center, '+', Colors.white, zoom);
    } else if (morphProgress < 0.5) {
      final cPaint = _chargePaint
        ..color = Colors.white.withValues(alpha: 0.95 * opacity);
      canvas.drawLine(
        Offset(center.dx - 1.5, center.dy),
        Offset(center.dx + 1.5, center.dy),
        cPaint,
      );
      canvas.drawLine(
        Offset(center.dx, center.dy - 1.5),
        Offset(center.dx, center.dy + 1.5),
        cPaint,
      );
    }
  }

  void _drawNitrate(
    Canvas canvas,
    Offset center,
    double phase, {
    double opacity = 1.0,
    bool isLocked = false,
    bool isPaused = false,
    required double zoom,
  }) {
    final Color colorN = CPKStandards.colorN;
    final Color colorO = CPKStandards.colorO;

    // 1. Shadow
    canvas.drawCircle(
      center + const Offset(0.5, 0.5),
      4.5,
      Paint()..color = Colors.black.withValues(alpha: 0.2 * opacity),
    );

    // 2. Central Nitrogen
    canvas.drawCircle(
      center,
      4.5,
      Paint()..color = colorN.withValues(alpha: opacity),
    );
    canvas.drawCircle(
      center - const Offset(1.2, 1.2),
      1.8,
      Paint()..color = Colors.white.withValues(alpha: opacity * 0.4),
    );

    final dist = 4.8;
    for (int i = 0; i < 3; i++) {
      final angle = phase * 0.008 + (i * 2.0943951023931953);
      final p = Offset(
        center.dx + dist * math.cos(angle),
        center.dy + dist * math.sin(angle),
      );

      // Oxygen atoms with shading
      canvas.drawCircle(
        p,
        1.5,
        Paint()..color = colorO.withValues(alpha: opacity * 0.9),
      );
      canvas.drawCircle(
        p - const Offset(0.4, 0.4),
        0.5,
        Paint()..color = Colors.white.withValues(alpha: opacity * 0.6),
      );
    }

    if (isPaused && zoom > 2.0) {
      _drawChargeLabel(canvas, center, '-', Colors.white, zoom);
    } else {
      final cPaint = _chargePaint
        ..color = Colors.white.withValues(alpha: 0.95 * opacity);
      canvas.drawLine(
        Offset(center.dx - 1.5, center.dy),
        Offset(center.dx + 1.5, center.dy),
        cPaint,
      );
    }
  }

  void _drawChargeLabel(
    Canvas canvas,
    Offset center,
    String symbol,
    Color color,
    double zoom,
  ) {
    canvas.drawCircle(
      center,
      6.0,
      Paint()..color = const Color(0xFF0F172A).withValues(alpha: 0.8),
    );
    canvas.drawCircle(
      center,
      6.0,
      Paint()
        ..color = color.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    final stroke = 1.5 / zoom; // Thicker stroke
    final paint = Paint()
      ..color = color.withValues(alpha: 1.0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    const s = 5.0;
    canvas.drawLine(
      Offset(center.dx - s / 2, center.dy),
      Offset(center.dx + s / 2, center.dy),
      paint,
    );
    if (symbol == '+') {
      canvas.drawLine(
        Offset(center.dx, center.dy - s / 2),
        Offset(center.dx, center.dy + s / 2),
        paint,
      );
    }
  }

  void _drawPhosphorus(
    Canvas canvas,
    Offset center, {
    double opacity = 1.0,
    bool isLocked = false,
    required double zoom,
  }) {
    final colorP = CPKStandards.colorP;
    _drawGlow(canvas, center, 7.0, colorP.withValues(alpha: 0.15 * opacity));

    canvas.drawCircle(
      center,
      2.8,
      Paint()..color = colorP.withValues(alpha: opacity),
    );

    // Draw tetrahedral phosphate (PO4) structure (simplified 2D)
    final dist = 4.0;
    final colorO = CPKStandards.colorO;
    for (int i = 0; i < 4; i++) {
      final angle = (i * 1.5707) + (game.currentTime() * 0.5);
      final p = Offset(
        center.dx + dist * math.cos(angle),
        center.dy + dist * math.sin(angle),
      );
      canvas.drawCircle(
        p,
        1.2,
        Paint()..color = colorO.withValues(alpha: opacity * 0.7),
      );
    }

    if (isLocked) {
      canvas.drawCircle(
        center,
        5.5,
        Paint()
          ..color = Colors.amber.withValues(alpha: 0.3 * opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }
  }

  void _drawLabileCarbon(
    Canvas canvas,
    Offset center,
    double phase, {
    double opacity = 1.0,
    required double zoom,
  }) {
    final colorC = CPKStandards.colorC;
    final colorO = CPKStandards.colorO;

    _drawGlow(canvas, center, 10.0, colorC.withValues(alpha: 0.15 * opacity));
    canvas.drawCircle(
      center,
      3.5,
      Paint()..color = colorC.withValues(alpha: opacity),
    );

    if (zoom > 1.3) {
      // Draw simplified glucose-like structure (ring/chain)
      for (int i = 0; i < 3; i++) {
        final angle = phase * 0.005 + (i * 2.0);
        final p = center + Offset(math.cos(angle) * 4.0, math.sin(angle) * 4.0);
        canvas.drawCircle(
          p,
          1.8,
          Paint()..color = colorO.withValues(alpha: opacity * 0.8),
        );
      }
    } else {
      // Add a slight contrast halo for black carbon on dark soil
      canvas.drawCircle(
        center,
        4.0,
        Paint()..color = Colors.white.withValues(alpha: 0.15 * opacity),
      );
    }
  }

  void _drawWater(
    Canvas canvas,
    Offset center,
    double phase, {
    double opacity = 1.0,
    required double zoom,
  }) {
    final colorO = CPKStandards.colorO;
    final colorH = CPKStandards.colorH;

    if (zoom > 1.5) {
      // High-fidelity CPK Water (Bent molecule)
      canvas.drawCircle(
        center,
        3.2,
        Paint()..color = colorO.withValues(alpha: opacity),
      );
      final dist = 3.8;
      for (int i = 0; i < 2; i++) {
        final angle = (i == 0 ? 0.6 : 2.5) + phase * 0.005;
        final p =
            center + Offset(math.cos(angle) * dist, math.sin(angle) * dist);
        canvas.drawCircle(
          p,
          1.4,
          Paint()..color = colorH.withValues(alpha: opacity * 0.9),
        );
      }
    } else {
      // Low zoom: Single dot with contrast halo
      canvas.drawCircle(
        center,
        4.2 / zoom,
        Paint()..color = Colors.white.withValues(alpha: 0.4 * opacity),
      );
      canvas.drawCircle(
        center,
        3.2 / zoom,
        Paint()..color = colorO.withValues(alpha: opacity),
      );
    }
  }

  void _drawOrganicNitrogen(
    Canvas canvas,
    Offset center,
    double phase, {
    double opacity = 1.0,
    required double zoom,
  }) {
    final colorN = CPKStandards.colorN;
    final colorC = CPKStandards.colorC;

    // Removed glow for clear CPK rendering
    canvas.drawCircle(
      center,
      3.8,
      Paint()..color = colorN.withValues(alpha: opacity),
    );

    if (zoom > 1.4) {
      // Cluster representing an amino acid
      for (int i = 0; i < 2; i++) {
        final angle = phase * 0.01 + (i * 3.14);
        final p = center + Offset(math.cos(angle) * 5.0, math.sin(angle) * 5.0);
        canvas.drawCircle(
          p,
          2.2,
          Paint()..color = colorC.withValues(alpha: opacity * 0.8),
        );
      }
    }
  }

  void _drawParticleTrail(
    Canvas canvas,
    double px,
    double py,
    double vx,
    double vy,
    int typeIndex,
    double zoom,
  ) {
    final speed = Vector2(vx, vy).length;
    if (speed < 8.0) return;

    final paint = _getSimplifiedPaint(typeIndex, false, 0.3)
      ..strokeWidth = 2.0 / zoom
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final unitV = Vector2(vx, vy).normalized();
    final trailLength = (speed / 5.0).clamp(5.0, 20.0) / zoom;
    canvas.drawLine(
      Offset(px, py),
      Offset(px - unitV.x * trailLength, py - unitV.y * trailLength),
      paint,
    );
  }
}
