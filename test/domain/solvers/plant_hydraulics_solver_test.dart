import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/core/biophysics_utils.dart';
import 'package:soilscope/domain/solvers/plant/plant_hydraulics_solver.dart';

void main() {
  group('PlantHydraulicsSolver.calculateLayerPsi', () {
    test('converts van Genuchten pressure head [m] to ψ [MPa] consistently', () {
      const double thetaS = 0.43;
      const double thetaR = 0.078;
      const double alpha = 3.6; // 1/m
      const double n = 1.56;
      const double theta = 0.25;

      final double psiHeadM = BiophysicsUtils.thetaToPsi(
        theta,
        thetaR,
        thetaS,
        alpha,
        n,
      );

      // ψ(MPa) = ρ g h / 1e6
      const double mH2OToMPa = 1000.0 * 9.80665 / 1e6;
      final double expectedMpa = (psiHeadM * mH2OToMPa).clamp(-10.0, 0.0);

      final double actualMpa = PlantHydraulicsSolver.calculateLayerPsi(
        theta,
        thetaR,
        thetaS,
        alpha,
        n,
      );

      expect(actualMpa, closeTo(expectedMpa, 1e-9));
      expect(actualMpa, lessThanOrEqualTo(0.0));
    });

    test('returns 0 MPa at saturation', () {
      const double thetaS = 0.43;
      const double thetaR = 0.078;
      const double alpha = 3.6; // 1/m
      const double n = 1.56;

      final double psiMpa = PlantHydraulicsSolver.calculateLayerPsi(
        thetaS,
        thetaR,
        thetaS,
        alpha,
        n,
      );

      expect(psiMpa, 0.0);
    });
  });
}
