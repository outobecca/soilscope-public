import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide PointerMoveEvent;
import '../soil_scope_game.dart';
import '../../../providers/simulation_session_provider.dart';
import '../../../providers/ui_state_provider.dart';

enum FluxType {
  water,
  carbon,
  nitrogen,
  phosphorus,
  potassium,
  calcium,
  magnesium,
  oxygen,
  gas,
  leaching,
  energy,
}

/// Interactive data packet representing flux of water, nutrients, carbon, etc.
class DataPacket extends PositionComponent
    with HasGameReference<SoilScopeGame>, TapCallbacks, HoverCallbacks {
  final FluxType type;
  final List<Vector2> path;
  final double speed;
  final Color color;
  double _progress = 0;
  bool _isSelected = false;
  double _selectionPulse = 0;

  DataPacket({
    required this.type,
    required this.path,
    this.speed = 100.0,
    required this.color,
  }) : super(size: Vector2.all(16.0), anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    final session = game.ref.read(simulationSessionProvider);
    final focus = session.selectedElementSymbol;

    bool isFocused = false;
    if (focus == 'N' && type == FluxType.nitrogen) isFocused = true;
    if (focus == 'P' && type == FluxType.phosphorus) isFocused = true;
    if (focus == 'K' && type == FluxType.potassium) isFocused = true;
    if (focus == 'Ca' && type == FluxType.calcium) isFocused = true;
    if (focus == 'Mg' && type == FluxType.magnesium) isFocused = true;
    if (focus == 'C' && type == FluxType.carbon) isFocused = true;
    if (focus == 'O' && type == FluxType.oxygen) isFocused = true;

    final isHighlighted = _isSelected || isFocused;
    final center = Offset(size.x / 2, size.y / 2);
    final drawSize = isHighlighted ? 12.0 : 8.0;

    // Outer glow
    canvas.drawCircle(
      center,
      drawSize * 1.5,
      Paint()
        ..color = color.withValues(alpha: isHighlighted ? 0.4 : 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    if (type == FluxType.energy) {
      // Energy is a diamond
      final diamond = Path()
        ..moveTo(center.dx, center.dy - drawSize)
        ..lineTo(center.dx + drawSize * 0.8, center.dy)
        ..lineTo(center.dx, center.dy + drawSize)
        ..lineTo(center.dx - drawSize * 0.8, center.dy)
        ..close();
      canvas.drawPath(diamond, Paint()..color = color);
      // Shine highlight for energy
      canvas.drawLine(Offset(center.dx - 2, center.dy - 2), Offset(center.dx + 2, center.dy + 2), Paint()..color = Colors.white.withValues(alpha: 0.5)..strokeWidth = 2);
    } else if (type == FluxType.leaching) {
      // Leaching is a downward arrow
      final arrow = Path()
        ..moveTo(center.dx - drawSize * 0.5, center.dy - drawSize * 0.5)
        ..lineTo(center.dx + drawSize * 0.5, center.dy - drawSize * 0.5)
        ..lineTo(center.dx, center.dy + drawSize * 0.8)
        ..close();
      canvas.drawPath(arrow, Paint()..color = color);
    } else {
      // Default: Shaded Circle
      final radius = drawSize * 0.7;
      // Shadow
      canvas.drawCircle(center + const Offset(1, 1), radius, Paint()..color = Colors.black.withValues(alpha: 0.2));
      // Main Body
      canvas.drawCircle(center, radius, Paint()..color = color);
      // Shading highlight
      canvas.drawCircle(center - Offset(radius * 0.3, radius * 0.3), radius * 0.3, Paint()..color = Colors.white.withValues(alpha: 0.4));
      
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }

    if (isHighlighted) {
      final ringPulse = 1.0 + 0.15 * math.sin(_selectionPulse * 8);
      canvas.drawCircle(
        center,
        drawSize * 2.0 * ringPulse,
        Paint()
          ..color = color.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!(game.simulationState?.isRunning ?? false)) return;
    _selectionPulse += dt;

    if (path.isEmpty) {
      removeFromParent();
      return;
    }

    // If it's a single point path, just remove it or stay there
    if (path.length < 2) {
      removeFromParent();
      return;
    }

    _progress += (speed * dt) / _pathLength();
    if (_progress >= 1.0) {
      removeFromParent();
      return;
    }
    position = _getPositionAt(_progress);
  }

  double _pathLength() {
    double length = 0;
    for (int i = 0; i < path.length - 1; i++) {
      length += path[i].distanceTo(path[i + 1]);
    }
    return length.clamp(1.0, double.infinity);
  }

  Vector2 _getPositionAt(double t) {
    if (t <= 0) return path.first;
    if (t >= 1) return path.last;
    double totalLen = _pathLength();
    double targetLen = t * totalLen;
    double currentLen = 0;
    for (int i = 0; i < path.length - 1; i++) {
      double segmentLen = path[i].distanceTo(path[i + 1]);
      if (currentLen + segmentLen >= targetLen) {
        double segmentT = (targetLen - currentLen) / segmentLen;
        return path[i] + (path[i + 1] - path[i]) * segmentT;
      }
      currentLen += segmentLen;
    }
    return path.last;
  }

  @override
  void onTapUp(TapUpEvent event) {
    _isSelected = true;
    _showFluxInfo(pinned: true);
    event.handled = true;
  }

  @override
  void onHoverEnter() {
    final currentInfo = game.ref.read(uIStateProvider);
    if (currentInfo == null || !currentInfo.isPinned) {
      _isSelected = true;
      _showFluxInfo(pinned: false);
    }
  }

  @override
  void onHoverExit() {
    _isSelected = false;
    final currentInfo = game.ref.read(uIStateProvider);
    if (currentInfo == null || !currentInfo.isPinned) {
      game.ref.read(uIStateProvider.notifier).setHoverInfo(null);
    }
  }

  void _showFluxInfo({bool pinned = false}) {
    final info = _getFluxTypeInfo();

    game.ref
        .read(uIStateProvider.notifier)
        .setHoverInfo(
          HoverInfo(
            title: info['title'] as String,
            description: info['description'] as String,
            stats: info['stats'] as Map<String, String>,
            isPinned: pinned,
            legends: info['legends'] as List<LegendItem>?,
          ),
        );
  }

  Map<String, dynamic> _getFluxTypeInfo() {
    final l = game.l10n;
    switch (type) {
      case FluxType.energy:
        return {
          'title':
              '☀️ ${l.energy.toUpperCase()} → ${l.photosynthesis.toUpperCase()}',
          'description': l.sunIndicatorDesc,
          'stats': {
            l.process: l.photosynthesis,
            l.source: l.atmosphere,
            l.productLabel: 'ATP / NADPH',
          },
        };

      case FluxType.water:
        return {
          'title': '💧 ${l.transpiration.toUpperCase()}',
          'description': l.waterUptakeDesc,
          'stats': {
            l.process: 'SPAC',
            l.routeLabel: l.xylemLabel,
            l.forceLabel: l.transpirationSuction,
          },
        };

      case FluxType.carbon:
        return {
          'title':
              '🍂 ${l.organicCarbon.toUpperCase()} ${l.fluxLabel.toUpperCase()}',
          'description': l.carbonCycleDesc,
          'stats': {
            l.routeLabel: l.phloemLabel,
            l.directionLabel: l.sugarsDown,
            l.significance: l.microbialEnergySource,
          },
        };

      case FluxType.nitrogen:
        return {
          'title':
              '🌿 ${l.nitrogenTitle.toUpperCase()} ${l.uptakeLabel.toUpperCase()}',
          'description': l.nitrogenUptakeDesc,
          'stats': {
            l.reactant: 'NO₃⁻ / NH₄⁺',
            l.role: l.macronutrient,
            l.risk: l.leachingTitle,
          },
        };

      case FluxType.phosphorus:
        return {
          'title':
              '🍊 ${l.phosphorusTitle.toUpperCase()} ${l.fluxLabel.toUpperCase()}',
          'description': l.phosphorusUptakeDesc,
          'stats': {
            l.helper: l.mycorrhizae,
            l.mobility: l.veryWeak,
            l.role: 'ATP / DNA',
          },
        };

      case FluxType.leaching:
        return {
          'title': '⚠️ ${l.leachingTitle.toUpperCase()}',
          'description': l.leachingDesc,
          'stats': {
            l.trigger: l.heavyRainTrigger,
            l.consequence: l.nutrientLossConsequence,
            l.risk: l.groundwaterContamination,
          },
        };

      case FluxType.oxygen:
        return {
          'title':
              '💨 ${l.oxygenTitle.toUpperCase()} ${l.diffusionTitle.toUpperCase()}',
          'description': l.oxygenDiffusionDesc,
          'stats': {
            l.mechanism: l.diffusionTitle,
            l.stateLabel: l.aerobicState,
            l.role: 'TEA',
          },
        };

      default:
        return {
          'title': type.toString().split('.').last.toUpperCase(),
          'description': l.biogeochemical,
          'stats': {l.speedLabel: '${speed.toStringAsFixed(0)} px/s'},
        };
    }
  }
}
