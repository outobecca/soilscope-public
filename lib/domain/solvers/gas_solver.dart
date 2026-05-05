import 'dart:math' as math;
import '../models/soil_layer.dart';
import '../models/soil_profile.dart';
import '../models/plant.dart';
import '../../core/simulation_constants.dart';
import '../../core/biophysics_utils.dart';

class GasSolver {
  // Diffusion constants in air (m^2/s)
  static const double d0O2 = 2.0e-5;
  static const double d0CO2 = 1.6e-5;

  // Atmospheric O2 saturation concentration delegated to shared constant.
  // See BiophysicsUtils.atmO2Saturation.

  /// Solves 1D Gas diffusion and respiration for O2 and CO2.
  /// Accounts for respiration from multiple plants in the SPAC continuum.
  static SoilProfile solve(
    SoilProfile profile,
    double dt, {
    List<Plant> plants = const [],
    double atmCO2 = SimulationConstants.atmCO2Default,
  }) {
    final updatedLayers = List<SoilLayer>.from(profile.layers);
    final n = updatedLayers.length;

    // 1. Local Respiration (Consumption/Production)
    for (int i = 0; i < n; i++) {
      updatedLayers[i] = _solveRespiration(updatedLayers[i], dt, plants);
    }

    // 2. Transport (Diffusion in air phase)
    return _solveDiffusion(updatedLayers, dt, profile, atmCO2: atmCO2);
  }

  static SoilLayer _solveRespiration(
    SoilLayer layer,
    double dt,
    List<Plant> plants,
  ) {
    // Environmental factors
    final double fTemp = BiophysicsUtils.q10Factor(layer.temperature);
    final double airFilledPorosity = (layer.porosity - layer.waterContent).clamp(0.0, 1.0);
    // fWater: substrate diffusion is severely limited only in near-saturated soils
    // (air-filled porosity < 2%); uses AFP threshold rather than full WFPS curve
    // because the O2-limitation term separately captures waterlogging effects.
    // Threshold of 2% AFP follows Renault & Stengel (1994) Soil Biol. Biochem.
    final double fWater = airFilledPorosity > 0.02 ? 1.0 : (airFilledPorosity / 0.02);

    // a. Microbial Respiration
    const double kMic = 1.0e-8; // mol / (kg_biomass * s)
    final double micActivity =
        fTemp * fWater * (layer.oxygenContent / BiophysicsUtils.atmO2Saturation).clamp(0.0, 1.0);
    final double respMic = kMic * layer.microbialBiomass * micActivity * dt;

    // b. Combined Root Respiration from all plants
    double totalRespRoot = 0.0;
    const double kRoot = 5.0e-10; // mol / (node * s)

    for (final plant in plants) {
      int rootNodes =
          plant.rootSystem
              .where((n) => n.z >= layer.depth && n.z <= layer.depth + layer.thickness)
              .length;

      totalRespRoot += kRoot * rootNodes * fTemp * (layer.oxygenContent / BiophysicsUtils.atmO2Saturation).clamp(0.1, 1.0) * dt;
    }

    final totalResp = respMic + totalRespRoot;

    return layer.copyWith(
      oxygenContent: (layer.oxygenContent - totalResp).clamp(0.0, 10.0),
      co2Content: (layer.co2Content + totalResp).clamp(0.0, 5.0),
    );
  }

  static SoilProfile _solveDiffusion(
    List<SoilLayer> layers,
    double dt,
    SoilProfile originalProfile, {
    double atmCO2 = SimulationConstants.atmCO2Default,
  }) {
    final n = layers.length;
    final o2Fluxes = List<double>.filled(n + 1, 0.0);
    final co2Fluxes = List<double>.filled(n + 1, 0.0);

    // Millington-Quirk effective diffusion
    final List<double> deO2 = List.filled(n, 0.0);
    final List<double> deCO2 = List.filled(n, 0.0);

    for (int i = 0; i < n; i++) {
      final l = layers[i];
      final eps = (l.porosity - l.waterContent).clamp(0.001, 1.0);
      final factor = math.pow(eps, 2.0) / math.pow(l.porosity, 2.0 / 3.0);
      deO2[i] = d0O2 * factor;
      deCO2[i] = d0CO2 * factor;
    }

    // 1. Surface Boundary (Exchange with Atmosphere)
    const double dzSurf = 0.01;
    o2Fluxes[0] = deO2[0] * (BiophysicsUtils.atmO2Saturation - layers[0].oxygenContent) / dzSurf;
    co2Fluxes[0] = deCO2[0] * (atmCO2 - layers[0].co2Content) / dzSurf;

    // 2. Internal Fluxes
    for (int i = 0; i < n - 1; i++) {
      final dz = (layers[i].thickness + layers[i + 1].thickness) / 2.0;
      final avgDeO2 = (deO2[i] + deO2[i + 1]) / 2.0;
      final avgDeCO2 = (deCO2[i] + deCO2[i + 1]) / 2.0;

      o2Fluxes[i + 1] = avgDeO2 * (layers[i].oxygenContent - layers[i + 1].oxygenContent) / dz;
      co2Fluxes[i + 1] = avgDeCO2 * (layers[i].co2Content - layers[i + 1].co2Content) / dz;
    }

    // 3. Bottom Boundary (Zero flux)
    o2Fluxes[n] = 0.0;
    co2Fluxes[n] = 0.0;

    // Update concentrations
    final finalLayers = List<SoilLayer>.from(layers);
    for (int i = 0; i < n; i++) {
      final layer = finalLayers[i];
      final netO2 = (o2Fluxes[i] - o2Fluxes[i + 1]) * dt / layer.thickness;
      final netCO2 = (co2Fluxes[i] - co2Fluxes[i + 1]) * dt / layer.thickness;

      finalLayers[i] = layer.copyWith(
        oxygenContent: (layer.oxygenContent + netO2).clamp(0.0, 10.0),
        co2Content: (layer.co2Content + netCO2).clamp(0.0, 5.0),
      );
    }

    return originalProfile.copyWith(layers: finalLayers);
  }
}
