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
    bool clearLayerId = false,
    String? selectedElementSymbol,
    bool clearElementSymbol = false,
    String? selectedInspectorType,
    bool clearInspectorType = false,
    bool? isMicroscopeEnabled,
    bool? isScrubbing,
    double? viewTime,
  }) {
    return SimulationSessionState(
      selectedLayerId: clearLayerId ? null : (selectedLayerId ?? this.selectedLayerId),
      selectedElementSymbol: clearElementSymbol ? null : (selectedElementSymbol ?? this.selectedElementSymbol),
      selectedInspectorType: clearInspectorType ? null : (selectedInspectorType ?? this.selectedInspectorType),
      isMicroscopeEnabled: isMicroscopeEnabled ?? this.isMicroscopeEnabled,
      isScrubbing: isScrubbing ?? this.isScrubbing,
      viewTime: viewTime ?? this.viewTime,
    );
  }

  /// Value identity matters here: panels watch this state as a whole and a
  /// tap that re-selects the current layer or element must not invalidate
  /// them. Without equality every re-select rebuilt the whole control panel.
  @override
  bool operator ==(Object other) =>
      other is SimulationSessionState &&
      other.selectedLayerId == selectedLayerId &&
      other.selectedElementSymbol == selectedElementSymbol &&
      other.selectedInspectorType == selectedInspectorType &&
      other.isMicroscopeEnabled == isMicroscopeEnabled &&
      other.isScrubbing == isScrubbing &&
      other.viewTime == viewTime;

  @override
  int get hashCode => Object.hash(
    selectedLayerId,
    selectedElementSymbol,
    selectedInspectorType,
    isMicroscopeEnabled,
    isScrubbing,
    viewTime,
  );
}

@Riverpod(keepAlive: true)
class SimulationSession extends _$SimulationSession {
  @override
  SimulationSessionState build() => const SimulationSessionState();

  double? _pendingViewTime;
  bool _isTimeUpdateScheduled = false;

  void selectLayer(String? layerId) {
    Future.microtask(() {
      if (state.selectedLayerId == layerId) return;
      state = state.copyWith(
        selectedLayerId: layerId,
        clearLayerId: layerId == null,
      );
    });
  }

  void selectElement(String? symbol) {
    final normalized = (symbol == null || symbol.isEmpty) ? null : symbol;
    Future.microtask(() {
      if (state.selectedElementSymbol == normalized) return;
      state = state.copyWith(
        selectedElementSymbol: normalized,
        clearElementSymbol: normalized == null,
      );
    });
  }

  void selectInspector(String? type) {
    Future.microtask(() {
      if (state.selectedInspectorType == type) return;
      state = state.copyWith(
        selectedInspectorType: type,
        clearInspectorType: type == null,
        isMicroscopeEnabled: type != null ? true : state.isMicroscopeEnabled,
      );
    });
  }

  void toggleMicroscope() {
    Future.microtask(() {
      final willEnable = !state.isMicroscopeEnabled;
      state = state.copyWith(
        isMicroscopeEnabled: willEnable,
        selectedInspectorType: willEnable
            ? (state.selectedInspectorType ?? 'rhizosphere')
            : null,
        clearInspectorType: !willEnable,
      );
    });
  }

  /// Reset all view state that belongs to a single scenario run. Called when
  /// a new scenario replaces the old one, so a selected layer or open
  /// microscope cannot leak into the next run.
  void resetForScenario() {
    _pendingViewTime = null;
    _isTimeUpdateScheduled = false;
    state = const SimulationSessionState();
  }

  void setScrubbing(bool isScrubbing) {
    if (state.isScrubbing == isScrubbing) return;
    state = state.copyWith(isScrubbing: isScrubbing);
  }

  void setViewTime(double time) {
    _pendingViewTime = time;
    if (!_isTimeUpdateScheduled) {
      _isTimeUpdateScheduled = true;
      Future.microtask(() {
        if (_pendingViewTime != null) {
          state = state.copyWith(viewTime: _pendingViewTime!);
          _pendingViewTime = null;
        }
        _isTimeUpdateScheduled = false;
      });
    }
  }

  void scrubTo(double time) {
    Future.microtask(() {
      state = state.copyWith(viewTime: time, isScrubbing: true);
    });
  }
}
