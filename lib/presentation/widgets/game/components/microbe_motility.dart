import 'dart:math' as math;

import 'package:flame/components.dart';

/// Visual-scale motility, feeding and population rules for soil microbes.
///
/// The rendered soil column is one metre deep and about 270 px tall, so a
/// pixel is a few millimetres. Real bacteria self-propel at micrometres per
/// second and are carried passively with soil water; these values deliberately
/// exaggerate speed for legibility while keeping a colony within a few
/// centimetres of a root instead of letting it cross the profile.
///
/// This is the single tuning surface for microbe behaviour. A value that
/// changes how a colony moves, feeds, multiplies on screen or absorbs a
/// nutrient belongs here rather than in a component. Doses that change the
/// simulated pools are in `ModelConfig` instead, because they change model
/// results and must join the parameter fingerprint.
class MicrobeMotility {
  const MicrobeMotility._();

  // ---------------------------------------------------------------------------
  // Movement envelope
  // ---------------------------------------------------------------------------

  /// Rhizosphere leash around the root the colony is attached to [px].
  /// At the scene scale this is roughly 13 cm.
  static const double rhizosphereRadius = 36.0;

  /// Visual speed caps [px/s]. Active swimming dominates passive transport.
  static const double seekingSpeed = 6.0;
  static const double feedingSpeed = 2.0;

  /// Upper bound for water-flux drift [px/s].
  static const double passiveDriftLimit = 1.2;

  /// Local sensing radii [px]. Beyond the rhizosphere a trip costs more than
  /// the resource is worth, so distant hotspots are ignored.
  static const double sensingRadiusHotspot = 48.0;
  static const double sensingRadiusExudate = 64.0;

  /// Extra margin used when deciding whether a sensed target is still tied to
  /// the anchored root [px].
  static const double rhizosphereSensingMargin = 12.0;

  /// Orbit around a root or a feeding site [px].
  static const double orbitFeedRadius = 4.0;
  static const double orbitSeekRadius = 10.0;
  static const double orbitGrowthPerSeed = 3.0;
  static const double orbitVerticalScale = 0.6;

  /// Orbit angular speed [rad/s].
  static const double orbitSpeedFeed = 0.03;
  static const double orbitSpeedSeek = 0.10;

  /// Approach scales and steering response.
  static const double feedVelocityScale = 0.7;
  static const double seekVelocityScale = 1.2;
  static const double velocityResponse = 2.0;
  static const double hoverSpeedDamping = 0.15;

  /// Neighbour separation radius and force [px, px/s²].
  static const double repulsionRadius = 18.0;
  static const double repulsionStrength = 1.2;

  /// Seconds between target re-evaluations.
  static const double retargetMinSeconds = 2.5;
  static const double retargetMaxSeconds = 6.0;

  /// How many of the nearest roots compete to become the colony anchor.
  static const int rootAnchorSearchCount = 5;

  // ---------------------------------------------------------------------------
  // Feeding and sensing
  // ---------------------------------------------------------------------------

  /// Distance at which the colony is considered to be feeding [px].
  static const double feedingRadiusHotspot = 20.0;
  static const double feedingRadiusRoot = 24.0;

  /// Per-second chance of consuming one pool dose while feeding.
  static const double feedingExudateRatePerSecond = 0.5;
  static const double feedingRootRatePerSecond = 0.2;

  /// Keep colonies inside the drawn soil column [px].
  static const double soilEdgeMargin = 15.0;

  /// Retained velocity when the rhizosphere clamp fires.
  static const double rhizosphereClampVelocityRetain = 0.5;

  /// C:N ratio above which nitrogen-rich hotspots are preferred.
  static const double nitrogenLimitedCnRatio = 24.0;

  /// Fitness weights used by the local target choice.
  static const double nutrientBenefit = 2.0;
  static const double nitrogenBenefitMultiplier = 2.5;
  static const double climateBenefit = 1.5;
  static const double hotspotDistanceScale = 100.0;
  static const double exudateBenefit = 3.0;
  static const double exudateNitrogenPenalty = 0.7;
  static const double exudateDistanceScale = 80.0;
  static const double minimumFitness = 0.5;

  // ---------------------------------------------------------------------------
  // Colony activity and particle handling
  // ---------------------------------------------------------------------------

  /// Activation decay/gain rates [1/s].
  static const double activationDecayPerSecond = 0.4;
  static const double activationSpeedBoost = 2.5;
  static const double activationGainHotspot = 1.5;
  static const double activationGainRoot = 0.5;

  /// Pulse scales and decay.
  static const double pulseDecayPerSecond = 2.0;
  static const double transformationPulseScale = 1.3;
  static const double capturePulseScale = 1.25;
  static const double transformationBoost = 0.2;
  static const double captureBoost = 0.1;

  /// Immobilized-particle handling [px, px/s].
  static const double immobilizationSensingRadius = 80.0;
  static const double immobilizationCaptureRadius = 6.0;
  static const double immobilizationPullStrength = 120.0;
  static const double immobilizationNudge = 0.2;

  /// Molecular transformation trigger.
  static const double transformationCheckRate = 0.1;
  static const double transformationRadius = 40.0;
  static const double transformationChance = 0.3;

  /// Captured nutrients shown around the core.
  static const int maxAbsorbedNutrients = 12;

  // ---------------------------------------------------------------------------
  // Population and spawning
  // ---------------------------------------------------------------------------

  /// Visible colony count derived from total microbial biomass.
  static const int minVisibleClusters = 3;
  static const int maxVisibleClusters = 12;
  static const double clustersPerBiomass = 5.0;

  /// Rhizosphere spawn offset [px].
  static const double spawnOffsetMin = 6.0;
  static const double spawnOffsetMax = 26.0;
  static const double spawnVerticalScale = 0.7;

  /// Fallback spawn when no root geometry is available.
  static const double fallbackSpawnSigma = 30.0;
  static const double fallbackSpawnDepth = 40.0;
  static const double spawnMargin = 20.0;

  // ---------------------------------------------------------------------------
  // Render-only swarm shape
  // ---------------------------------------------------------------------------

  static const double swarmRotationSpeed = 0.4;
  static const double swarmPulseSpeed = 0.25;
  static const double swarmBaseDistance = 10.0;
  static const double swarmPulseDistance = 2.0;
  static const double swarmVerticalScale = 0.8;
  static const double swarmDotRadius = 1.0;
  static const double swarmDotBase = 6.0;
  static const int swarmDotMin = 3;
  static const int swarmDotMax = 12;
  static const double nutrientOrbitSpeed = 0.5;
  static const double nutrientOrbitDistance = 14.0;

  /// Clamps a desired position to the rhizosphere around [root].
  static Vector2 clampToRhizosphere(Vector2 root, Vector2 desired) {
    final offset = desired - root;
    final distance = offset.length;
    if (distance <= rhizosphereRadius) return desired;
    return root + offset * (rhizosphereRadius / distance);
  }

  /// Passive drift from the layer's net water flux [m/s].
  ///
  /// A real cell moves far less than a pixel; mapping the flux to at most
  /// [passiveDriftLimit] keeps transport visible without dominating motility.
  /// Positive flux is downward, matching the hydrology solver's convention.
  static double passiveDrift(double verticalFlux) {
    if (verticalFlux.isNaN) return 0;
    return (verticalFlux * 2.0e5)
        .clamp(-passiveDriftLimit, passiveDriftLimit)
        .toDouble();
  }

  /// Q10-scaled speed cap for the current soil temperature.
  static double speedLimit({
    required bool feeding,
    required double activityFactor,
  }) {
    final temperatureScale = activityFactor.clamp(0.6, 1.3).toDouble();
    return (feeding ? feedingSpeed : seekingSpeed) * temperatureScale;
  }

  /// Number of visible colonies the current biomass supports.
  static int visibleClusterCount(double totalBiomass) =>
      (totalBiomass * clustersPerBiomass)
          .toInt()
          .clamp(minVisibleClusters, maxVisibleClusters);

  /// A random offset inside the rhizosphere-spawn envelope.
  static Vector2 spawnOffset(math.Random random) {
    final angle = random.nextDouble() * math.pi * 2;
    final radius =
        spawnOffsetMin + random.nextDouble() * (spawnOffsetMax - spawnOffsetMin);
    return Vector2(
      math.cos(angle) * radius,
      math.sin(angle) * radius * spawnVerticalScale,
    );
  }

  /// A random delay before the next target re-evaluation.
  static double retargetDelay(math.Random random) =>
      retargetMinSeconds +
      random.nextDouble() * (retargetMaxSeconds - retargetMinSeconds);
}
