part of '../hud_dashboard.dart';

/// Accessible table equivalent of the canvas.
///
/// The table is only built while expanded; previously the full DataTable was
/// rebuilt on every simulation tick even though it was collapsed and hidden
/// below the fold.
class _HUDDataView extends StatefulWidget {
  const _HUDDataView();

  @override
  State<_HUDDataView> createState() => _HUDDataViewState();
}

class _HUDDataViewState extends State<_HUDDataView> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

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
      onExpansionChanged: (expanded) {
        setState(() => _expanded = expanded);
      },
      children: [
        if (_expanded) const _HUDDataTable(),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _HUDDataTable extends ConsumerWidget {
  const _HUDDataTable();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(
      displayedSimulationStateProvider.select((s) => s.profile),
    );
    return SoilDataTable(profile: profile);
  }
}
