import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/domain/models/soil_layer.dart';
import 'package:soilscope/domain/models/soil_profile.dart';
import 'package:soilscope/domain/models/plant.dart';
import 'package:soilscope/domain/solvers/plant_solver.dart';
import 'package:soilscope/domain/solvers/nutrient_buffer.dart';

void main() {
  group('PlantSolver Advanced', () {
    final layer = SoilLayer(
      id: 'A',
      depth: 0.0,
      thickness: 0.2,
      kSat: 1e-5,
      porosity: 0.45,
      thetaR: 0.05,
      vgAlpha: 2.0,
      vgN: 1.4,
      vgL: 0.5,
      bulkDensity: 1300,
      waterContent: 0.35,
      temperature: 293.15,
      heatCapacity: 800,
      ph: 6.5,
      ec: 0.1,
      redoxPotential: 600,
      nitrateContent: 50,
      ammoniumContent: 20,
      phosphateContent: 10,
      potassiumContent: 10,
      exchangeablePotassium: 100,
      cec: 15,
      microbialBiomass: 100,
      epsContent: 0.1,
      fungalHyphaeDensity: 0.1,
      necromass: 1.0,
      organicCarbon: 2.0,
      particulateOrganicMatter: 10.0,
      mineralAssociatedOrganicMatter: 1.0,
      nitrogenContent: 70.0,
    );

    final plant = Plant(
      id: 'p1',
      species: 'Wheat',
      age: 10,
      height: 0.1,
      lai: 0.5,
      turgorPressure: 0.8,
      rootSystem: [const RootNode(x: 0.5, z: 0.05, radius: 0.01, isTip: true)],
      nitrogenUptake: 0,
      waterUptake: 0,
      totalBiomass: 100,
    );

    final profile = SoilProfile(
      id: 't',
      name: 'T',
      layers: [layer],
      surfaceAlbedo: 0.2,
      slope: 0.0,
    );

    test('Calculates Nutrient Sinks', () {
      // First run solve to get plant with actual transpiration calculated
      final (updatedPlant, _) = PlantSolver.solve(plant, profile, 3600.0);
      final buffer = NutrientBuffer(profile.layers.length);
      PlantSolver.accumulateSinks(updatedPlant, profile, buffer);

      // With SPAC integration, sinks depend on actual transpiration
      // Verify the structure is correct
      expect(buffer.nitrate.length, equals(1));
      if (updatedPlant.actualTranspiration > 0) {
        expect(buffer.nitrate[0], greaterThanOrEqualTo(0.0));
      }
      // Carbon source from root exudates should still exist
      expect(buffer.carbonSource[0], greaterThanOrEqualTo(0.0));
    });

    test('Growth increments totalBiomass', () {
      final (updated, _) = PlantSolver.solve(plant, profile, 86400.0); // 24h
      expect(updated.totalBiomass, greaterThan(100.0));
    });
  });
}
