import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Ref;
import 'package:flutter/foundation.dart';
import '../../domain/models/scenario.dart';
import '../../core/periodic_table.dart';
import '../../l10n/app_localizations.dart';

part 'ui_state_provider.g.dart';

class LegendItem {
  final IconData icon;
  final Color color;
  final String label;

  LegendItem({required this.icon, required this.color, required this.label});
}

enum TooltipType {
  basic,      // Simple label/value
  inspector,  // Full detailed panel
}

class HoverInfo {
  final String title;
  final String description;
  final Map<String, String>? stats;
  final List<LegendItem>? legends;
  final String? formula; // Mathematical representation or deep scientific context
  final bool isPinned; // Whether this info should persist (was tapped vs hovered)
  
  // Unified Tooltip Support
  final Offset? screenPosition;
  final Color? accentColor;
  final TooltipType type;
  final String? elementSymbol; // For CPK coloring

  /// Stable identity of the visual element that owns this info card.
  /// Used to tell a refresh of the same selection from a new selection.
  final String? sourceId;

  /// Soil layer this selection belongs to, when it is layer-specific. The
  /// Logic Lab uses it to evaluate the hotspot's process with that layer's
  /// live values instead of silently falling back to the topsoil.
  final String? layerId;

  /// Optional Logic Lab process hint for sources whose id is ambiguous.
  final String? logicLabModel;

  /// Called when this pinned card is dismissed or replaced by another one.
  /// Interactive canvas components use it to release their local visual
  /// selection state instead of keeping a stale highlight/pause forever.
  final VoidCallback? onDismiss;

  HoverInfo({
    required this.title,
    required this.description,
    this.stats,
    this.legends,
    this.formula,
    this.isPinned = false,
    this.screenPosition,
    this.accentColor,
    this.type = TooltipType.basic,
    this.elementSymbol,
    this.sourceId,
    this.layerId,
    this.logicLabModel,
    this.onDismiss,
  });

  HoverInfo copyWith({
    String? title,
    String? description,
    Map<String, String>? stats,
    List<LegendItem>? legends,
    String? formula,
    bool? isPinned,
    Offset? screenPosition,
    Color? accentColor,
    TooltipType? type,
    String? elementSymbol,
    String? sourceId,
    String? layerId,
    String? logicLabModel,
    VoidCallback? onDismiss,
  }) {
    return HoverInfo(
      title: title ?? this.title,
      description: description ?? this.description,
      stats: stats ?? this.stats,
      legends: legends ?? this.legends,
      formula: formula ?? this.formula,
      isPinned: isPinned ?? this.isPinned,
      screenPosition: screenPosition ?? this.screenPosition,
      accentColor: accentColor ?? this.accentColor,
      type: type ?? this.type,
      elementSymbol: elementSymbol ?? this.elementSymbol,
      sourceId: sourceId ?? this.sourceId,
      layerId: layerId ?? this.layerId,
      logicLabModel: logicLabModel ?? this.logicLabModel,
      onDismiss: onDismiss ?? this.onDismiss,
    );
  }
}

@Riverpod(keepAlive: true)
class UIState extends _$UIState {
  @override
  HoverInfo? build() => null;

  HoverInfo? _pendingHoverInfo;
  bool _isUpdateScheduled = false;

  void setHoverInfo(HoverInfo? info) {
    // Don't replace pinned info with a non-pinned hover, but allow setting to null
    if (state != null && state!.isPinned) {
      if (info != null && !info.isPinned) {
        return; // Keep the pinned info over unpinned hovers
      }
    }

    if (state == null && info == null) {
      return;
    }
    if (state?.title == info?.title &&
        state?.description == info?.description &&
        state?.isPinned == info?.isPinned &&
        state?.sourceId == info?.sourceId &&
        mapEquals(state?.stats, info?.stats)) {
      return;
    }

    // A pinned card is a visual selection, not just a Flutter overlay. Tell
    // the old owner when the card is replaced or cleared so it can drop its
    // highlight and local pause/damping state. Refreshes of the same source
    // (for example a moving particle's live stats) are not dismissals.
    final previous = state;
    if (previous != null && previous.isPinned) {
      final sameSource = info != null &&
          info.isPinned &&
          ((previous.sourceId != null &&
                  previous.sourceId == info.sourceId) ||
              (previous.sourceId == null &&
                  info.sourceId == null &&
                  previous.title == info.title));
      if (!sameSource) {
        previous.onDismiss?.call();
      }
    }

    _pendingHoverInfo = info;
    if (!_isUpdateScheduled) {
      _isUpdateScheduled = true;
      Future.microtask(() {
        state = _pendingHoverInfo;
        _isUpdateScheduled = false;
      });
    }
  }

  /// Update just the screen position (for mouse following)
  void updateScreenPosition(Offset pos) {
    if (state != null && !state!.isPinned) {
      final currentPos = state!.screenPosition;
      if (currentPos == null || (pos - currentPos).distance > 80.0) {
        state = state!.copyWith(screenPosition: pos);
      }
    }
  }

  /// Pin the current info (make it persist)
  void pinCurrentInfo() {
    if (state != null && !state!.isPinned) {
      Future.microtask(() {
        state = state!.copyWith(isPinned: true);
      });
    }
  }

  /// Unpin and clear the current info
  void clearPinnedInfo() {
    if (state != null && state!.isPinned) {
      state!.onDismiss?.call();
      Future.microtask(() {
        state = null;
      });
    }
  }

  /// Clear any active hover or pinned info unconditionally
  void clearHoverInfo() {
    final previous = state;
    if (previous != null && previous.isPinned) {
      previous.onDismiss?.call();
    }
    _pendingHoverInfo = null;
    Future.microtask(() {
      state = null;
    });
  }

  /// Drop the inspection card when the simulation itself is replaced.
  /// Owners are deliberately not notified here: their canvas components are
  /// torn down with the old scenario, so invoking stale refs would be unsafe.
  void resetInspection() {
    _pendingHoverInfo = null;
    state = null;
  }

  /// Clear only transient hover content. Canvas components call this on
  /// pointer exit; a hover-exit must never dismiss a pinned card owned by a
  /// different component.
  void clearUnpinnedHover() {
    // A hover may still be waiting in the microtask queue. Check that value
    // too, otherwise a fast pointer exit can let the stale hover appear after
    // the pointer has already left the element.
    final current = _pendingHoverInfo ?? state;
    if (current == null || current.isPinned) return;
    _pendingHoverInfo = null;
    if (!_isUpdateScheduled) {
      state = null;
    }
  }

  /// Convenience method for showing pinned info from map
  void showInfo(
    Map<String, dynamic> infoMap, {
    String? sourceId,
    VoidCallback? onDismiss,
  }) {
    final legends = (infoMap['legends'] as List<dynamic>?)
        ?.cast<LegendItem>()
        .toList();
    final stats = (infoMap['stats'] as Map<String, dynamic>?)?.map(
      (k, v) => MapEntry(k, v.toString()),
    );

    setHoverInfo(
      HoverInfo(
        title: infoMap['title'] as String? ?? 'Info',
        description: infoMap['description'] as String? ?? '',
        stats: stats,
        legends: legends,
        formula: infoMap['formula'] as String?,
        isPinned: true,
        accentColor: infoMap['accentColor'] as Color?,
        elementSymbol: infoMap['elementSymbol'] as String?,
        screenPosition: infoMap['screenPosition'] as Offset?,
        sourceId: sourceId ?? infoMap['sourceId'] as String?,
        onDismiss: onDismiss ?? infoMap['onDismiss'] as VoidCallback?,
      ),
    );
  }
}

/// True while an interactive element is pinned for inspection. The game loop
/// uses this to freeze visual animation without stopping the simulation.
final inspectionPausedProvider = Provider<bool>((ref) {
  final info = ref.watch(uIStateProvider);
  return info?.isPinned ?? false;
});

enum ObservationCycle {
  none,
  nitrogen,
  carbon,
  water,
  phosphorus,
}

@riverpod
class ActiveCycle extends _$ActiveCycle {
  @override
  ObservationCycle build() => ObservationCycle.none;

  void setCycle(ObservationCycle cycle) {
    Future.microtask(() {
      state = (state == cycle) ? ObservationCycle.none : cycle;
    });
  }
}

@riverpod
class ParticleFlowMode extends _$ParticleFlowMode {
  @override
  bool build() => true;

  void toggle() {
    state = !state;
  }
}

@Riverpod(keepAlive: true)
class ActiveTutorialStep extends _$ActiveTutorialStep {
  @override
  ScenarioTutorialStep? build() => null;

  void setTutorialStep(ScenarioTutorialStep? step) {
    state = step;
  }
}

enum VisualLayoutMode {
  organic,
  schematic,
}

@riverpod
class VisualLayoutModeState extends _$VisualLayoutModeState {
  @override
  VisualLayoutMode build() => VisualLayoutMode.organic;

  void setMode(VisualLayoutMode mode) => state = mode;
  void toggle() {
    state = (state == VisualLayoutMode.organic)
        ? VisualLayoutMode.schematic
        : VisualLayoutMode.organic;
  }
}

extension ElementInfoHoverExtension on ElementInfo {
  HoverInfo toHoverInfo(
    String langCode, {
    required AppLocalizations l10n,
    bool isPinned = true,
    Offset? screenPosition,
  }) {
    String formulaDisplay;
    if (typicalCharge > 0) {
      formulaDisplay = typicalCharge == 1 ? '$symbol⁺' : '$symbol⁺$typicalCharge';
    } else if (typicalCharge < 0) {
      formulaDisplay = typicalCharge == -1 ? '$symbol⁻' : '$symbol⁻${typicalCharge.abs()}';
    } else {
      formulaDisplay = symbol;
    }

    return HoverInfo(
      title: localizedName(langCode),
      description: localizedSoilRole(langCode),
      elementSymbol: symbol,
      accentColor: cpkColor,
      isPinned: isPinned,
      screenPosition: screenPosition,
      type: TooltipType.inspector,
      formula: formulaDisplay,
      stats: {
        l10n.roleLabel: localizedAgronomicRole(langCode),
        l10n.categoryLabel: localizedCategory(langCode),
        l10n.atomicNumber: '$atomicNumber',
        l10n.atomicMass: '$atomicMass u',
        l10n.groupPeriod: '$group / $period',
      },
    );
  }
}

class SidebarState {
  final bool isLeftOpen;
  final bool isRightOpen;

  const SidebarState({
    this.isLeftOpen = false,
    this.isRightOpen = false,
  });

  SidebarState copyWith({
    bool? isLeftOpen,
    bool? isRightOpen,
  }) {
    return SidebarState(
      isLeftOpen: isLeftOpen ?? this.isLeftOpen,
      isRightOpen: isRightOpen ?? this.isRightOpen,
    );
  }
}

class SidebarStateNotifier extends Notifier<SidebarState> {
  @override
  SidebarState build() => const SidebarState();

  void toggleLeft({bool isOverlay = false}) {
    final next = !state.isLeftOpen;
    state = state.copyWith(
      isLeftOpen: next,
      isRightOpen: (next && isOverlay) ? false : state.isRightOpen,
    );
  }

  void toggleRight({bool isOverlay = false}) {
    final next = !state.isRightOpen;
    state = state.copyWith(
      isRightOpen: next,
      isLeftOpen: (next && isOverlay) ? false : state.isLeftOpen,
    );
  }

  void setLeft(bool open) => state = state.copyWith(isLeftOpen: open);
  void setRight(bool open) => state = state.copyWith(isRightOpen: open);
  void closeAll() => state = const SidebarState(isLeftOpen: false, isRightOpen: false);
}

final sidebarStateProvider =
    NotifierProvider<SidebarStateNotifier, SidebarState>(
        SidebarStateNotifier.new);

