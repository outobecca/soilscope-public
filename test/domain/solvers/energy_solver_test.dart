import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/domain/models/plant.dart';
import 'package:soilscope/domain/models/soil_layer.dart';
import 'package:soilscope/domain/models/soil_profile.dart';
import 'package:soilscope/domain/solvers/energy_solver.dart';

void main() {
  group('EnergySolver', () {
    test('solve updates surface albedo based on wetness', () {
      // Dry profile
      final dryProfile = SoilProfile(
        id: 'test_dry',
        name: 'Dry Test',
        layers: [
          _createLayer(
            id: 'L1',
            depth: 0.0,
            thickness: 0.1,
            porosity: 0.5,
            waterContent: 0.0,
            temperature: 293.15,
          ),
        ],
        surfaceAlbedo: 0.2, // Base albedo
        slope: 0.0,
      );

      // Wet profile
      final wetProfile = SoilProfile(
        id: 'test_wet',
        name: 'Wet Test',
        layers: [
          _createLayer(
            id: 'L1',
            depth: 0.0,
            thickness: 0.1,
            porosity: 0.5,
            waterContent: 0.5,
            temperature: 293.15,
          ), // Fully saturated
        ],
        surfaceAlbedo: 0.2,
        slope: 0.0,
      );

      final dryResult = EnergySolver.solve(dryProfile, 3600.0, 0.0);
      final wetResult = EnergySolver.solve(wetProfile, 3600.0, 0.0);

      // Wet soil should be darker (lower albedo) than dry soil
      expect(wetResult.surfaceAlbedo, lessThan(dryResult.surfaceAlbedo));
      // Specifically: dry albedo should be ~0.2, wet albedo should be 0.2 * (1 - 0.5 * 1.0) = 0.1
      expect(dryResult.surfaceAlbedo, closeTo(0.2, 0.01));
      expect(wetResult.surfaceAlbedo, closeTo(0.1, 0.01));
    });

    test('solve updates surface albedo based on LAI', () {
      final profile = SoilProfile(
        id: 'test',
        name: 'Test',
        layers: [
          _createLayer(
            id: 'L1',
            depth: 0.0,
            thickness: 0.1,
            porosity: 0.5,
            waterContent: 0.0,
            temperature: 293.15,
          ),
        ],
        surfaceAlbedo: 0.2,
        slope: 0.0,
      );

      final noPlantResult = EnergySolver.solve(profile, 3600.0, 0.0);

      final plant = Plant(
        id: 'p1',
        species: 'Wheat',
        age: 30,
        height: 0.5,
        lai: 3.0, // Significant canopy coverage
        turgorPressure: 1.0,
        rootSystem: [],
        nitrogenUptake: 0.0,
        waterUptake: 0.0,
      );

      final plantResult = EnergySolver.solve(
        profile,
        3600.0,
        0.0,
        plants: [plant],
      );

      // Canopy coverage (higher LAI) should decrease albedo (darker surface)
      expect(plantResult.surfaceAlbedo, lessThan(noPlantResult.surfaceAlbedo));
      // Base albedo with LAI 3.0: 0.2 * (1 - 0.3 * (3/6)) = 0.2 * (1 - 0.15) = 0.17
      expect(plantResult.surfaceAlbedo, closeTo(0.17, 0.01));
    });

    test('solve updates layer thermal properties based on water content', () {
      final profile = SoilProfile(
        id: 'test',
        name: 'Test',
        layers: [
          _createLayer(
            id: 'L1',
            depth: 0.0,
            thickness: 0.1,
            porosity: 0.5,
            waterContent: 0.25,
            temperature: 293.15,
          ), // 50% saturated
        ],
        surfaceAlbedo: 0.2,
        slope: 0.0,
      );

      final result = EnergySolver.solve(profile, 3600.0, 0.0);
      final layer = result.layers.first;

      // Thermal conductivity: 0.2 + 1.8 * (0.25 / 0.5) = 0.2 + 1.8 * 0.5 = 1.1
      expect(layer.thermalConductivity, closeTo(1.1, 0.01));

      // Heat Capacity: 1300 * 800 + 0.25 * 1000 * 4184 = 1,040,000 + 1,046,000 = 2,086,000
      expect(layer.heatCapacity, closeTo(2086000.0, 1.0));
    });

    test('solve increases temperature under daytime shortwave radiation', () {
      final profile = SoilProfile(
        id: 'test',
        name: 'Test',
        layers: [
          _createLayer(
            id: 'L1',
            depth: 0.0,
            thickness: 0.1,
            porosity: 0.5,
            waterContent: 0.2,
            temperature: 293.15,
          ),
        ],
        surfaceAlbedo: 0.2,
        slope: 0.0,
      );

      // Daytime (noon) -> t = 43200s (12 hours)
      // This should yield positive shortwave radiation, thus increasing temperature.
      final noonResult = EnergySolver.solve(
        profile,
        3600.0,
        43200.0,
        airTemperature: 293.15,
      );

      expect(noonResult.layers.first.temperature, greaterThan(293.15));
    });

    test(
      'solve decreases temperature under nighttime conditions (longwave cooling)',
      () {
        final profile = SoilProfile(
          id: 'test',
          name: 'Test',
          layers: [
            _createLayer(
              id: 'L1',
              depth: 0.0,
              thickness: 0.1,
              porosity: 0.5,
              waterContent: 0.2,
              temperature: 293.15,
            ),
          ],
          surfaceAlbedo: 0.2,
          slope: 0.0,
        );

        // Nighttime (midnight) -> t = 0s
        // Solar intensity is 0. Surface emits longwave and cools.
        final midnightResult = EnergySolver.solve(
          profile,
          3600.0,
          0.0,
          airTemperature: 283.15,
        ); // Cooler air

        expect(midnightResult.layers.first.temperature, lessThan(293.15));
      },
    );

    test('solve transfers heat downwards via conduction', () {
      // Hot top layer, cold bottom layer
      final profile = SoilProfile(
        id: 'test',
        name: 'Test',
        layers: [
          _createLayer(
            id: 'L1',
            depth: 0.0,
            thickness: 0.1,
            porosity: 0.5,
            waterContent: 0.2,
            temperature: 310.0,
          ), // Hot
          _createLayer(
            id: 'L2',
            depth: 0.1,
            thickness: 0.1,
            porosity: 0.5,
            waterContent: 0.2,
            temperature: 290.0,
          ), // Cold
        ],
        surfaceAlbedo: 0.2,
        slope: 0.0,
      );

      // Run during the night to minimize radiation effects adding more heat to top layer
      final result = EnergySolver.solve(
        profile,
        3600.0,
        0.0,
        airTemperature: 310.0,
      );

      // Top layer might cool slightly or stay similar due to balance, but heat MUST transfer down.
      // Bottom layer should warm up due to conduction from L1.
      expect(result.layers[1].temperature, greaterThan(290.0));
      // Top layer should be cooler than its initial hot state because heat was conducted down.
      expect(result.layers[0].temperature, lessThan(310.0));
    });
  });
}

SoilLayer _createLayer({
  required String id,
  required double depth,
  required double thickness,
  required double porosity,
  required double waterContent,
  required double temperature,
  double bulkDensity = 1300.0,
}) {
  return SoilLayer(
    id: id,
    depth: depth,
    thickness: thickness,
    kSat: 1e-4,
    porosity: porosity,
    thetaR: 0.05,
    vgAlpha: 2.0,
    vgN: 1.4,
    vgL: 0.5,
    bulkDensity: bulkDensity,
    waterContent: waterContent,
    temperature: temperature,
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
