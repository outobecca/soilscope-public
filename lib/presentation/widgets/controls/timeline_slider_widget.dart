import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/simulation_provider.dart';
import '../../providers/simulation_session_provider.dart';

String _formatTimelineTime(AppLocalizations l10n, double seconds) {
  // Match the HUD's minute formatting so the timeline label cannot show a
  // different minute for the same snapshot.
  final totalMinutes = (seconds / 60).floor();
  final day = totalMinutes ~/ Duration.minutesPerDay + 1;
  final hour =
      (totalMinutes % Duration.minutesPerDay) ~/ Duration.minutesPerHour;
  final minute = totalMinutes % Duration.minutesPerHour;
  final time =
      '${hour.toString().padLeft(2, '0')}:'
      '${minute.toString().padLeft(2, '0')}';
  return '${l10n.dayPrefix('$day')} · $time';
}

class TimelineSliderWidget extends ConsumerWidget {
  const TimelineSliderWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(simulationProvider.select((s) => s.history));
    final session = ref.watch(simulationSessionProvider);

    if (!session.isScrubbing || !hasScrubbableTimeline(history)) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final displayedTime = ref.watch(
      displayedSimulationStateProvider.select((s) => s.timeElapsed),
    );
    final snapshotIndex = nearestHistorySnapshotIndex(
      history,
      displayedTime,
    ).clamp(0, history.length - 1);
    final currentLabel = _formatTimelineTime(l10n, displayedTime);

    final label = Text(
      currentLabel,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );

    final slider = SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: theme.colorScheme.primary,
        inactiveTrackColor: theme.colorScheme.primaryContainer.withValues(
          alpha: 0.3,
        ),
        thumbColor: theme.colorScheme.primary,
        overlayColor: theme.colorScheme.primary.withValues(alpha: 0.15),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
        trackHeight: 3,
      ),
      child: Slider(
        value: snapshotIndex.toDouble(),
        min: 0,
        max: (history.length - 1).toDouble(),
        onChanged: (value) {
          final index = value.round().clamp(0, history.length - 1);
          ref
              .read(simulationSessionProvider.notifier)
              .scrubTo(history[index].timeElapsed);
        },
      ),
    );

    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Below this width the fixed slider and the longer localized day
            // label cannot share one line without clipping or overflowing.
            final isNarrow = constraints.maxWidth < 480;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: isNarrow
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [label, const SizedBox(height: 2), slider],
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(child: label),
                        const SizedBox(width: 12),
                        SizedBox(width: 250, child: slider),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }
}
