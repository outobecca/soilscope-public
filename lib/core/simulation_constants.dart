/// Central repository for physical and visual simulation constants.
/// Ensures unified behavior across solvers and Flame components.
class SimulationConstants {
  // ============ TIME & INTEGRATION ============
  
  /// Base delta time multiplier for time scaling.
  static const double baseTickDelta = 2.0; // Reduced from 10.0
  
  /// Maximum duration of a single integration sub-step [seconds].
  static const double maxSubStep = 600.0;
  
  /// Maximum number of sub-steps allowed per tick to prevent CPU lock.
  static const int maxSubStepsPerTick = 50;

  // ============ BIOPHYSICAL BOUNDARIES ============

  static const double nitrateMax = 1000.0;
  static const double ammoniumMax = 500.0;
  static const double phosphateMax = 1000.0;
  static const double potassiumMax = 1000.0;
  static const double organicMatterMax = 2000.0;

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

  // ============ PARTICLE PHYSICS ============

  /// C:N ratio threshold for N immobilization.
  static const double immobilizationCnThreshold = 25.0;

  /// Target C:N ratio for microbial growth.
  static const double microbialCnTarget = 15.0;

  /// Base jitter strength for Brownian motion.
  static const double particleJitterBase = 12.0; // Reduced from 18.0

  /// Force scaling for attractor hotspots.
  static const double attractorForceScale = 800.0; // Reduced from 1500.0

  /// Attraction radius for interaction (Mining/Consumption) [px].
  static const double interactionDistance = 30.0;

  /// Duration of a single physics tick in the isolate [ms].
  static const int physicsTickMs = 34; // Approx 30 FPS

  // ============ GASES & ATMOSPHERE ============

  /// Universal Gas Constant [J mol⁻¹ K⁻¹].
  static const double gasConstant = 8.314;

  /// Default atmospheric CO2 concentration [mol m⁻³] (≈ 415 ppm at STP).
  static const double atmCO2Default = 0.017;

  /// CO2 half-saturation constant for fertilization effect.
  static const double co2HalfSat = 0.005;

  // ============ ENERGY & THERMODYNAMICS ============

  /// Stefan-Boltzmann constant [W m⁻² K⁻⁴].
  static const double stefanBoltzmann = 5.67e-8;

  /// Default soil emissivity.
  static const double soilEmissivity = 0.95;

  /// Default air emissivity.
  static const double airEmissivity = 0.75;

  /// Peak solar constant [W m⁻²].
  static const double solarConstantPeak = 800.0;

  /// Base sub-step for energy integration [s].
  static const double energySubStep = 60.0;

  /// Default base air temperature [K].
  static const double baseAirTemperature = 293.15;

  // ============ PLANT BIOLOGY ============

  /// Growth rate of mycorrhizal hyphae [m/day].
  static const double hyphalGrowthRate = 0.005;

  /// Initial root thickness [m].
  static const double initialRootRadius = 0.025;

  /// Base growth step for roots [m].
  static const double rootGrowthStep = 0.005;

  /// Base branching step for roots [m].
  static const double rootBranchStep = 0.004;

  /// Maximum allowed root nodes per plant.
  static const int maxRootsPerPlant = 350;

  /// Energy cost scaling factor for root growth.
  static const double rootEnergyCostFactor = 120.0;

  /// Nitrogen half-saturation constant (Km_N) for uptake [mg/kg].
  static const double nitrogenHalfSat = 15.0;

  /// Maintenance respiration fraction of total biomass [day⁻¹].
  static const double maintenanceRespirationFraction = 0.002;

  // ============ AGGREGATION & CARBON CYCLE ============

  /// Base production rate of EPS [kg EPS / kg biomass / s].
  static const double epsProdBase = 1.0e-6;

  /// Base decay rate of EPS [s⁻¹].
  static const double epsDecayBase = 5.0e-7;

  /// Base growth rate of fungi [s⁻¹].
  static const double fungiGrowthBase = 1.0e-7;

  /// Base death rate of fungi [s⁻¹].
  static const double fungiDeathBase = 2.0e-7;

  /// Base mineralization rate for POM [s⁻¹].
  static const double pomMinRate = 1.0e-8;

  /// Base death rate for microbial biomass [s⁻¹].
  static const double microbialDeathRate = 5.0e-8;

  /// Fraction of dead microbial biomass stabilized into MAOM.
  static const double maomStabRate = 0.4;

  /// Rate of change for saturated hydraulic conductivity [s⁻¹].
  static const double ksatChangeRate = 1.0e-8;

  // ============ HYDROLOGY ============

  /// Base evaporation rate per degree Celsius [m/s/°C].
  static const double evapBaseRate = 1.0e-8;

  /// Minimum volumetric water content buffer above residual moisture.
  static const double thetaMinBuffer = 0.001;
}
