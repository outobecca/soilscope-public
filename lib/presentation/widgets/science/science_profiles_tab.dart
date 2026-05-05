import 'package:flutter/material.dart';
import '../../../../domain/models/biophysical_state.dart';
import '../../../l10n/app_localizations.dart';

class ScienceProfilesTab extends StatelessWidget {
  final BiophysicalState state;
  const ScienceProfilesTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.depthProfiles.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(l10n.soilColumnAnalysis, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 24),
          // Simple visual representation of profiles
          ...state.profile.layers.map(
            (layer) => _buildLayerProfileRow(layer, theme, l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildLayerProfileRow(
    dynamic layer,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.layerLabelWithDepth(
              layer.id,
              (layer.depth * 100).toStringAsFixed(0),
              ((layer.depth + layer.thickness) * 100).toStringAsFixed(0),
            ),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildBarIndicator(
            l10n.waterContent,
            layer.waterContent / layer.porosity,
            Colors.blue,
            theme,
          ),
          _buildBarIndicator(
            l10n.microbialBiomass,
            layer.microbialBiomass / 500.0,
            Colors.purple,
            theme,
          ),
          _buildBarIndicator(
            l10n.redoxPotential,
            (layer.redoxPotential + 200) / 800,
            Colors.orange,
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildBarIndicator(
    String label,
    double value,
    Color color,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: theme.textTheme.labelSmall),
              Text(
                '${(value * 100).toStringAsFixed(0)}%',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            color: color,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            minHeight: 4,
          ),
        ],
      ),
    );
  }
}
