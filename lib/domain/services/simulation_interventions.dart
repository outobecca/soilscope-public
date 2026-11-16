import '../actions/simulation_actions.dart';
import '../models/biophysical_state.dart';
import '../models/soil_layer.dart';

/// Applies the interventions a user can trigger from the controls.
///
/// The provider owns engine lifecycle, persistence and Riverpod state; this
/// class owns what an intervention does to the state. State access, the event
/// log and engine synchronisation are supplied as callbacks, so the logic can
/// be exercised without a notifier, isolate or widget tree.
class SimulationInterventions {
  SimulationInterventions({
    required this.readState,
    required this.apply,
    required this.log,
    required this.leaveHistoryMode,
    required this.selectedLayerId,
    required this.isDisposed,
  });

  final BiophysicalState Function() readState;

  /// Writes the new state and synchronises the engine.
  final void Function(BiophysicalState state) apply;

  /// Appends a user-facing event at the given simulated time.
  final void Function(String message, double timeElapsed) log;

  /// Leaves timeline mode before an edit from a historical control.
  final void Function() leaveHistoryMode;

  final String? Function() selectedLayerId;

  final bool Function() isDisposed;

  void setSpeed(double speed) {
    apply(readState().copyWith(timeScale: speed));
  }

  void setPrecipitation(double precipitation) {
    leaveHistoryMode();
    apply(readState().copyWith(precipitation: precipitation));
  }

  void toggleAutoWeather() {
    final current = readState();
    leaveHistoryMode();
    apply(
      SimulationActions.updateWeather(
        current,
        current.airTemperature,
        current.relativeHumidity,
      ).copyWith(autoWeather: !current.autoWeather),
    );
  }

  /// Sets the auto-weather mode explicitly so a control shown from a historical
  /// snapshot can apply the state the user actually saw.
  void setAutoWeather(bool enabled) {
    final current = readState();
    leaveHistoryMode();
    apply(
      SimulationActions.updateWeather(
        current,
        current.airTemperature,
        current.relativeHumidity,
      ).copyWith(autoWeather: enabled),
    );
  }

  void applyCoverCrop() {
    leaveHistoryMode();
    final next = SimulationActions.toggleCoverCrop(readState());
    apply(next);
    log(
      'Cover crop ${next.hasCoverCrop ? "planted" : "removed"}.',
      next.timeElapsed,
    );
  }

  /// Sets the cover-crop state explicitly for controls that may be showing a
  /// historical snapshot rather than the live engine.
  void setCoverCrop(bool planted) {
    leaveHistoryMode();
    final current = readState();
    if (current.hasCoverCrop == planted) return;
    final next = SimulationActions.toggleCoverCrop(current);
    apply(next);
    log(
      'Cover crop ${next.hasCoverCrop ? "planted" : "removed"}.',
      next.timeElapsed,
    );
  }

  void applyNutrients(Map<String, double> pendingNutrients) {
    if (pendingNutrients.isEmpty) return;

    final current = readState();
    final layerId = _targetLayerId(current);
    if (layerId == null) return;

    leaveHistoryMode();
    var next = current;
    pendingNutrients.forEach((symbol, amount) {
      next = SimulationActions.applyNutrients(next, layerId, symbol, amount);
    });
    apply(next);
  }

  void triggerHeatWave() {
    leaveHistoryMode();
    final next = SimulationActions.triggerHeatWave(readState());
    apply(next);
    log('Heat wave!', next.timeElapsed);
  }

  void triggerFlashFlood() {
    leaveHistoryMode();
    final next = SimulationActions.triggerFlashFlood(readState());
    apply(next);
    log('Flash flood!', next.timeElapsed);
  }

  void updateWeather(double temperature, double humidity) {
    leaveHistoryMode();
    apply(SimulationActions.updateWeather(readState(), temperature, humidity));
  }

  void updateNutrient(String layerId, String symbol, double value) {
    leaveHistoryMode();
    apply(
      SimulationActions.applyNutrients(readState(), layerId, symbol, value),
    );
  }

  void updateSolarRadiation(double value) {
    leaveHistoryMode();
    apply(readState().copyWith(solarRadiationOverride: value));
  }

  void updatePAR(double value) {
    leaveHistoryMode();
    apply(readState().copyWith(solarRadiationOverride: value / 2.1));
  }

  void updateAtmosphere({
    double? temperature,
    double? humidity,
    double? precipitation,
    double? co2,
  }) {
    final current = readState();
    leaveHistoryMode();
    apply(
      current.copyWith(
        airTemperature: temperature ?? current.airTemperature,
        relativeHumidity: humidity ?? current.relativeHumidity,
        precipitation: precipitation ?? current.precipitation,
        atmCO2: co2 ?? current.atmCO2,
      ),
    );
  }

  bool applyTillage() {
    leaveHistoryMode();
    final next = SimulationActions.applyTillage(readState());
    apply(next);
    log('Soil tilled.', next.timeElapsed);
    return true;
  }

  void applyIrrigation({double amountMm = 10.0}) {
    leaveHistoryMode();
    final next = SimulationActions.applyIrrigation(
      readState(),
      amountMm: amountMm,
    );
    apply(next);
    log(
      'Irrigation applied (${amountMm.toStringAsFixed(0)} mm).',
      next.timeElapsed,
    );
  }

  void applyOrganicMatter() {
    leaveHistoryMode();
    final next = SimulationActions.applyOrganicMatter(readState());
    apply(next);
    log('Organic matter incorporated.', next.timeElapsed);
  }

  void applyDrainage() {
    leaveHistoryMode();
    final next = SimulationActions.applyDrainage(readState());
    apply(next);
    log('Soil drained and re-aerated.', next.timeElapsed);
  }

  /// Applies a one-tap fertilizer dose to the selected layer, falling back to
  /// the topsoil when the user has not selected a layer.
  void applyQuickNutrient(String symbol, {double amount = 20.0}) {
    final current = readState();
    final targetLayer = _targetLayerId(current);
    if (targetLayer == null) return;

    leaveHistoryMode();
    final next = SimulationActions.applyNutrients(
      current,
      targetLayer,
      symbol,
      amount,
    );
    apply(next);
    log('$symbol applied to $targetLayer.', next.timeElapsed);
  }

  /// Resolves the layer a nutrient application should target. A missing,
  /// atmosphere or stale selection falls back to the topsoil, matching the
  /// fertilizer console's expectation that applying a mix always reaches the
  /// soil instead of only playing the canvas effect.
  String? _targetLayerId(BiophysicalState state) {
    if (state.profile.layers.isEmpty) return null;

    final selected = selectedLayerId();
    if (selected != null &&
        selected != 'atmosphere' &&
        state.profile.layers.any((layer) => layer.id == selected)) {
      return selected;
    }
    return state.profile.layers.first.id;
  }

  /// Functional update pattern for soil layers.
  /// Decouples the UI from the internal structure of the SoilLayer.
  void updateLayer(String layerId, SoilLayer Function(SoilLayer) transform) {
    final current = readState();
    final newLayers = current.profile.layers.map<SoilLayer>((layer) {
      if (layer.id == layerId) return transform(layer);
      return layer;
    }).toList();

    if (isDisposed()) return;
    leaveHistoryMode();
    // Apply synchronously so a dragged slider never lags a frame behind.
    apply(
      current.copyWith(profile: current.profile.copyWith(layers: newLayers)),
    );
  }

  /// Convenience wrapper for updating a single soil layer parameter by string
  /// name.
  void updateLayerParameter(String layerId, String param, double value) {
    updateLayer(layerId, (layer) {
      switch (param) {
        case 'kSat':
          return layer.copyWith(kSat: value);
        case 'waterContent':
          return layer.copyWith(
            previousWaterContent: layer.waterContent,
            waterContent: value.clamp(
              layer.thetaR,
              (layer.porosity * 0.98).clamp(layer.thetaR, 1.0),
            ),
          );
        case 'thetaR':
          final thetaR = value.clamp(0.0, 0.4);
          return layer.copyWith(
            thetaR: thetaR,
            waterContent: layer.waterContent < thetaR
                ? thetaR
                : layer.waterContent,
          );
        case 'vgAlpha':
          return layer.copyWith(vgAlpha: value);
        case 'vgN':
          return layer.copyWith(vgN: value);
        case 'sandFraction':
          return layer.copyWith(sandFraction: value);
        case 'siltFraction':
          return layer.copyWith(siltFraction: value);
        case 'clayFraction':
          return layer.copyWith(clayFraction: value);
        case 'organicCarbon':
          return layer.copyWith(organicCarbon: value);
        case 'bulkDensity':
          return layer.copyWith(bulkDensity: value);
        case 'porosity':
          return layer.copyWith(porosity: value);
        case 'ammoniumContent':
          return layer.copyWith(ammoniumContent: value.clamp(0.0, 1000.0));
        case 'nitrateContent':
          return layer.copyWith(nitrateContent: value);
        case 'organicNitrogen':
          return layer.copyWith(organicNitrogen: value.clamp(0.0, 5000.0));
        case 'redoxPotential':
          return layer.copyWith(redoxPotential: value.clamp(-500.0, 800.0));
        case 'phosphateContent':
          return layer.copyWith(phosphateContent: value);
        case 'potassiumContent':
          return layer.copyWith(potassiumContent: value);
        default:
          return layer;
      }
    });
  }
}
