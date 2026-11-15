import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/domain/models/reference_dataset.dart';
import 'package:soilscope/domain/services/validation_reference_run.dart';
import 'package:soilscope/domain/solvers/validation_framework.dart';

void main() {
  Map<String, dynamic> measuredJson() {
    return {
      'id': 'measured_test_site',
      'kind': 'measured',
      'source': 'Test citation (2026), test site.',
      'provenanceNotes': 'Test fixture for schema coverage; not a field claim.',
      'sampling': 'Two depths at 0 and 24 hours from run start.',
      'generatedBy': 'Measured reference test fixture.',
      'model': {
        'id': 'test-model',
        'version': 1,
        'fingerprint': 'test-fingerprint',
      },
      'timesSeconds': [0.0, 86400.0],
      'series': [
        {
          'variable': 'waterContent',
          'layerIndex': 0,
          'layerId': 'A',
          'unit': 'm3/m3',
          'values': [0.32, 0.31],
          'threshold': {'nse': 0.5, 'rmse': 0.02},
        },
        {
          'variable': 'nitrateContent',
          'layerIndex': 1,
          'layerId': 'B',
          'unit': 'mg/kg',
          'values': [40.0, 39.0],
          'threshold': {'nse': 0.5, 'rmse': 2.0},
        },
      ],
    };
  }

  ReferenceDataset measuredDataset() =>
      ReferenceDataset.fromJson(measuredJson());

  test('measured multi-layer schema accepts 0 s and absolute times', () {
    final dataset = measuredDataset();

    expect(dataset.isIllustrative, isFalse);
    expect(dataset.sampleCount, 2);
    expect(dataset.timesFor(3600), [0.0, 86400.0]);
    expect(dataset.series.map((series) => series.layerIndex), [0, 1]);
    expect(dataset.series.map((series) => series.key), [
      'waterContent@0',
      'nitrateContent@1',
    ]);
  });

  test('measured datasets must record a model parameter set', () {
    final json = measuredJson()..remove('model');

    expect(
      () => ReferenceDataset.fromJson(json),
      throwsA(isA<FormatException>()),
      reason: 'a measured file without a model cannot be tied to a run',
    );
  });

  test('a depth absent from the scenario is uncovered, not a crash', () {
    final history = ValidationReferenceRun.run(hours: 1);
    final profile = ReferenceSeries(
      variable: 'waterContent',
      layerIndex: 5,
      unit: 'm3/m3',
      values: [0.32, 0.31],
      threshold: const ReferenceThreshold(nse: 0.5, rmse: 0.02),
    );

    final comparison = ValidationFramework.compareToReferenceSeries(
      history,
      [profile],
      [0.0, 3600.0],
    );

    expect(comparison.uncoveredSeries.keys, contains(profile.key));
    expect(comparison.uncoveredSeries[profile.key], contains('depth'));
    expect(comparison.variableResults, isEmpty);
  });

  test('an unsupported variable is uncovered, not a crash', () {
    final history = ValidationReferenceRun.run(hours: 1);
    final profile = ReferenceSeries(
      variable: 'bulkDensity',
      layerIndex: 0,
      unit: 'kg/m3',
      values: [1400.0, 1400.0],
      threshold: const ReferenceThreshold(nse: 0.5, rmse: 1.0),
    );

    final comparison = ValidationFramework.compareToReferenceSeries(
      history,
      [profile],
      [0.0, 3600.0],
    );

    expect(comparison.uncoveredSeries.keys, contains(profile.key));
    expect(comparison.uncoveredSeries[profile.key], contains('variable'));
    expect(comparison.variableResults, isEmpty);
  });

  test('absolute samples beyond the run are uncovered, not clamped', () {
    final history = ValidationReferenceRun.run(hours: 1);
    final profile = ReferenceSeries(
      variable: 'waterContent',
      layerIndex: 0,
      unit: 'm3/m3',
      values: [0.32, 0.32],
      threshold: const ReferenceThreshold(nse: 0.5, rmse: 0.02),
    );

    final comparison = ValidationFramework.compareToReferenceSeries(
      history,
      [profile],
      [0.0, 7200.0],
    );

    expect(comparison.uncoveredSeries.keys, contains(profile.key));
    expect(comparison.variableResults, isEmpty);
  });

  test('relative reference times still reject zero', () {
    final raw = measuredDataset();
    expect(
      () => ReferenceDataset(
        id: 'relative_zero',
        kind: 'measured',
        source: raw.source,
        provenanceNotes: raw.provenanceNotes,
        sampling: raw.sampling,
        generatedBy: raw.generatedBy,
        relativeTimes: const [0.0, 0.5],
        series: raw.series,
        model: raw.model,
      ),
      throwsA(isA<FormatException>()),
    );
  });
}
