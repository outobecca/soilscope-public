import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide PointerMoveEvent;
import '../soil_scope_game.dart';
import '../../../providers/ui_state_provider.dart';

enum ProcessMarkerType {
  nitrification,
  mineralization,
  adsorption,
  denitrification,
}

class ProcessLabel extends PositionComponent
    with HasGameReference<SoilScopeGame>, TapCallbacks, HoverCallbacks {
  final ProcessMarkerType type;
  final Color color;
  final bool isStatic;
  final double lifeTime = 5.0;
  double _elapsed = 0;
  bool _isHovered = false;
  bool _isPinned = false;

  ProcessLabel({
    required this.type,
    required this.color,
    required Vector2 position,
    this.isStatic = false,
  }) : super(
          position: position,
          size: Vector2.all(36),
          anchor: Anchor.center,
          priority: 1600,
        );

  @override
  void update(double dt) {
    super.update(dt);
    if (!(game.simulationState?.isRunning ?? false)) return;
    if (!isStatic && !_isPinned) {
      _elapsed += dt;
      position.y -= 10 * dt;
    }
    if (!isStatic && _elapsed >= lifeTime && !_isPinned) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final double opacity = (isStatic || _isPinned)
        ? 1.0
        : (1.0 - _elapsed / lifeTime).clamp(0.0, 1.0);
    final isHighlighted = _isHovered || _isPinned;
    final center = Offset(size.x / 2, size.y / 2);

    // Core glow effect
    canvas.drawCircle(
      center,
      isHighlighted ? 16.0 : 12.0,
      Paint()
        ..color = color.withValues(
          alpha: (isHighlighted ? 0.4 : 0.25) * opacity,
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    final framePaint = Paint()
      ..color = color.withValues(alpha: (isHighlighted ? 1.0 : 0.8) * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isHighlighted ? 2.5 : 1.8;

    final fillPaint = Paint()
      ..color = const Color(0xFF0F172A).withValues(alpha: 0.9 * opacity)
      ..style = PaintingStyle.fill;

    // Draw the circular icon frame
    canvas.drawCircle(center, 11, fillPaint);
    canvas.drawCircle(center, 11, framePaint);

    _drawMarkerSymbol(canvas, center, framePaint, opacity);

    // Visual feedback for selection - no more floating text boxes here
    if (_isPinned) {
      canvas.drawCircle(
        center,
        14.5,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.4 * opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    _isPinned = !_isPinned;
    if (_isPinned) {
      _showProcessInfo(pinned: true);
    } else {
      game.ref.read(uIStateProvider.notifier).setHoverInfo(null);
    }
    event.handled = true;
  }

  @override
  void onHoverEnter() {
    _isHovered = true;
    final currentInfo = game.ref.read(uIStateProvider);
    if (currentInfo == null || !currentInfo.isPinned) {
      _showProcessInfo(pinned: false);
    }
  }

  @override
  void onHoverExit() {
    _isHovered = false;
    if (!_isPinned) {
      final currentInfo = game.ref.read(uIStateProvider);
      if (currentInfo == null || !currentInfo.isPinned) {
        game.ref.read(uIStateProvider.notifier).setHoverInfo(null);
      }
    }
  }

  void _showProcessInfo({bool pinned = false}) {
    final l = game.l10n;
    String description = l.biogeochemical;
    String title = l.process.toUpperCase();
    Map<String, String> stats = {l.type: l.process, l.stateLabel: l.active};

    switch (type) {
      case ProcessMarkerType.nitrification:
        title = l.nitrificationTitle.toUpperCase();
        description = l.nitrificationDesc;
        break;
      case ProcessMarkerType.mineralization:
        title = l.mineralizationTitle.toUpperCase();
        description = l.mineralizationDesc;
        break;
      case ProcessMarkerType.adsorption:
        title = l.adsorptionTitle.toUpperCase();
        description = l.adsorptionDesc;
        break;
      case ProcessMarkerType.denitrification:
        title = l.denitrification.toUpperCase();
        description = l.denitrificationDesc;
        break;
    }

    game.ref
        .read(uIStateProvider.notifier)
        .setHoverInfo(
          HoverInfo(
            title: title,
            description: description,
            stats: stats,
            isPinned: pinned,
          ),
        );
  }

  void _drawMarkerSymbol(
    Canvas canvas,
    Offset center,
    Paint framePaint,
    double opacity,
  ) {
    switch (type) {
      case ProcessMarkerType.nitrification:
        final drop = Path()
          ..moveTo(center.dx, center.dy - 5.5)
          ..quadraticBezierTo(
            center.dx - 4.2,
            center.dy - 1.2,
            center.dx,
            center.dy + 5.8,
          )
          ..quadraticBezierTo(
            center.dx + 4.2,
            center.dy - 1.2,
            center.dx,
            center.dy - 5.5,
          )
          ..close();
        canvas.drawPath(
          drop,
          Paint()
            ..color = color.withValues(alpha: 0.85 * opacity)
            ..style = PaintingStyle.fill,
        );
        break;
      case ProcessMarkerType.mineralization:
        final sparkPaint = Paint()
          ..color = color.withValues(alpha: 0.95 * opacity)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;
        canvas.drawLine(
          center + const Offset(-4, 0),
          center + const Offset(4, 0),
          sparkPaint,
        );
        canvas.drawLine(
          center + const Offset(0, -4),
          center + const Offset(0, 4),
          sparkPaint,
        );
        canvas.drawCircle(
          center,
          1.4,
          Paint()..color = Colors.white.withValues(alpha: opacity),
        );
        break;
      case ProcessMarkerType.adsorption:
        canvas.drawCircle(
          center,
          5.2,
          Paint()
            ..color = color.withValues(alpha: 0.9 * opacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.8,
        );
        canvas.drawCircle(
          center,
          1.7,
          Paint()..color = color.withValues(alpha: 0.95 * opacity),
        );
        break;
      case ProcessMarkerType.denitrification:
        final tri = Path()
          ..moveTo(center.dx - 4.8, center.dy - 3.8)
          ..lineTo(center.dx + 4.8, center.dy - 3.8)
          ..lineTo(center.dx, center.dy + 5.2)
          ..close();
        canvas.drawPath(
          tri,
          Paint()
            ..color = color.withValues(alpha: 0.9 * opacity)
            ..style = PaintingStyle.fill,
        );
        break;
    }

    if (_isPinned) {
      canvas.drawCircle(
        center,
        13.5,
        framePaint
          ..strokeWidth = 1.3
          ..color = Colors.white.withValues(alpha: 0.7 * opacity),
      );
    }
  }
}
