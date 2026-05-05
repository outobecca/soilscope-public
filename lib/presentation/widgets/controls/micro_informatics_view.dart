import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../domain/models/soil_layer.dart';
import '../../../core/biophysics_utils.dart';

class MicroInformaticsView extends StatelessWidget {
  final SoilLayer layer;
  final bool compact;
  const MicroInformaticsView({
    super.key,
    required this.layer,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Re-calculating live factors (using same logic as solvers for UI transparency)
    final double fTemp = BiophysicsUtils.q10Factor(layer.temperature);
    final double airFilledPorosity = (layer.porosity - layer.waterContent).clamp(0.0, 1.0);
    final double fWater = airFilledPorosity > 0.05 ? 1.0 : (airFilledPorosity / 0.05);
    final double fO2 = (layer.oxygenContent / BiophysicsUtils.atmO2Saturation).clamp(0.0, 1.0);

    // Microbial activity index (0-100%)
    final double activity = fTemp * fWater * fO2 * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!compact) _buildSectionHeader(l10n.microbialEngines.toUpperCase(), theme),
        _buildActivityMeter(activity, l10n, theme),
        const SizedBox(height: 24),
        if (!compact) _buildSectionHeader(l10n.liveCalculations.toUpperCase(), theme),
        _buildStatRow(
          l10n.tempFactor,
          'x${fTemp.toStringAsFixed(2)}',
          l10n.metabolicMultiplier,
          theme,
        ),
        _buildStatRow(
          l10n.waterLimitation,
          '${(fWater * 100).toStringAsFixed(0)}%',
          l10n.hydraulicConnectivity,
          theme,
        ),
        _buildStatRow(
          l10n.o2Availability,
          '${(fO2 * 100).toStringAsFixed(0)}%',
          l10n.aerobicRespirationPotential,
          theme,
        ),

        const SizedBox(height: 24),
        if (!compact) _buildSectionHeader(l10n.bioChemicalRates.toUpperCase(), theme),
        _buildRateItem(
          l10n.soilRespiration,
          '${(layer.microbialBiomass * 1e-8 * fTemp * fWater * fO2 * 3600).toStringAsFixed(4)} mol/hr',
          l10n.co2ProductionRate,
          theme,
        ),
        _buildRateItem(
          l10n.nNitrification,
          '${(layer.ammoniumContent * 1e-6 * fTemp * fO2 * 360).toStringAsFixed(3)} mg/hr',
          l10n.transformationDesc,
          theme,
        ),
        _buildRateItem(
          l10n.denitrification,
          layer.oxygenContent < 2.5 ? l10n.active : l10n.inhibited,
          l10n.denitrificationDesc,
          theme,
        ),

        if (!compact) ...[
          const SizedBox(height: 24),
          Text(
            l10n.zoomNote,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(
        title,
        style: theme.textTheme.labelSmall?.copyWith(
          color: Colors.green.shade700,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildActivityMeter(
    double value,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.metabolicFlux,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              '${value.toStringAsFixed(1)}%',
              style: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (value / 100).clamp(0, 1),
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            color: Colors.green.shade600,
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(
    String label,
    String value,
    String desc,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                desc,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateItem(
    String label,
    String value,
    String desc,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  desc,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.green.shade700,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
