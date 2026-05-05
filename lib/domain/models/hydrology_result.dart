import '../models/soil_profile.dart';

class HydrologyResult {
  final SoilProfile profile;
  final List<double> averageFluxes;
  final double latentHeat; // W/m^2
  final double actualEvaporation; // m/s

  HydrologyResult({
    required this.profile,
    required this.averageFluxes,
    required this.latentHeat,
    this.actualEvaporation = 0.0,
  });
}
