import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/scenario.dart';
import '../../data/scenario_repository.dart';

part 'scenarios_provider.g.dart';

@riverpod
Future<List<Scenario>> scenarios(Ref ref) async {
  return ScenarioRepository.getScenarios();
}
