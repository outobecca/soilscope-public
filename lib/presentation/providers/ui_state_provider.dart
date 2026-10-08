import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import '../../domain/models/scenario.dart';
import '../../core/periodic_table.dart';

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
        mapEquals(state?.stats, info?.stats)) {
      return;
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
      state = state!.copyWith(screenPosition: pos);
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
      Future.microtask(() {
        state = null;
      });
    }
  }

  /// Clear any active hover or pinned info unconditionally
  void clearHoverInfo() {
    _pendingHoverInfo = null;
    Future.microtask(() {
      state = null;
    });
  }

  /// Convenience method for showing pinned info from map
  void showInfo(Map<String, dynamic> infoMap) {
    final legends = (infoMap['legends'] as List<dynamic>?)
        ?.cast<LegendItem>()
        .toList();
    final stats = (infoMap['stats'] as Map<String, dynamic>?)?.map(
      (k, v) => MapEntry(k, v.toString()),
    );

    Future.microtask(() {
      state = HoverInfo(
        title: infoMap['title'] as String? ?? 'Info',
        description: infoMap['description'] as String? ?? '',
        stats: stats,
        legends: legends,
        formula: infoMap['formula'] as String?,
        isPinned: true,
        accentColor: infoMap['accentColor'] as Color?,
        elementSymbol: infoMap['elementSymbol'] as String?,
        screenPosition: infoMap['screenPosition'] as Offset?,
      );
    });
  }
}

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
    bool isPinned = true,
    Offset? screenPosition,
  }) {
    final isFi = langCode.toLowerCase().startsWith('fi');
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
        isFi ? 'Rooli' : 'Agronomic Role': localizedAgronomicRole(langCode),
        isFi ? 'Luokka' : 'Category': localizedCategory(langCode),
        isFi ? 'Järjestysluku' : 'Atomic Number': '$atomicNumber',
        isFi ? 'Atomimassa' : 'Atomic Mass': '$atomicMass u',
        isFi ? 'Ryhmä / Jakso' : 'Group / Period': '$group / $period',
      },
    );
  }
}
