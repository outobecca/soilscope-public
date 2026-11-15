import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/main.dart';

void main() {
  test('scenario route names expose a decoded id', () {
    expect(
      scenarioIdFromRouteName('/simulation/nitrate_leaching'),
      'nitrate_leaching',
    );
    expect(scenarioIdFromRouteName('/simulation/my%20scenario'), 'my scenario');
  });

  test('non-scenario routes do not expose an id', () {
    expect(scenarioIdFromRouteName('/simulation'), isNull);
    expect(scenarioIdFromRouteName('/'), isNull);
    expect(scenarioIdFromRouteName('/science_reference'), isNull);
    expect(scenarioIdFromRouteName('/simulation/'), isNull);
  });
}
