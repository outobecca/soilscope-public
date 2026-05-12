import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide PointerMoveEvent;
import '../soil_scope_game.dart';
import '../../../providers/ui_state_provider.dart';
import '../../../providers/simulation_session_provider.dart';
import '../../../../core/cpk_standards.dart';
import 'molecule_particle_component.dart';

enum FluxType { co2Uptake, h2oTranspiration, co2Emission, o2Diffusion, n2oEmission }

/// Interactive indicator for atmospheric gas and water fluxes.
class AtmosphericFluxIndicator extends PositionComponent
    with HasGameReference<SoilScopeGame>, TapCallbacks, HoverCallbacks {
  final FluxType type;
  final Offset? startOffset;
  final Offset? endOffset;
  final bool isCurved;
  final double fluxValue;
  
  bool _isPinned = false;
  double _emissionTimer = 0.0;

  AtmosphericFluxIndicator({
    required Vector2 position,
    required this.type,
    this.startOffset,
    this.endOffset,
    this.isCurved = false,
    this.fluxValue = 0.5,
    required Vector2 size,
  }) : super(position: position, size: size, anchor: Anchor.center, priority: 300);

  @override
  void update(double dt) {
    super.update(dt);
    if (!(game.simulationState?.isRunning ?? false)) return;
    if (fluxValue <= 0.01) return;

    // Emit particles along the curve or arrow
    _emissionTimer += dt;
    final double interval = (0.8 / fluxValue).clamp(0.2, 5.0); // Frequency based on flux
    
    if (_emissionTimer > interval) {
       _emissionTimer = 0;
       _spawnFluxParticle();
    }
  }

  void _spawnFluxParticle() {
    if (!isCurved || startOffset == null || endOffset == null) return;
    
    final worldStart = position.toOffset() + startOffset!;
    final worldEnd = position.toOffset() + endOffset!;
    
    final molType = _getMoleculeType();
    if (molType == null) return;

    // Velocity influenced by flux and direction
    final direction = (worldEnd - worldStart);
    final unitDir = Vector2(direction.dx, direction.dy).normalized();
    // Atmospheric dynamics: Gases should float upwards with breezy wispiness
    final isRising = type != FluxType.co2Uptake && type != FluxType.o2Diffusion;
    
    // Generate an organic "wisp" path
    final List<Vector2> wispPath = [];
    final normal = Vector2(-(worldEnd.dy - worldStart.dy), worldEnd.dx - worldStart.dx).normalized();
    final drift = (math.Random().nextDouble() - 0.5) * 120.0;
    
    final speed = (40.0 + fluxValue * 50.0).clamp(30.0, 150.0);
    final cp1 = Vector2(worldStart.dx, worldStart.dy) + unitDir * (direction.distance * 0.3) + normal * drift;
    final cp2 = Vector2(worldStart.dx, worldStart.dy) + unitDir * (direction.distance * 0.7) - normal * drift;
    
    // Discrete cubic bezier for the particle to follow
    for (double t = 0.1; t <= 1.0; t += 0.2) {
      final invT = 1.0 - t;
      final pos = Vector2(
        invT * invT * invT * worldStart.dx + 3 * invT * invT * t * cp1.x + 3 * invT * t * t * cp2.x + t * t * t * worldEnd.dx,
        invT * invT * invT * worldStart.dy + 3 * invT * invT * t * cp1.y + 3 * invT * t * t * cp2.y + t * t * t * worldEnd.dy,
      );
      wispPath.add(pos);
    }
    
    // Extra vertical drift for emissions
    if (isRising) {
       wispPath.add(Vector2(worldEnd.dx + (math.Random().nextDouble() - 0.5) * 100, worldEnd.dy - 200));
    }

    game.moleculePool?.spawn(
      position: Vector2(worldStart.dx, worldStart.dy),
      type: molType,
      velocity: unitDir * speed,
      path: wispPath,
      opacity: (0.3 + fluxValue * 0.5).clamp(0.2, 0.8),
      lifeTime: isRising ? 10.0 : 6.0, 
      isInteractionEnabled: false,
      seed: math.Random().nextInt(1000),
    );
  }

  MoleculeType? _getMoleculeType() {
     switch (type) {
       case FluxType.co2Uptake: return MoleculeType.co2;
       case FluxType.co2Emission: return MoleculeType.co2;
       case FluxType.h2oTranspiration: return MoleculeType.waterVapor;
       case FluxType.o2Diffusion: return MoleculeType.oxygen;
       case FluxType.n2oEmission: return MoleculeType.nitrousOxide;
     }
  }

  @override
  void render(Canvas canvas) {
    final time = game.currentTime();
    final zoom = game.camera.viewfinder.zoom;
    final color = _getColor();

    // Element Highlighting Logic
    final session = game.ref.read(simulationSessionProvider);
    final highlightedSymbol = session.selectedElementSymbol;
    bool isElementHighlighted = false;
    if (highlightedSymbol != null && highlightedSymbol.isNotEmpty) {
      if (highlightedSymbol == 'C') {
        isElementHighlighted = type == FluxType.co2Uptake || type == FluxType.co2Emission;
      } else if (highlightedSymbol == 'H') {
        isElementHighlighted = type == FluxType.h2oTranspiration;
      } else if (highlightedSymbol == 'O') {
        isElementHighlighted = true; // All fluxes contain O
      }
    }

    canvas.save();
    try {
      if (isElementHighlighted) {
        final pulse = 0.5 + 0.5 * math.sin(game.currentTime() * 8);
        final highlightPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.6 * pulse)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0 / zoom
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        
        if (!isCurved) {
          canvas.drawCircle(Offset.zero, 30 / zoom, highlightPaint);
        }
      }

      if (isCurved && startOffset != null && endOffset != null) {
        _drawCurvedFlux(canvas, startOffset!, endOffset!, color, time, zoom);
      } else {
        _drawFluxArrow(
          canvas,
          Offset.zero,
          type == FluxType.o2Diffusion,
          color,
          time,
          zoom,
        );
      }
    } catch (e) {
      // Robustness
    }

    canvas.restore();
  }

  Color _getColor() {
    switch (type) {
      case FluxType.co2Uptake:
      case FluxType.co2Emission:
        return const Color(0xFFEC4899);
      case FluxType.h2oTranspiration:
        return const Color(0xFF22D3EE);
      case FluxType.o2Diffusion:
        return const Color(0xFF4FC3F7);
      case FluxType.n2oEmission:
        return const Color(0xFFA855F7); // Purple/Violet for N2O
    }
  }

  void _drawCurvedFlux(
    Canvas canvas,
    Offset start,
    Offset end,
    Color color,
    double time,
    double zoom,
  ) {
    final midX = (start.dx + end.dx) / 2;
    final midY = (start.dy + end.dy) / 2;
    final perpX = -(end.dy - start.dy) * 0.3;
    final perpY = (end.dx - start.dx) * 0.3;
    final controlPoint = Offset(midX + perpX, midY + perpY);

    // Fade the path itself if flux is low
    final double pathOpacity = (0.2 + fluxValue).clamp(0.1, 0.6);
    final paint = Paint()
      ..color = color.withValues(alpha: pathOpacity)
      ..strokeWidth = 1.5 / zoom
      ..style = PaintingStyle.stroke;

    final dashOffset = time * 35;
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(controlPoint.dx, controlPoint.dy, end.dx, end.dy);

    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final pathMetrics = metrics.first;
    final pathLength = pathMetrics.length;
    if (pathLength <= 0) return;

    const dashWidth = 10.0;
    const dashSpace = 12.0;
    double currentDist = dashOffset % (dashWidth + dashSpace);

    while (currentDist < pathLength) {
      final startDist = currentDist.clamp(0.0, pathLength);
      final endDist = (currentDist + dashWidth).clamp(0.0, pathLength);
      if (endDist > startDist) {
        // Comet effect: vary opacity along the path
        final double distFactor = (currentDist / pathLength).clamp(0.2, 1.0);
        paint.color = color.withValues(alpha: pathOpacity * distFactor);
        canvas.drawPath(pathMetrics.extractPath(startDist, endDist), paint);
      }
      currentDist += dashWidth + dashSpace;
    }

    // Arrow head
    if (pathLength > 1) {
      final tangent = pathMetrics.getTangentForOffset(pathLength - 1);
      if (tangent != null) {
        final angle = math.atan2(tangent.vector.dy, tangent.vector.dx);
        canvas.save();
        canvas.translate(end.dx, end.dy);
        canvas.rotate(angle);
        canvas.drawPath(
          Path()
            ..moveTo(0, 0)
            ..lineTo(-7 / zoom, -3.5 / zoom)
            ..lineTo(-7 / zoom, 3.5 / zoom)
            ..close(),
          Paint()..color = color.withValues(alpha: 0.8 * pathOpacity),
        );
        canvas.restore();
      }
    }
  }

  void _drawFluxArrow(
    Canvas canvas,
    Offset pos,
    bool pointingDown,
    Color color,
    double time,
    double zoom,
  ) {
    final float = math.sin(time * 2.5) * 4;
    final y = pos.dy + float;

    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final path = Path();
    if (pointingDown) {
      path.moveTo(0, y + 25 / zoom);
      path.lineTo(-6 / zoom, y + 16 / zoom);
      path.lineTo(-2 / zoom, y + 16 / zoom);
      path.lineTo(-2 / zoom, y);
      path.lineTo(2 / zoom, y);
      path.lineTo(2 / zoom, y + 16 / zoom);
      path.lineTo(6 / zoom, y + 16 / zoom);
      path.close();
    } else {
      path.moveTo(0, y);
      path.lineTo(-6 / zoom, y + 9 / zoom);
      path.lineTo(-2 / zoom, y + 9 / zoom);
      path.lineTo(-2 / zoom, y + 25 / zoom);
      path.lineTo(2 / zoom, y + 25 / zoom);
      path.lineTo(2 / zoom, y + 9 / zoom);
      path.lineTo(6 / zoom, y + 9 / zoom);
      path.close();
    }
    canvas.drawPath(path, paint);

    // Trailing flow particles
    for (int i = 0; i < 3; i++) {
      final pPhase = (time * 1.5 + i * 0.3) % 1.0;
      final pOffset = pointingDown ? -pPhase * 30 : pPhase * 30;
      final pAlpha = (1.0 - pPhase) * 0.4;
      canvas.drawCircle(
        Offset(0, y + pOffset),
        1.5 / zoom,
        Paint()..color = color.withValues(alpha: pAlpha),
      );
    }
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    if (isCurved && startOffset != null && endOffset != null) {
      // Create a rect that encompasses the curve
      final rect = Rect.fromPoints(startOffset!, endOffset!).inflate(15);
      return rect.contains(point.toOffset());
    }
    return point.length < 15.0;
  }

  @override
  void onTapUp(TapUpEvent event) {
    _isPinned = !_isPinned;
    _showInfo(pinned: _isPinned);
    event.handled = true;
  }

  @override
  void onHoverEnter() {
    final current = game.ref.read(uIStateProvider);
    if (current == null || !current.isPinned) _showInfo(pinned: false);
  }

  @override
  void onHoverExit() {
    if (!_isPinned) game.ref.read(uIStateProvider.notifier).setHoverInfo(null);
  }

  void _showInfo({bool pinned = false}) {
    final l = game.l10n;
    String title = "";
    String desc = "";
    Map<String, String> stats = {};
    String? symbol;
    Color? accent;

    switch (type) {
      case FluxType.co2Uptake:
        title = l.co2UptakeTitle;
        desc = l.photosynthesis;
        stats = {l.source: l.atmosphere, l.productLabel: l.sugarCompound};
        symbol = 'C';
        accent = CPKStandards.colorC;
        break;
      case FluxType.h2oTranspiration:
        title = l.transpiration.toUpperCase();
        desc = l.transpirationDesc;
        stats = {l.source: l.root, l.driverLabel: l.vpdLabel};
        symbol = 'O'; // Focus on Oxygen in H2O
        accent = Colors.blueAccent;
        break;
      case FluxType.co2Emission:
        title = l.soilRespiration.toUpperCase();
        desc = l.bubbleCo2Description;
        stats = {l.source: l.microbes, l.processLabel: l.aerobicRespiration};
        symbol = 'C';
        accent = CPKStandards.colorC;
        break;
      case FluxType.o2Diffusion:
        title = l.o2DiffusionTitle;
        desc = l.oxygenDiffusionDesc;
        stats = {l.directionLabel: l.intoRoot, l.importance: l.aerobicState};
        symbol = 'O';
        accent = CPKStandards.colorO;
        break;
      case FluxType.n2oEmission:
        title = l.n2oEmissionTitle;
        desc = l.nitrogenLossDenit;
        stats = {l.source: l.subsoilHorizon, l.riskLabel: l.greenhouseGas};
        symbol = 'N';
        accent = CPKStandards.colorN;
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
            accentColor: accent,
            elementSymbol: symbol,
            screenPosition: game.worldToScreen(absolutePosition).toOffset(),
          ),
        );
  }
}
