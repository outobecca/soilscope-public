import 'dart:math' as math;
import '../models/soil_layer.dart';
import '../models/soil_profile.dart';
import '../models/plant.dart';
import 'nutrient_buffer.dart';
import 'plant/root_architecture_solver.dart';
import '../models/hydrology_result.dart';
import 'plant_solver.dart';
import '../../core/biophysics_utils.dart';
import '../../core/simulation_constants.dart';

class HydrologySolver {
  /// Solves 1D Richards equation flux between layers for a time step [dt]
  /// accounts for Bypass Flow, Hysteresis, Macro-porosity feedbacks and Evaporation.
  ///
  /// Integrates with multiple plants in the SPAC continuum.
  static HydrologyResult solve(
    SoilProfile profile,
    double dt, {
    double precipitation = 0.0,
    double airTemperature = 293.15,
    List<Plant> plants = const [],
  }) {
    // 1. Calculate Adaptive Sub-steps
    double minThickness = profile.layers.fold(
      1.0,
      (min, l) => math.min(min, l.thickness),
    );
    double maxKsat = profile.layers.fold(
      1e-9,
      (max, l) => math.max(max, l.kSat),
    );

    // Stability criteria for explicit diffusion: dt < 0.5 * dx^2 / K
    double safeDt = 0.25 * (minThickness * minThickness) / (maxKsat + 1e-10);
    double subStep = safeDt.clamp(0.1, 30.0);
    if (precipitation > 1e-4) {
      subStep = math.min(subStep, 1.0);
    }

    int steps = (dt / subStep).ceil().clamp(1, 2000);
    double actualDt = dt / steps;

    SoilProfile currentProfile = profile;
    final List<double> totalFluxes = List.filled(
      currentProfile.layers.length + 1,
      0.0,
    );

    // Bare Soil Evaporation
    final double airTempC = airTemperature - 273.15;
    final double potentialEvap = SimulationConstants.evapBaseRate * math.max(0.0, airTempC);
    final firstLayer = currentProfile.layers.first;
    final double surfaceRelativeSaturation =
        (firstLayer.waterContent / firstLayer.porosity).clamp(0.0, 1.0);
    final double actualEvap =
        potentialEvap * math.pow(surfaceRelativeSaturation, 2.0);

    // Aggregate sinks from all plants
    final List<double> aggregatedSinks = List.filled(
      currentProfile.layers.length,
      0.0,
    );
    for (final plant in plants) {
      final buffer = NutrientBuffer(currentProfile.layers.length);
      PlantSolver.accumulateSinks(
        plant,
        currentProfile,
        buffer,
        airTemperature: airTemperature,
      );
      // However, we need to add water tracking to NutrientBuffer,
      // or we can just calculate water sink directly here like PlantSolver does,
      // since water uptake velocity is `weight * actualTrans`.
      final (layerWeights, totalRootWeight) = RootArchitectureSolver.calculateLayerWeights(plant, currentProfile);
      final actualTrans = plant.actualTranspiration;
      if (totalRootWeight > 0 && actualTrans > 0) {
        for (int i = 0; i < currentProfile.layers.length; i++) {
          final weight = layerWeights[i] / totalRootWeight;
          final uptakeVelocity = weight * actualTrans;
          aggregatedSinks[i] += uptakeVelocity / currentProfile.layers[i].thickness;
        }
      }
    }

    for (int s = 0; s < steps; s++) {
      double stepPrecip = (precipitation * dt / steps) / actualDt;
      double stepEvap = (actualEvap * dt / steps) / actualDt;

      final topLayer = currentProfile.layers.first;
      final dzTop = topLayer.thickness / 2.0;
      final psiTop = BiophysicsUtils.thetaToPsi(
        topLayer.waterContent,
        topLayer.thetaR,
        topLayer.porosity,
        topLayer.vgAlpha,
        topLayer.vgN,
      );
      double infiltrationCapacity = topLayer.kSat * (1.0 - psiTop / dzTop);

      double matrixInfiltration = math.min(stepPrecip, infiltrationCapacity);
      double bypassInfiltration = math.max(
        0.0,
        stepPrecip - infiltrationCapacity,
      );

      final result = _solveStepWithFluxes(
        currentProfile,
        actualDt,
        surfaceFlux: matrixInfiltration - stepEvap,
        sinks: aggregatedSinks.map((sink) => sink / steps).toList(),
      );

      currentProfile = result.profile;

      if (bypassInfiltration > 0) {
        currentProfile = _applyBypass(
          currentProfile,
          bypassInfiltration * actualDt,
        );
      }

      for (int i = 0; i < totalFluxes.length; i++) {
        totalFluxes[i] += result.averageFluxes[i];
      }
    }

    return HydrologyResult(
      profile: currentProfile,
      averageFluxes: totalFluxes.map((f) => f / steps).toList(),
      latentHeat: actualEvap * 1000.0 * 2.45e6, // W/m^2
      actualEvaporation: actualEvap,
    );
  }

  static SoilProfile _applyBypass(SoilProfile profile, double waterVolume) {
    if (waterVolume <= 0) return profile;
    
    final updatedLayers = List<SoilLayer>.from(profile.layers);
    
    // Calculate total macro-porosity capacity across the profile
    double totalMacroCapacity = 0.0;
    for (final layer in updatedLayers) {
      totalMacroCapacity += layer.effectiveMacroPorosity * layer.thickness;
    }

    if (totalMacroCapacity > 1e-9) {
      for (int i = 0; i < updatedLayers.length; i++) {
        final layer = updatedLayers[i];
        final fraction = (layer.effectiveMacroPorosity * layer.thickness) / totalMacroCapacity;
        final layerWater = waterVolume * fraction;
        
        final deltaTheta = layerWater / layer.thickness;
        updatedLayers[i] = layer.copyWith(
          waterContent: (layer.waterContent + deltaTheta).clamp(
            layer.thetaR,
            layer.porosity,
          ),
        );
      }
    } else {
      // Fallback if no macro-porosity exists: saturate from top down
      double remainingWater = waterVolume;
      for (int i = 0; i < updatedLayers.length; i++) {
        if (remainingWater <= 0) break;
        final layer = updatedLayers[i];
        final capacity = (layer.porosity - layer.waterContent) * layer.thickness;
        final accepted = math.min(remainingWater, capacity);
        
        updatedLayers[i] = layer.copyWith(
          waterContent: (layer.waterContent + accepted / layer.thickness).clamp(0.0, layer.porosity),
        );
        remainingWater -= accepted;
      }
    }
    return profile.copyWith(layers: updatedLayers);
  }

  static HydrologyResult _solveStepWithFluxes(
    SoilProfile profile,
    double dt, {
    double surfaceFlux = 0.0,
    List<double>? sinks,
  }) {
    final n = profile.layers.length;
    final updatedLayers = List<SoilLayer>.from(profile.layers);
    final fluxes = List<double>.filled(n + 1, 0.0);

    final psis = List<double>.filled(n, 0.0);
    final ks = List<double>.filled(n, 0.0);

    for (int i = 0; i < n; i++) {
      final l = profile.layers[i];
      final double adjAlpha =
          l.vgAlpha * (1.0 + l.effectiveMacroPorosity * 2.0);
      final double adjN = (l.vgN * (1.0 - l.effectiveMacroPorosity * 0.2))
          .clamp(1.05, 10.0);

      psis[i] = BiophysicsUtils.thetaToPsi(
        l.waterContent,
        l.thetaR,
        l.porosity,
        adjAlpha,
        adjN,
        previousTheta: l.previousWaterContent,
      );
      final se = (l.waterContent - l.thetaR) / (l.porosity - l.thetaR);
      ks[i] = BiophysicsUtils.calculateK(
        se.clamp(0.0, 1.0),
        l.kSat,
        adjN,
        l: l.vgL,
      );
    }

    fluxes[0] = surfaceFlux;

    for (int i = 0; i < n - 1; i++) {
      final l1 = profile.layers[i];
      final l2 = profile.layers[i + 1];
      final kInterface = (2 * ks[i] * ks[i + 1]) / (ks[i] + ks[i + 1] + 1e-20);
      final dz = l2.depth - l1.depth;
      final dPsi = psis[i + 1] - psis[i];
      fluxes[i + 1] = kInterface * (1.0 - dPsi / dz);
    }

    fluxes[n] = ks[n - 1];

    for (int i = 0; i < n; i++) {
      final layer = updatedLayers[i];
      final netFlux = (fluxes[i] - fluxes[i + 1]);
      final sinkTerm = (sinks != null) ? sinks[i] : 0.0;
      final deltaTheta = (netFlux / layer.thickness - sinkTerm) * dt;

      var newTheta = layer.waterContent + deltaTheta;
      newTheta = newTheta.clamp(layer.thetaR + SimulationConstants.thetaMinBuffer, layer.porosity);

      updatedLayers[i] = layer.copyWith(
        previousWaterContent: layer.waterContent,
        waterContent: newTheta,
      );
    }

    return HydrologyResult(
      profile: profile.copyWith(layers: updatedLayers),
      averageFluxes: fluxes,
      latentHeat: 0.0,
    );
  }
}
