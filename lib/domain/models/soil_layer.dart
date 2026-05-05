import 'package:freezed_annotation/freezed_annotation.dart';

part 'soil_layer.freezed.dart';
part 'soil_layer.g.dart';

@Freezed(fromJson: true, toJson: true)
abstract class SoilLayer with _$SoilLayer {
  const factory SoilLayer({
    required String id,
    required double depth, // m
    required double thickness, // m
    // Physical properties
    required double kSat, // Hydraulic conductivity (m/s)
    required double porosity, // (0.0 - 1.0) - also thetaS
    required double thetaR, // Residual water content
    required double vgAlpha, // van Genuchten alpha (1/m)
    required double vgN, // van Genuchten n
    @Default(0.5) double vgL, // Tortuosity parameter
    required double bulkDensity, // (kg/m^3)
    required double waterContent, // (m^3/m^3)
    @Default(0.0) double previousWaterContent,
    @Default(0.0) double verticalFlux, // m/s (Net flux within layer)
    required double temperature, // K
    required double heatCapacity, // J/(m^3*K) (volumetric heat capacity Cv)
    // Chemical properties
    required double ph,
    required double ec, // Electrical conductivity (dS/m)
    required double redoxPotential, // Eh (mV)
    required double nitrateContent, // mg/kg
    required double ammoniumContent, // mg/kg
    required double phosphateContent, // mg/kg (solution pool)
    @Default(0.0) double sorbedPhosphate, // mg/kg (solid pool)
    @Default(5.0) double potassiumContent, // mg/kg (solution pool)
    @Default(50.0) double exchangeablePotassium, // mg/kg
    @Default(100.0) double solutionCalcium, // mg/kg
    @Default(1000.0) double exchangeableCalcium, // mg/kg
    @Default(20.0) double solutionMagnesium, // mg/kg
    @Default(200.0) double exchangeableMagnesium, // mg/kg
    @Default(5.0) double exchangeableAluminium, // mg/kg
    @Default(10.0) double cec, // cmol(+)/kg
    @Default(0.2) double clayFraction, // (0.0 - 1.0)
    @Default(0.4) double sandFraction, // (0.0 - 1.0)
    @Default(0.4) double siltFraction, // (0.0 - 1.0)
    @Default(0.0) double effectiveMacroPorosity, // (0.0 - 1.0)
    @Default(0.5) double aggregateStability, // (0.0 - 1.0)
    @Default(8.5) double oxygenContent, // mol/m^3 (approx 21% air at 20C)
    @Default(0.02) double co2Content, // mol/m^3 (approx 400 ppm)
    @Default(0.0) double methaneContent, // mol/m^3
    @Default(0.0) double nitrousOxideContent, // mol/m^3
    @Default(1.0) double thermalConductivity, // W/m*K
    // Biological properties
    required double microbialBiomass, // (kg/m^3)
    required double epsContent, // Extracellular Polymeric Substances
    required double fungalHyphaeDensity,
    required double necromass, // Stabilized organic matter (MAOM)
    // Carbon/Nutrients
    required double organicCarbon,
    required double particulateOrganicMatter, // Labile (POM) (kg/m^3)
    required double mineralAssociatedOrganicMatter, // Stable (MAOM) (kg/m^3)
    // Cultivation / Tillage
    @Default(false) bool isCultivated,
    @Default(0.0) double cultivationDisturbance, // 0.0 to 1.0 (1.0 = fully disturbed)
    @Default(0.0) double labileCarbon, // Alias/Specific pool for POM
    @Default(0.0) double stableCarbon, // Alias/Specific pool for MAOM
    @Default(100.0) double organicNitrogen, // mg/kg (POM-N pool)
    @Default(10.0) double microbialNitrogen, // mg/kg (Mic-N pool)
    @Default(50.0) double maomNitrogen, // mg/kg (MAOM-N pool)
    required double nitrogenContent,
    
    // === NEW DIAGNOSTIC FLUXES ===
    @Default(0.0) double nitrificationRate, // mg/kg/s
    @Default(0.0) double denitrificationRate, // mg/kg/s
    
    @Default({}) Map<String, double> traceElements,
  }) = _SoilLayer;

  const SoilLayer._();

  factory SoilLayer.fromJson(Map<String, dynamic> json) =>
      _$SoilLayerFromJson(json);

  double get aluminumLevel {
    // Al solubility increases exponentially below pH 5.5
    if (ph >= 5.5) return 0.0;
    return (5.5 - ph) * 2.0; // Simplified scale
  }

  double get cnRatio {
    // Total C in kg/m^3
    final double totalC = organicCarbon;
    
    // Convert TOC to mg/kg to match Nitrogen pools
    final double tocMgKg = (totalC * 1e6) / bulkDensity;
    final double totalN = nitrateContent + ammoniumContent + organicNitrogen + maomNitrogen;
    
    if (totalN <= 0) return 99.0;
    
    // Apply 0.1 scaling factor to adjust for low default organic Nitrogen pool values
    final double calculatedRatio = (tocMgKg / totalN) * 0.1;
    return calculatedRatio.clamp(5.0, 50.0);
  }

  double get calculatedEC {
    // Electrical Conductivity (EC) approximation (dS/m)
    // Formula: EC ≈ 0.1 * Σ(C_i * |z_i|) in meq/L
    // Conversion: meq/L = (mg/kg * bulkDensity) / (EquivalentWeight * waterContent)
    
    final theta = waterContent.clamp(0.01, 1.0);
    final rho = bulkDensity;
    
    double totalMeqL = 0;
    
    // Anions
    totalMeqL += (nitrateContent * rho) / (62.0 * theta * 1000.0); // NO3-
    totalMeqL += (phosphateContent * rho) / (97.0 * theta * 1000.0); // H2PO4-
    
    // Cations
    totalMeqL += (ammoniumContent * rho) / (18.0 * theta * 1000.0); // NH4+
    totalMeqL += (potassiumContent * rho) / (39.1 * theta * 1000.0); // K+
    totalMeqL += (solutionCalcium * rho) / (20.05 * theta * 1000.0); // Ca2+
    totalMeqL += (solutionMagnesium * rho) / (12.15 * theta * 1000.0); // Mg2+
    
    // Add contribution from other trace elements (average eq weight ~35)
    for (final val in traceElements.values) {
       totalMeqL += (val * rho) / (35.0 * theta * 1000.0);
    }
    
    // Base salinity factor related to clay content (intrinsic salts)
    final salinityBase = clayFraction * 1.5;
    
    return (totalMeqL * 0.1) + (salinityBase * 0.05);
  }

  double get organicMatterContent {
    // Standard conversion: OM = SOC * 1.724 (Van Bemmelen factor)
    // SOC is organicCarbon in kg/m3. 
    // Usually expressed as fraction or percentage. 
    // Let's return the fraction (0.0 to 1.0) for normalization.
    return (organicCarbon / bulkDensity) * 1.724;
  }

  double get microbialActivity {
    // Based on user prompt: (oxygen * phScale) - (aluminumLevel * 0.5)
    final phScale = (ph - 4.0).clamp(0.0, 3.0) / 3.0; // 0 at pH 4, 1 at pH 7
    final activity = (oxygenContent * phScale) - (aluminumLevel * 0.5);
    return activity.clamp(0.0, double.infinity);
  }
}
