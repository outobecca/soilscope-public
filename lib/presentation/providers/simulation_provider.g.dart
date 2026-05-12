// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simulation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Simulation)
final simulationProvider = SimulationProvider._();

final class SimulationProvider
    extends $NotifierProvider<Simulation, BiophysicalState> {
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

String _$simulationHash() => r'78420a3df9f234f6006afc60d6ad71311cf148c9';

abstract class _$Simulation extends $Notifier<BiophysicalState> {
  BiophysicalState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<BiophysicalState, BiophysicalState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BiophysicalState, BiophysicalState>,
              BiophysicalState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
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
    r'8874101c8e354d75c9b3b0e5f49f177f57fc549a';
