import 'package:flame/components.dart';
import '../soil_scope_game.dart';
import 'horizon_color_bands_component.dart';
import 'redox_gradient_component.dart';
import 'ph_gradient_component.dart';
import 'thermal_gradient_component.dart';
import 'soil_texture_pattern_component.dart';
import 'soil_evaporation_component.dart';
import 'diffusion_lines_component.dart';

/// Background layer for soil-specific visuals.
/// Consolidated to remove 'box' effects and ensure full-screen immersion.
class SoilBackgroundLayer extends Component
    with HasGameReference<SoilScopeGame> {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // 1. Core Backgrounds (Expanded to 16000px)
    add(HorizonColorBandsComponent()..priority = 1);
    add(RedoxGradientComponent()..priority = 2);
    add(PHGradientComponent()..priority = 3);
    add(ThermalGradientComponent()..priority = 4);
    add(SoilTexturePatternComponent()..priority = 5);
    
    // 2. Passive Simulation Overlays
    add(SoilEvaporationComponent()..priority = 6);
    add(DiffusionLinesComponent()..priority = 7);
  }
}
