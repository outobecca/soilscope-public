import 'dart:math' as math;
import '../models/soil_layer.dart';
import '../models/soil_profile.dart';
import '../models/plant.dart';
import '../../core/simulation_constants.dart';

class EnergySolver {
  static const double sigma = SimulationConstants.stefanBoltzmann; // Stefan-Boltzmann constant
  static const double emissivity = SimulationConstants.soilEmissivity; // Soil emissivity
  static const double solarConstant = SimulationConstants.solarConstantPeak; // W/m^2 (approximate peak)

  /// Solves heat transfer (Stefan-Boltzmann, conduction, and diurnal cycle)
  /// Accounts for multiple plants shading the soil surface.
  static SoilProfile solve(
    SoilProfile profile,
    double dt,
    double timeElapsed, {
    double airTemperature = SimulationConstants.baseAirTemperature,
    double latentHeat = 0.0,
    List<Plant> plants = const [],
    double? solarRadiation,
  }) {
    // 1. Update Profile Albedo (Darker when wet, darker when covered by plants)
    final firstLayer = profile.layers.first;
    final double wetnessFactor =
        (firstLayer.waterContent / firstLayer.porosity).clamp(0.0, 1.0);

    // Sum LAI from all plants for shading effect
    final double totalLai = plants.fold(0.0, (sum, p) => sum + p.lai);
    final double laiFactor = totalLai / 10.0; // Scaled for multi-plant canopy

    // Base albedo reduced by wetness (up to 50%) and LAI (up to 40%)
    final double currentAlbedo =
        (0.2 * (1.0 - 0.5 * wetnessFactor) * (1.0 - 0.4 * laiFactor)).clamp(
          0.05,
          0.3,
        );

    // 2. Update Layer Thermal Properties
    final updatedLayers =
        profile.layers.map((l) {
          final double lambda = 0.2 + 1.8 * (l.waterContent / l.porosity);
          final double cvTotal =
              l.bulkDensity * 800.0 + l.waterContent * 1000.0 * 4184.0;
          return l.copyWith(thermalConductivity: lambda, heatCapacity: cvTotal);
        }).toList();

    SoilProfile currentProfile = profile.copyWith(
      surfaceAlbedo: currentAlbedo,
      layers: updatedLayers,
    );

    // Sub-stepping for stability
    const double subStep = SimulationConstants.energySubStep;
    int steps = (dt / subStep).ceil();
    double actualDt = dt / steps;

    for (int s = 0; s < steps; s++) {
      currentProfile = _solveStep(
        currentProfile,
        actualDt,
        timeElapsed + s * actualDt,
        airTemperature: airTemperature,
        latentHeat: latentHeat,
        solarRadiation: solarRadiation,
      );
    }
    return currentProfile;
  }

  static SoilProfile _solveStep(
    SoilProfile profile,
    double dt,
    double t, {
    double airTemperature = SimulationConstants.baseAirTemperature,
    double latentHeat = 0.0,
    double? solarRadiation,
  }) {
    final n = profile.layers.length;
    final updatedLayers = List<SoilLayer>.from(profile.layers);
    final heatFluxes = List<double>.filled(n + 1, 0.0);

    // 1. Shortwave Radiation (Diurnal cycle or Override)
    final double dayTime = t % 86400.0;
    final double hourAngle = (dayTime / 86400.0) * 2.0 * math.pi;
    final double solarIntensity = solarRadiation ??
        (math.max(0.0, math.sin(hourAngle - math.pi / 2.0)) * solarConstant);
    final double netShortwave = (1.0 - profile.surfaceAlbedo) * solarIntensity;

    // 2. Surface Energy Balance
    final surfaceTemp = profile.layers.first.temperature;

    final outgoingLongwave = emissivity * sigma * math.pow(surfaceTemp, 4);

    const double epsilonAir = SimulationConstants.airEmissivity;
    final incomingLongwave = epsilonAir * sigma * math.pow(airTemperature, 4);

    final sensibleHeat = 10.0 * (surfaceTemp - airTemperature);

    heatFluxes[0] =
        netShortwave +
        incomingLongwave -
        outgoingLongwave -
        sensibleHeat -
        latentHeat;

    // 3. Conduction
    for (int i = 0; i < n - 1; i++) {
      final l1 = profile.layers[i];
      final l2 = profile.layers[i + 1];
      final avgLambda = (l1.thermalConductivity + l2.thermalConductivity) / 2.0;
      final dz = (l1.thickness + l2.thickness) / 2.0;
      heatFluxes[i + 1] = -avgLambda * (l2.temperature - l1.temperature) / dz;
    }

    // 4. Update temperatures
    for (int i = 0; i < n; i++) {
      final layer = updatedLayers[i];
      double fluxIn = (i == 0) ? heatFluxes[0] : heatFluxes[i];
      double fluxOut = heatFluxes[i + 1];
      final netFlux = fluxIn - fluxOut;

      final deltaT = (netFlux * dt) / (layer.thickness * layer.heatCapacity);

      updatedLayers[i] = layer.copyWith(
        temperature: (layer.temperature + deltaT).clamp(260.0, 330.0),
      );
    }

    return profile.copyWith(layers: updatedLayers);
  }
}
