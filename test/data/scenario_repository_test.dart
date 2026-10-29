import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/data/scenario_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ScenarioRepository loads scenarios and tutorialSteps', () async {
    final scenarios = await ScenarioRepository.getScenarios();
    expect(scenarios.length, 4);

    for (final scenario in scenarios) {
      expect(scenario.tutorialSteps, isNotEmpty,
          reason: 'Scenario ${scenario.id} should have tutorial steps');
      for (final step in scenario.tutorialSteps) {
        expect(step.triggerTime >= 0, isTrue);
        expect(step.targetId.isNotEmpty, isTrue);
        expect(step.title.isNotEmpty, isTrue);
        expect(step.description.isNotEmpty, isTrue);
      }
    }
  });
}
