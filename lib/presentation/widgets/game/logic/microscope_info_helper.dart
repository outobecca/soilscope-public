import 'package:flutter/material.dart';
import '../../../../domain/models/biophysical_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../providers/ui_state_provider.dart';
import '../components/process_magnifier_component.dart';

/// Provides localized, pedagogically rich biophysical telemetry and educational insights
/// for each high-fidelity microscope (Nanovision) target.
class MicroscopeInfoHelper {
  static MagnifierType? parseType(String? typeName) {
    if (typeName == null || typeName.isEmpty) return null;
    return MagnifierType.values.where((t) => t.name == typeName).firstOrNull;
  }

  static String getMagnificationLevel(MagnifierType type) {
    return switch (type) {
      MagnifierType.leaf => '400x',
      MagnifierType.stem => '200x',
      MagnifierType.root => '400x',
      MagnifierType.rhizosphere => '600x',
      MagnifierType.microbe => '1200x',
      MagnifierType.soilStructure => '250x',
      MagnifierType.apicalMeristem => '800x',
    };
  }

  static IconData getIcon(MagnifierType type) {
    return switch (type) {
      MagnifierType.leaf => Icons.eco_rounded,
      MagnifierType.stem => Icons.straighten_rounded,
      MagnifierType.root => Icons.account_tree_rounded,
      MagnifierType.rhizosphere => Icons.grain_rounded,
      MagnifierType.microbe => Icons.bug_report_rounded,
      MagnifierType.soilStructure => Icons.layers_rounded,
      MagnifierType.apicalMeristem => Icons.spa_rounded,
    };
  }

  static String getLocalizedTitle(MagnifierType type, AppLocalizations l) {
    return switch (type) {
      MagnifierType.leaf => l.leaf,
      MagnifierType.stem => l.stem,
      MagnifierType.root => l.root,
      MagnifierType.rhizosphere => l.rhizosphere,
      MagnifierType.microbe => l.microbes,
      MagnifierType.soilStructure => l.soilStructure,
      MagnifierType.apicalMeristem => l.apicalMeristem,
    };
  }

  static HoverInfo createHoverInfo({
    required MagnifierType type,
    required AppLocalizations l,
    required BiophysicalState state,
    bool isPinned = true,
    Offset? screenPosition,
  }) {
    final topLayer = state.profile.layers.first;
    final plant = state.plants.isNotEmpty ? state.plants.first : state.plant;
    final magLevel = getMagnificationLevel(type);

    String title;
    String desc;
    String? formula;
    Map<String, String> stats;

    switch (type) {
      case MagnifierType.apicalMeristem:
        title = '${l.apicalMeristem} ($magLevel)';
        desc = l.meristemDesc;
        formula = 'd(Cell)/dt = μ · N · P';
        stats = {
          l.tissueLabel: l.meristematic,
          l.stateLabel: l.undifferentiated,
          l.rateLabel: l.highDivision,
        };
        break;

      case MagnifierType.leaf:
        title = '${l.plantCanopy.toUpperCase()} ($magLevel)';
        desc = l.plantCanopyDesc;
        formula = '6 CO₂ + 6 H₂O + hν → C₆H₁₂O₆ + 6 O₂';
        stats = {
          l.typeLabel: l.leaf,
          l.turgorLabel: '${(plant.turgorPressure * 100).toStringAsFixed(0)}%',
          l.heightLabel: '${(plant.height * 100).toStringAsFixed(1)} cm',
          l.laiLabel: plant.lai.toStringAsFixed(2),
          l.processLabel: l.transpiration,
        };
        break;

      case MagnifierType.stem:
        title = '${l.stemCrossSection.toUpperCase()} ($magLevel)';
        desc = l.stemDesc;
        final suction = (plant.waterUptake * 1000).toStringAsFixed(2);
        formula = 'J_v = L_p · (ΔΨ_p - σΔΨ_s)';
        stats = {
          l.typeLabel: l.vascularTissue,
          l.fluxLabel: '$suction µl/s',
          l.roleLabel: l.transport,
          l.turgorPressure: '${(plant.turgorPressure * 100).toStringAsFixed(0)} %',
        };
        break;

      case MagnifierType.root:
        title = '${l.rootTissue.toUpperCase()} ($magLevel)';
        desc = l.rootTissueDesc;
        formula = 'Ψ_root = Ψ_soil - r_axial · Flux';
        stats = {
          l.typeLabel: l.root,
          l.rootNodes: plant.rootSystem.length.toString(),
          l.processLabel: l.uptake,
          l.depthLabel: '${(topLayer.depth * 100).toStringAsFixed(0)} cm',
        };
        break;

      case MagnifierType.rhizosphere:
        title = '${l.rhizosphere.toUpperCase()} ($magLevel)';
        desc = l.rhizosphereDesc;
        formula = 'C_exudate → Microbe_biomass + Enzymes';
        stats = {
          l.locationLabel: l.rhizosphereLocation,
          l.microbialBiomassLabel: '${topLayer.microbialBiomass.toStringAsFixed(1)} kg/m³',
          l.bioActivityLabel: topLayer.redoxPotential > 400 ? l.active : l.inhibited,
          l.phLabel: topLayer.ph.toStringAsFixed(2),
        };
        break;

      case MagnifierType.microbe:
        title = '${l.microbialCell.toUpperCase()} ($magLevel)';
        desc = l.microbialCellDesc;
        formula = 'C₆H₁₂O₆ + 6 O₂ → 6 CO₂ + 6 H₂O + ATP';
        stats = {
          l.typeLabel: l.microbialCell,
          l.co2Label: '${topLayer.co2Content.toStringAsFixed(3)} mol/m³',
          l.processLabel: l.metabolismLabel,
          l.temperature: '${topLayer.temperature.toStringAsFixed(1)} K',
        };
        break;

      case MagnifierType.soilStructure:
        title = '${l.soilStructure.toUpperCase()} ($magLevel)';
        desc = l.soilStructureTexture;
        formula = 'Stability = f(EPS, Clay, Fungal_Hyphae)';
        stats = {
          l.typeLabel: l.hexMatrix,
          l.stabilityLabel(''): '${(topLayer.aggregateStability * 100).toStringAsFixed(0)}%',
          l.clayFractionLabel: '${(topLayer.clayFraction * 100).toStringAsFixed(0)}%',
          l.porosity: '${(topLayer.porosity * 100).toStringAsFixed(0)}%',
        };
        break;
    }

    return HoverInfo(
      title: title,
      description: desc,
      formula: formula,
      stats: stats,
      isPinned: isPinned,
      screenPosition: screenPosition,
      type: TooltipType.inspector,
      accentColor: const Color(0xFF06B6D4),
    );
  }
}
