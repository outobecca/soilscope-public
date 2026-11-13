part of '../hud_dashboard.dart';

/// Accessible table equivalent of the canvas.
class _HUDDataView extends ConsumerWidget {
  const _HUDDataView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.watch(simulationProvider.select((s) => s.profile));

    return ExpansionTile(
      title: Text(
        l10n.dataView.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
      dense: true,
      tilePadding: EdgeInsets.zero,
      children: [
        SoilDataTable(profile: profile),
        const SizedBox(height: 8),
      ],
    );
  }
}
