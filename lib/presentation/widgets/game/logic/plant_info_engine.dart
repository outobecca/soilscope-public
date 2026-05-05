import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../domain/models/plant.dart';
import '../../../providers/ui_state_provider.dart';
import '../soil_scope_game.dart';
import 'plant_style_engine.dart';

/// Logic for generating plant information cards and physiology stats.
class PlantInfoEngine {
  static void showPlantInfo(
    SoilScopeGame game,
    Plant plant, {
    bool pinned = false,
  }) {
    final l = game.l10n;

    String stressStatus;
    if (plant.turgorPressure > 0.8) {
      stressStatus = l.goodWaterStatus;
    } else if (plant.turgorPressure > 0.5) {
      stressStatus = l.mildStress;
    } else {
      stressStatus = l.severeStress;
    }

    final stressColor = PlantStyleEngine.getStressColor(plant.turgorPressure);

    game.ref
        .read(uIStateProvider.notifier)
        .setHoverInfo(
          HoverInfo(
            title: '${l.plantTitle.toUpperCase()} (${l.physiologyTitle})',
            description: l.plantDescription,
            stats: {
              l.heightLabel: '${(plant.height * 100).toStringAsFixed(1)} cm',
              l.laiLabel: '${plant.lai.toStringAsFixed(2)} m²/m²',
              l.turgorPressure:
                  '${(plant.turgorPressure * 100).toStringAsFixed(0)}%',
              l.waterStatus: stressStatus,
              l.rootNodesLabel: '${plant.rootSystem.length} kpl',
              l.rootDepthLabel:
                  '${(plant.rootSystem.isNotEmpty ? plant.rootSystem.map((r) => r.z).reduce(math.max) * 100 : 0).toStringAsFixed(0)} cm',
              l.photosynthesis: plant.turgorPressure > 0.5
                  ? l.active
                  : l.limited,
            },
            isPinned: pinned,
            legends: [
              LegendItem(
                icon: Icons.water_drop,
                color: Colors.cyan,
                label: '${l.xylemLabel} (${l.waterUp})',
              ),
              LegendItem(
                icon: Icons.bolt,
                color: Colors.pink,
                label: '${l.phloemLabel} (${l.sugarsDown})',
              ),
              LegendItem(
                icon: Icons.eco,
                color: stressColor,
                label: stressStatus,
              ),
            ],
          ),
        );
  }
}
