import 'dart:math' as math;
import '../models/soil_layer.dart';
import '../models/soil_profile.dart';
import '../models/plant.dart';
import '../../core/biophysics_utils.dart';
import '../../core/simulation_constants.dart';

/// Calculates dynamic Ksat, Carbon pooling, Fungal dynamics, Cracking and Aggregate Stability.
/// Accounts for multiple plants in the SPAC continuum.
class AggregationSolver {
  static const double q10 = 2.0;
  static const double tRef = 293.15; // 20 C

  /// Calculates dynamic Ksat, Carbon pooling, Fungal dynamics, Cracking and Aggregate Stability.
  /// Accounts for multiple plants in the SPAC continuum.
  static SoilProfile solve(
    SoilProfile profile,
    double dt, {
    List<Plant> plants = const [],
    bool hasCoverCrop = false,
    double precipitation = 0.0,
  }) {
    final updatedLayers = List<SoilLayer>.from(profile.layers);

    // Sum total LAI for soil surface protection
    final double totalLai = plants.fold(0.0, (sum, p) => sum + p.lai);

    for (int i = 0; i < updatedLayers.length; i++) {
      final layer = updatedLayers[i];

      // 1. Environmental factors
      final double fTemp = BiophysicsUtils.q10Factor(layer.temperature);
      final double airFilledPorosity = (layer.porosity - layer.waterContent).clamp(0.0, 1.0);
      // fWater here uses AFP threshold for aggregate stability / EPS context.
      // AFP > 5% is required for aerobic biofilm formation and EPS secretion;
      // below 5% pore continuity collapses (Chenu & Cosentino 2011, Soil Biol.
      // Biochem.). The full WFPS moisture curve is reserved for enzyme kinetics
      // in MicrobialEnzymesSolver (Linn & Doran 1984, SSSA J.).
      final double fWater = airFilledPorosity > 0.05 ? 1.0 : (airFilledPorosity / 0.05);
      final double fO2 = (layer.oxygenContent / BiophysicsUtils.atmO2Saturation).clamp(0.05, 1.0);
      final double activity = fTemp * fWater * fO2;

      // 2. EPS production (Bacterial glue)
      const double epsProdBase = SimulationConstants.epsProdBase;
      const double epsDecayBase = SimulationConstants.epsDecayBase;
      final double epsProduction = layer.microbialBiomass * epsProdBase * activity * dt;
      final double epsDecay = layer.epsContent * epsDecayBase * fTemp * dt;
      final double newEps = (layer.epsContent + epsProduction - epsDecay).clamp(0.0, 20.0);

      // 3. Fungal Dynamics (FSPM-lite)
      const double fungiGrowthBase = SimulationConstants.fungiGrowthBase;
      const double fungiDeathBase = SimulationConstants.fungiDeathBase;

      // Sum root nodes from all plants for rhizofactor
      double totalRootNodes = 0;
      for (final plant in plants) {
        totalRootNodes +=
            plant.rootSystem
                .where((n) => n.z >= layer.depth && n.z <= layer.depth + layer.thickness)
                .length;
      }
      double rhizofactor = 1.0 + (totalRootNodes * 0.08).clamp(0.0, 8.0);

      if (hasCoverCrop && i == 0) {
        rhizofactor += 2.0;
      }

      double fRedox = (layer.redoxPotential > 200) ? 1.0 : (layer.redoxPotential + 200) / 400;
      fRedox = fRedox.clamp(0.0, 1.0);
      final double fungiGrowth =
          layer.particulateOrganicMatter * fungiGrowthBase * activity * rhizofactor * dt;
      final double fungiDeath =
          layer.fungalHyphaeDensity * fungiDeathBase * fTemp * (1.1 - fRedox) * dt;
      final double newFungi = (layer.fungalHyphaeDensity + fungiGrowth - fungiDeath).clamp(0.0, 1.0);

      // 4. Aggregate Stability Logic
      final double stabilityBuilding =
          (newFungi * 0.01 +
              newEps * 0.005 +
              (layer.mineralAssociatedOrganicMatter / 1000.0) * 0.01) *
          activity *
          dt;

      double slaking = 0.0;
      if (i == 0 && precipitation > 1e-6) {
        // Protect by combined LAI or cover crop
        double protection = totalLai / 8.0;
        if (hasCoverCrop) protection = math.max(protection, 0.8);
        slaking = 5.0e-4 * math.pow(precipitation * 1e5, 1.5) * (1.0 - protection.clamp(0, 1)) * dt;
      }

      final double newStability = (layer.aggregateStability + stabilityBuilding - slaking).clamp(
        0.05,
        1.0,
      );

      // 5. Shrink-Swell (Cracking)
      double targetMacro = 0.0;
      if (layer.waterContent < 0.25 * layer.porosity && layer.clayFraction > 0.3) {
        targetMacro = layer.clayFraction * (0.25 - (layer.waterContent / layer.porosity)) * 2.0;
      }
      final double newMacro =
          layer.effectiveMacroPorosity +
          (targetMacro - layer.effectiveMacroPorosity) * (1.0 - math.exp(-1e-4 * dt));

      // 6. Bio-Aggregation Feedback
      double crustFactor = 1.0;
      if (i == 0 && newStability < 0.3 && precipitation > 0) {
        crustFactor = 0.1 + 0.9 * (newStability / 0.3);
      }

      final double fAgg = (newEps * 0.3) + (newFungi * 2.0);
      final double structuralIntegrity = (1.0 + fAgg * 0.05 + newMacro * 10.0).clamp(1.0, 20.0);
      const double ksatChangeRate = SimulationConstants.ksatChangeRate;
      final double newKsat =
          layer.kSat * (1.0 + (structuralIntegrity - 1.0) * activity * ksatChangeRate * dt) *
          crustFactor;

      // 7. MAOM Stabilization (Stable Carbon & Nitrogen)
      // Task 3/6: Consolidation of necro-mass stabilization logic.
      // High clay fraction increases MAOM capacity and protection (Cotrufo et al. 2013).
      final double fClay = (layer.clayFraction * 2.0).clamp(0.1, 1.0);
      const double maomStabRate = SimulationConstants.maomStabRate;
      const double deathRate = SimulationConstants.microbialDeathRate;
      
      // Calculate fluxes based on current biomass pools
      final double cDeathFlux = layer.microbialBiomass * deathRate * fTemp * dt;
      final double nDeathFlux = layer.microbialNitrogen * deathRate * fTemp * dt;
      
      // Stabilization: Fraction of dead biomass captured by mineral surfaces
      final double cStabilized = (cDeathFlux * maomStabRate * fClay).clamp(0.0, layer.particulateOrganicMatter * 0.5);
      final double nStabilized = (nDeathFlux * maomStabRate * fClay).clamp(0.0, layer.microbialNitrogen * 0.5);

      final double newMaomC = (layer.mineralAssociatedOrganicMatter + cStabilized).clamp(0.0, SimulationConstants.organicMatterMax);
      final double newMaomN = (layer.maomNitrogen + nStabilized).clamp(0.0, 5000.0);
      
      // Stoichiometric sync: subtract stabilized portion from POM/Biomass if not handled elsewhere.
      // Since MicrobialEnzymesSolver adds ALL death to POM, we subtract the stabilized part from POM.
      final double newPom = (layer.particulateOrganicMatter - cStabilized).clamp(0.0, 1000.0);
      final double newMicN = (layer.microbialNitrogen - nStabilized).clamp(0.0, 1000.0);

      updatedLayers[i] = layer.copyWith(
        kSat: newKsat,
        epsContent: newEps,
        fungalHyphaeDensity: newFungi,
        aggregateStability: newStability,
        effectiveMacroPorosity: newMacro,
        // MAOM Updates
        mineralAssociatedOrganicMatter: newMaomC,
        stableCarbon: newMaomC,
        maomNitrogen: newMaomN,
        particulateOrganicMatter: newPom,
        labileCarbon: newPom,
        microbialNitrogen: newMicN,
      );
    }

    return profile.copyWith(layers: updatedLayers);
  }
}
