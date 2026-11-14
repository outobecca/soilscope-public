part of '../hud_dashboard.dart';

/// Header, sustainability summary and scrub row for the HUD.
class _HUDHeader extends ConsumerWidget {
  const _HUDHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isScrubbing = ref.watch(
      simulationSessionProvider.select((s) => s.isScrubbing),
    );

    return Row(
      children: [
        Icon(
          Icons.analytics_outlined,
          color: theme.colorScheme.primary,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            l10n.fieldMetrics.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.info_outline, size: 18),
          onPressed: () => _showInfoDialog(context, l10n),
          tooltip: l10n.index,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 8),
        if (isScrubbing)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange.shade800,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              l10n.historyMode.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  void _showInfoDialog(BuildContext context, AppLocalizations l10n) {
    // AlertDialog measures its content with IntrinsicWidth. The reference view
    // contains rows with Expanded children, and a ListView/PageView cannot
    // provide an intrinsic width, which used to abort layout and leave the HUD
    // untappable. A concrete content width keeps the dialog measurable.
    final contentWidth =
        (MediaQuery.sizeOf(context).width - 80).clamp(280.0, 500.0).toDouble();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.index),
        content: SizedBox(
          width: contentWidth,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.65,
            ),
            child: const SingleChildScrollView(child: InformaticsView()),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _HUDSustainabilityMetrics extends ConsumerWidget {
  const _HUDSustainabilityMetrics();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // Watch only the profile for metrics
    final profile = ref.watch(
      displayedSimulationStateProvider.select((s) => s.profile),
    );

    return Column(
      children: [
        AnalyticsHealthBar(
          label: l10n.soilStructure,
          value: _calculateStructureHP(profile),
          color: Colors.teal,
        ),
        const SizedBox(height: 12),
        AnalyticsHealthBar(
          label: l10n.bioActivity,
          value: _calculateBioScore(profile),
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        AnalyticsHealthBar(
          label: l10n.leachingRisk,
          value: _calculatePollutionMeter(profile),
          color: Colors.orange,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _HUDScrubber extends ConsumerWidget {
  const _HUDScrubber();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final hasTimeline = ref.watch(
      simulationProvider.select((s) => hasTimelineHistory(s.history)),
    );

    final isRunning = ref.watch(simulationProvider.select((s) => s.isRunning));
    final isScrubbing = ref.watch(
      simulationSessionProvider.select((s) => s.isScrubbing),
    );
    final viewTime = ref.watch(
      simulationSessionProvider.select((s) => s.viewTime),
    );
    final minTime = ref.watch(
      simulationProvider.select(
        (s) => s.history.isNotEmpty ? s.history.first.timeElapsed : 0.0,
      ),
    );
    // A pre-calculated timeline can leave the live clock at its start while
    // history extends into the future. The scrub range must follow the history
    // end, matching TimelineSliderWidget and the displayed snapshot.
    final maxTime = ref.watch(
      simulationProvider.select(
        (s) => s.history.isNotEmpty ? s.history.last.timeElapsed : s.timeElapsed,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isScrubbing ? l10n.historyMode.toUpperCase() : l10n.realTime,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isScrubbing
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    isRunning ? Icons.pause : Icons.play_arrow,
                    size: 16,
                  ),
                  onPressed: () => isRunning
                      ? ref.read(simulationProvider.notifier).stop()
                      : ref.read(simulationProvider.notifier).start(),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    isScrubbing ? Icons.close : Icons.history,
                    size: 16,
                  ),
                  onPressed: !hasTimeline && !isScrubbing
                      ? null
                      : () => isScrubbing
                          ? ref
                              .read(simulationProvider.notifier)
                              .stopScrubbing()
                          : ref
                              .read(simulationProvider.notifier)
                              .startScrubbing(),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ],
        ),
        if (isScrubbing)
          Slider(
            value: viewTime.clamp(minTime, maxTime),
            min: minTime,
            max: maxTime > minTime ? maxTime : minTime + 1.0,
            onChanged: maxTime > minTime
                ? (value) =>
                      ref.read(simulationSessionProvider.notifier).scrubTo(value)
                : null,
          ),
      ],
    );
  }
}
