import '../../core/simulation_constants.dart';
import '../models/biophysical_state.dart';
import '../models/soil_layer.dart';
import '../models/plant.dart';
import 'hydrology_solver.dart';
import 'chemistry_solver.dart';
import 'aggregation_solver.dart';
import 'plant_solver.dart';
import 'energy_solver.dart';
import 'nutrient_solver.dart';
import 'gas_solver.dart';
import 'package:flutter/foundation.dart';
import 'scoring_solver.dart';
import 'microbial_enzymes_solver.dart';
import 'mycorrhiza_solver.dart';
import 'nutrient_buffer.dart';

class SimulationEngine {
  static bool _validateBiophysicalState(BiophysicalState state) {
    // Check layers
    for (final layer in state.profile.layers) {
      if ([
        layer.temperature,
        layer.waterContent,
        layer.ph,
        layer.ec,
        layer.oxygenContent,
        layer.co2Content,
      ].any((v) => v.isNaN || v.isInfinite)) {
        debugPrint('[SimulationEngine] Layer validation failed: $layer');
        return false;
      }
    }

    // Check plants
    for (final plant in state.plants) {
      if ([
        plant.height,
        plant.lai,
        plant.turgorPressure,
        plant.nitrogenUptake,
        plant.waterUptake,
      ].any((v) => v.isNaN || v.isInfinite)) {
        debugPrint('[SimulationEngine] Plant validation failed: $plant');
        return false;
      }
    }

    // Check mycorrhiza
    if (state.mycorrhizaState != null) {
      final ms = state.mycorrhizaState!;
      if ([ms.rootColonization, ms.totalHyphalLength, ms.fungalBiomass]
          .any((v) => v.isNaN || v.isInfinite)) {
        debugPrint('[SimulationEngine] Mycorrhiza state validation failed');
        return false;
      }
    }

    return true;
  }

  static BiophysicalState _sanitizeState(BiophysicalState state) {
    final layers = state.profile.layers.map((l) {
      return l.copyWith(
        temperature: l.temperature.isNaN || l.temperature.isInfinite ? 293.15 : l.temperature,
        waterContent: l.waterContent.isNaN || l.waterContent.isInfinite ? l.porosity * 0.5 : l.waterContent,
        ph: l.ph.isNaN || l.ph.isInfinite ? 7.0 : l.ph,
        ec: l.ec.isNaN || l.ec.isInfinite ? 0.5 : l.ec,
        oxygenContent: l.oxygenContent.isNaN || l.oxygenContent.isInfinite ? 5.0 : l.oxygenContent,
        co2Content: l.co2Content.isNaN || l.co2Content.isInfinite ? 0.1 : l.co2Content,
      );
    }).toList();

    final plants = state.plants.map((p) {
      return p.copyWith(
        height: p.height.isNaN || p.height.isInfinite ? 0.1 : p.height,
        lai: p.lai.isNaN || p.lai.isInfinite ? 0.1 : p.lai,
        turgorPressure: p.turgorPressure.isNaN || p.turgorPressure.isInfinite ? 0.8 : p.turgorPressure,
        nitrogenUptake: p.nitrogenUptake.isNaN || p.nitrogenUptake.isInfinite ? 0.0 : p.nitrogenUptake,
        waterUptake: p.waterUptake.isNaN || p.waterUptake.isInfinite ? 0.0 : p.waterUptake,
      );
    }).toList();

    return state.copyWith(
      profile: state.profile.copyWith(layers: layers),
      plants: plants,
    );
  }

  /// Runs a single time step (dt) of the entire biophysical model.
  /// Iterates through all plants in the collection.
  static BiophysicalState tick(
    BiophysicalState state,
    double dt, {
    double precipitation = 0.0,
  }) {
    if (state.profile.layers.isEmpty) {
      throw ArgumentError('Profile must have at least one layer');
    }
    if (dt <= 0) {
      throw ArgumentError('Time step must be positive');
    }
    if (state.profile.layers.any((l) => l.thickness <= 0)) {
      throw ArgumentError('All layers must have positive thickness');
    }

    int totalSteps = (dt / SimulationConstants.maxSubStep).ceil().clamp(1, SimulationConstants.maxSubStepsPerTick);
    double stepDt = dt / totalSteps;

    BiophysicalState currentState = state;

    for (int step = 0; step < totalSteps; step++) {
      currentState = _integrateStep(
        currentState,
        stepDt,
        precipitation: step == 0 ? precipitation : 0.0,
      );

      // Validate after each step
      if (!_validateBiophysicalState(currentState)) {
        debugPrint('[SimulationEngine] WARNING: Invalid state at step $step, sanitizing...');
        currentState = _sanitizeState(currentState);
      }
    }

    final newScore = ScoringSolver.solve(currentState, dt);

    final result = currentState.copyWith(score: newScore);
    if (!_validateBiophysicalState(result)) {
      debugPrint('[SimulationEngine] ERROR: Final state invalid, returning previous state');
      return state;
    }

    return result;
  }

  static BiophysicalState _integrateStep(
    BiophysicalState state,
    double dt, {
    double precipitation = 0.0,
  }) {
    // 1. Hydrology (Richards Eq with combined plant transpiration)
    final hydroResult = HydrologySolver.solve(
      state.profile,
      dt,
      precipitation: precipitation,
      plants: state.plants,
    );
    var updatedProfile = hydroResult.profile;

    final layersWithFlux = List<SoilLayer>.from(updatedProfile.layers);
    for (int i = 0; i < layersWithFlux.length; i++) {
      final topFlux = hydroResult.averageFluxes[i];
      final bottomFlux = hydroResult.averageFluxes[i + 1];
      layersWithFlux[i] = layersWithFlux[i].copyWith(
        verticalFlux: (topFlux + bottomFlux) / 2.0,
      );
    }
    updatedProfile = updatedProfile.copyWith(layers: layersWithFlux);

    // 2. Energy balance (Stefan-Boltzmann with combined canopy shading)
    updatedProfile = EnergySolver.solve(
      updatedProfile,
      dt,
      state.timeElapsed,
      airTemperature: state.airTemperature,
      latentHeat: hydroResult.latentHeat,
      plants: state.plants,
      solarRadiation: state.solarRadiation,
    );

    // 3. Soil Atmosphere (O2/CO2 Diffusion & Combined Root Respiration)
    updatedProfile = GasSolver.solve(
      updatedProfile,
      dt,
      plants: state.plants,
      atmCO2: state.atmCO2,
    );

    // 4. Chemistry (Redox, pH) - Done before N-cycle and Microbial to establish redox potential
    updatedProfile = ChemistrySolver.solve(updatedProfile, dt);

    // 5. Nutrients (Diffusion, Advection, N-Cycle)
    updatedProfile = NutrientSolver.solve(
      updatedProfile,
      dt,
      waterFluxes: hydroResult.averageFluxes,
    );

    // 5.5 Microbial Enzymes
    updatedProfile = MicrobialEnzymesSolver.solve(updatedProfile, dt);

    // 6. Bio-Aggregation (Combined rhizosphere effects)
    updatedProfile = AggregationSolver.solve(
      updatedProfile,
      dt,
      plants: state.plants,
      hasCoverCrop: state.hasCoverCrop,
      precipitation: precipitation,
    );

    // 7. Individual Plant Growth (Solve for each plant in the collection)
    final List<Plant> updatedPlants = [];
    for (final plant in state.plants) {
      updatedPlants.add(
        PlantSolver.solve(
          plant,
          updatedProfile,
          dt,
          airTemperature: state.airTemperature,
          atmCO2: state.atmCO2,
          relativeHumidity: state.relativeHumidity,
          solarRadiation: state.solarRadiation,
        ),
      );
    }

    // 7.5 Mycorrhiza Symbiosis (Coupled with all plants and cover crop)
    // Modular initialization: ensures state exists even if scenario doesn't provide it.
    var currentMycorrhizaState =
        state.mycorrhizaState ??
        MycorrhizaState.initial(updatedProfile.layers.length);

    // a) Actual Plants
    for (int pIdx = 0; pIdx < updatedPlants.length; pIdx++) {
      final plant = updatedPlants[pIdx];
      // Young or small plants have minimal mycorrhizal interaction
      if (plant.totalBiomass < 5.0) continue;

      final mycorrhizaResult = MycorrhizaSolver.solve(
        updatedProfile,
        plant,
        currentMycorrhizaState,
        dt,
        dailyPhotosynthate: plant.totalBiomass * 0.01,
      );
      
      updatedProfile = mycorrhizaResult.profile;
      updatedPlants[pIdx] = mycorrhizaResult.plant;
      currentMycorrhizaState = mycorrhizaResult.mycorrhizaState;
    }

    // b) Cover Crop (Virtual participant in the Wood Wide Web)
    if (state.hasCoverCrop) {
      // Create a virtual plant proxy for the cover crop
      final virtualCoverPlant = Plant(
        id: "cover_crop_proxy",
        species: "CoverCrop",
        age: 30.0,
        height: 0.05,
        lai: 1.5, // High surface coverage
        turgorPressure: 0.8,
        nitrogenUptake: 0.0,
        waterUptake: 0.0,
        totalBiomass: 500.0,
        rootBiomass: 200.0,
        // Roots are distributed across top layers
        rootSystem: [
          const RootNode(x: 0.2, z: 0.05, radius: 0.001, isTip: true),
          const RootNode(x: 0.5, z: 0.10, radius: 0.001, isTip: true),
          const RootNode(x: 0.8, z: 0.05, radius: 0.001, isTip: true),
        ],
      );

      final mycorrhizaResult = MycorrhizaSolver.solve(
        updatedProfile,
        virtualCoverPlant,
        currentMycorrhizaState,
        dt,
        dailyPhotosynthate: virtualCoverPlant.totalBiomass * 0.005, // Lower C allocation than primary crop
      );
      
      updatedProfile = mycorrhizaResult.profile;
      // We don't save the virtual plant back, but its effects on the profile and state persist
      currentMycorrhizaState = mycorrhizaResult.mycorrhizaState;
    }

    final updatedMycorrhizaState = currentMycorrhizaState;

    // 8. Apply Plant-induced Sinks (Coupling all plants to soil layers)
    final coupledLayers = List<SoilLayer>.from(updatedProfile.layers);

    // First, aggregate sinks from all plants into a zero-allocation buffer
    final buffer = NutrientBuffer(coupledLayers.length);

    for (final plant in updatedPlants) {
      PlantSolver.accumulateSinks(
        plant,
        updatedProfile,
        buffer,
        airTemperature: state.airTemperature,
        relativeHumidity: state.relativeHumidity,
      );
    }

    // Then, apply aggregated sinks from the buffer
    for (int i = 0; i < coupledLayers.length; i++) {
      final l = coupledLayers[i];
      coupledLayers[i] = l.copyWith(
        nitrateContent: (l.nitrateContent - buffer.nitrate[i] * dt).clamp(0.0, 1000.0),
        ammoniumContent: (l.ammoniumContent - buffer.ammonium[i] * dt).clamp(0.0, 500.0),
        potassiumContent: (l.potassiumContent - buffer.potassium[i] * dt).clamp(0.0, 1000.0),
        phosphateContent: (l.phosphateContent - buffer.phosphate[i] * dt).clamp(0.0, 1000.0),
        solutionCalcium: (l.solutionCalcium - buffer.calcium[i] * dt).clamp(0.0, 10000.0),
        solutionMagnesium: (l.solutionMagnesium - buffer.magnesium[i] * dt).clamp(0.0, 5000.0),
        particulateOrganicMatter: (l.particulateOrganicMatter + buffer.carbonSource[i] * dt).clamp(0.0, 1000.0),
      );
    }

    updatedProfile = updatedProfile.copyWith(layers: coupledLayers);

    return state.copyWith(
      profile: updatedProfile,
      plants: updatedPlants,
      timeElapsed: state.timeElapsed + dt,
      precipitation: precipitation,
      soilEvaporation: hydroResult.actualEvaporation,
      mycorrhizaState: updatedMycorrhizaState,
    );
  }
}
