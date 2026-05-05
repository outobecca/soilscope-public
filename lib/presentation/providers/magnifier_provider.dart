import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'magnifier_provider.g.dart';

/// Enum matching the MagnifierType in process_magnifier.dart
enum MagnifierViewType { leaf, stem, root, rhizosphere, microbe, soilStructure }

/// Provider to track which magnifier view is selected.
/// This allows the Flutter UI to control the Flame magnifier visibility.
@riverpod
class SelectedMagnifier extends _$SelectedMagnifier {
  @override
  MagnifierViewType? build() => null;

  void select(MagnifierViewType type) {
    if (state == type) {
      state = null; // Toggle off if same type
    } else {
      state = type;
    }
  }

  void clear() {
    state = null;
  }
}
