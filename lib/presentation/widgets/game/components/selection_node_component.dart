import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide PointerMoveEvent;
import '../soil_scope_game.dart';
import '../../../providers/ui_state_provider.dart';
import '../../../providers/simulation_session_provider.dart';

enum SelectionNodeType {
  atmosphere,
  soilLayer,
  enzymes,
}

/// A specialized selection node that provides a clear, non-overlapping click target
/// for large simulation areas like the atmosphere, soil layers, or biochemical processes.
class SelectionNodeComponent extends PositionComponent
    with HasGameReference<SoilScopeGame>, TapCallbacks, HoverCallbacks {
  final SelectionNodeType nodeType;
  final String? layerId;
  final String title;
  final String description;
  final Map<String, String>? Function()? statsProvider;
  final Color accentColor;
  final IconData icon;

  bool _isPinned = false;
  bool _isHovered = false;

  SelectionNodeComponent({
    required this.nodeType,
    required this.title,
    required this.description,
    required this.accentColor,
    required this.icon,
    this.layerId,
    this.statsProvider,
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2.all(44),
          anchor: Anchor.center,
          priority: 2000, // Always on top
        );

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    final time = game.uiTime();
    final zoom = game.camera.viewfinder.zoom;
    
    // 1. Outer Glow
    final glowAlpha = _isHovered ? 0.3 : 0.15;
    canvas.drawCircle(
      center,
      20 * (_isHovered ? 1.2 : 1.0),
      Paint()
        ..color = accentColor.withValues(alpha: glowAlpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // 2. Glassmorphic Background
    final bgPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 18, bgPaint);
    
    canvas.drawCircle(
      center,
      18,
      Paint()
        ..color = accentColor.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 / zoom,
    );

    // 3. Icon
    final iconColor = _isHovered || _isPinned ? accentColor : Colors.white.withValues(alpha: 0.9);
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: 20,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: iconColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(canvas, center - Offset(iconPainter.width / 2, iconPainter.height / 2));

    // 4. Subtle rotation pulse for enzymes
    if (nodeType == SelectionNodeType.enzymes) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(time * 0.5);
      final ringPaint = Paint()
        ..color = accentColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;
      
      for (int i = 0; i < 4; i++) {
        canvas.drawArc(
          Rect.fromCircle(center: Offset.zero, radius: 22),
          i * math.pi / 2,
          math.pi / 4,
          false,
          ringPaint,
        );
      }
      canvas.restore();
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    _isPinned = !_isPinned;
    _handleSelection();
    _showInfo(pinned: _isPinned);
    event.handled = true;
  }

  void _handleSelection() {
    if (nodeType == SelectionNodeType.atmosphere) {
      game.ref.read(simulationSessionProvider.notifier).selectLayer("atmosphere");
    } else if (nodeType == SelectionNodeType.soilLayer && layerId != null) {
      game.ref.read(simulationSessionProvider.notifier).selectLayer(layerId!);
    }
  }

  @override
  void onHoverEnter() {
    _isHovered = true;
    final current = game.ref.read(uIStateProvider);
    if (current == null || !current.isPinned) {
      _showInfo(pinned: false);
    }
  }

  @override
  void onHoverExit() {
    _isHovered = false;
    if (!_isPinned) {
      game.ref.read(uIStateProvider.notifier).setHoverInfo(null);
    }
  }

  void _showInfo({bool pinned = false}) {
    final stats = statsProvider?.call();
    game.ref.read(uIStateProvider.notifier).setHoverInfo(
      HoverInfo(
        title: title,
        description: description,
        stats: stats,
        isPinned: pinned,
        accentColor: accentColor,
        screenPosition: game.worldToScreen(absolutePosition).toOffset(),
      ),
    );
  }
}
