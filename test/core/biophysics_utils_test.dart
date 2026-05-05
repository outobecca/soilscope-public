import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/core/biophysics_utils.dart';

void main() {
  group('BiophysicsUtils - van Genuchten', () {
    const double thetaS = 0.43;
    const double thetaR = 0.078;
    const double alpha = 3.6; // 1/m
    const double n = 1.56;

    test('calculateSe returns 1.0 for positive psi', () {
      expect(BiophysicsUtils.calculateSe(0.0, alpha, n), 1.0);
      expect(BiophysicsUtils.calculateSe(10.0, alpha, n), 1.0);
    });

    test('calculateSe returns expected value for negative psi', () {
      final se = BiophysicsUtils.calculateSe(-1.0, alpha, n);
      expect(se, lessThan(1.0));
      expect(se, greaterThan(0.0));
    });

    test('thetaToPsi returns 0.0 for saturated theta', () {
      expect(BiophysicsUtils.thetaToPsi(thetaS, thetaR, thetaS, alpha, n), 0.0);
    });

    test('thetaToPsi returns negative value for unsaturated theta', () {
      final psi = BiophysicsUtils.thetaToPsi(0.25, thetaR, thetaS, alpha, n);
      expect(psi, lessThan(0.0));
    });

    test('calculateK returns kSat for Se=1.0', () {
      const kSat = 1e-5;
      expect(BiophysicsUtils.calculateK(1.0, kSat, n), kSat);
    });

    test('calculateK returns 0.0 for Se=0.0', () {
      expect(BiophysicsUtils.calculateK(0.0, 1e-5, n), 0.0);
    });
  });

  group('BiophysicsUtils - PTF', () {
    test('getVGParams returns correct params for Sand', () {
      final params = BiophysicsUtils.getVGParams(SoilTexture.sand);
      expect(params.alpha, 14.5);
      expect(params.n, 2.68);
    });

    test('getVGParams returns correct params for Clay', () {
      final params = BiophysicsUtils.getVGParams(SoilTexture.clay);
      expect(params.alpha, 0.8);
      expect(params.n, 1.09);
    });
  });
}
