import 'dart:math' as math;
import '../../models/plant.dart';
import '../../models/soil_profile.dart';
import '../../../core/simulation_constants.dart';

/// Logic for plant nutrient uptake and stress factors (N-stress, Toxicity).
class PlantNutrientUptakeSolver {
  /// Calculates actual nutrient uptake and stress factors for N, P, Ca, and Mg.
  static (double nUptake, double pUptake, double caUptake, double mgUptake, double nStress, double pStress) calculateNutrientStress(
    Plant plant,
    SoilProfile profile,
    List<double> layerWeights,
    double totalRootWeight,
    double potTranspiration,
  ) {
    double nUptake = 0.0;
    double pUptake = 0.0;
    double caUptake = 0.0;
    double mgUptake = 0.0;

    if (totalRootWeight > 0) {
      for (int i = 0; i < profile.layers.length; i++) {
        if (layerWeights[i] > 0) {
          final layerUptake =
              (layerWeights[i] / totalRootWeight) * potTranspiration;
          final layer = profile.layers[i];
          
          // pH Modulator for P availability
          double pAvailability = 1.0;
          if (layer.ph < 6.0) {
             pAvailability = math.max(0.2, 1.0 - (6.0 - layer.ph)); 
          } else if (layer.ph > 7.5) {
             pAvailability = math.max(0.4, 1.0 - (layer.ph - 7.5) * 0.5);
          }

          // EC Modulator for Osmotic Stress
          double ecFactor = 1.0;
          if (layer.ec > 2.5) {
             ecFactor = math.exp(-(layer.ec - 2.5) * 0.5); 
          }

          final effectiveLayerUptake = layerUptake * ecFactor;

          nUptake +=
              effectiveLayerUptake * (layer.nitrateContent + layer.ammoniumContent);
          pUptake += effectiveLayerUptake * (layer.phosphateContent * pAvailability);
          
          // Ca and Mg are taken up via mass flow from solution
          // We convert mg/L to mg/kg proxy for consistent units in uptake accumulation
          caUptake += effectiveLayerUptake * layer.solutionCalcium;
          mgUptake += effectiveLayerUptake * layer.solutionMagnesium;
        }
      }
    }

    // Michaelis-Menten nutrient stress response
    const double kmN = SimulationConstants.nitrogenHalfSat;
    const double kmP = 5.0; // Half-saturation for Phosphorus (~5 mg/kg)
    
    // Normalized nutrient availability relative to demand (LAI as proxy for demand)
    final double demandN = plant.lai * 20.0 + 1.0; 
    final double demandP = plant.lai * 5.0 + 0.5;

    final double concentrationN = nUptake / (demandN * 1e-8 + 1e-12);
    final double concentrationP = pUptake / (demandP * 1e-8 + 1e-12);
    
    final double nStressFactor = (concentrationN / (kmN + concentrationN)).clamp(
      0.1,
      1.0,
    );
    final double pStressFactor = (concentrationP / (kmP + concentrationP)).clamp(
      0.1,
      1.0,
    );
    
    return (nUptake, pUptake, caUptake, mgUptake, nStressFactor, pStressFactor);
  }

  /// Calculates growth toxicity factor based on pH and roots in layers.
  static double calculateToxicityFactor(Plant plant, SoilProfile profile) {
    double toxicityFactor = 1.0;
    if (plant.rootSystem.isEmpty) return 1.0;

    for (final layer in profile.layers) {
      final double rootWeight =
          plant.rootSystem
              .where(
                (n) =>
                    n.z >= layer.depth && n.z <= layer.depth + layer.thickness,
              )
              .length /
          plant.rootSystem.length.toDouble();

      if (layer.ph < 5.5) {
        final alTox = (layer.exchangeableAluminium / 150.0).clamp(0.0, 0.7);
        toxicityFactor -= alTox * rootWeight;
      }
    }
    return toxicityFactor.clamp(0.1, 1.0);
  }
}
