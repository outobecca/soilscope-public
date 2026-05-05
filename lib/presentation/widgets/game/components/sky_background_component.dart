import 'package:flame/components.dart';
import 'package:flutter/material.dart' hide Image;
import '../soil_scope_game.dart';

/// A screen-space background component that provides a dynamic sky gradient.
/// Added to the game root to ensure it covers the entire viewport regardless of camera state.
class SkyBackgroundComponent extends PositionComponent with HasGameReference<SoilScopeGame> {
  SkyBackgroundComponent() : super(priority: -1000);

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }

  @override
  void render(Canvas canvas) {
    final state = game.simulationState;
    // Fallback if state is null
    final sunIntensity = state != null ? (1.0 - (state.precipitation * 2.0).clamp(0.0, 1.0)) : 1.0;
    
    // 1. Sky Gradient (Screen Space)
    final skyRect = size.toRect();
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(const Color(0xFF0F172A), const Color(0xFF38BDF8), sunIntensity)!, // Slightly more vibrant
          Color.lerp(const Color(0xFF1E293B), const Color(0xFFBAE6FD), sunIntensity)!,
        ],
      ).createShader(skyRect);

    canvas.drawRect(skyRect, skyPaint);
  }
}

/// A screen-space background component that provides the base soil color.
/// Prevents "black gaps" below the soil layers when zooming out.
class SoilBasementComponent extends PositionComponent with HasGameReference<SoilScopeGame> {
  SoilBasementComponent() : super(priority: -950);

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }

  @override
  void render(Canvas canvas) {
    // We only want to fill the bottom part of the screen where soil resides.
    // Calculate the screen-space Y position of the soil surface.
    // Since this is in the game root, we can use the camera's worldToGlobal.
    final surfaceWorldY = game.soilSurfaceY;
    // Map world Y to viewport (screen) coordinates
    final surfaceGlobalPos = game.camera.viewfinder.zoom * (surfaceWorldY - game.camera.viewfinder.position.y) + (size.y / 2);
    
    final basementTop = surfaceGlobalPos.clamp(0.0, size.y);
    
    if (basementTop < size.y) {
      final basementRect = Rect.fromLTRB(0, basementTop, size.x, size.y);
      canvas.drawRect(
        basementRect, 
        Paint()..color = const Color(0xFF1A120B) // Deep earth brown
      );
    }
  }
}
