import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../soil_scope_game.dart';
import '../../../providers/ui_state_provider.dart';

/// Shared logic for interactive biological and chemical entities within the simulation.
/// Centralizes hover and tap behaviors for entities like Ions, Microbes, and Clay nodes.
mixin BiologicalEntityMixin on PositionComponent, HasGameReference<SoilScopeGame>, TapCallbacks, HoverCallbacks {
  
  /// The unique title identifying this entity in the central HUD.
  String get entityTitle;

  /// Whether the entity is currently selected/pinned to the HUD.
  bool get isPinned {
    final central = game.ref.read(uIStateProvider);
    if (central == null || !central.isPinned) return false;
    return central.title.toUpperCase().contains(entityTitle.toUpperCase()) ||
           entityTitle.toUpperCase().contains(central.title.toUpperCase());
  }

  @override
  bool isHovered = false;

  /// Standard hover entry logic.
  void handleHoverEnter(void Function() showInfo) {
    isHovered = true;
    final currentInfo = game.ref.read(uIStateProvider);
    if (currentInfo == null || !currentInfo.isPinned) {
      showInfo();
    }
  }

  /// Standard hover exit logic.
  void handleHoverExit() {
    isHovered = false;
    if (!isPinned) {
      game.ref.read(uIStateProvider.notifier).setHoverInfo(null);
    }
  }

  /// Standard tap logic to pin/unpin info.
  void handleTapUp(void Function({bool pinned}) showInfo) {
    if (isPinned) {
      game.ref.read(uIStateProvider.notifier).setHoverInfo(null);
    } else {
      showInfo(pinned: true);
    }
  }
}
