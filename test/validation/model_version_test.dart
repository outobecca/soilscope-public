import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soilscope/core/model_config.dart';
import 'package:soilscope/data/model_config_repository.dart';
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
      expect(ModelParameterSet.current.version, 3);
      expect(ModelParameterSet.current.fingerprint, '410ef21c');
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

    test('every configured model value is fingerprinted', () {
      // Keep this list limited to values that only affect rendering or
      // component layout. Everything else in SimulationConstants changes a
      // simulated value and must be part of the model identity.
      const renderingOnly = {
        'massFlowVisualDensity',
        'nitrificationVisualDensity',
        'minVisualFlux',
        'particleBaseSpeed',
        'fluxToSpeedScale',
        'minNodeDistance',
        'nodeRepulsionIterations',
        'detailZoomThreshold',
        'particleJitterBase',
        'attractorForceScale',
        'interactionDistance',
        'physicsTickMs',
      };
      Set<String> staticConstantsIn(String path) =>
          RegExp(r'static const \w+ (\w+) =')
              .allMatches(File(path).readAsStringSync())
              .map((match) => match.group(1)!)
              .toSet();

      // Plot geometry is namespaced in the fingerprint so it cannot collide
      // with a simulation constant of the same bare name.
      final plotParameters = staticConstantsIn(
        'lib/domain/models/simulation_plot.dart',
      ).map((name) => 'plot${name[0].toUpperCase()}${name.substring(1)}');
      final expected = {...ModelConfig.defaults.keys, ...plotParameters};

      expect(
        ModelParameterSet.current.parameters.keys.toSet(),
        expected,
        reason:
            'a model parameter was added or removed without joining the '
            'fingerprint',
      );
      expect(
        ModelConfig.defaults,
        isNotEmpty,
        reason: 'the parameter scan must not silently find no constants',
      );
      expect(
        staticConstantsIn(
          'lib/core/simulation_constants.dart',
        ).difference(renderingOnly),
        isEmpty,
        reason:
            'a SimulationConstants value still affects the model without '
            'being configured in ModelConfig',
      );

      // Solver-local constants used to be invisible to the fingerprint. They
      // are now read through ModelConfig; a new one must join the fingerprint
      // rather than becoming another hidden tuning value. The allowlist is
      // limited to particle-affinity constants and a unit conversion, neither
      // of which is a scientific tuning input.
      const localNonTunable = {'kM', 'mH2OToMPa'};
      for (final file
          in Directory('lib/domain/solvers')
              .listSync(recursive: true)
              .whereType<File>()
              .where((file) => file.path.endsWith('.dart'))) {
        expect(
          staticConstantsIn(file.path),
          isEmpty,
          reason: '${file.path} declares a static constant outside ModelConfig',
        );
        final localConstants = RegExp(r'const (?:double|int) (\w+) =')
            .allMatches(file.readAsStringSync())
            .map((match) => match.group(1)!)
            .toSet();
        expect(
          localConstants.difference(localNonTunable),
          isEmpty,
          reason: '${file.path} declares a model constant outside ModelConfig',
        );
      }
    });

    test('a runtime override changes the fingerprint and the engine', () {
      final baselineFingerprint = ModelParameterSet.current.fingerprint;
      final baseline = ValidationReferenceRun.run(
        hours: 1,
      ).last.profile.layers.first.waterContent;

      try {
        ModelConfig.applyOverrides({'evapBaseRate': 1.0e-6});
        final overridden = ValidationReferenceRun.run(
          hours: 1,
        ).last.profile.layers.first.waterContent;

        expect(
          ModelParameterSet.current.fingerprint,
          isNot(baselineFingerprint),
        );
        expect(overridden, isNot(closeTo(baseline, 1e-12)));
      } finally {
        ModelConfig.reset();
      }
      expect(ModelConfig.values, ModelConfig.defaults);
    });

    test('unknown and non-finite overrides are rejected', () {
      expect(
        () => ModelConfig.applyOverrides({'not.a.parameter': 1.0}),
        throwsArgumentError,
      );
      expect(
        () => ModelConfig.applyOverrides({'evapBaseRate': double.nan}),
        throwsArgumentError,
      );
      expect(ModelConfig.values, ModelConfig.defaults);
    });

    test(
      'the checked-in config asset loads without changing defaults',
      () async {
        await ModelConfigRepository.load();
        expect(ModelConfig.values, ModelConfig.defaults);
      },
    );

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
