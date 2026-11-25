import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/domain/models/default_simulation_profile.dart';
import 'package:soilscope/presentation/widgets/game/logic/soil_layer_noise_engine.dart';

void main() {
  final base = defaultSoilProfile().layers.first;
  final baseKey = SoilLayerNoiseKey.of(base);

  group('SoilLayerNoiseKey', () {
    test('changes when any painter input changes', () {
      expect(
        SoilLayerNoiseKey.of(base.copyWith(sandFraction: 0.55)),
        isNot(baseKey),
      );
      expect(
        SoilLayerNoiseKey.of(base.copyWith(siltFraction: 0.30)),
        isNot(baseKey),
      );
      expect(
        SoilLayerNoiseKey.of(base.copyWith(clayFraction: 0.35)),
        isNot(baseKey),
      );
      expect(
        SoilLayerNoiseKey.of(base.copyWith(aggregateStability: 0.05)),
        isNot(baseKey),
      );
    });

    test('collapses organic carbon above the patch saturation point', () {
      // The painter clamps organicCarbon * 25 to 1.0 at and above 0.04, so all
      // saturated soils must share one raster.
      final saturated = base.copyWith(
        organicCarbon: SoilLayerNoiseKey.carbonSaturation * 100,
      );
      expect(SoilLayerNoiseKey.of(saturated), baseKey);
      expect(
        SoilLayerNoiseKey.of(
          saturated.copyWith(organicCarbon: saturated.organicCarbon + 500),
        ),
        baseKey,
      );
    });

    test('keeps sub-bucket drift out of the key', () {
      expect(
        SoilLayerNoiseKey.of(base.copyWith(sandFraction: 0.4001)),
        baseKey,
      );
      expect(
        SoilLayerNoiseKey.of(base.copyWith(aggregateStability: 0.5001)),
        baseKey,
      );
    });

    test('tolerates non-finite inputs', () {
      expect(
        () => SoilLayerNoiseKey.of(base.copyWith(sandFraction: double.nan)),
        returnsNormally,
      );
    });
  });
}
