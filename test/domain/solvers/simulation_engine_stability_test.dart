import 'package:flutter_test/flutter_test.dart';

import 'package:soilscope/domain/models/biophysical_state.dart';
import 'package:soilscope/domain/models/soil_layer.dart';
import 'package:soilscope/domain/models/soil_profile.dart';
import 'package:soilscope/domain/solvers/simulation_engine.dart';

SoilLayer _layer(
  String id,
  double depth,
  double thickness, {
  double kSat = 1e-5,
}) {
  return SoilLayer(
    id: id,
    depth: depth,
    thickness: thickness,
    kSat: kSat,
    porosity: 0.45,
    thetaR: 0.05,
    vgAlpha: 1.5,
    vgN: 1.5,
    bulkDensity: 1400.0,
    waterContent: 0.25,
    temperature: 293.15,
    heatCapacity: 2.4e6,
    ph: 6.5,
    ec: 0.2,
    redoxPotential: 400.0,
    nitrateContent: 15.0,
    ammoniumContent: 5.0,
    phosphateContent: 5.0,
    microbialBiomass: 40.0,
    epsContent: 0.0,
    fungalHyphaeDensity: 0.0,
    necromass: 0.0,
    organicCarbon: 10.0,
    mineralAssociatedOrganicMatter: 10.0,
    particulateOrganicMatter: 0.5,
    nitrogenContent: 0.2,
  );
}

void main() {
  test('200 hourly ticks stay finite and inside physical bounds', () {
    var state = BiophysicalState(
      profile: SoilProfile(
        id: 'stability',
        name: 'stability',
        layers: [
          _layer('A1', 0.0, 0.3),
          _layer('B1', 0.3, 0.5, kSat: 5e-6),
        ],
        surfaceAlbedo: 0.2,
        slope: 0.02,
      ),
      plants: const [],
      timeElapsed: 0,
    );

    for (var i = 0; i < 200; i++) {
      state = SimulationEngine.tick(state, 3600);
    }

    for (final layer in state.profile.layers) {
      expect(layer.waterContent.isFinite, isTrue,
          reason: '${layer.id} water became non-finite');
      expect(layer.waterContent, greaterThanOrEqualTo(0.0));
      // A tiny numerical overshoot above saturation is tolerated; a large one
      // means the adaptive sub-step is not doing its job.
      expect(layer.waterContent, lessThanOrEqualTo(layer.porosity + 0.02));
      expect(layer.nitrateContent.isFinite, isTrue);
      expect(layer.nitrateContent, greaterThanOrEqualTo(-1e-6));
      expect(layer.ph.isFinite, isTrue);
      expect(layer.ph, inInclusiveRange(3.0, 10.0));
    }

    expect(state.timeElapsed, closeTo(200 * 3600, 1e-6));
  });
}
