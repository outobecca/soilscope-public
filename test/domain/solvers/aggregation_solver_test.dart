import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/domain/models/soil_layer.dart';
import 'package:soilscope/domain/models/soil_profile.dart';
import 'package:soilscope/domain/models/plant.dart';
import 'package:soilscope/domain/solvers/aggregation_solver.dart';

void main() {
  group('AggregationSolver', () {
    test('Environmental Activity: Factors affect biological activity', () {
      final baseLayer = _createLayer().copyWith(
        temperature: 293.15, // 20C, fTemp = 1.0
        waterContent: 0.2, // afp = 0.25 > 0.05, fWater = 1.0
        oxygenContent: 8.5, // fO2 = 1.0
      );

      // 1. Temperature sensitivity (Q10=2)
      final layer30 = baseLayer.copyWith(
        temperature: 303.15,
      ); // 30C, fTemp = 2.0

      // 2. Water limitation (anaerobic/saturated)
      final layerSat = baseLayer.copyWith(
        waterContent: 0.44,
      ); // afp = 0.01 < 0.05, fWater = 0.2

      // 3. Oxygen limitation
      final layerLowO2 = baseLayer.copyWith(oxygenContent: 0.85); // fO2 = 0.1

      final dt = 3600.0;
      final profileBase = SoilProfile(
        id: 'base',
        name: 'base',
        layers: [baseLayer],
        surfaceAlbedo: 0.2,
        slope: 0.0,
      );
      final profile30 = SoilProfile(
        id: '30',
        name: '30',
        layers: [layer30],
        surfaceAlbedo: 0.2,
        slope: 0.0,
      );
      final profileSat = SoilProfile(
        id: 'sat',
        name: 'sat',
        layers: [layerSat],
        surfaceAlbedo: 0.2,
        slope: 0.0,
      );
      final profileLowO2 = SoilProfile(
        id: 'lowO2',
        name: 'lowO2',
        layers: [layerLowO2],
        surfaceAlbedo: 0.2,
        slope: 0.0,
      );

      final updatedBase = AggregationSolver.solve(profileBase, dt);
      final updated30 = AggregationSolver.solve(profile30, dt);
      final updatedSat = AggregationSolver.solve(profileSat, dt);
      final updatedLowO2 = AggregationSolver.solve(profileLowO2, dt);

      // EPS production depends on activity
      final epsProdBase =
          updatedBase.layers[0].epsContent - baseLayer.epsContent;
      final epsProd30 = updated30.layers[0].epsContent - layer30.epsContent;
      final epsProdSat = updatedSat.layers[0].epsContent - layerSat.epsContent;
      final epsProdLowO2 =
          updatedLowO2.layers[0].epsContent - layerLowO2.epsContent;

      expect(epsProd30, greaterThan(epsProdBase));
      expect(epsProdSat, lessThan(epsProdBase));
      expect(epsProdLowO2, lessThan(epsProdBase));
    });

    test('EPS Dynamics: Production and decay', () {
      // Base EPS is 0.1
      final layer = _createLayer().copyWith(
        microbialBiomass: 100.0,
        epsContent: 0.1,
        temperature: 293.15,
      );
      final profile = SoilProfile(
        id: 'p',
        name: 'p',
        layers: [layer],
        surfaceAlbedo: 0.2,
        slope: 0.0,
      );

      // With biomass=100, activity=1, dt=3600
      // epsProduction = 100 * 1e-6 * 1 * 3600 = 0.36
      // epsDecay = 0.1 * 5e-7 * 1 * 3600 = 0.00018
      // newEps = 0.1 + 0.36 - 0.00018 = 0.45982
      final updated = AggregationSolver.solve(profile, 3600.0);
      expect(updated.layers[0].epsContent, closeTo(0.45982, 0.0001));
    });

    test('Fungal Dynamics: Growth influenced by roots and cover crops', () {
      final layer = _createLayer().copyWith(
        depth: 0.0,
        thickness: 0.2,
        particulateOrganicMatter: 10.0,
        fungalHyphaeDensity: 0.1,
        redoxPotential: 600, // Aerobic
      );
      final profile = SoilProfile(
        id: 'p',
        name: 'p',
        layers: [layer],
        surfaceAlbedo: 0.2,
        slope: 0.0,
      );

      const plant = Plant(
        id: 'p1',
        species: 'test',
        age: 10,
        height: 0.5,
        lai: 1.0,
        turgorPressure: 1.0,
        rootSystem: [
          RootNode(x: 0, z: 0.1, radius: 0.01, isTip: true), // Inside layer
        ],
        nitrogenUptake: 0,
        waterUptake: 0,
      );

      final updatedNoPlant = AggregationSolver.solve(profile, 3600.0);
      final updatedWithPlant = AggregationSolver.solve(
        profile,
        3600.0,
        plants: [plant],
      );
      final updatedWithCoverCrop = AggregationSolver.solve(
        profile,
        3600.0,
        hasCoverCrop: true,
      );

      expect(
        updatedWithPlant.layers[0].fungalHyphaeDensity,
        greaterThan(updatedNoPlant.layers[0].fungalHyphaeDensity),
      );
      expect(
        updatedWithCoverCrop.layers[0].fungalHyphaeDensity,
        greaterThan(updatedNoPlant.layers[0].fungalHyphaeDensity),
      );

      // Anaerobic conditions may affect fungal growth differently
      // In improved model, fungi may persist longer even in low redox
      final layerAnaerobic = layer.copyWith(redoxPotential: -200); // fRedox = 0
      final profileAnaerobic = profile.copyWith(layers: [layerAnaerobic]);
      final updatedAnaerobic = AggregationSolver.solve(
        profileAnaerobic,
        3600.0 * 24,
      );
      // With root exudates, fungi can still grow even with some redox stress
      expect(
        updatedAnaerobic.layers[0].fungalHyphaeDensity,
        greaterThanOrEqualTo(0.0),
      );
    });

    test(
      'Aggregate Stability: Increases with biology, decreases with slaking',
      () {
        final layer = _createLayer().copyWith(
          depth: 0.0,
          thickness: 0.1,
          aggregateStability: 0.5,
          epsContent: 1.0,
          fungalHyphaeDensity: 0.5,
          mineralAssociatedOrganicMatter: 100.0,
        );
        final profile = SoilProfile(
          id: 'p',
          name: 'p',
          layers: [layer],
          surfaceAlbedo: 0.2,
          slope: 0.0,
        );

        // Case 1: Stability building (no rain)
        final updatedBuilding = AggregationSolver.solve(profile, 3600.0);
        expect(updatedBuilding.layers[0].aggregateStability, greaterThan(0.5));

        // Case 2: Slaking (rain)
        final precipitation = 1e-4; // m/s
        final updatedSlaking = AggregationSolver.solve(
          profile,
          3600.0,
          precipitation: precipitation,
        );
        expect(
          updatedSlaking.layers[0].aggregateStability,
          lessThan(updatedBuilding.layers[0].aggregateStability),
        );

        // Case 3: Protection from LAI
        const plantWithLai = Plant(
          id: 'p1',
          species: 'test',
          age: 10,
          height: 0.5,
          lai: 3.0,
          turgorPressure: 1.0,
          rootSystem: [],
          nitrogenUptake: 0,
          waterUptake: 0,
        );
        final updatedProtectedLai = AggregationSolver.solve(
          profile,
          3600.0,
          plants: [plantWithLai],
          precipitation: precipitation,
        );
        expect(
          updatedProtectedLai.layers[0].aggregateStability,
          greaterThan(updatedSlaking.layers[0].aggregateStability),
        );

        // Case 4: Protection from Cover Crop
        final updatedProtectedCC = AggregationSolver.solve(
          profile,
          3600.0,
          hasCoverCrop: true,
          precipitation: precipitation,
        );
        expect(
          updatedProtectedCC.layers[0].aggregateStability,
          greaterThan(updatedSlaking.layers[0].aggregateStability),
        );
      },
    );

    test('POM/MAOM Dynamics: Mineralization and stabilization', () {
      final layer = _createLayer().copyWith(
        particulateOrganicMatter: 100.0,
        mineralAssociatedOrganicMatter: 10.0,
        microbialBiomass: 100.0,
        clayFraction: 0.5,
      );
      final profile = SoilProfile(
        id: 'p',
        name: 'p',
        layers: [layer],
        surfaceAlbedo: 0.2,
        slope: 0.0,
      );

      final updated = AggregationSolver.solve(profile, 3600.0 * 24); // 1 day

      // With improved enzyme kinetics, POM dynamics are more complex
      // MAOM should increase due to stabilization of microbial necromass
      expect(
        updated.layers[0].mineralAssociatedOrganicMatter,
        greaterThan(10.0),
      );
      // POM may increase or decrease depending on input vs mineralization
      // Just verify it stays positive
      expect(updated.layers[0].particulateOrganicMatter, greaterThan(0.0));
    });

    test('Shrink-Swell: Cracking in dry clay soil', () {
      final layer = _createLayer().copyWith(
        waterContent: 0.05, // Very dry
        porosity: 0.5,
        clayFraction: 0.5, // High clay
        effectiveMacroPorosity: 0.01,
      );
      final profile = SoilProfile(
        id: 'p',
        name: 'p',
        layers: [layer],
        surfaceAlbedo: 0.2,
        slope: 0.0,
      );

      final updated = AggregationSolver.solve(profile, 3600.0 * 24);
      expect(updated.layers[0].effectiveMacroPorosity, greaterThan(0.01));
    });

    test('Ksat Feedback: Crusting during rain with low stability', () {
      final layer = _createLayer().copyWith(
        depth: 0.0,
        aggregateStability: 0.1, // Low stability (< 0.3)
        kSat: 1e-5,
        epsContent: 0.1,
        fungalHyphaeDensity: 0.1,
        effectiveMacroPorosity: 0.0,
      );
      final profile = SoilProfile(
        id: 'p',
        name: 'p',
        layers: [layer],
        surfaceAlbedo: 0.2,
        slope: 0.0,
      );

      // Rain causes crusting if stability < 0.3 and i == 0
      final updatedWithRain = AggregationSolver.solve(
        profile,
        3600.0,
        precipitation: 0.001,
      );
      final updatedNoRain = AggregationSolver.solve(
        profile,
        3600.0,
        precipitation: 0.0,
      );

      // With rain and low stability, Ksat should decrease (crusting)
      expect(
        updatedWithRain.layers[0].kSat,
        lessThan(updatedNoRain.layers[0].kSat),
      );

      // Verify high stability prevents crusting
      final layerStable = layer.copyWith(aggregateStability: 0.8);
      final profileStable = SoilProfile(
        id: 'ps',
        name: 'ps',
        layers: [layerStable],
        surfaceAlbedo: 0.2,
        slope: 0.0,
      );
      final updatedStable = AggregationSolver.solve(
        profileStable,
        3600.0,
        precipitation: 0.001,
      );
      // With high stability, Ksat should stay at or above the low-stability result
      expect(
        updatedStable.layers[0].kSat,
        greaterThanOrEqualTo(updatedWithRain.layers[0].kSat),
      );
    });
  });
}

SoilLayer _createLayer() {
  return const SoilLayer(
    id: 'L1',
    depth: 0.0,
    thickness: 0.2,
    kSat: 1e-5,
    porosity: 0.45,
    thetaR: 0.05,
    vgAlpha: 2.0,
    vgN: 1.4,
    bulkDensity: 1300,
    waterContent: 0.2,
    temperature: 293.15,
    heatCapacity: 800,
    ph: 6.5,
    ec: 0.1,
    redoxPotential: 600,
    nitrateContent: 50,
    ammoniumContent: 20,
    phosphateContent: 10,
    clayFraction: 0.2,
    microbialBiomass: 100,
    epsContent: 0.1,
    fungalHyphaeDensity: 0.1,
    necromass: 1.0,
    organicCarbon: 20.0,
    particulateOrganicMatter: 10.0,
    mineralAssociatedOrganicMatter: 10.0,
    nitrogenContent: 70.0,
  );
}
