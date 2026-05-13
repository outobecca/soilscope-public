import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/domain/models/soil_layer.dart';
import 'package:soilscope/domain/models/soil_profile.dart';
import 'package:soilscope/domain/models/plant.dart';
import 'package:soilscope/domain/solvers/plant/plant_nutrient_uptake_solver.dart';
import 'package:soilscope/domain/solvers/microbial_enzymes_solver.dart';

void main() {
  group('Rhizosphere Hotspot Simulation', () {
    test('Hotspot lifecycle: maintenance and decay', () {
      final plant = Plant(
        id: 'test-plant',
        species: 'test',
        age: 10,
        height: 0.1,
        lai: 1.0,
        turgorPressure: 0.8,
        rootSystem: [
          const RootNode(x: 0.5, z: 0.05, radius: 0.01, isTip: true),
        ],
        nitrogenUptake: 0,
        waterUptake: 0,
      );

      final layer = SoilLayer(
        id: 'top',
        depth: 0.05,
        thickness: 0.1,
        temperature: 293,
        waterContent: 0.2,
        ph: 7.0,
        kSat: 1e-5,
        porosity: 0.45,
        thetaR: 0.05,
        vgAlpha: 2.0,
        vgN: 1.4,
        bulkDensity: 1300,
        heatCapacity: 1e6,
        ec: 0.1,
        redoxPotential: 400,
        nitrateContent: 20,
        ammoniumContent: 5,
        phosphateContent: 2,
        microbialBiomass: 100.0,
        epsContent: 0.1,
        fungalHyphaeDensity: 0.1,
        necromass: 10.0,
        organicCarbon: 2.0, // Low C/N ratio (~10)
        particulateOrganicMatter: 30.0,
        mineralAssociatedOrganicMatter: 20.0,
        nitrogenContent: 100.0,
        hotspots: [], // Start empty
      );

      final profile = SoilProfile(
        id: 'test-profile',
        name: 'Test',
        layers: [layer],
        surfaceAlbedo: 0.2,
        slope: 0.0,
      );

      // 1. Initial uptake: should spawn a hotspot
      final (_, _, _, _, _, _, updatedLayers) = PlantNutrientUptakeSolver.calculateNutrientStress(
        plant,
        profile,
        [1.0],
        100.0,
        0.001,
        3600.0, // 1 hour dt
      );

      expect(updatedLayers[0].hotspots.length, 1);
      final initialIntensity = updatedLayers[0].hotspots[0].intensity;
      expect(initialIntensity, greaterThan(0));

      // 2. Subsequent step: intensity should increase with maintenance or at least be high
      final plantHighTurgor = plant.copyWith(turgorPressure: 1.0);
      final updatedProfile = profile.copyWith(layers: updatedLayers);
      final (_, _, _, _, _, _, maintenanceLayers) = PlantNutrientUptakeSolver.calculateNutrientStress(
        plantHighTurgor,
        updatedProfile,
        [1.0],
        100.0,
        0.001,
        3600.0,
      );

      // We expect it to be at least the same or higher if turgor increased
      expect(maintenanceLayers[0].hotspots[0].intensity, greaterThanOrEqualTo(initialIntensity));

      // 3. Decay: move plant root away or simulate with a plant that has no roots in that zone
      final plantNoRoots = plant.copyWith(rootSystem: []);
      final decayedProfile = updatedProfile.copyWith(layers: maintenanceLayers);
      final (_, _, _, _, _, _, decayedLayers) = PlantNutrientUptakeSolver.calculateNutrientStress(
        plantNoRoots,
        decayedProfile,
        [1.0],
        100.0,
        0.001,
        3600.0,
      );

      expect(decayedLayers[0].hotspots[0].intensity, lessThan(maintenanceLayers[0].hotspots[0].intensity));
    });

    test('Hotspot integration: Microbial priming boost', () {
      final layerWithHotspot = SoilLayer(
        id: 'hot',
        depth: 0.05,
        thickness: 0.1,
        temperature: 293,
        waterContent: 0.2,
        ph: 7.0,
        kSat: 1e-5,
        porosity: 0.45,
        thetaR: 0.05,
        vgAlpha: 2.0,
        vgN: 1.4,
        bulkDensity: 1300,
        heatCapacity: 1e6,
        ec: 0.1,
        redoxPotential: 400,
        nitrateContent: 20,
        ammoniumContent: 5,
        phosphateContent: 2,
        microbialBiomass: 100.0,
        epsContent: 0.1,
        fungalHyphaeDensity: 0.1,
        necromass: 10.0,
        organicCarbon: 2.0, // Low C/N ratio
        particulateOrganicMatter: 30.0,
        mineralAssociatedOrganicMatter: 20.0,
        nitrogenContent: 100.0,
        hotspots: [
          const RhizosphereHotspot(id: 'h1', x: 0.5, z: 0.5, intensity: 1.0, type: HotspotType.rhizosphere, age: 0),
        ],
      );

      final layerNoHotspot = layerWithHotspot.copyWith(hotspots: []);

      final profileWith = SoilProfile(
        id: 'p-with',
        name: 'With',
        layers: [layerWithHotspot],
        surfaceAlbedo: 0.2,
        slope: 0.0,
      );
      final profileWithout = SoilProfile(
        id: 'p-without',
        name: 'Without',
        layers: [layerNoHotspot],
        surfaceAlbedo: 0.2,
        slope: 0.0,
      );

      final resultWith = MicrobialEnzymesSolver.solve(profileWith, 60.0);
      final resultWithout = MicrobialEnzymesSolver.solve(profileWithout, 60.0);

      // NH4+ gain (from organic N mineralization) should be higher with hotspot priming
      final nh4With = resultWith.layers[0].ammoniumContent;
      final nh4Without = resultWithout.layers[0].ammoniumContent;

      expect(nh4With, greaterThan(nh4Without));
    });
  });
}
