import 'dart:math' as math;
import '../../models/plant.dart';
import '../../models/soil_profile.dart';
import '../../models/soil_layer.dart';
import '../../../core/simulation_constants.dart';

/// Logic for plant nutrient uptake and stress factors (N-stress, Toxicity).
/// Implements biophysical transport mechanisms based on Finnish botanical definitions:
/// - Proton Pumps (H+-ATPase): Energy-dependent H+ efflux maintaining gradient.
/// - Ion Channels: Passive transport for K+, Ca2+, Mg2+.
/// - Symporters: Secondary active transport for NO3-, H2PO4- using H+ gradient.
/// - Antiporters: Secondary active transport for ion sequestration (e.g. Na+).
class PlantNutrientUptakeSolver {
  // ============ BIOPHYSICAL CONSTANTS ============
  
  /// Target membrane potential (V) - typical root cell is -140mV
  static const double targetVm = -0.14; 
  
  /// Faraday constant (C/mol)
  static const double faraday = 96485.3;
  
  /// Gas constant (J/mol*K)
  static const double gasConstant = 8.314;

  /// Calculates actual nutrient uptake and stress factors.
  static (double nUptake, double pUptake, double caUptake, double mgUptake, double nStress, double pStress, List<SoilLayer> updatedLayers) calculateNutrientStress(
    Plant plant,
    SoilProfile profile,
    List<double> layerWeights,
    double totalRootWeight,
    double actualTranspiration,
    double dt,
  ) {
    double totalNUptake = 0.0;
    double totalPUptake = 0.0;
    double totalCaUptake = 0.0;
    double totalMgUptake = 0.0;
    
    final List<SoilLayer> nextLayers = List.from(profile.layers);

    // ATP availability based on plant biomass and turgor (energy proxy)
    final double atpAvailability = (plant.totalBiomass / 1000.0).clamp(0.1, 1.5) * plant.turgorPressure;

    if (totalRootWeight > 0) {
      for (int i = 0; i < profile.layers.length; i++) {
        final layer = profile.layers[i];
        
        // --- HOTSPOT MAINTENANCE ---
        final rootTipsInLayer = plant.rootSystem.where((n) => 
          n.isTip && n.z >= layer.depth && n.z <= layer.depth + layer.thickness
        ).toList();
        
        final updatedLayer = updateLayerHotspots(layer, rootTipsInLayer, atpAvailability, dt);
        nextLayers[i] = updatedLayer;

        if (layerWeights[i] > 0) {
          final double rootFraction = layerWeights[i] / totalRootWeight;
          
          // 1. Proton Pump Activity (H+ Efflux)
          // Pumps H+ out, creating a gradient and acidifying the rhizosphere.
          final hEfflux = _calculateProtonPumpFlux(layer.ph, atpAvailability);
          
          // HOTSPOT BOOST: Hotspots aggregate H+ efflux significantly
          final double hotspotIntensity = updatedLayer.hotspots.fold(0.0, (sum, h) => sum + h.intensity);
          final double totalHEfflux = hEfflux * (1.0 + hotspotIntensity * 2.0);

          // 2. Transporter-Specific Fluxes (mg/kg/s proxy)
          
          // Nitrate (NO3-) - Symporters (uses H+ gradient)
          final nFlux = _calculateSymportFlux(
            layer.nitrateContent + layer.ammoniumContent, 
            layer.ph, 
            targetVm, 
            atpAvailability,
          );
          
          // Phosphate (H2PO4-) - Symporters (highly pH sensitive)
          double pAvailability = 1.0;
          if (layer.ph < 6.0) {
             pAvailability = math.max(0.2, 1.0 - (6.0 - layer.ph)); 
          } else if (layer.ph > 7.5) {
             pAvailability = math.max(0.4, 1.0 - (layer.ph - 7.5) * 0.5);
          }
          
          // Hotspot bonus for P availability (organic acid exudation proxy)
          pAvailability = (pAvailability * (1.0 + hotspotIntensity * 0.5)).clamp(0.0, 1.0);

          final pFlux = _calculateSymportFlux(
            layer.phosphateContent * pAvailability, 
            layer.ph, 
            targetVm, 
            atpAvailability,
          );
          
          // Ca and Mg - Passive Channels
          final caFlux = _calculateChannelFlux(layer.solutionCalcium, 2.0, targetVm, layer.temperature);
          final mgFlux = _calculateChannelFlux(layer.solutionMagnesium, 2.0, targetVm, layer.temperature);

          // 3. Mass Flow contribution (Transpiration-driven)
          final massFlowUptake = (layerWeights[i] / totalRootWeight) * actualTranspiration;

          // 4. Update Layer Chemistry Feedback
          // Acidification from H+ Efflux (approximate pH change)
          final double phChange = -totalHEfflux * dt * 0.1;
          // Labile carbon exudation into hotspots
          final double carbonExudation = hotspotIntensity * atpAvailability * dt * 0.001;

          nextLayers[i] = updatedLayer.copyWith(
            ph: (updatedLayer.ph + phChange).clamp(3.5, 9.5),
            labileCarbon: updatedLayer.labileCarbon + carbonExudation,
          );

          // Aggregate into plant uptake totals
          const double baseEff = 0.05;
          totalNUptake += (nFlux * baseEff + massFlowUptake * (layer.nitrateContent + layer.ammoniumContent)) * rootFraction;
          totalPUptake += (pFlux * baseEff + massFlowUptake * (layer.phosphateContent * pAvailability)) * rootFraction;
          totalCaUptake += (caFlux * baseEff + massFlowUptake * layer.solutionCalcium) * rootFraction;
          totalMgUptake += (mgFlux * baseEff + massFlowUptake * layer.solutionMagnesium) * rootFraction;
        }
      }
    }

    // Michaelis-Menten nutrient stress response
    const double kmN = SimulationConstants.nitrogenHalfSat;
    const double kmP = 5.0; 
    
    final double demandN = plant.lai * 20.0 + 1.0; 
    final double demandP = plant.lai * 5.0 + 0.5;

    final double concentrationN = totalNUptake / (demandN * 1e-8 + 1e-12);
    final double concentrationP = totalPUptake / (demandP * 1e-8 + 1e-12);
    
    final double nStressFactor = (concentrationN / (kmN + concentrationN)).clamp(0.1, 1.0);
    final double pStressFactor = (concentrationP / (kmP + concentrationP)).clamp(0.1, 1.0);
    
    return (totalNUptake, totalPUptake, totalCaUptake, totalMgUptake, nStressFactor, pStressFactor, nextLayers);
  }

  /// Manages lifecycle and spatial mapping of rhizosphere hotspots in a layer.
  static SoilLayer updateLayerHotspots(
    SoilLayer layer,
    List<RootNode> rootTipsInLayer,
    double atpAvailability,
    double dt,
  ) {
    final List<RhizosphereHotspot> nextHotspots = [];
    
    // 1. Decay and age existing hotspots
    for (final h in layer.hotspots) {
      final double nextAge = h.age + dt;
      // Hotspots live for ~4 hours simulation time
      if (nextAge < 14400) {
        final double stepDecay = math.exp(-dt / 8000.0);
        nextHotspots.add(h.copyWith(
          age: nextAge,
          intensity: (h.intensity * stepDecay).clamp(0.1, 1.0),
        ));
      }
    }
    
    // 2. Generate/Refresh hotspots from root tips
    for (final tip in rootTipsInLayer) {
      // Tip Z is 0..1 relative to profile. Map to layer-local Z.
      final double localZ = ((tip.z - layer.depth) / layer.thickness).clamp(0.0, 1.0);
      
      // Find if a hotspot already exists near this tip (within 5cm)
      final existingIdx = nextHotspots.indexWhere((h) => 
        (h.x - tip.x).abs() < 0.04 && (h.z - localZ).abs() < 0.04
      );
      
      final double targetIntensity = atpAvailability.clamp(0.2, 1.0);
      
      if (existingIdx != -1) {
        final h = nextHotspots[existingIdx];
        nextHotspots[existingIdx] = h.copyWith(
          intensity: math.max(h.intensity, targetIntensity),
          age: 0, // Keep alive while tip is present
        );
      } else if (nextHotspots.length < 12) { // Cap to avoid state bloat
        nextHotspots.add(RhizosphereHotspot(
          id: "rhizo_${tip.hashCode}_${layer.id}",
          x: tip.x,
          z: localZ,
          intensity: targetIntensity,
          radius: 0.04, 
          age: 0,
          type: HotspotType.rhizosphere,
        ));
      }
    }
    
    return layer.copyWith(hotspots: nextHotspots);
  }

  /// Calculates H+ efflux (mol/m2/s) driven by H+-ATPase
  static double _calculateProtonPumpFlux(double phSoil, double atp) {
    // Cell pH is typically ~7.2
    const double phCell = 7.2;
    final double dpH = phCell - phSoil;
    
    // Nernst potential for H+
    // E_H = (RT/F) * ln([H+]out/[H+]in)
    // E_H = -0.059 * dpH (at 25C)
    final double eh = -0.059 * dpH;
    
    // Driving force = Vm - Eh
    // Pump must overcome this electrochemical gradient
    final double drivingForce = targetVm - eh;
    
    // Flux is proportional to ATP and reduced by high external H+ (low pH)
    // and extreme gradient
    final pumpEfficiency = atp * math.exp(drivingForce * 5.0).clamp(0.0, 1.0);
    return pumpEfficiency * 1e-6; // Base flux magnitude
  }

  /// Calculates passive ion flux through channels using Goldmann-Hodgkin-Katz (GHK) logic
  static double _calculateChannelFlux(double concentration, double z, double vm, double tempK) {
    if (concentration <= 0) return 0.0;
    
    // GHK simplified flux: J = P * z^2 * (VF/RT) * [C] / (1 - exp(-zVF/RT))
    final double f = faraday / (gasConstant * tempK);
    final double xi = z * vm * f;
    
    double ghkFactor;
    if (xi.abs() < 1e-4) {
      ghkFactor = 1.0; // Avoid div by zero
    } else {
      ghkFactor = xi / (1.0 - math.exp(-xi));
    }
    
    return concentration * ghkFactor.abs();
  }

  /// Calculates secondary active transport (Symport) coupled to H+ gradient
  static double _calculateSymportFlux(double substrate, double phSoil, double vm, double atp) {
    if (substrate <= 0) return 0.0;
    
    const double phCell = 7.2;
    final double dpH = phCell - phSoil; // H+ gradient (positive if soil is more acidic)
    
    // Symporters use the H+ influx to pull nutrients in.
    // Efficiency increases with larger H+ gradient (lower soil pH)
    final double drivingForce = dpH + (vm / -0.059); 
    final double efficiency = (drivingForce / 5.0).clamp(0.0, 1.0) * atp;
    
    // Michaelis-Menten on substrate
    const double km = 10.0;
    return efficiency * (substrate / (km + substrate));
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

