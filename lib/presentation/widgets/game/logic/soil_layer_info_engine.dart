import 'package:flutter/material.dart';
import '../../../../domain/models/soil_layer.dart';
import '../../../providers/ui_state_provider.dart';
import '../soil_scope_game.dart';

/// Logic for generating soil layer information cards and localized descriptions.
class SoilLayerInfoEngine {
  static void showLayerInfo(
    SoilScopeGame game,
    SoilLayer layer,
    String layerId, {
    bool pinned = false,
  }) {
    final l = game.l10n;
    String horizonName;
    String horizonDescription;
    IconData horizonIcon;
    Color horizonColor;

    if (layerId.toUpperCase().startsWith('A') ||
        layerId.toLowerCase().contains('a-hori')) {
      horizonName = 'A-HORISONTTI (${l.topsoilHorizon})';
      horizonDescription = l.topsoilDesc;
      horizonIcon = Icons.eco;
      horizonColor = Colors.brown.shade700;
    } else if (layerId.toUpperCase().startsWith('B') ||
        layerId.toLowerCase().contains('b-hori')) {
      horizonName = 'B-HORISONTTI (${l.subsoilHorizon})';
      horizonDescription = l.subsoilDesc;
      horizonIcon = Icons.layers;
      horizonColor = Colors.brown.shade400;
    } else if (layerId.toUpperCase().startsWith('C') ||
        layerId.toLowerCase().contains('c-hori')) {
      horizonName = 'C-HORISONTTI (${l.parentMaterialHorizon})';
      horizonDescription = l.parentMaterialDesc;
      horizonIcon = Icons.foundation;
      horizonColor = Colors.grey.shade600;
    } else {
      horizonName = '${l.soilProfile}: ${layerId.toUpperCase()}';
      horizonDescription = l.genericLayerDesc;
      horizonIcon = Icons.terrain;
      horizonColor = Colors.brown;
    }

    final double airFilledPorosity = (layer.porosity - layer.waterContent)
        .clamp(0.0, 1.0);
    String aerationStatus;
    Color aerationColor;
    if (airFilledPorosity > 0.15) {
      aerationStatus = l.goodAeration;
      aerationColor = Colors.green;
    } else if (airFilledPorosity > 0.05) {
      aerationStatus = l.sufficientAeration;
      aerationColor = Colors.orange;
    } else {
      aerationStatus = l.poorAeration;
      aerationColor = Colors.red;
    }

    String redoxStatus;
    Color redoxColor;
    if (layer.redoxPotential > 400) {
      redoxStatus = l.aerobicState;
      redoxColor = Colors.green;
    } else if (layer.redoxPotential > 100) {
      redoxStatus = l.variableRedox;
      redoxColor = Colors.orange;
    } else {
      redoxStatus = l.anaerobicState;
      redoxColor = Colors.red;
    }

    game.ref
        .read(uIStateProvider.notifier)
        .setHoverInfo(
          HoverInfo(
            title: horizonName,
            description: horizonDescription,
            stats: {
              l.soilTypeLabel: _getTextureClass(game, layer),
              l.waterContent:
                  '${(layer.waterContent * 100).toStringAsFixed(1)}%',
              l.porosity: '${(layer.porosity * 100).toStringAsFixed(0)}%',
              l.aerationLabel: aerationStatus,
              l.oxidationReduction:
                  '${layer.redoxPotential.toStringAsFixed(0)} mV',
              l.redoxStateLabel: redoxStatus,
              l.organicCarbonLabel:
                  '${layer.organicCarbon.toStringAsFixed(1)} g/kg',
              l.ph: layer.ph.toStringAsFixed(1),
              l.ec: '${layer.calculatedEC.toStringAsFixed(2)} dS/m',
              l.microbialMassLabel:
                  '${layer.microbialBiomass.toStringAsFixed(0)} mg C/kg',
              l.temperature:
                  '${(layer.temperature - 273.15).toStringAsFixed(1)} °C',
            },
            isPinned: pinned,
            legends: [
              LegendItem(
                icon: horizonIcon,
                color: horizonColor,
                label: horizonName.split(' ')[0],
              ),
              LegendItem(
                icon: Icons.air,
                color: aerationColor,
                label: aerationStatus,
              ),
              LegendItem(
                icon: Icons.science,
                color: redoxColor,
                label: redoxStatus,
              ),
            ],
          ),
        );
  }

  static String _getTextureClass(SoilScopeGame game, SoilLayer layer) {
    final sand = layer.sandFraction;
    final clay = layer.clayFraction;
    final silt = 1.0 - sand - clay;
    final l = game.l10n;

    if (clay >= 0.40) return '${l.clay} (Clay)';
    if (clay >= 0.27 && sand < 0.20) return '${l.siltyClay} (Silty Clay)';
    if (clay >= 0.27) return '${l.sandyClay} (Sandy Clay)';
    if (clay >= 0.20 && silt >= 0.28 && sand <= 0.45) {
      return '${l.clayLoam} (Clay Loam)';
    }
    if (sand >= 0.52 && clay >= 0.20) {
      return '${l.sandyClayLoam} (Sandy Clay Loam)';
    }
    if (silt >= 0.50 && clay >= 0.12) {
      return '${l.siltyClayLoam} (Silty Clay Loam)';
    }
    if (silt >= 0.80) return '${l.silt} (Silt)';
    if (silt >= 0.50) return '${l.siltLoam} (Silt Loam)';
    if (sand >= 0.85) return '${l.sand} (Sand)';
    if (sand >= 0.70) return '${l.loamySand} (Loamy Sand)';
    return '${l.loam} (Loam)';
  }
}
