import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/domain/models/reference_dataset.dart';
import 'package:soilscope/domain/services/validation_reference_run.dart';
import 'package:soilscope/domain/solvers/validation_framework.dart';

void main() {
  ReferenceDataset measuredDataset() {
    return ReferenceDataset.fromJson({
      'id': 'measured_test_site',
      'kind': 'measured',
      'source': 'Test citation (2026), test site.',
      'provenanceNotes': 'Test fixture for schema coverage; not a field claim.',
      'sampling': 'Two depths at 0 and 24 hours from run start.',
      'generatedBy': 'Measured reference test fixture.',
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
    });
  }

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
      ),
      throwsA(isA<FormatException>()),
    );
  });
}
