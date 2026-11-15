import 'package:flutter_test/flutter_test.dart';

import 'package:soilscope/domain/models/biophysical_state.dart';
import 'package:soilscope/domain/models/default_simulation_profile.dart';
import 'package:soilscope/domain/services/simulation_resource_exchange.dart';
import 'package:soilscope/domain/services/validation_reference_run.dart';

class _Host {
  _Host() {
    state = ValidationReferenceRun.initialState().copyWith(
      plants: [seedPlant()],
    );
  }

  late BiophysicalState state;
  int writes = 0;
  int syncs = 0;
  final List<void Function()> deferred = [];

  late final SimulationResourceExchange exchange = SimulationResourceExchange(
    readState: () => state,
    apply: (next) {
      state = next;
      writes++;
    },
    sync: () => syncs++,
    defer: deferred.add,
  );

  void flush() {
    final actions = List<void Function()>.of(deferred);
    deferred.clear();
    for (final action in actions) {
      action();
    }
  }
}

void main() {
  group('resource exchange', () {
    test('nutrient absorption is deferred and does not sync the engine', () {
      final host = _Host();
      final before = host.state.plants.single.nitrogenUptake;

      host.exchange.absorbNutrient('plant_1', 'N', 2.5);

      expect(host.writes, 0);
      expect(host.deferred, hasLength(1));

      host.flush();

      expect(host.writes, 1);
      expect(host.syncs, 0);
      expect(host.state.plants.single.nitrogenUptake, before + 2.5);
    });

    test('an unknown nutrient is a no-op', () {
      final host = _Host();
      final before = host.state.plants.single;

      host.exchange.absorbNutrient('plant_1', 'X', 2.5);
      host.flush();

      expect(host.state.plants.single.nitrogenUptake, before.nitrogenUptake);
      expect(host.state.plants.single.calciumUptake, before.calciumUptake);
    });

    test('potassium is only consumed when the pool covers the amount', () {
      final host = _Host();
      final before = host.state.profile.layers.first.potassiumContent;

      expect(host.exchange.consumePotassium('A', before + 1), isFalse);
      expect(host.deferred, isEmpty);

      expect(host.exchange.consumePotassium('A', 5), isTrue);
      expect(host.writes, 0);

      host.flush();

      expect(host.state.profile.layers.first.potassiumContent, before - 5);
      expect(host.syncs, 1);
    });

    test('nitrate consumption updates the pool and syncs once', () {
      final host = _Host();
      final before = host.state.profile.layers.first.nitrateContent;

      expect(host.exchange.consumeResource('A', 'nitrate', 4), isTrue);
      host.flush();

      expect(host.state.profile.layers.first.nitrateContent, before - 4);
      expect(host.syncs, 1);
    });

    test('oxygen bubbles add to the pool while CO2 is limited', () {
      final host = _Host();
      final before = host.state.profile.layers.first.oxygenContent;

      expect(host.exchange.consumeGas('A', 'O2', 1), isTrue);
      host.flush();
      expect(host.state.profile.layers.first.oxygenContent, before + 1);

      expect(host.exchange.consumeGas('A', 'CO2', 1e9), isFalse);
    });
  });
}
