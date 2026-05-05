import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class InformaticsView extends StatelessWidget {
  const InformaticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(l10n.semanticZoomLevels.toUpperCase(), theme),
        _buildZoomInfo(l10n.macroZoomTitle, l10n.macroZoomDesc, theme),
        _buildZoomInfo(l10n.mesoZoomTitle, l10n.mesoZoomDesc, theme),
        _buildZoomInfo(l10n.microZoomTitle, l10n.microZoomDesc, theme),
        _buildZoomInfo(l10n.nanoZoomTitle, l10n.nanoZoomDesc, theme),

        const SizedBox(height: 24),
        _buildSectionHeader(l10n.soilStructureTexture.toUpperCase(), theme),
        _buildLegendItem(
          Icons.grain,
          Colors.brown.shade400,
          l10n.aggregates,
          l10n.aggregatesDesc,
          theme,
        ),
        _buildLegendItem(
          Icons.square,
          Colors.orange.shade400,
          l10n.sandGrains,
          l10n.sandGrainsDesc,
          theme,
        ),
        _buildLegendItem(
          Icons.water_drop,
          Colors.blue.shade600,
          l10n.waterFlux,
          l10n.waterFluxDesc,
          theme,
        ),

        const SizedBox(height: 24),
        _buildSectionHeader(l10n.plantInteractions.toUpperCase(), theme),
        _buildLegendItem(
          Icons.blur_on,
          Colors.lightGreen.withValues(alpha: 0.5),
          l10n.rhizosphere,
          l10n.rhizosphereDesc,
          theme,
        ),
        _buildLegendItem(
          Icons.eco,
          Colors.green.shade600,
          l10n.rootExudates,
          l10n.rootExudatesDesc,
          theme,
        ),
        _buildLegendItem(
          Icons.water,
          Colors.lightBlue.shade400,
          l10n.transpiration,
          l10n.transpirationDesc,
          theme,
        ),

        const SizedBox(height: 24),
        _buildSectionHeader(l10n.hiddenGasCycles.toUpperCase(), theme),
        _buildLegendItem(
          Icons.air,
          Colors.white.withValues(alpha: 0.6),
          l10n.boundaryFlux,
          l10n.boundaryFluxDesc,
          theme,
        ),
        _buildLegendItem(
          Icons.bubble_chart,
          Colors.blueGrey.shade400,
          l10n.co2Bubbles,
          l10n.co2BubblesDesc,
          theme,
        ),

        const SizedBox(height: 24),
        _buildSectionHeader(l10n.hiddenChemicalDynamics.toUpperCase(), theme),
        _buildLegendItem(
          Icons.control_point,
          Colors.amber.withValues(alpha: 0.6),
          l10n.cecSnapping,
          l10n.cecSnappingDesc,
          theme,
        ),
        _buildMetricInfo(l10n.cationExchange, l10n.cationExchangeDesc, theme),
        _buildMetricInfo(l10n.elementToxicity, l10n.elementToxicityDesc, theme),
        _buildMetricInfo(l10n.phEmergence, l10n.phEmergenceDesc, theme),
      ],
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(
        title,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildZoomInfo(String level, String desc, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            level,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Text(
            desc,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    IconData icon,
    Color color,
    String title,
    String desc,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  desc,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricInfo(String title, String desc, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Text(
            desc,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
