import 'dart:math' as math;
import '../models/biophysical_state.dart';
import '../../core/biophysics_utils.dart';

/// Coupling Matrix - Explicit Bidirectional Feedback Tracking.
/// Accounts for all plants in the collection.
class CouplingMatrix {
  static const double hydrologyCouplingStrength = 1.0;
  static const double biologyCouplingStrength = 0.8;
  static const double structureCouplingStrength = 0.7;
  static const double temperatureCouplingStrength = 1.0;

  static CouplingDiagnostics analyze(BiophysicalState state) {
    final diagnostics = <String, double>{};
    final feedbackChains = <String>[];

    final waterStressCoupling = _analyzeWaterStressCoupling(state);
    diagnostics['water_stress_coupling'] = waterStressCoupling.strength;
    if (waterStressCoupling.active) {
      feedbackChains.add(waterStressCoupling.description);
    }

    final tempRespCoupling = _analyzeTemperatureRespirationCoupling(state);
    diagnostics['temp_respiration_coupling'] = tempRespCoupling.strength;
    if (tempRespCoupling.active) {
      feedbackChains.add(tempRespCoupling.description);
    }

    final redoxNutrientCoupling = _analyzeRedoxNutrientCoupling(state);
    diagnostics['redox_nutrient_coupling'] = redoxNutrientCoupling.strength;
    if (redoxNutrientCoupling.active) {
      feedbackChains.add(redoxNutrientCoupling.description);
    }

    final rootPHCoupling = _analyzeRootPHCoupling(state);
    diagnostics['root_ph_coupling'] = rootPHCoupling.strength;
    if (rootPHCoupling.active) {
      feedbackChains.add(rootPHCoupling.description);
    }

    final overallCoupling = diagnostics.values.reduce((a, b) => a + b) / diagnostics.length;

    return CouplingDiagnostics(
      couplingStrengths: diagnostics,
      activeFeedbackChains: feedbackChains,
      overallCouplingIndex: overallCoupling,
      systemStability: _assessSystemStability(diagnostics),
    );
  }

  static _CouplingResult _analyzeWaterStressCoupling(BiophysicalState state) {
    double avgSe = 0.0;
    for (final layer in state.profile.layers) {
      final se = (layer.waterContent - layer.thetaR) / (layer.porosity - layer.thetaR);
      avgSe += se.clamp(0.0, 1.0);
    }
    avgSe /= state.profile.layers.length;

    final topLayer = state.profile.layers.first;
    final m = 1.0 - 1.0 / topLayer.vgN;
    final psi =
        avgSe > 0.01
            ? -(1.0 / topLayer.vgAlpha) *
                math.pow(math.pow(avgSe, -1.0 / m) - 1.0, 1.0 / topLayer.vgN) /
                10000.0
            : -3.0;

    // Average stress from all plants
    final waterStressIndex =
        state.plants.isEmpty
            ? 0.0
            : state.plants.fold(0.0, (sum, p) => sum + p.waterStressIndex) / state.plants.length;
    final actualCoupling = waterStressIndex * hydrologyCouplingStrength;

    final bool isActive = psi < -0.3 && waterStressIndex > 0.1;

    return _CouplingResult(
      strength: actualCoupling.clamp(0.0, 1.0),
      active: isActive,
      description:
          isActive
              ? 'Vesi→Kasvi: Maan kuivuus (ψ=${psi.toStringAsFixed(2)} MPa) → '
                  'Ilmarakojen sulkeutuminen (${(waterStressIndex * 100).toStringAsFixed(0)}%) → '
                  'Vähentynyt transpiraatio'
              : '',
    );
  }

  static _CouplingResult _analyzeTemperatureRespirationCoupling(BiophysicalState state) {
    double avgTemp = 0.0;
    double avgCO2 = 0.0;
    for (final layer in state.profile.layers) {
      avgTemp += layer.temperature;
      avgCO2 += layer.co2Content;
    }
    avgTemp /= state.profile.layers.length;
    avgCO2 /= state.profile.layers.length;

    // Q10 scaling referenced to 25°C (298.15 K) because the coupling signal
    // represents the *deviation* of photosynthesis / respiration rates from
    // their common optimum at 25°C (standard reference in FvCB model;
    // Farquhar et al. 1980, Planta 149).
    final tempEffect = BiophysicsUtils.q10Factor(avgTemp, tRef: 298.15);
    final couplingStrength = (tempEffect - 1.0).abs().clamp(0.0, 1.0);

    final bool isActive = avgCO2 > 0.03 && (avgTemp - 298.15).abs() > 5;

    return _CouplingResult(
      strength: couplingStrength * temperatureCouplingStrength,
      active: isActive,
      description:
          isActive
              ? 'Lämpö→CO₂→pH: T=${(avgTemp - 273.15).toStringAsFixed(1)}°C → '
                  'Hengitys ${tempEffect.toStringAsFixed(1)}× → '
                  'CO₂ lisääntyy → pH laskee'
              : '',
    );
  }

  static _CouplingResult _analyzeRedoxNutrientCoupling(BiophysicalState state) {
    final topLayer = state.profile.layers.first;
    final o2Saturation = topLayer.oxygenContent / BiophysicsUtils.atmO2Saturation;

    final isReducing = o2Saturation < 0.3;
    final couplingStrength = isReducing ? (1.0 - o2Saturation) : 0.0;

    return _CouplingResult(
      strength: couplingStrength,
      active: isReducing,
      description:
          isReducing
              ? 'Redox→Ravinteet: O₂↓ (${(o2Saturation * 100).toStringAsFixed(0)}%) → '
                  'Fe³⁺→Fe²⁺ → P vapautuu → Huuhtoutumisriski!'
              : '',
    );
  }

  static _CouplingResult _analyzeRootPHCoupling(BiophysicalState state) {
    // Total biomass from all plants
    final rootBiomass = state.plants.fold(0.0, (sum, p) => sum + p.rootBiomass);
    final rootDensity = rootBiomass / (state.profile.layers.length * 0.1);

    final exudateEffect = _sigmoid(rootDensity - 1.0, 1.0);
    final rootZonePH = state.profile.layers.first.ph;
    final isPHAffected = rootZonePH < 6.5 || rootBiomass > 1500;

    return _CouplingResult(
      strength: exudateEffect * biologyCouplingStrength,
      active: isPHAffected && rootBiomass > 300,
      description:
          isPHAffected
              ? 'Juuri→pH: Juurieritteet → pH=${rootZonePH.toStringAsFixed(1)} → '
                  'P, Fe, Mn saatavuus muuttuu'
              : '',
    );
  }

  static double _sigmoid(double x, double k) => 1.0 / (1.0 + math.exp(-k * x));

  static SystemStability _assessSystemStability(Map<String, double> couplings) {
    final avgCoupling = couplings.values.reduce((a, b) => a + b) / couplings.length;
    final maxCoupling = couplings.values.reduce(math.max);

    if (maxCoupling > 0.8 && avgCoupling < 0.3) return SystemStability.unstable;
    if (avgCoupling > 0.6) return SystemStability.stressed;
    if (avgCoupling < 0.2) return SystemStability.stable;
    return SystemStability.dynamic;
  }
}

class _CouplingResult {
  final double strength;
  final bool active;
  final String description;
  const _CouplingResult({required this.strength, required this.active, required this.description});
}

enum SystemStability { stable, dynamic, stressed, unstable }

class CouplingDiagnostics {
  final Map<String, double> couplingStrengths;
  final List<String> activeFeedbackChains;
  final double overallCouplingIndex;
  final SystemStability systemStability;
  const CouplingDiagnostics({required this.couplingStrengths, required this.activeFeedbackChains, required this.overallCouplingIndex, required this.systemStability});

  String get summary {
    final stabilityText = switch (systemStability) {
      SystemStability.stable => 'Tasapainossa',
      SystemStability.dynamic => 'Dynaaminen',
      SystemStability.stressed => 'Stressaantunut',
      SystemStability.unstable => 'Epävakaa',
    };
    return 'Järjestelmän tila: $stabilityText\n'
        'Kytkentäindeksi: ${(overallCouplingIndex * 100).toStringAsFixed(0)}%\n'
        'Aktiivisia takaisinkytkentöjä: ${activeFeedbackChains.length}';
  }
}
