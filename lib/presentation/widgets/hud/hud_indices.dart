part of '../hud_dashboard.dart';

/// Index chips for the selected layer.
class _HUDIndices extends ConsumerWidget {
  const _HUDIndices();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(
      displayedSimulationStateProvider.select((s) => s.profile),
    );

    final topLayer = profile.layers.isNotEmpty ? profile.layers.first : null;
    if (topLayer == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          _buildIndexChip(
            icon: Icons.water_drop,
            label: 'θ',
            value: '${(topLayer.waterContent * 100).toStringAsFixed(1)}%',
            color: Colors.cyan,
            theme: theme,
          ),
          _buildIndexChip(
            // Pair the colour with a direction cue: acid ↓, neutral →,
            // alkaline ↑, so the state is not encoded by hue alone.
            icon: _getpHIcon(topLayer.ph),
            label: 'pH',
            value: topLayer.ph.toStringAsFixed(1),
            color: _getpHColor(topLayer.ph),
            theme: theme,
          ),
          _buildIndexChip(
            icon: Icons.bolt,
            label: 'N',
            value: topLayer.nitrateContent.toStringAsFixed(0),
            color: Colors.green,
            theme: theme,
          ),
          _buildIndexChip(
            icon: Icons.thermostat,
            label: 'T',
            value: '${(topLayer.temperature - 273.15).toStringAsFixed(1)}°C',
            color: Colors.orange,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildIndexChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required ThemeData theme,
  }) {
    return Semantics(
      label: label,
      value: value,
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                '$label: ',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 40),
                child: Text(
                  value,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
