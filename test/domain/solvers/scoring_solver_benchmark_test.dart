import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/domain/models/biophysical_state.dart';
import 'package:soilscope/domain/models/sustainability_score.dart';
import 'package:soilscope/domain/models/soil_profile.dart';
import 'package:soilscope/domain/models/soil_layer.dart';
import 'package:soilscope/domain/models/plant.dart';
import 'package:soilscope/domain/models/scenario.dart';
import 'package:soilscope/domain/solvers/scoring_solver.dart';

void main() {
  test('ScoringSolver performance benchmark', () {
    // Setup state
    final objectives = List.generate(
      1000,
      (index) => MissionObjective(
        id: 'obj_$index',
        type: 'yield',
        targetValue: 100.0,
        title: 'Test',
      ),
    );

    final scenario = Scenario(
      id: 'test_scenario',
      title: 'Test',
      description: 'Test',
      initialProfile: const SoilProfile(
        id: 'test_profile',
        name: 'Test',
        surfaceAlbedo: 0.1,
        slope: 0.0,
        layers: [],
      ),
      weatherData: {},
      objectives: objectives,
    );

    final layer = SoilLayer(
      id: "l1",
      thickness: 0.1,
      depth: 0.1,
      kSat: 0.1,
      porosity: 0.5,
      thetaR: 0.1,
      vgAlpha: 1.0,
      vgN: 2.0,
      bulkDensity: 1200.0,
      heatCapacity: 2000.0,
      ph: 7.0,
      ec: 1.0,
      redoxPotential: 400.0,
      phosphateContent: 0.05,
      sandFraction: 0.3,
      siltFraction: 0.4,
      clayFraction: 0.3,
      waterContent: 0.2,
      temperature: 20.0,
      particulateOrganicMatter: 10.0,
      maomNitrogen: 10.0,
      microbialBiomass: 10.0,
      fungalHyphaeDensity: 10.0,
      nitrateContent: 10.0,
      ammoniumContent: 10.0,
      aggregateStability: 0.5,
      epsContent: 10.0,
      necromass: 10.0,
      organicCarbon: 10.0,
      mineralAssociatedOrganicMatter: 10.0,
      nitrogenContent: 1.0,
    );

    var state = BiophysicalState(
      profile: SoilProfile(
        id: 'test_profile',
        name: 'Test',
        surfaceAlbedo: 0.1,
        slope: 0.0,
        layers: [layer],
      ),
      plants: [const Plant(
        id: 'test_plant',
        species: 'Test',
        age: 1.0,
        height: 1.0,
        lai: 1.0,
        turgorPressure: 1.0,
        rootSystem: [],
        nitrogenUptake: 1.0,
        waterUptake: 1.0,
        totalBiomass: 100.0,
      )],
      timeElapsed: 0.0,
      currentScenario: scenario,
      score: SustainabilityScore(
        yieldScore: 50.0,
        metObjectiveIds: List.generate(
          1000,
          (i) => 'obj_$i',
        ), // Fill with previously met objectives to test membership lookup heavily
      ),
    );

    // Warmup
    for (int i = 0; i < 100; i++) {
      state = state.copyWith(score: ScoringSolver.solve(state, 1.0));
    }

    // Benchmark
    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < 10000; i++) {
      state = state.copyWith(score: ScoringSolver.solve(state, 1.0));
    }
    stopwatch.stop();

    // ignore: avoid_print
    print('Benchmark time: ${stopwatch.elapsedMilliseconds} ms');
  });
}
