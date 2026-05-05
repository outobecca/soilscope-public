import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'simulation_session_provider.g.dart';

class SimulationSessionState {
  final String? selectedLayerId;
  final String? selectedElementSymbol;
  final String? selectedInspectorType;
  final bool isMicroscopeEnabled;
  final bool isScrubbing;
  final double viewTime;

  const SimulationSessionState({
    this.selectedLayerId,
    this.selectedElementSymbol,
    this.selectedInspectorType,
    this.isMicroscopeEnabled = false,
    this.isScrubbing = false,
    this.viewTime = 0.0,
  });

  SimulationSessionState copyWith({
    String? selectedLayerId,
    String? selectedElementSymbol,
    String? selectedInspectorType,
    bool? isMicroscopeEnabled,
    bool? isScrubbing,
    double? viewTime,
  }) {
    return SimulationSessionState(
      selectedLayerId: selectedLayerId ?? this.selectedLayerId,
      selectedElementSymbol: selectedElementSymbol ?? this.selectedElementSymbol,
      selectedInspectorType: selectedInspectorType ?? this.selectedInspectorType,
      isMicroscopeEnabled: isMicroscopeEnabled ?? this.isMicroscopeEnabled,
      isScrubbing: isScrubbing ?? this.isScrubbing,
      viewTime: viewTime ?? this.viewTime,
    );
  }
}

@Riverpod(keepAlive: true)
class SimulationSession extends _$SimulationSession {
  @override
  SimulationSessionState build() => const SimulationSessionState();

  void selectLayer(String? layerId) {
    state = state.copyWith(selectedLayerId: layerId);
  }

  void selectElement(String? symbol) {
    state = state.copyWith(selectedElementSymbol: symbol);
  }

  void selectInspector(String? type) {
    state = state.copyWith(selectedInspectorType: type);
  }

  void toggleMicroscope() {
    state = state.copyWith(isMicroscopeEnabled: !state.isMicroscopeEnabled);
  }

  void setScrubbing(bool isScrubbing) {
    state = state.copyWith(isScrubbing: isScrubbing);
  }

  void setViewTime(double time) {
    state = state.copyWith(viewTime: time);
  }

  void scrubTo(double time) {
    state = state.copyWith(viewTime: time, isScrubbing: true);
  }
}
