import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/domain/actions/simulation_actions.dart';
import 'package:soilscope/domain/models/biophysical_state.dart';
import 'package:soilscope/domain/models/soil_layer.dart';
import 'package:soilscope/domain/models/soil_profile.dart';

SoilLayer _layer({
  required String id,
  required double depth,
  required double waterContent,
  required double redox,
  required double organicCarbon,
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
    nitrateContent: 40,
    ammoniumContent: 5,
    phosphateContent: 3,
    microbialBiomass: 200,
    epsContent: 10,
    fungalHyphaeDensity: 20,
    necromass: 100,
    organicCarbon: organicCarbon,
    particulateOrganicMatter: 10,
    mineralAssociatedOrganicMatter: 10,
    nitrogenContent: 1000,
    aggregateStability: 0.5,
  );
}

BiophysicalState _state() {
  const profile = SoilProfile(
    id: 'actions',
    name: 'Actions',
    layers: [],
    surfaceAlbedo: 0.2,
    slope: 0,
  );
  return BiophysicalState(
    profile: profile.copyWith(
      layers: [
        _layer(
          id: 'top',
          depth: 0,
          waterContent: 0.25,
          redox: 250,
          organicCarbon: 50,
        ),
        _layer(
          id: 'deep',
          depth: 0.3,
          waterContent: 0.3,
          redox: 100,
          organicCarbon: 10,
        ),
        _layer(
          id: 'bottom',
          depth: 0.6,
          waterContent: 0.35,
          redox: 50,
          organicCarbon: 5,
        ),
      ],
    ),
    plants: const [],
    timeElapsed: 0,
  );
}

void main() {
  test('irrigation raises topsoil water by the applied depth', () {
    final before = _state();
    final after = SimulationActions.applyIrrigation(before, amountMm: 10);

    expect(before.profile.layers.first.waterContent, 0.25);
    expect(after.profile.layers.first.waterContent, closeTo(0.2833, 0.0001));
    expect(after.profile.layers.first.previousWaterContent, 0.25);
    expect(after.profile.layers[1].waterContent, 0.3);
  });

  test('organic matter adds labile carbon and microbial biomass', () {
    final after = SimulationActions.applyOrganicMatter(_state());
    final top = after.profile.layers.first;

    expect(top.organicCarbon, 55);
    expect(top.labileCarbon, 5);
    expect(top.particulateOrganicMatter, 15);
    expect(top.microbialBiomass, 210);
    expect(top.aggregateStability, closeTo(0.55, 0.0001));
  });

  test('drainage lowers water and re-aerates the upper layers only', () {
    final after = SimulationActions.applyDrainage(_state());
    final top = after.profile.layers.first;
    final deep = after.profile.layers[1];
    final bottom = after.profile.layers[2];

    expect(top.waterContent, closeTo(0.22, 0.0001));
    expect(top.oxygenContent, 9.5);
    expect(top.redoxPotential, 325);
    expect(deep.waterContent, closeTo(0.27, 0.0001));
    expect(deep.redoxPotential, 175);
    expect(bottom.waterContent, 0.35);
    expect(bottom.redoxPotential, 50);
  });

  test('quick actions are safe on an empty profile', () {
    const state = BiophysicalState(
      profile: SoilProfile(
        id: 'empty',
        name: 'Empty',
        layers: [],
        surfaceAlbedo: 0.2,
        slope: 0,
      ),
      plants: [],
      timeElapsed: 0,
    );

    expect(SimulationActions.applyIrrigation(state), same(state));
    expect(SimulationActions.applyOrganicMatter(state), same(state));
    expect(SimulationActions.applyDrainage(state), same(state));
  });
}
