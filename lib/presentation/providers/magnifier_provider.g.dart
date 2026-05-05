// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'magnifier_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider to track which magnifier view is selected.
/// This allows the Flutter UI to control the Flame magnifier visibility.

@ProviderFor(SelectedMagnifier)
final selectedMagnifierProvider = SelectedMagnifierProvider._();

/// Provider to track which magnifier view is selected.
/// This allows the Flutter UI to control the Flame magnifier visibility.
final class SelectedMagnifierProvider
    extends $NotifierProvider<SelectedMagnifier, MagnifierViewType?> {
  /// Provider to track which magnifier view is selected.
  /// This allows the Flutter UI to control the Flame magnifier visibility.
  SelectedMagnifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedMagnifierProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedMagnifierHash();

  @$internal
  @override
  SelectedMagnifier create() => SelectedMagnifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MagnifierViewType? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MagnifierViewType?>(value),
    );
  }
}

String _$selectedMagnifierHash() => r'1363e114704ec715a40eb29aaa2faed06601eb60';

/// Provider to track which magnifier view is selected.
/// This allows the Flutter UI to control the Flame magnifier visibility.

abstract class _$SelectedMagnifier extends $Notifier<MagnifierViewType?> {
  MagnifierViewType? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MagnifierViewType?, MagnifierViewType?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MagnifierViewType?, MagnifierViewType?>,
              MagnifierViewType?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
