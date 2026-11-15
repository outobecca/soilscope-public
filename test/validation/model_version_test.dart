import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soilscope/domain/models/model_parameter_set.dart';
import 'package:soilscope/domain/models/reference_dataset.dart';
import 'package:soilscope/domain/services/simulation_persistence.dart';
import 'package:soilscope/domain/services/validation_reference_run.dart';

const _referencePath = 'assets/validation/reference.json';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('model parameter set', () {
    test('the current fingerprint is pinned', () {
      // A changed value here means a simulation constant moved. Bump
      // ModelParameterSet.currentVersion, update this pin and regenerate the
      // validation reference deliberately; do not edit it to silence a drift.
      expect(ModelParameterSet.current.id, 'soilscope-core');
      expect(ModelParameterSet.current.version, 1);
      expect(ModelParameterSet.current.fingerprint, '8712a30f');
      expect(ModelParameterSet.current.parameters, isNotEmpty);
      expect(
        ModelParameterSet.current.parameters.values.every((v) => v.isFinite),
        isTrue,
      );
    });

    test('fingerprint ignores insertion order but not values', () {
      final reordered = Map<String, double>.fromEntries(
        ModelParameterSet.current.parameters.entries.toList().reversed,
      );
      final copy = ModelParameterSet(
        id: ModelParameterSet.current.id,
        version: ModelParameterSet.current.version,
        parameters: reordered,
      );
      expect(copy.fingerprint, ModelParameterSet.current.fingerprint);

      final altered = Map<String, double>.from(
        ModelParameterSet.current.parameters,
      );
      altered['evapBaseRate'] = altered['evapBaseRate']! * 1.01;
      final changed = ModelParameterSet(
        id: ModelParameterSet.current.id,
        version: ModelParameterSet.current.version,
        parameters: altered,
      );
      expect(changed.fingerprint, isNot(ModelParameterSet.current.fingerprint));
    });

    test('a version bump alone changes the fingerprint', () {
      final bumped = ModelParameterSet(
        id: ModelParameterSet.current.id,
        version: ModelParameterSet.current.version + 1,
        parameters: ModelParameterSet.current.parameters,
      );
      expect(bumped.fingerprint, isNot(ModelParameterSet.current.fingerprint));
    });
  });

  group('provenance', () {
    test('the illustrative reference records the current model', () async {
      final raw = await File(_referencePath).readAsString();
      final dataset = ReferenceDataset.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      expect(dataset.model, isNotNull);
      expect(dataset.model!.id, ModelParameterSet.current.id);
      expect(dataset.model!.version, ModelParameterSet.current.version);
      expect(dataset.model!.fingerprint, ModelParameterSet.current.fingerprint);
    });

    test('a saved session records the model and loads it back', () async {
      SharedPreferences.setMockInitialValues({});
      final state = ValidationReferenceRun.initialState();
      final persistence = SimulationPersistence();
      await persistence.save(state);

      final prefs = await SharedPreferences.getInstance();
      final envelope =
          jsonDecode(prefs.getString(SimulationPersistence.stateKey)!)
              as Map<String, dynamic>;
      expect(envelope['model'], isA<Map<String, dynamic>>());

      final loaded = await persistence.loadSession();
      expect(loaded, isNotNull);
      expect(loaded!.model?.id, ModelParameterSet.current.id);
      expect(loaded.model?.fingerprint, ModelParameterSet.current.fingerprint);
      expect(
        loaded.state.profile.layers.first.waterContent,
        closeTo(state.profile.layers.first.waterContent, 1e-12),
      );
    });

    test('legacy saves upgrade to a model record on load', () async {
      SharedPreferences.setMockInitialValues({
        SimulationPersistence.legacyStateKey: jsonEncode(
          ValidationReferenceRun.initialState().toJson(),
        ),
      });

      final session = await SimulationPersistence().loadSession();
      expect(session, isNotNull);
      expect(
        session!.model?.fingerprint,
        ModelParameterSet.current.fingerprint,
      );

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(SimulationPersistence.stateKey), isNotNull);
      expect(prefs.getString(SimulationPersistence.legacyStateKey), isNull);
    });
  });
}
