import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/biophysics_utils.dart';
import '../../../../domain/models/biophysical_state.dart';
import '../../../l10n/app_localizations.dart';
import '../controls/atmosphere_informatics_view.dart';

class ScienceAtmosphereTab extends ConsumerWidget {
  final BiophysicalState state;
  const ScienceAtmosphereTab({super.key, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final currentTemp = state.airTemperature;
    final currentRH = state.relativeHumidity;
    final vpd = BiophysicsUtils.getVPD(currentTemp, currentRH);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.3,
            ),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: AtmosphereInformaticsView(),
            ),
          ),
          const SizedBox(height: 24),
          _buildAtmosphereDetails(
            currentTemp,
            currentRH,
            vpd,
            theme,
            l10n,
          ),
        ],
      ),
    );
  }

  Widget _buildAtmosphereDetails(
    double t,
    double rh,
    double vpd,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.meteorology.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(l10n.airAndWaterVapor, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 24),
        _buildStatRow(
          l10n.airTemperature,
          '${(t - 273.15).toStringAsFixed(1)} °C',
          theme,
        ),
        _buildStatRow(
          l10n.relativeHumidity,
          '${(rh * 100).toStringAsFixed(0)}%',
          theme,
        ),
        _buildStatRow(
          l10n.vaporPressureDeficit,
          '${vpd.toStringAsFixed(2)} kPa',
          theme,
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label, 
              style: theme.textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
