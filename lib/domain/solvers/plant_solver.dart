import 'dart:math' as math;
import '../models/plant.dart';
import '../models/soil_profile.dart';
import '../../core/simulation_constants.dart';
import 'plant/root_architecture_solver.dart';
import 'plant/plant_hydraulics_solver.dart';
import 'plant/plant_biomass_solver.dart';
import 'plant/plant_nutrient_uptake_solver.dart';
import 'nutrient_buffer.dart';

/// Coordinator for plant biophysical processes.
/// Refactored into modular sub-solvers for hydraulics, nutrients, biomass, and roots.
///
/// SPAC Integration (Soil-Plant-Atmosphere Continuum):
/// - Water flows from soil → roots → stem → leaves → atmosphere
/// - Transpiration is now LIMITED by soil water availability
/// - Stomatal conductance responds to leaf water potential and VPD
///
/// References:
/// - Jarvis (2011): Compensatory water uptake
/// - Tardieu & Simonneau (1998): ABA-mediated stomatal response
/// - Sperry et al. (2017): Hydraulic limitation theory
class PlantSolver {
  /// Solves plant growth, water/nutrient uptake, branching and biomass accumulation.
  static Plant solve(
    Plant plant,
    SoilProfile profile,
    double dt, {
    double airTemperature = 293.15,
    double atmCO2 = SimulationConstants.atmCO2Default,
    double relativeHumidity = 0.5,
    double? solarRadiation,
  }) {
    const double maxSubStep = 1800.0; // 30 mins
    int steps = (dt / maxSubStep).ceil().clamp(1, 100);
    double actualDt = dt / steps;

    Plant currentPlant = plant;
    for (int s = 0; s < steps; s++) {
      currentPlant = _solveStep(
        currentPlant,
        profile,
        actualDt,
        airTemperature: airTemperature,
        atmCO2: atmCO2,
        relativeHumidity: relativeHumidity,
        solarRadiation: solarRadiation,
      );
    }
    return currentPlant;
  }

  static Plant _solveStep(
    Plant plant,
    SoilProfile profile,
    double dt, {
    double airTemperature = 293.15,
    double atmCO2 = SimulationConstants.atmCO2Default,
    double relativeHumidity = 0.5,
    double? solarRadiation,
  }) {
    // 1. Calculate root layer weights for water/nutrient distribution
    final (layerWeights, totalRootWeight) =
        RootArchitectureSolver.calculateLayerWeights(plant, profile);

    // 2. SPAC Hydraulics - THE KEY IMPROVEMENT
    // Calculate VPD with actual relative humidity
    final vpd = PlantHydraulicsSolver.calculateVPD(
      airTemperature,
      relativeHumidity: relativeHumidity,
    );

    // Calculate actual transpiration (limited by soil water availability)
    // This replaces the old "potential = actual" assumption
    final spacResult = PlantHydraulicsSolver.calculateActualTranspiration(
      plant,
      profile,
      layerWeights,
      totalRootWeight,
      vpd,
      plant.psiLeaf, // Previous leaf water potential
      dt,
    );

    // Calculate turgor from leaf water potential (not soil potential!)
    final turgor = PlantHydraulicsSolver.calculateTurgor(spacResult.psiLeaf);

    // Calculate water stress for growth reduction and visualization
    final waterStress = PlantHydraulicsSolver.calculateWaterStressIndex(
      spacResult.psiLeaf,
    );
    final rwc = PlantHydraulicsSolver.calculateRWC(spacResult.psiLeaf);

    // 3. Nutrients & Stress Factors
    // Use ACTUAL transpiration for nutrient uptake (mass flow)
    final (
      nUptake,
      pUptake,
      caUptake,
      mgUptake,
      nStress,
      pStress,
    ) = PlantNutrientUptakeSolver.calculateNutrientStress(
      plant,
      profile,
      layerWeights,
      totalRootWeight,
      spacResult.transpiration,
    );
    final combinedNutrientStress = math.min(nStress, pStress);
    final toxicity = PlantNutrientUptakeSolver.calculateToxicityFactor(
      plant,
      profile,
    );

    // CO2 Fertilization Effect
    final double co2Factor =
        (atmCO2 / (atmCO2 + SimulationConstants.co2HalfSat)) / (SimulationConstants.atmCO2Default / (SimulationConstants.atmCO2Default + SimulationConstants.co2HalfSat));

    // 4. Growth & Biomass
    // Growth is now also reduced by water stress
    final waterStressFactor =
        1.0 - waterStress * 0.8; // Max 80% reduction under severe stress
    final growthRate =
        PlantBiomassSolver.calculateGrowthRate(
          plant,
          turgor,
          combinedNutrientStress,
          toxicity,
          co2Factor,
        ) *
        waterStressFactor;

    // Calculate PAR from solar radiation (W/m² to µmol m⁻² s⁻¹, factor ≈ 4.57)
    // Reference: McCree (1972)
    final double par = solarRadiation != null ? solarRadiation * 4.57 : 500.0;

    final (newTotalB, newRootB) = PlantBiomassSolver.calculateBiomass(
      plant,
      growthRate,
      co2Factor,
      airTemperature - 273.15,
      dt,
      co2Concentration: atmCO2,
      par: par,
    );

    final newHeight = (plant.height + growthRate * dt).clamp(
      0.0,
      PlantBiomassSolver.maxHeight,
    );
    final newLai = (plant.lai + growthRate * dt * 5.0).clamp(
      0.1,
      PlantBiomassSolver.maxLai,
    );

    // 5. Spatial Root Growth (Pass profile for Hydro/Chemotropism)
    final newRoots = RootArchitectureSolver.growRoots(plant, profile, growthRate, dt);

    // Calculate diagnostic light fields (Beer-Lambert law)
    final double solarW = solarRadiation ?? 800.0;
    final double transmission = math.exp(-0.5 * newLai);
    final double absorbed = solarW * 0.45 * (1.0 - transmission);

    return plant.copyWith(
      height: newHeight,
      lai: newLai,
      turgorPressure: turgor,
      rootSystem: newRoots,
      waterUptake: spacResult.transpiration, // NOW ACTUAL, not potential!
      actualTranspiration: spacResult.transpiration,
      nitrogenUptake: nUptake,
      phosphorusUptake: pUptake,
      calciumUptake: caUptake,
      magnesiumUptake: mgUptake,
      totalBiomass: newTotalB,
      rootBiomass: newRootB,
      age: plant.age + dt / 86400.0,
      // New SPAC state variables
      psiLeaf: spacResult.psiLeaf,
      stomatalConductance: spacResult.gs,
      waterStressIndex: waterStress,
      relativeWaterContent: rwc,
      // Diagnostic light fields
      absorbedPAR: absorbed,
      lightTransmission: transmission,
    );
  }

  /// Calculates sinks for soil layers (water, nutrients, carbon exudation).
  /// Now uses ACTUAL transpiration instead of potential.
  /// Result is accumulated directly into the provided [NutrientBuffer]
  /// without making any allocations.
  static void accumulateSinks(
    Plant plant,
    SoilProfile profile,
    NutrientBuffer buffer, {
    double airTemperature = 293.15,
    double relativeHumidity = 0.5,
  }) {
    final (layerWeights, totalRootWeight) =
        RootArchitectureSolver.calculateLayerWeights(plant, profile);

    // Use plant's actual transpiration (already calculated with SPAC)
    // This ensures consistency between plant state and soil sinks
    final actualTrans = plant.actualTranspiration;

    if (totalRootWeight > 0 && actualTrans > 0) {
      for (int i = 0; i < profile.layers.length; i++) {
        final weight = (layerWeights[i] / totalRootWeight);

        // Compensatory uptake: wetter layers contribute more
        // This is already accounted for in layerWeights via PlantHydraulicsSolver
        final double uptakeVelocity = weight * actualTrans;
        final layer = profile.layers[i];

        buffer.nitrate[i] +=
            uptakeVelocity * layer.nitrateContent / layer.thickness;
        buffer.ammonium[i] +=
            uptakeVelocity * layer.ammoniumContent / layer.thickness;
        buffer.potassium[i] +=
            uptakeVelocity * layer.potassiumContent / layer.thickness;
        buffer.phosphate[i] +=
            uptakeVelocity * layer.phosphateContent / layer.thickness;
        buffer.calcium[i] +=
            uptakeVelocity * layer.solutionCalcium / layer.thickness;
        buffer.magnesium[i] +=
            uptakeVelocity * layer.solutionMagnesium / layer.thickness;

        // Root exudation increases under stress (priming effect)
        // Reference: Canarini et al. (2019) - Root exudation and drought
        final double stressFactor = 1.0 + plant.waterStressIndex * 0.5;
        const double exudationFraction = 0.15;
        buffer.carbonSource[i] +=
            exudationFraction *
            stressFactor *
            1e-6 *
            plant.lai /
            layer.thickness;
      }
    }
  }
}
