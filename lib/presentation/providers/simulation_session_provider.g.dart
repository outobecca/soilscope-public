// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simulation_session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SimulationSession)
final simulationSessionProvider = SimulationSessionProvider._();

final class SimulationSessionProvider
    extends $NotifierProvider<SimulationSession, SimulationSessionState> {
  SimulationSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'simulationSessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$simulationSessionHash();

  @$internal
  @override
  SimulationSession create() => SimulationSession();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SimulationSessionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SimulationSessionState>(value),
    );
  }
}

String _$simulationSessionHash() => r'399f343057ccc612f91e85dc5c6a42dda65c9bfa';

abstract class _$SimulationSession extends $Notifier<SimulationSessionState> {
  SimulationSessionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<SimulationSessionState, SimulationSessionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SimulationSessionState, SimulationSessionState>,
              SimulationSessionState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
