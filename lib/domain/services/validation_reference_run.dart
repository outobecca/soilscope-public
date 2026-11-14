import '../models/biophysical_state.dart';
import '../models/soil_layer.dart';
import '../models/soil_profile.dart';
import '../solvers/simulation_engine.dart';

/// A fixed, plant-free soil column used to exercise the water and nitrate
/// solvers for the illustrative reference check.
///
/// It is deliberately deterministic: no plants means no root-growth RNG, so
/// the same engine code always produces the same reference series. The fixture
/// is a regression reference generated from this run, not field data.
class ValidationReferenceRun {
  static const int defaultHours = 168;

  /// Fractions of the run at which reference points are sampled.
  static const List<double> fractions = [
    0.125,
    0.25,
    0.375,
    0.5,
    0.625,
    0.75,
    0.875,
    1.0,
  ];

  static BiophysicalState initialState() {
    return const BiophysicalState(
      profile: SoilProfile(
        id: 'validation_reference',
        name: 'Illustrative reference loam',
        layers: [
          SoilLayer(
            id: 'A',
            depth: 0.0,
            thickness: 0.3,
            kSat: 1e-5,
            porosity: 0.45,
            thetaR: 0.05,
            vgAlpha: 2.0,
            vgN: 1.4,
            bulkDensity: 1300.0,
            waterContent: 0.32,
            temperature: 293.15,
            heatCapacity: 800.0,
            ph: 6.5,
            ec: 0.5,
            redoxPotential: 550.0,
            nitrateContent: 80.0,
            ammoniumContent: 20.0,
            phosphateContent: 10.0,
            potassiumContent: 20.0,
            sandFraction: 0.5,
            siltFraction: 0.3,
            clayFraction: 0.2,
            microbialBiomass: 200.0,
            epsContent: 5.0,
            fungalHyphaeDensity: 12.0,
            necromass: 8.0,
            organicCarbon: 12.0,
            particulateOrganicMatter: 4.0,
            mineralAssociatedOrganicMatter: 8.0,
            nitrogenContent: 1.0,
          ),
          SoilLayer(
            id: 'B',
            depth: 0.3,
            thickness: 0.5,
            kSat: 5e-6,
            porosity: 0.42,
            thetaR: 0.06,
            vgAlpha: 1.8,
            vgN: 1.3,
            bulkDensity: 1400.0,
            waterContent: 0.28,
            temperature: 291.15,
            heatCapacity: 850.0,
            ph: 6.8,
            ec: 0.3,
            redoxPotential: 500.0,
            nitrateContent: 40.0,
            ammoniumContent: 10.0,
            phosphateContent: 5.0,
            potassiumContent: 20.0,
            sandFraction: 0.4,
            siltFraction: 0.35,
            clayFraction: 0.25,
            microbialBiomass: 120.0,
            epsContent: 3.0,
            fungalHyphaeDensity: 8.0,
            necromass: 5.0,
            organicCarbon: 8.0,
            particulateOrganicMatter: 2.0,
            mineralAssociatedOrganicMatter: 6.0,
            nitrogenContent: 0.6,
          ),
        ],
        surfaceAlbedo: 0.2,
        slope: 0.01,
      ),
      plants: [],
      timeElapsed: 0,
      isInitializing: false,
      isRunning: false,
    );
  }

  static List<BiophysicalState> run({int hours = defaultHours}) {
    final history = <BiophysicalState>[initialState()];
    var current = history.first;
    for (var i = 0; i < hours; i++) {
      current = SimulationEngine.tick(current, 3600);
      history.add(current);
    }
    return history;
  }

  /// Nearest-neighbour samples at [fractions] of the final run time.
  static List<BiophysicalState> sample(
    List<BiophysicalState> history,
    List<double> fractions,
  ) {
    if (history.isEmpty) return const [];
    final end = history.last.timeElapsed;
    return [
      for (final fraction in fractions)
        history.reduce((a, b) {
          final target = end * fraction;
          return (a.timeElapsed - target).abs() <=
                  (b.timeElapsed - target).abs()
              ? a
              : b;
        }),
    ];
  }
}
