part of '../hud_dashboard.dart';

/// Plant vitality and zoom indicators that sit above the view.
class _HUDPlantVitality extends ConsumerWidget {
  const _HUDPlantVitality();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final plant = ref.watch(
      displayedSimulationStateProvider.select((s) => s.plant),
    );
    final timeElapsed = ref.watch(
      displayedSimulationStateProvider.select((s) => s.timeElapsed),
    );

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.grass, size: 14, color: Colors.green.shade600),
                const SizedBox(width: 4),
                Text(
                  l10n.plantTitle.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              '${(plant.turgorPressure * 100).toStringAsFixed(1)}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: _buildSmallStat(
                Icons.height,
                '${(plant.height * 100).toStringAsFixed(1)} cm',
                theme,
              ),
            ),
            Flexible(
              child: _buildSmallStat(
                Icons.layers,
                'LAI: ${plant.lai.toStringAsFixed(2)}',
                theme,
              ),
            ),
            Flexible(
              child: _buildSmallStat(
                Icons.schedule,
                _formatTime(timeElapsed),
                theme,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HUDZoomIndicator extends ConsumerWidget {
  const _HUDZoomIndicator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final timeElapsed = ref.watch(
      displayedSimulationStateProvider.select((s) => s.timeElapsed),
    );
    final hours = (timeElapsed % 86400 / 3600).floor();
    final isDay = hours > 6 && hours < 18;
    final int day = (timeElapsed / 86400).floor() + 1;
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Icon(
          isDay ? Icons.wb_sunny : Icons.nightlight_round,
          size: 16,
          color: isDay ? Colors.orange : Colors.indigo,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            l10n.dayLabel(day).toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.zoom_in, size: 16, color: theme.colorScheme.primary),
      ],
    );
  }
}

// Helper Functions
