// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simulation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Owns the simulation's Riverpod-facing concerns: engine lifecycle, tick
/// merging, session persistence, timeline entry points and the public
/// intervention facades.
///
/// The transition rules live in [SimulationInterventions], snapshot storage in
/// [SimulationTimeline], tick reconciliation in [SimulationTickProcessor],
/// isolate and particle lifecycle in [SimulationRuntime], and the saved-session
/// envelope in [SimulationPersistence]. This notifier coordinates them; it does
/// not reimplement them.

@ProviderFor(Simulation)
final simulationProvider = SimulationProvider._();

/// Owns the simulation's Riverpod-facing concerns: engine lifecycle, tick
/// merging, session persistence, timeline entry points and the public
/// intervention facades.
///
/// The transition rules live in [SimulationInterventions], snapshot storage in
/// [SimulationTimeline], tick reconciliation in [SimulationTickProcessor],
/// isolate and particle lifecycle in [SimulationRuntime], and the saved-session
/// envelope in [SimulationPersistence]. This notifier coordinates them; it does
/// not reimplement them.
final class SimulationProvider
    extends $NotifierProvider<Simulation, BiophysicalState> {
  /// Owns the simulation's Riverpod-facing concerns: engine lifecycle, tick
  /// merging, session persistence, timeline entry points and the public
  /// intervention facades.
  ///
  /// The transition rules live in [SimulationInterventions], snapshot storage in
  /// [SimulationTimeline], tick reconciliation in [SimulationTickProcessor],
  /// isolate and particle lifecycle in [SimulationRuntime], and the saved-session
  /// envelope in [SimulationPersistence]. This notifier coordinates them; it does
  /// not reimplement them.
  SimulationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'simulationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$simulationHash();

  @$internal
  @override
  Simulation create() => Simulation();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BiophysicalState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BiophysicalState>(value),
    );
  }
}

String _$simulationHash() => r'576b753134c52a5c4eeef8677170bf0907d5f64d';

/// Owns the simulation's Riverpod-facing concerns: engine lifecycle, tick
/// merging, session persistence, timeline entry points and the public
/// intervention facades.
///
/// The transition rules live in [SimulationInterventions], snapshot storage in
/// [SimulationTimeline], tick reconciliation in [SimulationTickProcessor],
/// isolate and particle lifecycle in [SimulationRuntime], and the saved-session
/// envelope in [SimulationPersistence]. This notifier coordinates them; it does
/// not reimplement them.

abstract class _$Simulation extends $Notifier<BiophysicalState> {
  BiophysicalState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<BiophysicalState, BiophysicalState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BiophysicalState, BiophysicalState>,
              BiophysicalState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(displayedSimulationState)
final displayedSimulationStateProvider = DisplayedSimulationStateProvider._();

final class DisplayedSimulationStateProvider
    extends
        $FunctionalProvider<
          BiophysicalState,
          BiophysicalState,
          BiophysicalState
        >
    with $Provider<BiophysicalState> {
  DisplayedSimulationStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'displayedSimulationStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$displayedSimulationStateHash();

  @$internal
  @override
  $ProviderElement<BiophysicalState> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BiophysicalState create(Ref ref) {
    return displayedSimulationState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BiophysicalState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BiophysicalState>(value),
    );
  }
}

String _$displayedSimulationStateHash() =>
    r'ef90f186d434bcb463024f3e967fb631e7295a36';
