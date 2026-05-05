import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/domain/models/soil_layer.dart';
import 'package:soilscope/domain/models/soil_profile.dart';
import 'package:soilscope/domain/solvers/nutrient_solver.dart';

void main() {
  group('NutrientSolver Transformations', () {
    test(
      'Nitrification: Ammonium should decrease and Nitrate should increase in aerobic conditions',
      () {
        final layer = _createLayer(
          'L1',
          0.0,
          0.1,
          1e-5,
          0.45,
          0.20,
          600.0,
          50.0,
          0.0,
          pom: 0.0,
        );
        final profile = SoilProfile(
          id: 'test',
          name: 'Test',
          layers: [layer],
          surfaceAlbedo: 0.2,
          slope: 0.0,
        );

        final updatedProfile = NutrientSolver.solve(
          profile,
          3600.0 * 24,
        ); // 24 hours

        final updatedLayer = updatedProfile.layers[0];
        expect(updatedLayer.ammoniumContent, lessThan(50.0));
        expect(updatedLayer.nitrateContent, greaterThan(0.0));
      },
    );

    test(
      'Denitrification: Nitrate should decrease in anaerobic conditions',
      () {
        // Saturated soil (waterContent = porosity)
        final layer = _createLayer(
          'L1',
          0.0,
          0.1,
          1e-5,
          0.45,
          0.45,
          -200.0,
          0.0,
          50.0,
        );
        final profile = SoilProfile(
          id: 'test',
          name: 'Test',
          layers: [layer],
          surfaceAlbedo: 0.2,
          slope: 0.0,
        );

        final updatedProfile = NutrientSolver.solve(
          profile,
          3600.0 * 24,
        ); // 24 hours

        final updatedLayer = updatedProfile.layers[0];
        expect(updatedLayer.nitrateContent, lessThan(50.0));
      },
    );

    test('Advection: Heavy rain should leach nitrate downwards', () {
      final initialLayers = [
        _createLayer(
          'L1',
          0.0,
          0.1,
          1e-4,
          0.45,
          0.20,
          600.0,
          0.0,
          100.0,
        ), // High nitrate
        _createLayer(
          'L2',
          0.1,
          0.1,
          1e-4,
          0.45,
          0.20,
          600.0,
          0.0,
          0.0,
        ), // No nitrate
      ];
      final profile = SoilProfile(
        id: 'test',
        name: 'Test',
        layers: initialLayers,
        surfaceAlbedo: 0.2,
        slope: 0.0,
      );

      // simulate 10 mm/h rain (1e-5 m/s) downward flux
      final fluxes = [1e-5, 1e-5, 1e-5];
      final updatedProfile = NutrientSolver.solve(
        profile,
        3600.0,
        waterFluxes: fluxes,
      );

      expect(updatedProfile.layers[0].nitrateContent, lessThan(100.0));
      expect(updatedProfile.layers[1].nitrateContent, greaterThan(0.0));
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
  double eh,
  double amm,
  double nit, {
  double pom = 10.0,
}) {
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
    temperature: 293.15,
    heatCapacity: 800,
    ph: 6.5,
    ec: 0.1,
    redoxPotential: eh,
    nitrateContent: nit,
    ammoniumContent: amm,
    phosphateContent: 5,
    sorbedPhosphate: 0.0,
    potassiumContent: 10,
    exchangeablePotassium: 100,
    cec: 15,
    microbialBiomass: 100,
    epsContent: 0.1,
    fungalHyphaeDensity: 0.1,
    necromass: 1.0,
    organicCarbon: 2.0,
    particulateOrganicMatter: pom,
    mineralAssociatedOrganicMatter: 1.0,
    organicNitrogen: pom * 10.0,
    nitrogenContent: nit + amm,
  );
}
