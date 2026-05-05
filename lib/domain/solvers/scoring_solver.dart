import '../models/biophysical_state.dart';
import '../models/sustainability_score.dart';

class ScoringSolver {
  /// Calculates real-time sustainability scores based on the entire SPAC state.
  static SustainabilityScore solve(BiophysicalState state, double dt) {
    // 1. Yield Score (Average turgor of all plants)
    final double healthScore = state.plants.isEmpty
        ? 0.0
        : (state.plants.fold(0.0, (sum, p) => sum + ((p.turgorPressure / 1.2).clamp(0.0, 1.0) * 0.7 + (p.totalBiomass / 2000.0).clamp(0.0, 1.0) * 0.3)) /
                state.plants.length)
            .clamp(0.0, 1.0);

    // 2. Carbon Score (Total biomass and organic carbon pools)
    final double biomass = state.plants.fold(0.0, (sum, p) => sum + p.totalBiomass);
    final double carbonScore = (biomass / 2000.0 + state.profile.layers.fold(0.0, (sum, l) => sum + l.organicCarbon) / 100.0).clamp(0.0, 1.0);

    // 3. Soil Health Score (Aggregated from layers)
    double soilHealthSum = 0.0;
    for (final layer in state.profile.layers) {
      final double stability = layer.aggregateStability;
      final double bioActivity = (layer.microbialBiomass / 500.0).clamp(0.0, 1.0);
      soilHealthSum += (stability + bioActivity) / 2.0;
    }
    final double soilHealthScore = state.profile.layers.isEmpty
        ? 0.0
        : soilHealthSum / state.profile.layers.length;

    // 4. Biodiversity Score (Microbial biomass and fungal density)
    final double biodiversityScore = state.profile.layers.fold(0.0, (sum, l) => sum + (l.microbialBiomass / 500.0 + l.fungalHyphaeDensity) / 2.0) / 
        (state.profile.layers.isEmpty ? 1.0 : state.profile.layers.length);

    return state.score.copyWith(
      yieldScore: healthScore,
      totalSoilHealth: soilHealthScore,
      carbonScore: carbonScore,
      biodiversityScore: biodiversityScore.clamp(0.0, 1.0),
    );
  }
}
