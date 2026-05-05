import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/data/scenario_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ScenarioRepository loads scenarios', () async {
    final scenarios = await ScenarioRepository.getScenarios();
    expect(scenarios, isNotEmpty);
  });
}
