import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/data/reference_dataset_repository.dart';
import 'package:soilscope/domain/models/reference_dataset.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('reference dataset provenance', () {
    test('the illustrative fixture carries complete provenance and units', () async {
      final raw = await File(ReferenceDatasetRepository.defaultAsset).readAsString();
      final dataset = ReferenceDataset.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );

      expect(dataset.kind, 'illustrative');
      expect(dataset.id, isNotEmpty);
      expect(dataset.source, isNotEmpty);
      expect(dataset.provenanceNotes, isNotEmpty);
      expect(dataset.sampling, isNotEmpty);
      expect(dataset.generatedBy, isNotEmpty);
      expect(dataset.source.toLowerCase(), contains('not measured'));
      expect(dataset.series, isNotEmpty);
      for (final series in dataset.series) {
        expect(series.unit, isNotEmpty);
        expect(series.values.length, dataset.sampleCount);
        expect(series.threshold.nse, greaterThan(0.5));
        expect(series.threshold.rmse, greaterThan(0));
      }
    });

    test('the same fixture is available to the running app as an asset', () async {
      ReferenceDatasetRepository.resetCache();
      final dataset = await ReferenceDatasetRepository.loadDefault();

      expect(dataset.id, 'illustrative_reference_loam_v1');
      expect(dataset.isIllustrative, isTrue);
      expect(dataset.series, isNotEmpty);
    });

    test('missing provenance is rejected rather than silently accepted', () {
      final raw = File(ReferenceDatasetRepository.defaultAsset)
          .readAsStringSync();
      final json = jsonDecode(raw) as Map<String, dynamic>;
      json.remove('provenanceNotes');

      expect(
        () => ReferenceDataset.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
