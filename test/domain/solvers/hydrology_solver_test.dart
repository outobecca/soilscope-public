import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/domain/models/soil_layer.dart';
import 'package:soilscope/domain/models/soil_profile.dart';
import 'package:soilscope/domain/solvers/hydrology_solver.dart';

void main() {
  group('HydrologySolver', () {
    test('Gravity drainage should move water downwards in a wet profile', () {
      final initialLayers = [
        _createLayer('L1', 0.0, 0.1, 1e-4, 0.45, 0.40), // Very wet
        _createLayer('L2', 0.1, 0.1, 1e-4, 0.45, 0.10), // Dry
      ];
      final profile = SoilProfile(
        id: 'test',
        name: 'Test',
        layers: initialLayers,
        surfaceAlbedo: 0.2,
        slope: 0.0,
      );

      final result = HydrologySolver.solve(profile, 3600.0); // 1 hour
      final updatedProfile = result.profile;

      final l1 = updatedProfile.layers[0];
      final l2 = updatedProfile.layers[1];

      // L1 should have decreased water, L2 should have increased
      expect(l1.waterContent, lessThan(0.40));
      expect(l2.waterContent, greaterThan(0.10));
      // There should be a positive downward flux between L1 and L2
      expect(result.averageFluxes[1], greaterThan(0.0));
    });

    test('Infiltration should increase top layer water content', () {
      final initialLayers = [
        _createLayer('L1', 0.0, 0.1, 1e-4, 0.45, 0.10), // Dry
      ];
      final profile = SoilProfile(
        id: 'test',
        name: 'Test',
        layers: initialLayers,
        surfaceAlbedo: 0.2,
        slope: 0.0,
      );

      final result = HydrologySolver.solve(
        profile,
        3600.0,
        precipitation: 1e-4,
      );

      expect(result.profile.layers[0].waterContent, greaterThan(0.10));
    });
  });
}

SoilLayer _createLayer(
  String id,
  double d,
  double t,
  double k,
  double p,
  double wc,
) {
  return SoilLayer(
    id: id,
    depth: d,
    thickness: t,
    kSat: k,
    porosity: p,
    thetaR: 0.05,
    vgAlpha: 2.0,
    vgN: 1.4,
    vgL: 0.5,
    bulkDensity: 1300,
    waterContent: wc,
    temperature: 293,
    heatCapacity: 800,
    ph: 6.5,
    ec: 0.1,
    redoxPotential: 600,
    nitrateContent: 10,
    ammoniumContent: 5,
    phosphateContent: 5,
    potassiumContent: 10,
    exchangeablePotassium: 100,
    cec: 15,
    microbialBiomass: 100,
    epsContent: 0.1,
    fungalHyphaeDensity: 0.1,
    necromass: 1.0,
    organicCarbon: 2.0,
    particulateOrganicMatter: 1.0,
    mineralAssociatedOrganicMatter: 1.0,
    nitrogenContent: 1.0,
  );
}
