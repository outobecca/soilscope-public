// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SoilScopeGameProvider)
final soilScopeGameProviderProvider = SoilScopeGameProviderProvider._();

final class SoilScopeGameProviderProvider
    extends $NotifierProvider<SoilScopeGameProvider, SoilScopeGame?> {
  SoilScopeGameProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'soilScopeGameProviderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$soilScopeGameProviderHash();

  @$internal
  @override
  SoilScopeGameProvider create() => SoilScopeGameProvider();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SoilScopeGame? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SoilScopeGame?>(value),
    );
  }
}

String _$soilScopeGameProviderHash() =>
    r'fbdf8f0b54bd4b91c46ac06a2b2845ed0a97ea61';

abstract class _$SoilScopeGameProvider extends $Notifier<SoilScopeGame?> {
  SoilScopeGame? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SoilScopeGame?, SoilScopeGame?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SoilScopeGame?, SoilScopeGame?>,
              SoilScopeGame?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
