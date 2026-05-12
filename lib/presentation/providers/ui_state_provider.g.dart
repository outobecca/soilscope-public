// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ui_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UIState)
final uIStateProvider = UIStateProvider._();

final class UIStateProvider extends $NotifierProvider<UIState, HoverInfo?> {
  UIStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'uIStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$uIStateHash();

  @$internal
  @override
  UIState create() => UIState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HoverInfo? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HoverInfo?>(value),
    );
  }
}

String _$uIStateHash() => r'ac9737fb0c1fdde12cf622aea64d4a47cb1b569a';

abstract class _$UIState extends $Notifier<HoverInfo?> {
  HoverInfo? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<HoverInfo?, HoverInfo?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HoverInfo?, HoverInfo?>,
              HoverInfo?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ActiveCycle)
final activeCycleProvider = ActiveCycleProvider._();

final class ActiveCycleProvider
    extends $NotifierProvider<ActiveCycle, ObservationCycle> {
  ActiveCycleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeCycleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeCycleHash();

  @$internal
  @override
  ActiveCycle create() => ActiveCycle();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ObservationCycle value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ObservationCycle>(value),
    );
  }
}

String _$activeCycleHash() => r'97570a29721e8667a61267816a3c4d91c24c93a0';

abstract class _$ActiveCycle extends $Notifier<ObservationCycle> {
  ObservationCycle build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ObservationCycle, ObservationCycle>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ObservationCycle, ObservationCycle>,
              ObservationCycle,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ParticleFlowMode)
final particleFlowModeProvider = ParticleFlowModeProvider._();

final class ParticleFlowModeProvider
    extends $NotifierProvider<ParticleFlowMode, bool> {
  ParticleFlowModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'particleFlowModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$particleFlowModeHash();

  @$internal
  @override
  ParticleFlowMode create() => ParticleFlowMode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$particleFlowModeHash() => r'39a878fee54ecd03bfcc5c42d32be8659d0ff242';

abstract class _$ParticleFlowMode extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ActiveTutorialStep)
final activeTutorialStepProvider = ActiveTutorialStepProvider._();

final class ActiveTutorialStepProvider
    extends $NotifierProvider<ActiveTutorialStep, ScenarioTutorialStep?> {
  ActiveTutorialStepProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeTutorialStepProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeTutorialStepHash();

  @$internal
  @override
  ActiveTutorialStep create() => ActiveTutorialStep();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScenarioTutorialStep? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScenarioTutorialStep?>(value),
    );
  }
}

String _$activeTutorialStepHash() =>
    r'838bf9eb758ee2ce26cb6ee20b6706af48607d28';

abstract class _$ActiveTutorialStep extends $Notifier<ScenarioTutorialStep?> {
  ScenarioTutorialStep? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ScenarioTutorialStep?, ScenarioTutorialStep?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ScenarioTutorialStep?, ScenarioTutorialStep?>,
              ScenarioTutorialStep?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
