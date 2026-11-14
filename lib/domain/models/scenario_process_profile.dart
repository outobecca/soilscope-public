import 'dart:math' as math;

import 'biophysical_state.dart';
import 'scenario.dart';
import 'soil_layer.dart';
import 'soil_profile.dart';

/// Relative emphasis of the processes a scenario is built around.
///
/// The values are normalized to 0..1 and are derived from the scenario's
/// *initial* profile. That keeps the visual emphasis stable while the user's
/// interventions change the running soil, and it also gives custom scenarios a
/// meaningful profile without requiring new scenario JSON fields.
class ScenarioProcessProfile {
  const ScenarioProcessProfile({
    this.scenarioId,
    this.nitrification = 0.0,
    this.denitrification = 0.0,
    this.leaching = 0.0,
    this.immobilization = 0.0,
    this.compaction = 0.0,
    this.clayDensity = 0.0,
  });

  static const empty = ScenarioProcessProfile();

  final String? scenarioId;

  /// Aerobic ammonium oxidation signal.
  final double nitrification;

  /// Anaerobic nitrate reduction signal.
  final double denitrification;

  /// Mobile-nitrate + water-flux signal.
  final double leaching;

  /// High-C/N microbial immobilization signal.
  final double immobilization;

  /// Physical impedance and loss of pore space.
  final double compaction;

  /// Clay content weighted by compaction, used by the texture renderer.
  final double clayDensity;

  bool get isCompacted => compaction >= 0.55;
  bool get hasNitrogenLeak => leaching >= 0.45;
  bool get hasAnaerobicRisk => denitrification >= 0.45;
  bool get hasImmobilization => immobilization >= 0.45;

  /// Root extension multiplier from the physical state of the soil.
  ///
  /// Kept here as well as on [SoilLayer] so scenario-level visuals and the
  /// solver use the same definition of compaction.
  double get rootGrowthFactor => (1.0 - compaction * 0.65).clamp(0.25, 1.0);

  static ScenarioProcessProfile fromState(BiophysicalState state) {
    return fromScenario(state.currentScenario, fallbackProfile: state.profile);
  }

  /// Derives a profile from the scenario's starting soil.
  ///
  /// [fallbackProfile] is used for the default/sandbox state when no scenario
  /// is selected, and for scenarios whose initial profile is unavailable.
  static ScenarioProcessProfile fromScenario(
    Scenario? scenario, {
    SoilProfile? fallbackProfile,
  }) {
    final profile = scenario?.initialProfile ?? fallbackProfile;
    final layers = profile?.layers ?? const <SoilLayer>[];
    if (layers.isEmpty) {
      return ScenarioProcessProfile(scenarioId: scenario?.id);
    }

    double average(double Function(SoilLayer layer) value) {
      return layers.fold<double>(0.0, (sum, layer) => sum + value(layer)) /
          layers.length;
    }

    final meanBulkDensity = average((l) => l.bulkDensity);
    final meanPorosity = average((l) => l.porosity);
    final meanClay = average((l) => l.clayFraction);
    final meanSand = average((l) => l.sandFraction);
    final meanNitrate = average((l) => l.nitrateContent);
    final meanAmmonium = average((l) => l.ammoniumContent);
    final meanRedox = average((l) => l.redoxPotential);
    final meanOxygen = average((l) => l.oxygenContent);
    final meanSaturation = average(
      (l) => (l.waterContent / l.porosity.clamp(0.01, 1.0)).clamp(0.0, 1.0),
    );
    final meanLogKsat = average(
      (l) => math.log(l.kSat.clamp(1.0e-12, 1.0)) / math.ln10,
    );
    final maxCnRatio = layers
        .map((l) => l.cnRatio)
        .reduce((a, b) => math.max(a, b));
    final meanOrganicCarbon = average((l) => l.organicCarbon);

    final densityFactor = _range(meanBulkDensity, 1350.0, 1750.0);
    final poreFactor = _range(0.45 - meanPorosity, 0.0, 0.16);
    final clayFactor = _range(meanClay, 0.20, 0.60);

    final compaction = _clamp01(
      densityFactor * 0.55 + poreFactor * 0.30 + clayFactor * 0.15,
    );

    final nitrification = _clamp01(
      _range(meanAmmonium, 2.0, 35.0) * 0.55 +
          _range(meanOxygen, 0.5, 8.5) * 0.45,
    );

    final leaching = _clamp01(
      _range(meanNitrate, 10.0, 100.0) * 0.50 +
          _range(meanLogKsat, -7.0, -4.0) * 0.30 +
          _range(meanSand, 0.1, 0.8) * 0.20,
    );

    final denitrification = _clamp01(
      _range(250.0 - meanRedox, 0.0, 400.0) * 0.55 +
          _range(meanSaturation, 0.55, 1.0) * 0.45,
    );

    // The lock scenario sits around C/N 27, which is already well above the
    // ~25 threshold where net immobilization begins. Saturate earlier than the
    // physical 40:1 upper bound so the signal is useful to the UI.
    final immobilization = _clamp01(
      _range(maxCnRatio, 15.0, 30.0) * 0.70 +
          _range(meanOrganicCarbon, 5.0, 60.0) * 0.30,
    );

    return ScenarioProcessProfile(
      scenarioId: scenario?.id,
      nitrification: nitrification,
      denitrification: denitrification,
      leaching: leaching,
      immobilization: immobilization,
      compaction: compaction,
      clayDensity: (meanClay * (0.65 + 0.35 * compaction)).clamp(0.0, 1.0),
    );
  }

  static double _range(double value, double low, double high) {
    if (high <= low) return 0.0;
    return _clamp01((value - low) / (high - low));
  }

  static double _clamp01(double value) => value.clamp(0.0, 1.0);
}
