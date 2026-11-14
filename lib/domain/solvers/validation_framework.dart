import 'dart:math' as math;
import '../models/biophysical_state.dart';
import '../models/reference_dataset.dart';

/// Validation Framework for SoilScope Simulation
///
/// Provides statistical metrics and tools for validating simulation outputs
/// against field measurements or reference data.
///
/// Metrics implemented:
/// - RMSE (Root Mean Square Error)
/// - MAE (Mean Absolute Error)
/// - Nash-Sutcliffe Efficiency (NSE)
/// - Coefficient of Determination (R²)
/// - Bias (Mean Error)
/// - Index of Agreement (d)
///
/// References:
/// - Nash & Sutcliffe (1970): River flow forecasting
/// - Willmott (1981): Index of agreement
/// - Legates & McCabe (1999): Evaluating use of goodness-of-fit measures
class ValidationFramework {
  /// Calculates Root Mean Square Error
  /// RMSE = √(Σ(pred - obs)² / n)
  ///
  /// Returns: RMSE in units of the variable
  static double calculateRMSE(List<double> predicted, List<double> observed) {
    if (predicted.length != observed.length || predicted.isEmpty) {
      throw ArgumentError('Lists must have equal non-zero length');
    }

    double sumSquaredError = 0.0;
    for (int i = 0; i < predicted.length; i++) {
      final diff = predicted[i] - observed[i];
      sumSquaredError += diff * diff;
    }

    return math.sqrt(sumSquaredError / predicted.length);
  }

  /// Calculates Mean Absolute Error
  /// MAE = Σ|pred - obs| / n
  static double calculateMAE(List<double> predicted, List<double> observed) {
    if (predicted.length != observed.length || predicted.isEmpty) {
      throw ArgumentError('Lists must have equal non-zero length');
    }

    double sumAbsError = 0.0;
    for (int i = 0; i < predicted.length; i++) {
      sumAbsError += (predicted[i] - observed[i]).abs();
    }

    return sumAbsError / predicted.length;
  }

  /// Calculates Nash-Sutcliffe Efficiency
  /// NSE = 1 - Σ(pred - obs)² / Σ(obs - obs_mean)²
  ///
  /// Interpretation:
  /// - NSE = 1: Perfect model
  /// - NSE = 0: Model is as good as using the mean
  /// - NSE < 0: Model is worse than using the mean
  ///
  /// Reference: Nash & Sutcliffe (1970)
  static double calculateNSE(List<double> predicted, List<double> observed) {
    if (predicted.length != observed.length || predicted.isEmpty) {
      throw ArgumentError('Lists must have equal non-zero length');
    }

    final double obsMean = observed.reduce((a, b) => a + b) / observed.length;

    double sumSquaredError = 0.0;
    double sumSquaredDeviation = 0.0;

    for (int i = 0; i < predicted.length; i++) {
      sumSquaredError += math.pow(predicted[i] - observed[i], 2);
      sumSquaredDeviation += math.pow(observed[i] - obsMean, 2);
    }

    if (sumSquaredDeviation == 0) return double.nan;

    return 1.0 - (sumSquaredError / sumSquaredDeviation);
  }

  /// Calculates Coefficient of Determination (R²)
  /// R² = (Σ(pred - pred_mean)(obs - obs_mean))² / (Σ(pred - pred_mean)² × Σ(obs - obs_mean)²)
  static double calculateR2(List<double> predicted, List<double> observed) {
    if (predicted.length != observed.length || predicted.isEmpty) {
      throw ArgumentError('Lists must have equal non-zero length');
    }

    final double predMean =
        predicted.reduce((a, b) => a + b) / predicted.length;
    final double obsMean = observed.reduce((a, b) => a + b) / observed.length;

    double sumCrossProduct = 0.0;
    double sumPredDev = 0.0;
    double sumObsDev = 0.0;

    for (int i = 0; i < predicted.length; i++) {
      final predDev = predicted[i] - predMean;
      final obsDev = observed[i] - obsMean;
      sumCrossProduct += predDev * obsDev;
      sumPredDev += predDev * predDev;
      sumObsDev += obsDev * obsDev;
    }

    if (sumPredDev == 0 || sumObsDev == 0) return double.nan;

    final r = sumCrossProduct / math.sqrt(sumPredDev * sumObsDev);
    return r * r;
  }

  /// Calculates Bias (Mean Error)
  /// Bias = Σ(pred - obs) / n
  ///
  /// Positive bias = model overestimates
  /// Negative bias = model underestimates
  static double calculateBias(List<double> predicted, List<double> observed) {
    if (predicted.length != observed.length || predicted.isEmpty) {
      throw ArgumentError('Lists must have equal non-zero length');
    }

    double sumError = 0.0;
    for (int i = 0; i < predicted.length; i++) {
      sumError += predicted[i] - observed[i];
    }

    return sumError / predicted.length;
  }

  /// Calculates Index of Agreement (d)
  /// d = 1 - Σ(pred - obs)² / Σ(|pred - obs_mean| + |obs - obs_mean|)²
  ///
  /// Range: 0 to 1, where 1 is perfect agreement
  ///
  /// Reference: Willmott (1981)
  static double calculateIndexOfAgreement(
    List<double> predicted,
    List<double> observed,
  ) {
    if (predicted.length != observed.length || predicted.isEmpty) {
      throw ArgumentError('Lists must have equal non-zero length');
    }

    final double obsMean = observed.reduce((a, b) => a + b) / observed.length;

    double sumSquaredError = 0.0;
    double sumPotentialError = 0.0;

    for (int i = 0; i < predicted.length; i++) {
      sumSquaredError += math.pow(predicted[i] - observed[i], 2);
      sumPotentialError += math.pow(
        (predicted[i] - obsMean).abs() + (observed[i] - obsMean).abs(),
        2,
      );
    }

    if (sumPotentialError == 0) return 1.0;

    return 1.0 - (sumSquaredError / sumPotentialError);
  }

  /// Calculates all validation metrics at once
  static ValidationResult calculateAll(
    List<double> predicted,
    List<double> observed,
  ) {
    return ValidationResult(
      rmse: calculateRMSE(predicted, observed),
      mae: calculateMAE(predicted, observed),
      nse: calculateNSE(predicted, observed),
      r2: calculateR2(predicted, observed),
      bias: calculateBias(predicted, observed),
      indexOfAgreement: calculateIndexOfAgreement(predicted, observed),
      n: predicted.length,
    );
  }

  /// Extracts time series of a specific variable from simulation history
  static List<double> extractTimeSeries(
    List<BiophysicalState> history,
    String variable, {
    int layerIndex = 0,
  }) {
    return history.map((state) {
      switch (variable) {
        // Soil variables
        case 'waterContent':
          return state.profile.layers[layerIndex].waterContent;
        case 'temperature':
          return state.profile.layers[layerIndex].temperature;
        case 'nitrateContent':
          return state.profile.layers[layerIndex].nitrateContent;
        case 'ammoniumContent':
          return state.profile.layers[layerIndex].ammoniumContent;
        case 'ph':
          return state.profile.layers[layerIndex].ph;
        case 'redoxPotential':
          return state.profile.layers[layerIndex].redoxPotential;
        case 'microbialBiomass':
          return state.profile.layers[layerIndex].microbialBiomass;
        case 'organicCarbon':
          return state.profile.layers[layerIndex].organicCarbon;

        // Plant variables
        case 'plantHeight':
          return state.plant.height;
        case 'lai':
          return state.plant.lai;
        case 'totalBiomass':
          return state.plant.totalBiomass;
        case 'rootBiomass':
          return state.plant.rootBiomass;
        case 'psiLeaf':
          return state.plant.psiLeaf;
        case 'waterStressIndex':
          return state.plant.waterStressIndex;
        case 'transpiration':
          return state.plant.actualTranspiration;

        // Environmental
        case 'airTemperature':
          return state.airTemperature;
        case 'precipitation':
          return state.precipitation;

        default:
          throw ArgumentError('Unknown variable: $variable');
      }
    }).toList();
  }

  /// Compares simulation output to each layer-aware reference series.
  ///
  /// Results are keyed by [ReferenceSeries.key] (`variable@layerIndex`) so a
  /// measured dataset can carry water and nitrate profiles at several depths.
  static ValidationComparison compareToReferenceSeries(
    List<BiophysicalState> simulationHistory,
    List<ReferenceSeries> referenceSeries,
    List<double> referenceTimes,
  ) {
    final results = <String, ValidationResult>{};

    for (final profile in referenceSeries) {
      // Extract simulated values at reference times
      // (requires interpolation or nearest-neighbor matching)
      final predicted = _extractAtTimes(
        simulationHistory,
        profile.variable,
        referenceTimes,
        layerIndex: profile.layerIndex,
      );

      if (predicted.length == profile.values.length) {
        results[profile.key] = calculateAll(predicted, profile.values);
      }
    }

    return ValidationComparison(variableResults: results);
  }

  /// Extracts simulated values at specific times (nearest neighbor)
  static List<double> _extractAtTimes(
    List<BiophysicalState> history,
    String variable,
    List<double> times, {
    int layerIndex = 0,
  }) {
    final result = <double>[];

    for (final targetTime in times) {
      // Find nearest state
      BiophysicalState? nearest;
      double minDiff = double.infinity;

      for (final state in history) {
        final diff = (state.timeElapsed - targetTime).abs();
        if (diff < minDiff) {
          minDiff = diff;
          nearest = state;
        }
      }

      if (nearest != null) {
        final timeSeries = extractTimeSeries(
          [nearest],
          variable,
          layerIndex: layerIndex,
        );
        result.add(timeSeries.first);
      }
    }

    return result;
  }
}

/// Result container for validation metrics
class ValidationResult {
  final double rmse;
  final double mae;
  final double nse;
  final double r2;
  final double bias;
  final double indexOfAgreement;
  final int n;

  const ValidationResult({
    required this.rmse,
    required this.mae,
    required this.nse,
    required this.r2,
    required this.bias,
    required this.indexOfAgreement,
    required this.n,
  });

  /// Returns a qualitative assessment of model performance
  String get qualitativeAssessment {
    if (nse > 0.75 && r2 > 0.8) return 'Excellent';
    if (nse > 0.65 && r2 > 0.7) return 'Good';
    if (nse > 0.50 && r2 > 0.5) return 'Satisfactory';
    if (nse > 0.0) return 'Acceptable';
    return 'Poor';
  }

  @override
  String toString() {
    return '''ValidationResult(
  RMSE: ${rmse.toStringAsFixed(4)}
  MAE: ${mae.toStringAsFixed(4)}
  NSE: ${nse.toStringAsFixed(4)}
  R²: ${r2.toStringAsFixed(4)}
  Bias: ${bias.toStringAsFixed(4)}
  Index of Agreement: ${indexOfAgreement.toStringAsFixed(4)}
  N: $n
  Assessment: $qualitativeAssessment
)''';
  }
}

/// Container for multi-variable validation comparison
class ValidationComparison {
  final Map<String, ValidationResult> variableResults;
  final int? layerIndex;

  const ValidationComparison({
    required this.variableResults,
    this.layerIndex,
  });

  /// Overall model performance (average NSE across variables)
  double get overallNSE {
    if (variableResults.isEmpty) return double.nan;
    final nseValues = variableResults.values
        .map((r) => r.nse)
        .where((v) => !v.isNaN);
    if (nseValues.isEmpty) return double.nan;
    return nseValues.reduce((a, b) => a + b) / nseValues.length;
  }

  @override
  String toString() {
    final layerLabel = layerIndex == null ? 'layered' : 'Layer $layerIndex';
    final buffer = StringBuffer('ValidationComparison ($layerLabel):\n');
    buffer.writeln('Overall NSE: ${overallNSE.toStringAsFixed(4)}\n');

    for (final entry in variableResults.entries) {
      buffer.writeln('--- ${entry.key} ---');
      buffer.writeln(entry.value.toString());
      buffer.writeln();
    }

    return buffer.toString();
  }
}
