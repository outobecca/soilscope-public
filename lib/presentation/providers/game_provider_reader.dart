import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/misc.dart' show ProviderListenable;

/// Snapshot-only provider access for long-lived Flame objects.
///
/// A [WidgetRef] is bound to a widget lifecycle and can watch, listen,
/// invalidate and subscribe. The game outlives the widgets that build it and
/// needs none of those: it reads the current value when a pointer or keyboard
/// event arrives. This adapter keeps that capability boundary explicit so a
/// component cannot accidentally start a subscription that leaks after the
/// view is gone.
class GameProviderReader {
  GameProviderReader._(this._read);

  /// Creates a reader from a widget reference at the widget/game boundary.
  factory GameProviderReader.fromRef(WidgetRef ref) =>
      GameProviderReader._(ref.read);

  final T Function<T>(ProviderListenable<T> provider) _read;

  /// Reads the current value without subscribing.
  T read<T>(ProviderListenable<T> provider) => _read(provider);
}
