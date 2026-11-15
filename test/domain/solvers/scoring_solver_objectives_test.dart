import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/domain/models/biophysical_state.dart';
import 'package:soilscope/domain/models/plant.dart';
import 'package:soilscope/domain/models/scenario.dart';
import 'package:soilscope/domain/models/soil_layer.dart';
import 'package:soilscope/domain/models/soil_profile.dart';
import 'package:soilscope/domain/models/sustainability_score.dart';
import 'package:soilscope/domain/solvers/scoring_solver.dart';

SoilLayer _layer({
  required String id,
  required double depth,
  double waterContent = 0.3,
  double nitrate = 40,
  double redox = 300,
  double organicCarbon = 50,
  double maom = 40,
  double aggregateStability = 0.9,
  double microbialBiomass = 400,
}) {
  return SoilLayer(
    id: id,
    depth: depth,
    thickness: 0.3,
    kSat: 1e-5,
    porosity: 0.45,
    thetaR: 0.05,
    vgAlpha: 2,
    vgN: 1.5,
    bulkDensity: 1200,
    waterContent: waterContent,
    temperature: 293.15,
    heatCapacity: 2.4e6,
    ph: 6.5,
    ec: 0.2,
    redoxPotential: redox,
    nitrateContent: nitrate,
    ammoniumContent: 5,
    phosphateContent: 3,
    microbialBiomass: microbialBiomass,
    epsContent: 10,
    fungalHyphaeDensity: 20,
    necromass: 100,
    organicCarbon: organicCarbon,
    particulateOrganicMatter: 10,
    mineralAssociatedOrganicMatter: maom,
    nitrogenContent: 1000,
    aggregateStability: aggregateStability,
  );
}

BiophysicalState _stateWith({
  required SoilProfile profile,
  required Scenario scenario,
  required List<String> metObjectiveIds,
}) {
  return BiophysicalState(
    profile: profile,
    plants: const [
      Plant(
        id: 'seedling',
        species: 'Test',
        age: 1,
        height: 0.1,
        lai: 0.5,
        turgorPressure: 1.0,
        rootSystem: [],
        nitrogenUptake: 0,
        waterUptake: 0,
        totalBiomass: 100,
      ),
    ],
    timeElapsed: 0,
    currentScenario: scenario,
    score: SustainabilityScore(metObjectiveIds: metObjectiveIds),
  );
}

void main() {
  test('evaluates yield, carbon, structure, and pollution objectives', () {
    final profile = SoilProfile(
      id: 'objectives',
      name: 'Objectives',
      layers: [
        _layer(id: 'top', depth: 0),
        _layer(
          id: 'deep',
          depth: 0.3,
          nitrate: 5,
          redox: 150,
          organicCarbon: 10,
        ),
      ],
      surfaceAlbedo: 0.2,
      slope: 0,
    );
    final scenario = Scenario(
      id: 'objective-test',
      title: 'Objectives',
      description: 'Objective evaluation',
      initialProfile: profile,
      weatherData: const {},
      objectives: const [
        MissionObjective(
          id: 'yield_50',
          type: 'yield',
          targetValue: 50,
          title: 'Yield',
        ),
        MissionObjective(
          id: 'yield_500',
          type: 'yield',
          targetValue: 500,
          title: 'High yield',
        ),
        MissionObjective(
          id: 'carbon_60',
          type: 'carbon',
          targetValue: 60,
          title: 'Carbon',
        ),
        MissionObjective(
          id: 'structure_80',
          type: 'structure',
          targetValue: 80,
          title: 'Structure',
        ),
        MissionObjective(
          id: 'wet_eh',
          type: 'structure',
          targetValue: 200,
          title: 'Redox',
        ),
        MissionObjective(
          id: 'leach_20',
          type: 'pollution',
          targetValue: 20,
          title: 'Leaching',
        ),
      ],
    );
    final state = _stateWith(
      profile: profile,
      scenario: scenario,
      metObjectiveIds: const ['legacy'],
    );

    final score = ScoringSolver.solve(state, 1);

    expect(
      score.metObjectiveIds,
      containsAll([
        'legacy',
        'yield_50',
        'carbon_60',
        'structure_80',
        'wet_eh',
        'leach_20',
      ]),
    );
    expect(score.metObjectiveIds, isNot(contains('yield_500')));
    // 0.9 aggregate stability and 400/500 microbial biomass give 85%.
    expect(score.totalSoilHealth, closeTo(0.85, 0.001));
  });

  test('keeps achieved objectives after conditions fall again', () {
    final profile = SoilProfile(
      id: 'sticky',
      name: 'Sticky',
      layers: [_layer(id: 'top', depth: 0)],
      surfaceAlbedo: 0.2,
      slope: 0,
    );
    final scenario = Scenario(
      id: 'sticky-test',
      title: 'Sticky',
      description: 'Sticky objectives',
      initialProfile: profile,
      weatherData: const {},
      objectives: const [
        MissionObjective(
          id: 'yield_50',
          type: 'yield',
          targetValue: 50,
          title: 'Yield',
        ),
      ],
    );
    final first = _stateWith(
      profile: profile,
      scenario: scenario,
      metObjectiveIds: const [],
    );
    final firstScore = ScoringSolver.solve(first, 1);
    expect(firstScore.metObjectiveIds, contains('yield_50'));

    final poorProfile = profile.copyWith(
      layers: [
        _layer(
          id: 'top',
          depth: 0,
          nitrate: 100,
          redox: -100,
          organicCarbon: 0,
          aggregateStability: 0.1,
          microbialBiomass: 0,
        ),
      ],
    );
    final second = first.copyWith(
      profile: poorProfile,
      plants: const [],
      score: firstScore,
    );
    final secondScore = ScoringSolver.solve(second, 1);
    expect(secondScore.metObjectiveIds, contains('yield_50'));
  });

  test('leaves objective progress untouched without a scenario', () {
    const profile = SoilProfile(
      id: 'free',
      name: 'Free',
      layers: [],
      surfaceAlbedo: 0.2,
      slope: 0,
    );
    const state = BiophysicalState(
      profile: profile,
      plants: [],
      timeElapsed: 0,
      score: SustainabilityScore(metObjectiveIds: ['kept']),
    );

    expect(
      ScoringSolver.solve(state, 1).metObjectiveIds,
      equals(const ['kept']),
    );
  });
}
