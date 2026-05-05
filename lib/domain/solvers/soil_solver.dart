import '../models/soil_profile.dart';
import '../models/plant.dart';

/// Encapsulates environmental forcing and physical bounds for solver integration.
class SolverContext {
  final double dt;
  final double precipitation;
  final double airTemperature;
  final double atmCO2;
  final double relativeHumidity;
  final double solarRadiation;
  final List<Plant> plants;

  SolverContext({
    required this.dt,
    this.precipitation = 0.0,
    this.airTemperature = 293.15,
    this.atmCO2 = 415.0,
    this.relativeHumidity = 0.5,
    this.solarRadiation = 500.0,
    this.plants = const [],
  });
}

/// Abstract blueprint for 1D numerical solvers managing SPAC transitions.
abstract interface class SoilSolver {
  /// Unique identifier of the scientific solver.
  String get name;

  /// Numerically integrates biophysical processes across the soil profile.
  SoilProfile solve(SoilProfile profile, SolverContext context);
}
