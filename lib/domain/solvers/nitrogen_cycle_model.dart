import 'dart:math' as math;
import '../models/soil_layer.dart';
import '../../core/biophysics_utils.dart';

class NitrogenCycleModel {
  /// Optimal C/N ratio for soil microbes
  static const double microbialTargetCN = 10.0;

  /// Carbon Use Efficiency (CUE) - fraction of assimilated C that goes to biomass
  static const double cue = 0.4;

  /// Runs one time step of the nitrogen cycle using Euler integration.
  /// Based on Schimel & Bennett (2004) and DNDC anaerobic rules.
  static SoilLayer tick(double dt, SoilLayer layer) {
    // Current Pools (mg/kg)
    double pomN = layer.organicNitrogen;
    double micN = layer.microbialNitrogen;
    double nh4 = layer.ammoniumContent;
    double no3 = layer.nitrateContent;

    // Environmental Factors
    final double fTemp = BiophysicsUtils.q10Factor(layer.temperature);
    final double airFilledPorosity = (layer.porosity - layer.waterContent)
        .clamp(0.0, 1.0);
    final double fWaterAerobic = airFilledPorosity > 0.05
        ? 1.0
        : (airFilledPorosity / 0.05);
    final double fWaterAnaerobic = 1.0 - fWaterAerobic;
    final double fO2 = (layer.oxygenContent / BiophysicsUtils.atmO2Saturation).clamp(0.0, 1.0);

    // --- A. DEPOLYMERIZATION & MINERALIZATION ---
    // Handled exclusively by MicrobialEnzymesSolver to prevent double-counting.
    // Organic N mineralisation is driven by cellulase/protease/urease enzyme
    // kinetics (Schimel & Weintraub 2003, Soil Biol. Biochem. 35:549-563),
    // which provide mechanistically richer substrate-limitation than the
    // simple first-order decay used in early DNDC-style N cycle models.

    // --- B. IMMOBILIZATION (C/N > 30) ---
    double nImmobilized = 0.0;
    double nh4Imm = 0.0;
    double no3Imm = 0.0;
    if (layer.cnRatio > 30.0) {
      // Microbes scavenge mineral N when carbon is abundant but N is poor
      const double kImm = 2.0e-5;
      final double targetN = (layer.labileCarbon / 8.0).clamp(0.0, 500.0);
      if (micN < targetN) {
        nImmobilized = (kImm * (targetN - micN) * fTemp * dt).clamp(0.0, (nh4 + no3) * 0.5);
        if (nImmobilized > 0) {
          final double totalN = nh4 + no3 + 1e-10;
          nh4Imm = nImmobilized * (nh4 / totalN);
          no3Imm = nImmobilized * (no3 / totalN);
        }
      }
    }

    // --- C. NITRIFICATION (NH4 -> NO3) ---
    const double kNit = 1.0e-6;
    final double fPhNit = math.exp(-0.5 * math.pow(layer.ph - 7.5, 2.0));
    // Nitrification is strictly aerobic: suppressed by low O2 AND low Redox
    final double fRedoxNit = (layer.redoxPotential > 500) 
        ? 1.0 
        : (layer.redoxPotential / 500.0).clamp(0.0, 1.0);
    final double nitRate = kNit * fTemp * fPhNit * fO2 * fRedoxNit;
    final double nNitrified = nh4 * nitRate * dt;

    // --- D. DENITRIFICATION (NO3 -> Gas Loss) ---
    // Triggered by low Redox/Hypoxia (DNDC logic)
    // Denitrification is a form of anaerobic respiration where NO3- is the TEA.
    const double kDenit = 5.0e-6;
    // Critical Eh threshold for denitrification approx 200-300 mV
    double fEhDenit = layer.redoxPotential < 250
        ? 1.0
        : math.exp(-0.01 * (layer.redoxPotential - 250));
    
    // Coupling to Carbon (Anaerobic Respiration)
    // Denitrification requires labile carbon as an electron donor
    final double fCDenit = (layer.labileCarbon / (50.0 + layer.labileCarbon)).clamp(0.1, 1.0);
    
    final double denitRate = kDenit * fTemp * fWaterAnaerobic * fEhDenit * fCDenit;
    final double nDenitrified = no3 * denitRate * dt;
    
    // Stoichiometry: 1 mg NO3- reduced approx oxidizes 0.8 mg Labile C
    // Reference: Reddy & DeLaune (2008) - Heterotrophic denitrification
    final double cOxidizedAnaerobic = nDenitrified * 0.8; 
    final double newLabileC = (layer.labileCarbon - cOxidizedAnaerobic).clamp(0.0, 1000.0);

    // --- E. BIOLOGICAL NITROGEN FIXATION (BNF) ---
    // Minimal base rate, boosted by low mineral N and presence of exudates
    const double kBNF = 1.0e-8;
    final double fNInhibition = math.exp(-0.1 * (nh4 + no3));
    final double nFixed = kBNF * fTemp * fNInhibition * (1.0 + layer.labileCarbon * 0.01) * dt;

    // --- EULER INTEGRATION (Pool Updates) ---
    // POM-N is unchanged here; MicrobialEnzymesSolver is responsible for
    // depolymerization of organic N (protease / urease).
    double newPomN = pomN.clamp(0.0, 10000.0);
    double newMicN = (micN + nImmobilized + nFixed).clamp(0.0, 1000.0);

    double newNh4 = (nh4 - nNitrified - nh4Imm + nFixed).clamp(0.0, 500.0);
    double newNo3 = (no3 + nNitrified - nDenitrified - no3Imm).clamp(
      0.0,
      1000.0,
    );
    
    // Update gas pools (simplified stoichiometry)
    // Denitrification produces N2O (intermediate) and N2 (end product)
    // Here we track N2O accumulation (mol/m^3)
    final double n2oProduced = (nDenitrified * layer.bulkDensity * 1e-6) / 28.0; // mg/kg to mol/m^3

    // Task 3/6: MAOM-N turnover (stabilization of necromass) moved to AggregationSolver.
    // This ensures that stable N accumulation is strictly coupled with stable C (MAOM-C).

    return layer.copyWith(
      organicNitrogen: newPomN,
      microbialNitrogen: newMicN,
      ammoniumContent: newNh4,
      nitrateContent: newNo3,
      nitrogenContent: newNh4 + newNo3,
      nitrificationRate: nitRate,
      denitrificationRate: denitRate,
      nitrousOxideContent: (layer.nitrousOxideContent + n2oProduced).clamp(0.0, 1.0),
      labileCarbon: newLabileC,
      particulateOrganicMatter: newLabileC,
      organicCarbon: newLabileC + layer.mineralAssociatedOrganicMatter,
    );
  }
}
