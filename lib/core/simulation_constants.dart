import 'model_config.dart';

/// Central repository for physical and visual simulation constants.
/// Ensures unified behavior across solvers and Flame components.

class SimulationConstants {
  // ============ TIME & INTEGRATION ============

  /// Base delta time multiplier for time scaling.
  static double get baseTickDelta =>
      ModelConfig.of('baseTickDelta'); // Reduced from 10.0

  /// Maximum duration of a single integration sub-step [seconds].
  static double get maxSubStep => ModelConfig.of('maxSubStep');

  /// Maximum number of sub-steps allowed per tick to prevent CPU lock.
  static int get maxSubStepsPerTick =>
      ModelConfig.of('maxSubStepsPerTick').toInt();

  // ============ BIOPHYSICAL BOUNDARIES ============

  static double get organicMatterMax => ModelConfig.of('organicMatterMax');

  // ============ VISUALIZATION SCALING ============

  /// Density factor for nitrate mass flow particles.
  static const double massFlowVisualDensity = 3e5;

  /// Density factor for nitrification flux particles.
  static const double nitrificationVisualDensity = 5e5;

  /// Minimum flux to trigger visual movement [m/s].
  static const double minVisualFlux = 1e-6;

  /// Base speed for molecule particles [px/s].
  static const double particleBaseSpeed = 25.0; // Reduced from 40.0

  /// Scaling factor for converting flux to particle speed.
  static const double fluxToSpeedScale = 5e6; // Reduced from 1e7

  // ============ COMPONENT LAYOUT ============

  /// Minimum distance between technical nodes (Nutrients/Sensors) [px].
  static const double minNodeDistance = 75.0;

  /// Number of iterations for the node repulsion physics.
  static const int nodeRepulsionIterations = 30;

  /// Zoom level threshold for showing high-detail icons.
  static const double detailZoomThreshold = 5.5;

  /// Seconds between repeats of the same process label.
  static const double processLabelInterval = 4.0;

  /// Absorbed PAR at which the photosynthesis label reaches full strength
  /// [W/m²]. A developing canopy absorbs far less than incident sunlight.
  static const double photosynthesisLabelFullScale = 50.0;

  // ============ PARTICLE PHYSICS ============

  /// Target C:N ratio for microbial growth.
  static double get microbialCnTarget => ModelConfig.of('microbialCnTarget');

  /// Base jitter strength for Brownian motion.
  static const double particleJitterBase = 12.0; // Reduced from 18.0

  /// Force scaling for attractor hotspots.
  static const double attractorForceScale = 800.0; // Reduced from 1500.0

  /// Attraction radius for interaction (Mining/Consumption) [px].
  static const double interactionDistance = 30.0;

  /// Duration of a single physics tick in the isolate [ms].
  static const int physicsTickMs = 34; // Approx 30 FPS

  // ============ GASES & ATMOSPHERE ============

  /// Default atmospheric CO2 concentration [mol m⁻³] (≈ 415 ppm at STP).
  static double get atmCO2Default => ModelConfig.of('atmCO2Default');

  /// CO2 half-saturation constant for fertilization effect.
  static double get co2HalfSat => ModelConfig.of('co2HalfSat');

  // ============ ENERGY & THERMODYNAMICS ============

  /// Default air emissivity.
  static double get airEmissivity => ModelConfig.of('airEmissivity');

  /// Base sub-step for energy integration [s].
  static double get energySubStep => ModelConfig.of('energySubStep');

  /// Default base air temperature [K].
  static double get baseAirTemperature => ModelConfig.of('baseAirTemperature');

  // ============ PLANT BIOLOGY ============

  /// Base growth step for roots [m].
  static double get rootGrowthStep => ModelConfig.of('rootGrowthStep');

  /// Base branching step for roots [m].
  static double get rootBranchStep => ModelConfig.of('rootBranchStep');

  /// Maximum allowed root nodes per plant.
  static int get maxRootsPerPlant => ModelConfig.of('maxRootsPerPlant').toInt();

  /// Nitrogen half-saturation constant (Km_N) for uptake [mg/kg].
  static double get nitrogenHalfSat => ModelConfig.of('nitrogenHalfSat');

  // ============ AGGREGATION & CARBON CYCLE ============

  /// Base production rate of EPS [kg EPS / kg biomass / s].
  static double get epsProdBase => ModelConfig.of('epsProdBase');

  /// Base decay rate of EPS [s⁻¹].
  static double get epsDecayBase => ModelConfig.of('epsDecayBase');

  /// Base growth rate of fungi [s⁻¹].
  static double get fungiGrowthBase => ModelConfig.of('fungiGrowthBase');

  /// Base death rate of fungi [s⁻¹].
  static double get fungiDeathBase => ModelConfig.of('fungiDeathBase');

  /// Base death rate for microbial biomass [s⁻¹].
  static double get microbialDeathRate => ModelConfig.of('microbialDeathRate');

  /// Fraction of dead microbial biomass stabilized into MAOM.
  static double get maomStabRate => ModelConfig.of('maomStabRate');

  /// Rate of change for saturated hydraulic conductivity [s⁻¹].
  static double get ksatChangeRate => ModelConfig.of('ksatChangeRate');

  // ============ HYDROLOGY ============

  /// Base evaporation rate per degree Celsius [m/s/°C].
  static double get evapBaseRate => ModelConfig.of('evapBaseRate');

  /// Minimum volumetric water content buffer above residual moisture.
  static double get thetaMinBuffer => ModelConfig.of('thetaMinBuffer');
}
