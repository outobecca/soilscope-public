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
import 'molecule_renderer.dart';

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


  @override
  Future<void> onLoad() async {
    await super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.simulationState?.isRunning == true) {
      final flowMode = game.ref.read(particleFlowModeProvider);
      final boost = flowMode ? 2.5 : 1.0;

      // Decouple visual movement from global simulation speed for pedagogical clarity
      final vdt = getPerceptualDt(dt) * boost;

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

        // Element Highlighting Logic
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

        // Use unified renderer
        MoleculeRenderer.drawParticle(
          canvas,
          pos,
          type,
          opacity: baseOpacity,
          isLocked: isImmobilized,
          morphProgress: morphProgress,
          isPaused: isPaused,
          zoom: renderZoom,
          phase: px + py, // Use spatial phase for stable micro-animations
        );

        // Draw movement trails
        if (!isImmobilized && !isPaused && renderZoom > 1.2) {
          _drawParticleTrail(canvas, px, py, pvx, pvy, pTypeIdx, renderZoom);
        }
      }
    } catch (e) {
      debugPrint('[ParticleSystemComponent] Render error: $e');
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

    Future.microtask(() {
      if (!isMounted) return;
      game.ref.read(uIStateProvider.notifier).setHoverInfo(
            HoverInfo(
              title: title,
              description: desc,
              stats: stats,
              formula: MoleculeRenderer.getMoleculeFormula(MoleculeRenderer.mapParticleToMolecule(type)),
              isPinned: pinned,
            ),
          );
    });
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

    final type = ParticleType.values[typeIndex];
    final color = CPKStandards.getColor(_getSymbolForType(type));

    final paint = Paint()
      ..color = color.withValues(alpha: 0.3)
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

  String _getSymbolForType(ParticleType type) {
    switch (type) {
      case ParticleType.ammonium || ParticleType.nitrate || ParticleType.organicNitrogen:
        return 'N';
      case ParticleType.labileCarbon || ParticleType.carbon || ParticleType.stableCarbon:
        return 'C';
      case ParticleType.water:
        return 'O';
      case ParticleType.phosphorus || ParticleType.organicPhosphorus:
        return 'P';
    }
  }
}
