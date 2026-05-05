import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../providers/simulation_provider.dart';
import '../providers/simulation_session_provider.dart';
import 'controls/slider_control.dart';
import 'diagrams/soil_texture_triangle.dart';
import 'controls/atmosphere_informatics_view.dart';

class ControlPanelSection extends ConsumerWidget {
  const ControlPanelSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(simulationProvider);
    final session = ref.watch(simulationSessionProvider);
    final selectedId = session.selectedLayerId;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (selectedId == "atmosphere") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cloud_outlined, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.atmosphere,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const AtmosphereInformaticsView(),
          const SizedBox(height: 16),
        ],
      );
    }

    if (selectedId != null) {
      final layer = state.profile.layers.firstWhere(
        (l) => l.id == selectedId,
        orElse: () => state.profile.layers.first,
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.layers, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.layerControls,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 1. PHYSICAL PROPERTIES
          ExpansionTile(
            title: Text(
              l10n.physical.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueAccent),
            ),
            initiallyExpanded: false,
            tilePadding: EdgeInsets.zero,
            children: [
              SliderControl(
                label: l10n.bulkDensity,
                value: layer.bulkDensity,
                min: 800.0,
                max: 2000.0,
                unit: " kg/m³",
                onChanged: (v) => ref.read(simulationProvider.notifier).updateLayer(layer.id, (l) => l.copyWith(bulkDensity: v)),
              ),
              SliderControl(
                label: l10n.stability,
                value: layer.aggregateStability,
                min: 0.0,
                max: 1.0,
                unit: " (0-1)",
                onChanged: (v) => ref.read(simulationProvider.notifier).updateLayer(layer.id, (l) => l.copyWith(aggregateStability: v)),
              ),
              const Divider(),
              Text(
                l10n.soilTexture.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 180,
                child: SoilTextureTriangle(
                  sand: layer.sandFraction,
                  silt: layer.siltFraction,
                  clay: layer.clayFraction,
                  onProbe: (sa, si, cl) {
                    ref.read(simulationProvider.notifier).updateLayer(layer.id, (l) => l.copyWith(
                      sandFraction: sa,
                      siltFraction: si,
                      clayFraction: cl,
                    ));
                  },
                ),
              ),
              _buildTextureSliders(context, ref, layer, l10n),
            ],
          ),

          // 2. CHEMICAL PROPERTIES
          ExpansionTile(
            title: Text(
              l10n.chemical.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.purpleAccent),
            ),
            initiallyExpanded: true,
            tilePadding: EdgeInsets.zero,
            children: [
              SliderControl(
                label: l10n.ph,
                value: layer.ph,
                min: 3.5,
                max: 9.5,
                unit: "",
                onChanged: (v) => ref.read(simulationProvider.notifier).updateLayer(layer.id, (l) => l.copyWith(ph: v)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.ec.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey.shade400),
                    ),
                    Text(
                      "${layer.calculatedEC.toStringAsFixed(2)} dS/m",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        color: Colors.purpleAccent.shade100,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SliderControl(
                label: l10n.nitrateN,
                value: layer.nitrateContent,
                min: 0.0,
                max: 100.0,
                unit: " mg/kg",
                onChanged: (v) => ref.read(simulationProvider.notifier).updateLayer(layer.id, (l) => l.copyWith(nitrateContent: v)),
              ),
              SliderControl(
                label: l10n.ammonium,
                value: layer.ammoniumContent,
                min: 0.0,
                max: 100.0,
                unit: " mg/kg",
                onChanged: (v) => ref.read(simulationProvider.notifier).updateLayer(layer.id, (l) => l.copyWith(ammoniumContent: v)),
              ),
              SliderControl(
                label: l10n.phosphateP,
                value: layer.phosphateContent,
                min: 0.0,
                max: 100.0,
                unit: " mg/kg",
                onChanged: (v) => ref.read(simulationProvider.notifier).updateLayer(layer.id, (l) => l.copyWith(phosphateContent: v)),
              ),
              SliderControl(
                label: l10n.potassiumK,
                value: layer.potassiumContent,
                min: 0.0,
                max: 100.0,
                unit: " mg/kg",
                onChanged: (v) => ref.read(simulationProvider.notifier).updateLayer(layer.id, (l) => l.copyWith(potassiumContent: v)),
              ),
              SliderControl(
                label: l10n.calciumCa,
                value: layer.solutionCalcium,
                min: 0.0,
                max: 1000.0,
                unit: " mg/kg",
                onChanged: (v) => ref.read(simulationProvider.notifier).updateLayer(layer.id, (l) => l.copyWith(solutionCalcium: v)),
              ),
              SliderControl(
                label: l10n.magnesiumMg,
                value: layer.solutionMagnesium,
                min: 0.0,
                max: 500.0,
                unit: " mg/kg",
                onChanged: (v) => ref.read(simulationProvider.notifier).updateLayer(layer.id, (l) => l.copyWith(solutionMagnesium: v)),
              ),
              SliderControl(
                label: "CEC",
                value: layer.cec,
                min: 1.0,
                max: 50.0,
                unit: " cmol/kg",
                onChanged: (v) => ref.read(simulationProvider.notifier).updateLayer(layer.id, (l) => l.copyWith(cec: v)),
              ),
            ],
          ),

          // 3. BIOLOGICAL & GAS PROPERTIES
          ExpansionTile(
            title: Text(
              l10n.biological.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.greenAccent),
            ),
            initiallyExpanded: false,
            tilePadding: EdgeInsets.zero,
            children: [
              SliderControl(
                label: l10n.labileC,
                value: layer.labileCarbon,
                min: 0.0,
                max: 200.0,
                unit: " kg/m³",
                onChanged: (v) => ref.read(simulationProvider.notifier).updateLayer(layer.id, (l) => l.copyWith(labileCarbon: v)),
              ),
              SliderControl(
                label: l10n.stableC,
                value: layer.stableCarbon,
                min: 0.0,
                max: 500.0,
                unit: " kg/m³",
                onChanged: (v) => ref.read(simulationProvider.notifier).updateLayer(layer.id, (l) => l.copyWith(stableCarbon: v)),
              ),
              SliderControl(
                label: l10n.microbialBiomass,
                value: layer.microbialBiomass,
                min: 0.0,
                max: 1000.0,
                unit: " mg/kg",
                onChanged: (v) => ref.read(simulationProvider.notifier).updateLayer(layer.id, (l) => l.copyWith(microbialBiomass: v)),
              ),
              SliderControl(
                label: l10n.oxygen,
                value: layer.oxygenContent,
                min: 0.0,
                max: 10.0,
                unit: " mol/m³",
                onChanged: (v) => ref.read(simulationProvider.notifier).updateLayer(layer.id, (l) => l.copyWith(oxygenContent: v)),
              ),
            ],
          ),
        ],
      );
    } else {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.layers_outlined,
                size: 48,
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.selectLayerToView,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildTextureSliders(BuildContext context, WidgetRef ref, dynamic layer, AppLocalizations l10n) {
    void handleTextureChange(String primary, double newValue) {
      double sand = layer.sandFraction;
      double silt = layer.siltFraction;
      double clay = layer.clayFraction;

      double oldPrimary = 0.0;
      if (primary == 'sand') oldPrimary = sand;
      if (primary == 'silt') oldPrimary = silt;
      if (primary == 'clay') oldPrimary = clay;

      double remainOld = 1.0 - oldPrimary;
      double remainNew = 1.0 - newValue;

      if (remainOld <= 0.0001) {
        // If it was 100%, split remaining equally
        if (primary == 'sand') { silt = remainNew / 2; clay = remainNew / 2; }
        if (primary == 'silt') { sand = remainNew / 2; clay = remainNew / 2; }
        if (primary == 'clay') { sand = remainNew / 2; silt = remainNew / 2; }
      } else {
        double scale = remainNew / remainOld;
        if (primary == 'sand') { silt *= scale; clay *= scale; }
        if (primary == 'silt') { sand *= scale; clay *= scale; }
        if (primary == 'clay') { sand *= scale; silt *= scale; }
      }

      if (primary == 'sand') sand = newValue;
      if (primary == 'silt') silt = newValue;
      if (primary == 'clay') clay = newValue;

      // Ensure no math errors
      double total = sand + silt + clay;
      if (total > 0) {
        sand /= total;
        silt /= total;
        clay /= total;
      }

      ref.read(simulationProvider.notifier).updateLayer(layer.id, (l) => l.copyWith(
        sandFraction: sand,
        siltFraction: silt,
        clayFraction: clay,
      ));
    }

    return Column(
      children: [
        SliderControl(
          label: l10n.sand,
          value: layer.sandFraction * 100,
          min: 0.0,
          max: 100.0,
          unit: "%",
          onChanged: (v) => handleTextureChange('sand', v / 100.0),
        ),
        SliderControl(
          label: l10n.silt,
          value: layer.siltFraction * 100,
          min: 0.0,
          max: 100.0,
          unit: "%",
          onChanged: (v) => handleTextureChange('silt', v / 100.0),
        ),
        SliderControl(
          label: l10n.clay,
          value: layer.clayFraction * 100,
          min: 0.0,
          max: 100.0,
          unit: "%",
          onChanged: (v) => handleTextureChange('clay', v / 100.0),
        ),
      ],
    );
  }
}
