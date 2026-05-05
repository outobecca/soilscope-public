import '../models/soil_layer.dart';
import '../models/soil_profile.dart';
import 'nitrogen_cycle_model.dart';

class NutrientSolver {
  /// Solves 1D Nutrient transport (Diffusion + Advection) and biological transformations
  static SoilProfile solve(
    SoilProfile profile,
    double dt, {
    List<double>? waterFluxes,
  }) {
    // For stability with high timeScale, use sub-stepping if dt > 600s
    const double maxSubStep = 600.0;
    int steps = (dt / maxSubStep).ceil().clamp(1, 100);
    double actualDt = dt / steps;

    SoilProfile currentProfile = profile;
    for (int s = 0; s < steps; s++) {
      currentProfile = _solveStep(
        currentProfile,
        actualDt,
        waterFluxes: waterFluxes,
      );
    }
    return currentProfile;
  }

  static SoilProfile _solveStep(
    SoilProfile profile,
    double dt, {
    List<double>? waterFluxes,
  }) {
    final updatedLayers = List<SoilLayer>.from(profile.layers);
    final n = updatedLayers.length;

    // 1. Biological Transformations (Using NitrogenCycleModel)
    for (int i = 0; i < n; i++) {
      updatedLayers[i] = NitrogenCycleModel.tick(dt, updatedLayers[i]);
    }

    // 2. Transport (Diffusion + Advection)
    return _solveTransport(updatedLayers, dt, profile, waterFluxes);
  }

  static SoilProfile _solveTransport(
    List<SoilLayer> layers,
    double dt,
    SoilProfile originalProfile,
    List<double>? waterFluxes,
  ) {
    final n = layers.length;
    final nitrateFluxes = List<double>.filled(n + 1, 0.0);
    final ammoniumFluxes = List<double>.filled(n + 1, 0.0);
    final potassiumFluxes = List<double>.filled(n + 1, 0.0);
    final phosphateFluxes = List<double>.filled(n + 1, 0.0);

    const double dLNitrate = 1.9e-9;
    const double dLAmmonium = 1.5e-9;
    const double dLPotassium = 1.8e-9;
    const double dLPhosphate = 0.8e-9;

    for (int i = 0; i < n - 1; i++) {
      final l1 = layers[i];
      final l2 = layers[i + 1];

      final dz = (l1.thickness + l2.thickness) / 2.0;
      final avgTheta = (l1.waterContent + l2.waterContent) / 2.0;
      final f = (avgTheta / 0.5).clamp(0.01, 1.0);

      nitrateFluxes[i + 1] =
          (dLNitrate * avgTheta * f) *
          (l1.nitrateContent - l2.nitrateContent) /
          dz;
      ammoniumFluxes[i + 1] =
          (dLAmmonium * avgTheta * f) *
          (l1.ammoniumContent - l2.ammoniumContent) /
          dz;
      potassiumFluxes[i + 1] =
          (dLPotassium * avgTheta * f) *
          (l1.potassiumContent - l2.potassiumContent) /
          dz;
      phosphateFluxes[i + 1] =
          (dLPhosphate * avgTheta * f) *
          (l1.phosphateContent - l2.phosphateContent) /
          dz;

      if (waterFluxes != null && i + 1 < waterFluxes.length) {
        final qw = waterFluxes[i + 1];
        final double cNit = qw > 0 ? l1.nitrateContent : l2.nitrateContent;
        final double cAmm = qw > 0 ? l1.ammoniumContent : l2.ammoniumContent;
        final double cPot = qw > 0 ? l1.potassiumContent : l2.potassiumContent;
        final double cPho = qw > 0 ? l1.phosphateContent : l2.phosphateContent;

        nitrateFluxes[i + 1] += qw * cNit;
        ammoniumFluxes[i + 1] += qw * cAmm;
        potassiumFluxes[i + 1] += qw * cPot;
        phosphateFluxes[i + 1] += qw * cPho;
      }
    }

    if (waterFluxes != null && waterFluxes.length > n) {
      final qwBottom = waterFluxes[n];
      if (qwBottom > 0) {
        final last = layers.last;
        nitrateFluxes[n] = qwBottom * last.nitrateContent;
        ammoniumFluxes[n] = qwBottom * last.ammoniumContent;
        potassiumFluxes[n] = qwBottom * last.potassiumContent;
        phosphateFluxes[n] = qwBottom * last.phosphateContent;
      }
    }

    final finalLayers = List<SoilLayer>.from(layers);
    for (int i = 0; i < n; i++) {
      final layer = finalLayers[i];
      final netNit =
          (nitrateFluxes[i] - nitrateFluxes[i + 1]) * dt / layer.thickness;
      final netAmm =
          (ammoniumFluxes[i] - ammoniumFluxes[i + 1]) * dt / layer.thickness;
      final netPot =
          (potassiumFluxes[i] - potassiumFluxes[i + 1]) * dt / layer.thickness;
      final netPho =
          (phosphateFluxes[i] - phosphateFluxes[i + 1]) * dt / layer.thickness;

      finalLayers[i] = layer.copyWith(
        nitrateContent: (layer.nitrateContent + netNit).clamp(0.0, 1000.0),
        ammoniumContent: (layer.ammoniumContent + netAmm).clamp(0.0, 500.0),
        potassiumContent: (layer.potassiumContent + netPot).clamp(0.0, 1000.0),
        phosphateContent: (layer.phosphateContent + netPho).clamp(0.0, 1000.0),
      );
    }

    return originalProfile.copyWith(layers: finalLayers);
  }
}
