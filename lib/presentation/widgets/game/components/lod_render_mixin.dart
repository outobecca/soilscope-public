import 'package:flame/components.dart';
import '../soil_scope_game.dart';

/// Centralizes Zoom Level of Detail (LOD) checks for game elements.
/// Helps optimize heavy physics rendering when zoomed far out.
mixin LODRenderMixin on HasGameReference<SoilScopeGame> {
  
  /// The current viewport zoom level.
  double get renderZoom => game.camera.viewfinder.zoom;

  /// Low level of detail: typically zoomed out far.
  bool get isLowLOD => renderZoom < 0.8;

  /// Mid level of detail: default inspection range.
  bool get isMidLOD => renderZoom >= 0.8 && renderZoom < 1.8;

  /// High level of detail: intense microscopic view.
  bool get isHighLOD => renderZoom >= 1.8;
}
