import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/simulation_provider.dart';
import '../../providers/simulation_session_provider.dart';

class TimelineSliderWidget extends ConsumerWidget {
  const TimelineSliderWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(simulationProvider.select((s) => s.history));
    final session = ref.watch(simulationSessionProvider);
    
    if (!session.isScrubbing || history.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final minTime = history.first.timeElapsed;
    final maxTime = history.last.timeElapsed;
    final currentTime = session.isScrubbing 
        ? session.viewTime.clamp(minTime, maxTime) 
        : maxTime;

    final currentDay = (currentTime / 86400).toStringAsFixed(1);



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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$currentDay pv',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 250,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: theme.colorScheme.primary,
                inactiveTrackColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                thumbColor: theme.colorScheme.primary,
                overlayColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                trackHeight: 3,
              ),
              child: Slider(
                value: currentTime,
                min: minTime,
                max: maxTime > minTime ? maxTime : minTime + 1.0,
                divisions: history.length > 1 ? history.length - 1 : 1,
                onChanged: (value) {
                  ref.read(simulationSessionProvider.notifier).scrubTo(value);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
