import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/domain/models/biophysical_state.dart';
import 'package:soilscope/domain/models/soil_layer.dart';
import 'package:soilscope/domain/models/soil_profile.dart';
import 'package:soilscope/presentation/widgets/game/components/visual_state_interpolator.dart';

SoilLayer _layer({required double water}) => SoilLayer(
  id: 'topsoil',
  depth: 0,
  thickness: 0.3,
  kSat: 1e-6,
  porosity: 0.45,
  thetaR: 0.05,
  vgAlpha: 1.5,
  vgN: 1.5,
  bulkDensity: 1400,
  waterContent: water,
  temperature: 293.15,
  heatCapacity: 800,
  ph: 6.5,
  ec: 0.2,
  redoxPotential: 500,
  nitrateContent: 15,
  ammoniumContent: 5,
  phosphateContent: 5,
  microbialBiomass: 40,
  epsContent: 0,
  fungalHyphaeDensity: 0,
  necromass: 0,
  organicCarbon: 10,
  mineralAssociatedOrganicMatter: 10,
  particulateOrganicMatter: 0.5,
  nitrogenContent: 0.2,
);

BiophysicalState _state({required double water, required double rain}) =>
    BiophysicalState(
      profile: SoilProfile(
        id: 'p',
        name: 'p',
        layers: [_layer(water: water)],
        surfaceAlbedo: 0.2,
        slope: 0,
      ),
      plants: const [],
      timeElapsed: 0,
      precipitation: rain,
    );

void main() {
  test('interpolates soil and atmosphere values without changing topology', () {
    final interpolator = VisualStateInterpolator(transitionSeconds: 0.2);
    final first = _state(water: 0.2, rain: 0);
    final second = _state(water: 0.4, rain: 10);

    interpolator.setTarget(first);
    expect(interpolator.value, same(first));

    interpolator.setTarget(second);
    expect(interpolator.value!.precipitation, 0);
    expect(interpolator.value!.profile.layers.single.waterContent, 0.2);

    interpolator.advance(0.1);
    expect(interpolator.value!.precipitation, closeTo(5, 1e-9));
    expect(
      interpolator.value!.profile.layers.single.waterContent,
      closeTo(0.3, 1e-9),
    );

    interpolator.advance(0.1);
    expect(interpolator.value!.precipitation, closeTo(10, 1e-9));
    expect(
      interpolator.value!.profile.layers.single.waterContent,
      closeTo(0.4, 1e-9),
    );
    expect(interpolator.isTransitioning, isFalse);
  });

  test('immediate targets follow timeline scrubbing without a transition', () {
    final interpolator = VisualStateInterpolator(transitionSeconds: 0.2);
    final first = _state(water: 0.2, rain: 0);
    final second = _state(water: 0.4, rain: 10);

    interpolator.setTarget(first);
    interpolator.setTarget(second, immediate: true);

    expect(interpolator.value, same(second));
    expect(interpolator.isTransitioning, isFalse);
    expect(interpolator.advance(0.1), isFalse);
  });

  test('a new snapshot starts from the currently displayed value', () {
    final interpolator = VisualStateInterpolator(transitionSeconds: 0.2);
    interpolator.setTarget(_state(water: 0.2, rain: 0));
    interpolator.setTarget(_state(water: 0.4, rain: 10));
    interpolator.advance(0.1);

    interpolator.setTarget(_state(water: 0.6, rain: 20));
    expect(interpolator.value!.precipitation, closeTo(5, 1e-9));
    expect(
      interpolator.value!.profile.layers.single.waterContent,
      closeTo(0.3, 1e-9),
    );

    interpolator.advance(0.2);
    expect(interpolator.value!.precipitation, closeTo(20, 1e-9));
    expect(
      interpolator.value!.profile.layers.single.waterContent,
      closeTo(0.6, 1e-9),
    );
  });
}
