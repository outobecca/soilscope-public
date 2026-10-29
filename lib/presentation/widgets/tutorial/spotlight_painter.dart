import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../providers/tutorial_provider.dart';

class SpotlightPainter extends CustomPainter {
  final TutorialTargetArea target;
  final double animationProgress;
  final bool isMobile;
  final Color spotlightGlowColor;

  SpotlightPainter({
    required this.target,
    required this.animationProgress,
    required this.isMobile,
    this.spotlightGlowColor = const Color(0xFF10B981),
  });

  Rect? getTargetRect(Size size) {
    switch (target) {
      case TutorialTargetArea.welcome:
      case TutorialTargetArea.canvas:
        return null;

      case TutorialTargetArea.inspection:
        return Rect.fromCenter(
          center: Offset(size.width * 0.5, size.height * 0.56),
          width: 190,
          height: 190,
        );

      case TutorialTargetArea.dashboard:
        final btnWidth = isMobile ? 64.0 : 160.0;
        return Rect.fromLTWH(16, 16, btnWidth, 54);

      case TutorialTargetArea.controls:
        final btnWidth = isMobile ? 64.0 : 160.0;
        return Rect.fromLTWH(size.width - btnWidth - 16, 16, btnWidth, 54);

      case TutorialTargetArea.timeline:
        return Rect.fromCenter(
          center: Offset(size.width * 0.5, size.height - 150),
          width: math.min(size.width - 32, 700.0),
          height: 64,
        );

      case TutorialTargetArea.observation:
        return Rect.fromCenter(
          center: Offset(size.width * 0.5, size.height - 45),
          width: math.min(size.width - 24, 750.0),
          height: 64,
        );

      case TutorialTargetArea.gamification:
        return Rect.fromCenter(
          center: Offset(size.width * 0.5, 42),
          width: math.min(size.width - 160, 800.0),
          height: 60,
        );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final targetRect = getTargetRect(size);

    // Dark backdrop overlay
    final bgPaint = Paint()..color = Colors.black.withValues(alpha: 0.74);

    if (targetRect == null) {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
      return;
    }

    // Save layer to allow PorterDuff clear blending
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    // 1. Draw full dark screen
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Clear cut-out with rounded rect
    final rrect = RRect.fromRectAndRadius(
      targetRect.inflate(8),
      const Radius.circular(20),
    );

    final clearPaint = Paint()..blendMode = BlendMode.clear;
    canvas.drawRRect(rrect, clearPaint);

    canvas.restore();

    // 3. Draw animated glowing highlight borders around target
    final pulseScale = 1.0 + (math.sin(animationProgress * math.pi * 2) * 0.04);
    final borderRRect = RRect.fromRectAndRadius(
      targetRect.inflate(8 * pulseScale),
      const Radius.circular(20),
    );

    final glowPaint = Paint()
      ..color = spotlightGlowColor.withValues(alpha: 0.6 + 0.3 * math.sin(animationProgress * math.pi * 2))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 6);

    canvas.drawRRect(borderRRect, glowPaint);

    // Outer subtle ambient ring
    final ambientPaint = Paint()
      ..color = spotlightGlowColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(borderRRect.inflate(4), ambientPaint);

    // Target beacon pointer for specific interactive targets
    if (target == TutorialTargetArea.inspection ||
        target == TutorialTargetArea.dashboard ||
        target == TutorialTargetArea.controls) {
      _drawBeacon(canvas, targetRect.center, animationProgress);
    }
  }

  void _drawBeacon(Canvas canvas, Offset center, double progress) {
    final rippleRadius = 16.0 + (progress * 24.0);
    final rippleAlpha = (1.0 - progress).clamp(0.0, 1.0) * 0.5;

    final ripplePaint = Paint()
      ..color = spotlightGlowColor.withValues(alpha: rippleAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, rippleRadius, ripplePaint);

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 3.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant SpotlightPainter oldDelegate) {
    return oldDelegate.target != target ||
        oldDelegate.animationProgress != animationProgress ||
        oldDelegate.isMobile != isMobile ||
        oldDelegate.spotlightGlowColor != spotlightGlowColor;
  }
}
