import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import '../../domain/models/scenario.dart';

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
    );
  }
}

@riverpod
class UIState extends _$UIState {
  @override
  HoverInfo? build() => null;

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
    state = info;
  }

  /// Pin the current info (make it persist)
  void pinCurrentInfo() {
    if (state != null && !state!.isPinned) {
      state = state!.copyWith(isPinned: true);
    }
  }

  /// Unpin and clear the current info
  void clearPinnedInfo() {
    if (state != null && state!.isPinned) {
      state = null;
    }
  }

  /// Convenience method for showing pinned info from map
  void showInfo(Map<String, dynamic> infoMap) {
    final legends = (infoMap['legends'] as List<dynamic>?)
        ?.cast<LegendItem>()
        .toList();
    final stats = (infoMap['stats'] as Map<String, dynamic>?)?.map(
      (k, v) => MapEntry(k, v.toString()),
    );

    state = HoverInfo(
      title: infoMap['title'] as String? ?? 'Info',
      description: infoMap['description'] as String? ?? '',
      stats: stats,
      legends: legends,
      formula: infoMap['formula'] as String?,
      isPinned: true,
    );
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
    state = (state == cycle) ? ObservationCycle.none : cycle;
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
