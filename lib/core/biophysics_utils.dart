import 'dart:math' as math;

enum SoilTexture {
  sand,
  loamySand,
  sandyLoam,
  loam,
  silt,
  siltLoam,
  sandyClayLoam,
  clayLoam,
  siltyClayLoam,
  sandyClay,
  siltyClay,
  clay,
}

enum FinnishSoilTexture {
  as, // Aitosavi
  hts, // Hietasavi
  hes, // Hiuesavi
  hss, // Hiesusavi
  ht, // Hieta
  he, // Hiue
  hs, // Hiesu
}

class VGParams {
  final double thetaS;
  final double thetaR;
  final double alpha;
  final double n;
  final double kSat;
  final double l;

  const VGParams({
    required this.thetaS,
    required this.thetaR,
    required this.alpha,
    required this.n,
    required this.kSat,
    this.l = 0.5,
  });
}

class BiophysicsUtils {
  // ============ ATMOSPHERIC CONSTANTS ============

  /// O2 saturation concentration in soil gas phase [mol/m³] at 20°C, 1 atm.
  /// Used as the reference value for normalizing soil oxygenContent fields.
  static const double atmO2Saturation = 8.5;

  // ============ BIOLOGICAL RATE HELPERS ============

  /// Q10 temperature scaling factor for biological reaction rates.
  ///
  /// Returns a dimensionless multiplier based on the van't Hoff rule: reaction
  /// rates double (when q10 = 2.0) per 10°C increase above the reference
  /// temperature [tRef].
  ///
  /// Reference: Arrhenius (1889); widely used in soil-biology models.
  static double q10Factor(
    double tempK, {
    double q10 = 2.0,
    double tRef = 293.15,
  }) {
    return math.pow(q10, (tempK - tRef) / 10.0).toDouble();
  }

  /// Moisture activity factor for aerobic soil microbial processes based on
  /// Water-Filled Pore Space (WFPS = waterContent / porosity).
  ///
  /// Four-region piecewise function:
  ///   - WFPS < 0.20 : linear ramp-up (substrate diffusion limited when dry)
  ///   - 0.20–0.60   : optimal (= 1.0)
  ///   - 0.60–0.90   : gradual decline (O2 diffusion increasingly limited)
  ///   - WFPS > 0.90 : steep decline (waterlogged / anaerobic)
  ///
  /// References: Linn & Doran (1984) SSSA J; Schimel & Weintraub (2003)
  static double moistureActivityFactor(double waterContent, double porosity) {
    if (porosity <= 0) return 0.0;
    final double wfps = (waterContent / porosity).clamp(0.0, 1.0);
    if (wfps < 0.2) {
      return wfps / 0.2;
    } else if (wfps < 0.6) {
      return 1.0;
    } else if (wfps < 0.9) {
      return 1.0 - (wfps - 0.6) / 0.3 * 0.5;
    } else {
      return (0.5 - (wfps - 0.9) / 0.1 * 0.4).clamp(0.0, 0.5);
    }
  }

  /// van Genuchten (1980) model for water retention
  /// Returns Se (Effective saturation) [0..1]
  static double calculateSe(double psi, double alpha, double n) {
    if (psi >= 0) return 1.0;
    final m = 1 - 1 / n;
    return math.pow(1 + math.pow(alpha * psi.abs(), n), -m).toDouble();
  }

  /// van Genuchten (1980) model to get pressure head ψ from volumetric water
  /// content θ.
  ///
  /// Units: if α is given in [1/m] (as in this codebase), this returns ψ in [m].
  ///
  /// Accounts for hysteresis based on current vs previous water content.
  static double thetaToPsi(
    double theta,
    double thetaR,
    double thetaS,
    double alpha,
    double n, {
    double previousTheta = 0.0,
  }) {
    if (theta >= thetaS) return 0.0;
    if (theta <= thetaR) return -1000.0;

    double effectiveAlpha = alpha;
    if (theta > previousTheta + 1e-5) {
      effectiveAlpha = alpha * 2.0; // Wetting curve proxy
    }

    final se = (theta - thetaR) / (thetaS - thetaR);
    final m = 1 - 1 / n;

    final val = math.pow(se, -1 / m) - 1;
    if (val <= 0) return 0.0;

    return -(1 / effectiveAlpha) * math.pow(val, 1 / n);
  }

  /// Calculates volumetric water content (theta) from Se
  static double calculateTheta(double se, double thetaR, double thetaS) {
    return thetaR + se * (thetaS - thetaR);
  }

  /// van Genuchten-Mualem model for hydraulic conductivity K(Se)
  static double calculateK(double se, double kSat, double n, {double l = 0.5}) {
    if (se >= 1.0) return kSat;
    if (se <= 0.0) return 0.0;

    final m = 1 - 1 / n;
    final inner = 1 - math.pow(se, 1 / m);
    final term = 1 - math.pow(inner, m);
    return kSat * math.pow(se, l) * math.pow(term, 2);
  }

  /// Determines USDA Soil Texture class based on sand, silt, and clay fractions [0..1]
  static SoilTexture getSoilTextureClass(
    double sand,
    double silt,
    double clay,
  ) {
    // Convert to percentages
    final s = sand * 100;
    final si = silt * 100;
    final c = clay * 100;

    if (s + si + c < 99 || s + si + c > 101) {
      // Normalize if slightly off
      final total = s + si + c;
      if (total == 0) return SoilTexture.loam;
    }

    if (c >= 40) {
      if (s > 45) return SoilTexture.sandyClay;
      if (si > 40) return SoilTexture.siltyClay;
      return SoilTexture.clay;
    } else if (c >= 27 && c < 40) {
      if (s > 45) return SoilTexture.sandyClayLoam;
      if (si > 40) return SoilTexture.siltyClayLoam;
      return SoilTexture.clayLoam;
    } else if (c >= 20 && c < 27) {
      if (s > 45) return SoilTexture.sandyClayLoam; // Small region
      if (si > 50) return SoilTexture.siltLoam;
      if (s > 52) return SoilTexture.sandyLoam;
      return SoilTexture.loam;
    } else {
      // c < 20
      if (si > 80) {
        if (c >= 12) return SoilTexture.siltLoam;
        return SoilTexture.silt;
      }
      if (si > 50) return SoilTexture.siltLoam;
      if (s > 85) {
        if (s > 90) return SoilTexture.sand;
        return SoilTexture.loamySand;
      }
      if (s > 70) {
        if (c < 10) return SoilTexture.loamySand;
        return SoilTexture.sandyLoam;
      }
      if (s > 52) return SoilTexture.sandyLoam;
      return SoilTexture.loam;
    }
  }

  /// Determines Finnish Soil Texture class based on sand, silt, and clay fractions [0..1]
  /// Based on the Maalajikolmio (Finnish Soil Triangle)
  static FinnishSoilTexture getFinnishSoilTextureClass(
    double sand,
    double silt,
    double clay,
  ) {
    if (clay >= 0.6) return FinnishSoilTexture.as;
    if (clay >= 0.3) {
      if (silt < 0.5) return FinnishSoilTexture.hts;
      if (sand >= 0.15) return FinnishSoilTexture.hes;
      return FinnishSoilTexture.hss;
    }
    if (silt < 0.5) return FinnishSoilTexture.ht;
    if (sand >= 0.15) return FinnishSoilTexture.he;
    return FinnishSoilTexture.hs;
  }

  /// Saturation Vapor Pressure (kPa) using Tetens equation
  /// Input: temperature in Kelvin
  static double getSaturationVaporPressure(double tempK) {
    final tC = tempK - 273.15;
    return getSaturationVaporPressureCelsius(tC);
  }

  /// Saturation Vapor Pressure (kPa) using Tetens equation
  /// Input: temperature in Celsius
  /// Reference: Tetens (1930), Murray (1967)
  /// es(T) = 0.61078 * exp(17.27 * T / (T + 237.3))
  static double getSaturationVaporPressureCelsius(double tC) {
    return 0.61078 * math.exp((17.27 * tC) / (tC + 237.3));
  }

  /// Actual Vapor Pressure (kPa)
  static double getActualVaporPressure(double tempK, double rh) {
    return getSaturationVaporPressure(tempK) * rh;
  }

  /// Vapor Pressure Deficit (kPa)
  static double getVPD(double tempK, double rh) {
    return getSaturationVaporPressure(tempK) * (1.0 - rh);
  }

  /// Humidity Ratio (kg water / kg dry air)
  /// Reference: ASHRAE Fundamentals (2017)
  /// ω = 0.622 * p_v / (p_atm - p_v)
  static double getHumidityRatio(double tempK, double rh, {double pAtm = 101.325}) {
    final pSat = getSaturationVaporPressure(tempK);
    final pAct = (pSat * rh).clamp(0.0, pAtm - 0.001);
    return 0.622 * pAct / (pAtm - pAct);
  }

  /// Rosetta / Carsel & Parrish (1988) PTF for soil texture classes
  static VGParams getVGParams(SoilTexture texture) {
    switch (texture) {
      case SoilTexture.sand:
        return const VGParams(
          thetaS: 0.43,
          thetaR: 0.045,
          alpha: 14.5,
          n: 2.68,
          kSat: 8.25e-5,
        );
      case SoilTexture.loamySand:
        return const VGParams(
          thetaS: 0.41,
          thetaR: 0.057,
          alpha: 12.4,
          n: 2.28,
          kSat: 4.05e-5,
        );
      case SoilTexture.sandyLoam:
        return const VGParams(
          thetaS: 0.41,
          thetaR: 0.065,
          alpha: 7.5,
          n: 1.89,
          kSat: 1.23e-5,
        );
      case SoilTexture.loam:
        return const VGParams(
          thetaS: 0.43,
          thetaR: 0.078,
          alpha: 3.6,
          n: 1.56,
          kSat: 2.89e-6,
        );
      case SoilTexture.silt:
        return const VGParams(
          thetaS: 0.46,
          thetaR: 0.034,
          alpha: 1.6,
          n: 1.37,
          kSat: 6.94e-7,
        );
      case SoilTexture.siltLoam:
        return const VGParams(
          thetaS: 0.45,
          thetaR: 0.067,
          alpha: 2.0,
          n: 1.41,
          kSat: 1.25e-6,
        );
      case SoilTexture.sandyClayLoam:
        return const VGParams(
          thetaS: 0.39,
          thetaR: 0.10,
          alpha: 5.9,
          n: 1.48,
          kSat: 3.64e-6,
        );
      case SoilTexture.clayLoam:
        return const VGParams(
          thetaS: 0.41,
          thetaR: 0.095,
          alpha: 1.9,
          n: 1.31,
          kSat: 7.17e-7,
        );
      case SoilTexture.siltyClayLoam:
        return const VGParams(
          thetaS: 0.43,
          thetaR: 0.089,
          alpha: 1.0,
          n: 1.23,
          kSat: 1.94e-7,
        );
      case SoilTexture.sandyClay:
        return const VGParams(
          thetaS: 0.38,
          thetaR: 0.10,
          alpha: 2.7,
          n: 1.23,
          kSat: 3.33e-7,
        );
      case SoilTexture.siltyClay:
        return const VGParams(
          thetaS: 0.36,
          thetaR: 0.07,
          alpha: 0.5,
          n: 1.09,
          kSat: 5.56e-8,
        );
      case SoilTexture.clay:
        return const VGParams(
          thetaS: 0.38,
          thetaR: 0.068,
          alpha: 0.8,
          n: 1.09,
          kSat: 5.56e-8,
        );
    }
  }

  /// Returns a localized name for the given USDA texture class
  static String getLocalizedTextureName(SoilTexture texture, dynamic l10n) {
    return switch (texture) {
      SoilTexture.sand => l10n.sand,
      SoilTexture.loamySand => l10n.loamySand,
      SoilTexture.sandyLoam => l10n.sandyLoam,
      SoilTexture.loam => l10n.loam,
      SoilTexture.silt => l10n.silt,
      SoilTexture.siltLoam => l10n.siltLoam,
      SoilTexture.sandyClayLoam => l10n.sandyClayLoam,
      SoilTexture.clayLoam => l10n.clayLoam,
      SoilTexture.siltyClayLoam => l10n.siltyClayLoam,
      SoilTexture.sandyClay => l10n.sandyClay,
      SoilTexture.siltyClay => l10n.siltyClay,
      SoilTexture.clay => l10n.clay,
    };
  }

  /// Returns a localized name for the given Finnish texture class
  static String getLocalizedFinnishTextureName(FinnishSoilTexture texture, dynamic l10n) {
    return switch (texture) {
      FinnishSoilTexture.as => l10n.clay, // Aitosavi
      FinnishSoilTexture.hts => "Hietasavi",
      FinnishSoilTexture.hes => "Hiuesavi",
      FinnishSoilTexture.hss => "Hiesusavi",
      FinnishSoilTexture.ht => "Hieta",
      FinnishSoilTexture.he => "Hiue",
      FinnishSoilTexture.hs => "Hiesu",
    };
  }
}
