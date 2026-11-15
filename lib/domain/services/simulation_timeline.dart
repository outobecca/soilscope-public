import '../models/biophysical_state.dart';

/// The run's timeline: the snapshots the scrubber can show.
///
/// Entries are stored without their own `history` so a snapshot cannot nest
/// the whole timeline. The provider owns engine and UI state; this class owns
/// only the ordered snapshot list and its immutable view.
class SimulationTimeline {
  final List<BiophysicalState> _entries = [];
  List<BiophysicalState> _view = const [];

  /// Mutable entries for the tick processor, which appends snapshots.
  List<BiophysicalState> get entries => _entries;

  /// Immutable view handed to widgets.
  List<BiophysicalState> get view => _view;

  int get length => _entries.length;

  bool get isEmpty => _entries.isEmpty;

  bool get isNotEmpty => _entries.isNotEmpty;

  BiophysicalState get first => _entries.first;

  BiophysicalState get last => _entries.last;

  /// Returns [state] with its timeline stripped, ready to be an entry.
  static BiophysicalState strip(BiophysicalState state) =>
      state.copyWith(history: const []);

  void clearAndAdd(BiophysicalState entry) {
    _entries
      ..clear()
      ..add(strip(entry));
    refresh();
  }

  void clearAndAddAll(Iterable<BiophysicalState> entries) {
    _entries
      ..clear()
      ..addAll(entries.map(strip));
    refresh();
  }

  /// Rebuilds the immutable view after the engine appended a snapshot.
  void refresh() {
    _view = List.unmodifiable(_entries);
  }
}
