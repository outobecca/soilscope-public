import '../models/biophysical_state.dart';
import '../models/scenario.dart';
import '../models/sustainability_score.dart';

class ScoringSolver {
  /// Calculates real-time sustainability scores based on the entire SPAC state.
  static SustainabilityScore solve(BiophysicalState state, double dt) {
    // 1. Yield Score (Average turgor of all plants)
    final double healthScore = state.plants.isEmpty
        ? 0.0
        : (state.plants.fold(
                    0.0,
                    (sum, p) =>
                        sum +
                        ((p.turgorPressure / 1.2).clamp(0.0, 1.0) * 0.7 +
                            (p.totalBiomass / 2000.0).clamp(0.0, 1.0) * 0.3),
                  ) /
                  state.plants.length)
              .clamp(0.0, 1.0);

    // 2. Carbon Score (Total biomass and organic carbon pools)
    final double biomass = state.plants.fold(
      0.0,
      (sum, p) => sum + p.totalBiomass,
    );
    final double carbonScore =
        (biomass / 2000.0 +
                state.profile.layers.fold(
                      0.0,
                      (sum, l) => sum + l.organicCarbon,
                    ) /
                    100.0)
            .clamp(0.0, 1.0);

    // 3. Soil Health Score (Aggregated from layers)
    double soilHealthSum = 0.0;
    for (final layer in state.profile.layers) {
      final double stability = layer.aggregateStability;
      final double bioActivity = (layer.microbialBiomass / 500.0).clamp(
        0.0,
        1.0,
      );
      soilHealthSum += (stability + bioActivity) / 2.0;
    }
    final double soilHealthScore = state.profile.layers.isEmpty
        ? 0.0
        : soilHealthSum / state.profile.layers.length;

    // 4. Biodiversity Score (Microbial biomass and fungal density)
    final double biodiversityScore =
        state.profile.layers.fold(
          0.0,
          (sum, l) =>
              sum + (l.microbialBiomass / 500.0 + l.fungalHyphaeDensity) / 2.0,
        ) /
        (state.profile.layers.isEmpty ? 1.0 : state.profile.layers.length);

    final metrics = _ObjectiveMetrics.fromState(
      state,
      soilHealthScore: soilHealthScore,
    );

    return state.score.copyWith(
      yieldScore: healthScore,
      totalSoilHealth: soilHealthScore,
      carbonScore: carbonScore,
      biodiversityScore: biodiversityScore.clamp(0.0, 1.0),
      metObjectiveIds: _evaluateObjectives(state, metrics),
    );
  }

  /// Evaluates the active scenario's objectives and keeps previously achieved
  /// objectives completed. Keeping them sticky avoids a level oscillating
  /// backwards when a transient sensor value dips for one tick.
  static List<String> _evaluateObjectives(
    BiophysicalState state,
    _ObjectiveMetrics metrics,
  ) {
    final scenario = state.currentScenario;
    if (scenario == null || scenario.objectives.isEmpty) {
      return state.score.metObjectiveIds;
    }

    final met = state.score.metObjectiveIds.toSet();
    for (final objective in scenario.objectives) {
      if (met.contains(objective.id)) continue;
      if (_isObjectiveMet(objective, metrics)) {
        met.add(objective.id);
      }
    }
    return met.toList(growable: false);
  }

  static bool _isObjectiveMet(
    MissionObjective objective,
    _ObjectiveMetrics metrics,
  ) {
    switch (objective.type) {
      case 'yield':
        return metrics.totalBiomass >= objective.targetValue;
      case 'carbon':
        return metrics.totalStableCarbon >= objective.targetValue;
      case 'pollution':
        // Pollution objectives are upper bounds: lower is better.
        return metrics.deepestNitrate < objective.targetValue;
      case 'structure':
        final id = objective.id.toLowerCase();
        if (id.contains('eh') ||
            id.contains('redox') ||
            id.contains('aerobic')) {
          return metrics.meanRedoxPotential >= objective.targetValue;
        }
        return metrics.soilHealthPercent >= objective.targetValue;
      default:
        return false;
    }
  }
}

class _ObjectiveMetrics {
  final double totalBiomass;
  final double totalStableCarbon;
  final double deepestNitrate;
  final double meanRedoxPotential;
  final double soilHealthPercent;

  const _ObjectiveMetrics({
    required this.totalBiomass,
    required this.totalStableCarbon,
    required this.deepestNitrate,
    required this.meanRedoxPotential,
    required this.soilHealthPercent,
  });

  factory _ObjectiveMetrics.fromState(
    BiophysicalState state, {
    required double soilHealthScore,
  }) {
    final layers = state.profile.layers;
    final totalBiomass = state.plants.fold<double>(
      0,
      (sum, plant) => sum + plant.totalBiomass,
    );
    // Stable carbon is the mineral-associated pool, not total organic carbon;
    // the "build stable carbon" objective should not be satisfied merely by
    // starting with fresh residues in the profile.
    final totalStableCarbon = layers.fold<double>(
      0,
      (sum, layer) => sum + layer.mineralAssociatedOrganicMatter,
    );
    final deepestNitrate = layers.isEmpty ? 0.0 : layers.last.nitrateContent;
    final meanRedox = layers.isEmpty
        ? 0.0
        : layers.fold<double>(0, (sum, layer) => sum + layer.redoxPotential) /
              layers.length;

    return _ObjectiveMetrics(
      totalBiomass: totalBiomass,
      totalStableCarbon: totalStableCarbon,
      deepestNitrate: deepestNitrate,
      meanRedoxPotential: meanRedox,
      soilHealthPercent: soilHealthScore * 100.0,
    );
  }
}
