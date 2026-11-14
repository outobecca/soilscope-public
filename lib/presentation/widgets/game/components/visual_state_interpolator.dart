import 'dart:math' as math;

import '../../../../domain/models/biophysical_state.dart';
import '../../../../domain/models/plant.dart';
import '../../../../domain/models/soil_layer.dart';

/// Smooths the visual fields that arrive from the engine at roughly 5 Hz.
///
/// The authoritative snapshot is never mutated. Each new target starts a short
/// transition from the currently displayed values, which avoids the visible
/// step that occurs when a soil layer, plant mass, or precipitation value is
/// assigned directly to the canvas. Discrete topology (layer IDs, root nodes,
/// booleans) comes from the target snapshot.
class VisualStateInterpolator {
  VisualStateInterpolator({this.transitionSeconds = 0.2});

  final double transitionSeconds;

  BiophysicalState? _from;
  BiophysicalState? _target;
  BiophysicalState? _value;
  double _elapsed = 0;
  bool _active = false;

  BiophysicalState? get value => _value;
  bool get isTransitioning => _active;

  /// Starts a transition to [next]. If this is the first value, it is applied
  /// immediately so the first rendered frame is never blank or half-built.
  void setTarget(BiophysicalState next, {bool immediate = false}) {
    if (immediate || _value == null || transitionSeconds <= 0) {
      _from = next;
      _target = next;
      _value = next;
      _elapsed = 0;
      _active = false;
      return;
    }
    if (identical(_target, next)) return;

    // Continue from what is currently on screen, not from the previous target.
    // This prevents a jump when a second snapshot arrives before the first
    // transition has finished.
    _from = _value;
    _target = next;
    _elapsed = 0;
    _active = true;
  }

  /// Advances the transition by [dt] seconds. Returns true when the displayed
  /// value changed.
  bool advance(double dt) {
    if (!_active || _target == null || _from == null) return false;
    if (!dt.isFinite || dt <= 0) return false;

    _elapsed += dt;
    if (transitionSeconds <= 0 || _elapsed >= transitionSeconds) {
      _value = _target;
      _from = _target;
      _elapsed = 0;
      _active = false;
      return true;
    }

    final t = (_elapsed / transitionSeconds).clamp(0.0, 1.0);
    _value = _interpolate(_from!, _target!, t);
    return true;
  }

  void reset(BiophysicalState? value) {
    _from = value;
    _target = value;
    _value = value;
    _elapsed = 0;
    _active = false;
  }

  BiophysicalState _interpolate(
    BiophysicalState from,
    BiophysicalState to,
    double t,
  ) {
    final fromLayers = {
      for (final layer in from.profile.layers) layer.id: layer,
    };
    final layers = to.profile.layers
        .map((target) {
          final source = fromLayers[target.id];
          return source == null ? target : _mixLayer(source, target, t);
        })
        .toList(growable: false);

    final fromPlants = {for (final plant in from.plants) plant.id: plant};
    final plants = to.plants
        .map((target) {
          final source = fromPlants[target.id];
          return source == null ? target : _mixPlant(source, target, t);
        })
        .toList(growable: false);

    return to.copyWith(
      profile: to.profile.copyWith(layers: layers),
      plants: plants,
      precipitation: _mix(from.precipitation, to.precipitation, t),
      soilEvaporation: _mix(from.soilEvaporation, to.soilEvaporation, t),
      airTemperature: _mix(from.airTemperature, to.airTemperature, t),
      relativeHumidity: _mix(from.relativeHumidity, to.relativeHumidity, t),
      atmCO2: _mix(from.atmCO2, to.atmCO2, t),
    );
  }

  SoilLayer _mixLayer(SoilLayer from, SoilLayer to, double t) {
    return to.copyWith(
      waterContent: _mix(from.waterContent, to.waterContent, t),
      previousWaterContent: _mix(
        from.previousWaterContent,
        to.previousWaterContent,
        t,
      ),
      verticalFlux: _mix(from.verticalFlux, to.verticalFlux, t),
      temperature: _mix(from.temperature, to.temperature, t),
      ph: _mix(from.ph, to.ph, t),
      redoxPotential: _mix(from.redoxPotential, to.redoxPotential, t),
      nitrateContent: _mix(from.nitrateContent, to.nitrateContent, t),
      ammoniumContent: _mix(from.ammoniumContent, to.ammoniumContent, t),
      phosphateContent: _mix(from.phosphateContent, to.phosphateContent, t),
      potassiumContent: _mix(from.potassiumContent, to.potassiumContent, t),
      exchangeablePotassium: _mix(
        from.exchangeablePotassium,
        to.exchangeablePotassium,
        t,
      ),
      organicCarbon: _mix(from.organicCarbon, to.organicCarbon, t),
      labileCarbon: _mix(from.labileCarbon, to.labileCarbon, t),
      stableCarbon: _mix(from.stableCarbon, to.stableCarbon, t),
      microbialBiomass: _mix(from.microbialBiomass, to.microbialBiomass, t),
      oxygenContent: _mix(from.oxygenContent, to.oxygenContent, t),
      co2Content: _mix(from.co2Content, to.co2Content, t),
      nitrousOxideContent: _mix(
        from.nitrousOxideContent,
        to.nitrousOxideContent,
        t,
      ),
      nitrogenContent: _mix(from.nitrogenContent, to.nitrogenContent, t),
      organicNitrogen: _mix(from.organicNitrogen, to.organicNitrogen, t),
      microbialNitrogen: _mix(from.microbialNitrogen, to.microbialNitrogen, t),
      maomNitrogen: _mix(from.maomNitrogen, to.maomNitrogen, t),
      epsContent: _mix(from.epsContent, to.epsContent, t),
      fungalHyphaeDensity: _mix(
        from.fungalHyphaeDensity,
        to.fungalHyphaeDensity,
        t,
      ),
      necromass: _mix(from.necromass, to.necromass, t),
      aggregateStability: _mix(
        from.aggregateStability,
        to.aggregateStability,
        t,
      ),
      nitrificationRate: _mix(from.nitrificationRate, to.nitrificationRate, t),
      denitrificationRate: _mix(
        from.denitrificationRate,
        to.denitrificationRate,
        t,
      ),
    );
  }

  Plant _mixPlant(Plant from, Plant to, double t) {
    return to.copyWith(
      age: _mix(from.age, to.age, t),
      height: _mix(from.height, to.height, t),
      lai: _mix(from.lai, to.lai, t),
      turgorPressure: _mix(from.turgorPressure, to.turgorPressure, t),
      totalBiomass: _mix(from.totalBiomass, to.totalBiomass, t),
      rootBiomass: _mix(from.rootBiomass, to.rootBiomass, t),
      nitrogenUptake: _mix(from.nitrogenUptake, to.nitrogenUptake, t),
      waterUptake: _mix(from.waterUptake, to.waterUptake, t),
      phosphorusUptake: _mix(from.phosphorusUptake, to.phosphorusUptake, t),
      calciumUptake: _mix(from.calciumUptake, to.calciumUptake, t),
      magnesiumUptake: _mix(from.magnesiumUptake, to.magnesiumUptake, t),
      psiLeaf: _mix(from.psiLeaf, to.psiLeaf, t),
      stomatalConductance: _mix(
        from.stomatalConductance,
        to.stomatalConductance,
        t,
      ),
      waterStressIndex: _mix(from.waterStressIndex, to.waterStressIndex, t),
      relativeWaterContent: _mix(
        from.relativeWaterContent,
        to.relativeWaterContent,
        t,
      ),
      actualTranspiration: _mix(
        from.actualTranspiration,
        to.actualTranspiration,
        t,
      ),
      absorbedPAR: _mix(from.absorbedPAR, to.absorbedPAR, t),
      lightTransmission: _mix(from.lightTransmission, to.lightTransmission, t),
    );
  }

  double _mix(double from, double to, double t) {
    if (!from.isFinite) return to;
    if (!to.isFinite) return from;
    return from + (to - from) * t;
  }
}

/// Small helper used by interpolation tests and future visual controllers.
double visualLerp(double from, double to, double t) =>
    from + (to - from) * t.clamp(0.0, 1.0);

/// A finite-difference guard for callers that receive a timestamp delta.
double safeAnimationDelta(double dt, {double max = 0.05}) {
  if (!dt.isFinite || dt <= 0) return 0;
  return math.min(dt, max);
}
