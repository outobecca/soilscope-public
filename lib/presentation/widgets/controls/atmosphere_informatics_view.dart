import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/biophysics_utils.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/simulation_provider.dart';
import '../diagrams/mollier_diagram.dart';
import '../diagrams/par_chart.dart';

import 'slider_control.dart';

/// Interactive panel for atmospheric monitoring and weather control.
///
/// Consolidates Mollier diagram interactions and PAR light intensity controls
/// with direct Two-Way Binding to [SimulationProvider].
///
/// Priority: High Reactivity (Task 5/6)
class AtmosphereInformaticsView extends ConsumerWidget {
  const AtmosphereInformaticsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // REAKTIVISUUS (Task 5/6): Read the state directly from the provider to ensure
    // the UI always reflects the simulation's "Single Source of Truth".
    final state = ref.watch(displayedSimulationStateProvider);
    
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    final vpdValue = BiophysicsUtils.getVPD(
      state.airTemperature,
      state.relativeHumidity,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. MOLLIER DIAGRAM (Temp & Humidity)
        SizedBox(
          height: 280,
          child: MollierDiagram(
            temperature: state.airTemperature,
            relativeHumidity: state.relativeHumidity,
            onProbe: (t, r) {
               // TWO-WAY BINDING: Update simulation state immediately on probe interaction
               ref.read(simulationProvider.notifier).updateWeather(t, r);
            },
          ),
        ),
        
        const SizedBox(height: 12),
        
        // 2. PAR CHART (Light Intensity)
        SizedBox(
          height: 120,
          child: PARChart(
            intensity: state.par,
            onChanged: (val) {
               // TWO-WAY BINDING: Update light intensity (PAR) in the simulation
               ref.read(simulationProvider.notifier).updatePAR(val);
            },
          ),
        ),
        
        const SizedBox(height: 16),

        // 3. ADDITIONAL CONTROLS (Precipitation & CO2)
        SliderControl(
          label: "SADEMÄÄRÄ",
          value: state.precipitation,
          min: 0.0,
          max: 50.0,
          unit: " mm/h",
          onChanged: (v) => ref.read(simulationProvider.notifier).updateAtmosphere(precipitation: v),
        ),
        SliderControl(
          label: "CO₂ KESKITYS",
          value: state.atmCO2 * 1000,
          min: 0.1,
          max: 2.0,
          unit: " mmol/m³",
          onChanged: (v) => ref.read(simulationProvider.notifier).updateAtmosphere(co2: v / 1000),
        ),
        
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Divider(),
        ),
        
        // 4. READOUTS (Mini Properties)
        _buildMiniProperty(
          l10n.airTemperature,
          '${(state.airTemperature - 273.15).toStringAsFixed(1)} °C',
          theme,
        ),
        _buildMiniProperty(
          l10n.relativeHumidity,
          '${(state.relativeHumidity * 100).toStringAsFixed(0)}%',
          theme,
        ),
        _buildMiniProperty(
          l10n.vaporPressureDeficit,
          '${vpdValue.toStringAsFixed(2)} kPa',
          theme,
        ),
        _buildMiniProperty(
          "PAR INTENSITY",
          '${state.par.toStringAsFixed(0)} µmol/m²s',
          theme,
        ),
        _buildMiniProperty(
          "PRECIPITATION",
          '${state.precipitation.toStringAsFixed(2)} mm/h',
          theme,
        ),
      ],
    );
  }

  Widget _buildMiniProperty(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
