// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_log_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EventLog)
final eventLogProvider = EventLogProvider._();

final class EventLogProvider
    extends $NotifierProvider<EventLog, List<EventLogEntry>> {
  EventLogProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventLogProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventLogHash();

  @$internal
  @override
  EventLog create() => EventLog();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<EventLogEntry> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<EventLogEntry>>(value),
    );
  }
}

String _$eventLogHash() => r'f2bc612fd9d2d02eb02399f1bb4c71bae659d4a0';

abstract class _$EventLog extends $Notifier<List<EventLogEntry>> {
  List<EventLogEntry> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<EventLogEntry>, List<EventLogEntry>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<EventLogEntry>, List<EventLogEntry>>,
              List<EventLogEntry>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
