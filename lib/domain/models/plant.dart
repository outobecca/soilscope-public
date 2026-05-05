import 'package:freezed_annotation/freezed_annotation.dart';

part 'plant.freezed.dart';
part 'plant.g.dart';

@Freezed(fromJson: true, toJson: true)
abstract class Plant with _$Plant {
  const factory Plant({
    required String id,
    required String species,
    required double age, // days
    required double height, // m
    required double lai, // Leaf Area Index
    required double turgorPressure, // MPa
    @Default(0.5) double baseX,
    required List<RootNode> rootSystem,
    required double nitrogenUptake,
    required double waterUptake,
    @Default(0.0) double phosphorusUptake,
    @Default(0.0) double calciumUptake,
    @Default(0.0) double magnesiumUptake,
    @Default(100.0) double totalBiomass, // mg
    @Default(50.0) double rootBiomass, // mg
    // === NEW SPAC FIELDS (Soil-Plant-Atmosphere Continuum) ===

    /// Leaf water potential [MPa] - key SPAC variable
    /// Represents the water status of leaves, drives stomatal closure
    /// Typical range: 0 (fully hydrated) to -2.0 (severely stressed)
    /// Reference: Hsiao (1973)
    @Default(-0.3) double psiLeaf,

    /// Stomatal conductance [mol H2O m⁻² s⁻¹]
    /// Controls gas exchange (CO2 in, H2O out)
    /// Typical range: 0.05 (closed) to 0.4 (fully open)
    /// Reference: Medlyn et al. (2011)
    @Default(0.3) double stomatalConductance,

    /// Water stress index [0-1], where 0 = no stress, 1 = severe stress
    /// Used for UI visualization and growth reduction
    @Default(0.0) double waterStressIndex,

    /// Relative water content [0-1]
    /// Useful for visualization of plant wilting
    @Default(0.9) double relativeWaterContent,

    /// Actual transpiration rate [m³ H2O m⁻² leaf s⁻¹]
    /// Distinct from potential - limited by soil water availability
    @Default(0.0) double actualTranspiration,

    // === DIAGNOSTIC LIGHT FIELDS ===
    @Default(0.0) double absorbedPAR, // W/m²
    @Default(1.0) double lightTransmission, // 0.0 to 1.0
  }) = _Plant;

  factory Plant.fromJson(Map<String, dynamic> json) => _$PlantFromJson(json);
}

@Freezed(fromJson: true, toJson: true)
abstract class RootNode with _$RootNode {
  const factory RootNode({
    required double x,
    required double z, // depth
    required double radius,
    required bool isTip,
    int? parentIndex, // Index in the rootSystem list
    @Default(0) int branchLevel, // 0 = taproot, 1 = lateral, etc.
    @Default(0) int branchSegmentCount, // segments since branching
  }) = _RootNode;

  factory RootNode.fromJson(Map<String, dynamic> json) =>
      _$RootNodeFromJson(json);
}
