import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/data/scenario_repository.dart';
import 'package:soilscope/domain/models/scenario.dart';
import 'package:soilscope/domain/models/scenario_process_profile.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, Scenario> scenarios;

  setUpAll(() async {
    final loaded = await ScenarioRepository.getScenarios();
    scenarios = {for (final scenario in loaded) scenario.id: scenario};
  });

  test('compacted clay is dominated by physical impedance', () {
    final profile = ScenarioProcessProfile.fromScenario(
      scenarios['compacted_clay'],
    );

    expect(profile.compaction, greaterThan(0.6));
    expect(profile.clayDensity, greaterThan(0.5));
    expect(profile.leaching, lessThan(0.4));
    expect(profile.isCompacted, isTrue);
  });

  test('nitrate leaching is dominated by nitrification and leaching', () {
    final profile = ScenarioProcessProfile.fromScenario(
      scenarios['nitrate_leaching'],
    );

    expect(profile.nitrification, greaterThan(0.5));
    expect(profile.leaching, greaterThan(0.55));
    expect(profile.hasNitrogenLeak, isTrue);
  });

  test('waterlogging is dominated by anaerobic denitrification', () {
    final profile = ScenarioProcessProfile.fromScenario(
      scenarios['waterlogging'],
    );

    expect(profile.denitrification, greaterThan(0.5));
    expect(profile.hasAnaerobicRisk, isTrue);
  });

  test('nitrogen lock is dominated by immobilization', () {
    final profile = ScenarioProcessProfile.fromScenario(
      scenarios['nitrogen_lock'],
    );

    expect(profile.immobilization, greaterThan(0.5));
    expect(profile.hasImmobilization, isTrue);
  });

  test('compacted layers resist root penetration more than loam', () {
    final compacted = scenarios['compacted_clay']!.initialProfile.layers[1];
    final loam = scenarios['nitrogen_lock']!.initialProfile.layers[0];

    expect(compacted.rootPenetrationResistance, greaterThan(0.5));
    expect(loam.rootPenetrationResistance, lessThan(0.4));
    expect(compacted.rootGrowthFactor, lessThan(loam.rootGrowthFactor));
  });
}
