import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../soil_scope_game.dart';
import '../../../../domain/models/biophysical_state.dart';
import 'biological_entities_component.dart';
import 'scientific_overlays_component.dart';
import 'sun_indicator_component.dart';
import 'biochemical_dynamics_component.dart';
import 'particle_system_component.dart';
import 'cover_crop_component.dart';
import 'wetting_front_component.dart';
import 'capillary_rise_component.dart';
import 'spac_connection_lines_component.dart';
import 'atmospheric_flux_layer_component.dart';
import 'inspection_target_layer_component.dart';
import 'molecule_particle_pool.dart';
import 'water_flow_paths_component.dart';
import 'enzyme_activity_component.dart';
import 'photosynthesis_indicator_component.dart';
import 'nitrous_oxide_bubble_component.dart';

/// Layer for the main simulation animations (plant, roots, organisms).
/// Contains high-fidelity biological and technical visual entities.
///
/// Priority: 10
class SimulationAnimationLayerComponent extends Component
    with HasGameReference<SoilScopeGame> {
  BiologicalEntitiesComponent? _biologicalEntities;
  AtmosphericFluxLayerComponent? _atmosphericFluxLayer;
  InspectionTargetLayerComponent? _inspectionTargetLayer;
  MoleculeParticlePool? _moleculePool;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    _moleculePool = MoleculeParticlePool(maxParticles: 50);
    add(_moleculePool!);
    game.moleculePool = _moleculePool;

    _biologicalEntities = BiologicalEntitiesComponent();
    add(_biologicalEntities!);

    _atmosphericFluxLayer = AtmosphericFluxLayerComponent();
    add(_atmosphericFluxLayer!);

    _inspectionTargetLayer = InspectionTargetLayerComponent();
    add(_inspectionTargetLayer!);

    try {
      _biologicalEntities?.priority = 100;

      // Phase 1: Visual Foundation (Handled by SoilBackgroundLayer)

      // Phase 3: Gradients (Handled by SoilBackgroundLayer)

      add(MolecularParticleFieldComponent()..priority = 200);
      add(BiochemicalDynamicsComponent()..priority = 12);
      add(CoverCropComponent()..priority = 12);
      add(EnzymeActivityComponent()); // Metabolic ripples
      add(WaterFlowPathsComponent()); // Xylem & Bypass flow
      add(SPACConnectionLinesComponent()..priority = 150);
      add(PhotosynthesisIndicatorComponent()); // Light rays & CO2 uptake
      add(NitrousOxideBubbleComponent()); // Anaerobic gas emission
      add(SunIndicatorComponent()..priority = 40);
      
      // Hydrology (Visible above texture)
      add(WettingFrontComponent()..priority = 50);
      add(CapillaryRiseComponent()..priority = 51);

      // DATA & DIAGNOSTICS (Must always be on top)
      // These components have internal priorities set to 1000+
      add(ScientificOverlaysComponent());
    } catch (e) {
      debugPrint("Error loading SimulationAnimationLayer: $e");
    }
  }

  void updateState(BiophysicalState state) {
    _atmosphericFluxLayer?.updateState(state);
    _biologicalEntities?.updateState(state);
    _inspectionTargetLayer?.updateState(state);
  }

  void triggerPlantGrowth() {
    _biologicalEntities?.triggerPlantGrowth();
  }
}
