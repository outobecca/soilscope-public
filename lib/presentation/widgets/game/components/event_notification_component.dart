import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../soil_scope_game.dart';

/// A component that shows temporary technical event notifications in the game world.
/// Used to provide immediate feedback for causal chain events (e.g. "PRIMING ACTIVATED").
class EventNotificationComponent extends PositionComponent
    with HasGameReference<SoilScopeGame> {
  final List<_EventMessage> _activeMessages = [];

  EventNotificationComponent() : super(priority: 200);

  /// Adds a new notification at the specified world position.
  void notify(
    String text,
    Vector2 position, {
    Color color = Colors.cyanAccent,
  }) {
    _activeMessages.add(
      _EventMessage(text: text, position: position.clone(), color: color),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    for (final msg in _activeMessages) {
      msg.update(dt);
    }
    _activeMessages.removeWhere((m) => m.isExpired);
  }

  @override
  void render(Canvas canvas) {
    for (final msg in _activeMessages) {
      final tp = TextPainter(
        text: TextSpan(
          text: msg.text.toUpperCase(),
          style: TextStyle(
            color: msg.color.withValues(alpha: msg.alpha),
            fontSize: 9,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            letterSpacing: 1.2,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      // Draw slightly above the target position, moving up
      final drawPos =
          msg.position.toOffset() +
          Offset(-tp.width / 2, -20 - msg.elapsed * 15);
      tp.paint(canvas, drawPos);
    }
  }
}

class _EventMessage {
  final String text;
  final Vector2 position;
  final Color color;
  double elapsed = 0;
  final double duration = 2.5;

  _EventMessage({
    required this.text,
    required this.position,
    required this.color,
  });

  void update(double dt) {
    elapsed += dt;
  }

  bool get isExpired => elapsed >= duration;
  double get alpha => (1.0 - (elapsed / duration)).clamp(0.0, 1.0);
}
