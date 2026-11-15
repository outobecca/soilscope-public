import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soilscope/domain/models/biophysical_state.dart';
import 'package:soilscope/domain/models/soil_profile.dart';
import 'package:soilscope/domain/services/simulation_persistence.dart';

BiophysicalState _state({double timeElapsed = 12.0}) => BiophysicalState(
  profile: const SoilProfile(
    id: 'saved',
    name: 'Saved profile',
    layers: [],
    surfaceAlbedo: 0.2,
    slope: 0.0,
  ),
  plants: const [],
  timeElapsed: timeElapsed,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('versioned store', () {
    test('save writes an envelope and load restores the state', () async {
      final persistence = SimulationPersistence();
      await persistence.save(_state(timeElapsed: 42));

      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(SimulationPersistence.stateKey);
      expect(raw, isNotNull);

      final envelope = jsonDecode(raw!) as Map<String, dynamic>;
      expect(envelope['version'], SimulationPersistence.formatVersion);
      expect(envelope['state'], isA<Map<String, dynamic>>());

      final loaded = await persistence.load();
      expect(loaded?.timeElapsed, 42);
      expect(loaded?.profile.id, 'saved');
    });

    test('save removes the legacy key after a successful write', () async {
      SharedPreferences.setMockInitialValues({
        SimulationPersistence.legacyStateKey: 'old value',
      });

      await SimulationPersistence().save(_state());

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey(SimulationPersistence.legacyStateKey), isFalse);
      expect(prefs.containsKey(SimulationPersistence.stateKey), isTrue);
    });
  });

  group('legacy migration', () {
    test('load upgrades raw JSON into the versioned envelope', () async {
      SharedPreferences.setMockInitialValues({
        SimulationPersistence.legacyStateKey: jsonEncode(
          _state(timeElapsed: 7).toJson(),
        ),
      });

      final loaded = await SimulationPersistence().load();

      expect(loaded?.timeElapsed, 7);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey(SimulationPersistence.legacyStateKey), isFalse);
      final envelope =
          jsonDecode(prefs.getString(SimulationPersistence.stateKey)!)
              as Map<String, dynamic>;
      expect(envelope['version'], SimulationPersistence.formatVersion);
    });
  });

  group('corruption recovery', () {
    test('clears an unreadable versioned payload', () async {
      SharedPreferences.setMockInitialValues({
        SimulationPersistence.stateKey: 'not-json',
      });

      final persistence = SimulationPersistence();
      expect(await persistence.hasSavedState(hasLiveRun: false), isTrue);
      expect(await persistence.load(), isNull);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey(SimulationPersistence.stateKey), isFalse);
      expect(await persistence.hasSavedState(hasLiveRun: false), isFalse);
    });

    test('clears an unsupported envelope version', () async {
      SharedPreferences.setMockInitialValues({
        SimulationPersistence.stateKey: jsonEncode({
          'version': SimulationPersistence.formatVersion + 1,
          'state': _state().toJson(),
        }),
      });

      expect(await SimulationPersistence().load(), isNull);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey(SimulationPersistence.stateKey), isFalse);
    });

    test('clears an unreadable legacy payload', () async {
      SharedPreferences.setMockInitialValues({
        SimulationPersistence.legacyStateKey: '{broken',
      });

      expect(await SimulationPersistence().load(), isNull);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey(SimulationPersistence.legacyStateKey), isFalse);
    });
  });

  test(
    'hasSavedState sees both formats and falls back to a live run',
    () async {
      final persistence = SimulationPersistence();

      expect(await persistence.hasSavedState(hasLiveRun: false), isFalse);

      SharedPreferences.setMockInitialValues({
        SimulationPersistence.legacyStateKey: '{}',
      });
      expect(await persistence.hasSavedState(hasLiveRun: false), isTrue);

      SharedPreferences.setMockInitialValues({
        SimulationPersistence.stateKey: '{}',
      });
      expect(await persistence.hasSavedState(hasLiveRun: false), isTrue);

      SharedPreferences.setMockInitialValues({});
      expect(await persistence.hasSavedState(hasLiveRun: true), isTrue);
    },
  );
}
