// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scenarios_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(scenarios)
final scenariosProvider = ScenariosProvider._();

final class ScenariosProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Scenario>>,
          List<Scenario>,
          FutureOr<List<Scenario>>
        >
    with $FutureModifier<List<Scenario>>, $FutureProvider<List<Scenario>> {
  ScenariosProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scenariosProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scenariosHash();

  @$internal
  @override
  $FutureProviderElement<List<Scenario>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Scenario>> create(Ref ref) {
    return scenarios(ref);
  }
}

String _$scenariosHash() => r'cbe7a9831af497ffeb728e545acb74fa97c97275';
