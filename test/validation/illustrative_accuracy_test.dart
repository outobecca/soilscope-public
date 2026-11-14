import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/data/reference_dataset_repository.dart';
import 'package:soilscope/domain/models/reference_dataset.dart';
import 'package:soilscope/domain/services/validation_reference_run.dart';
import 'package:soilscope/domain/solvers/validation_framework.dart';

/// Regression gate over the illustrative reference profile.
///
/// These thresholds are not field-accuracy claims. They make unintended solver
/// drift fail CI while the reference is synthetic. Replacing the fixture with
/// measured observations is documented in docs/validation/README.md.
void main() {
  test('illustrative reference profiles stay within the accuracy gate', () {
    final raw = File(ReferenceDatasetRepository.defaultAsset).readAsStringSync();
    final dataset = ReferenceDataset.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
    final history = ValidationReferenceRun.run();
    final referenceTimes = dataset.timesFor(history.last.timeElapsed);

    final comparison = ValidationFramework.compareToReferenceSeries(
      history,
      dataset.series,
      referenceTimes,
    );

    for (final profile in dataset.series) {
      final result = comparison.variableResults[profile.key]!;
      final threshold = profile.threshold;

      // ignore: avoid_print
      print(
        'GATE ${profile.key}: NSE=${result.nse.toStringAsFixed(6)} '
        '(min ${threshold.nse}), '
        'RMSE=${result.rmse.toStringAsFixed(8)} '
        '(max ${threshold.rmse}), n=${result.n}',
      );

      expect(
        result.nse,
        greaterThanOrEqualTo(threshold.nse),
        reason: '${profile.key} NSE regressed below the declared gate',
      );
      expect(
        result.rmse,
        lessThanOrEqualTo(threshold.rmse),
        reason: '${profile.key} RMSE regressed above the declared gate',
      );
    }
  });
}
