import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../providers/simulation_provider.dart';

class MissionPanel extends ConsumerWidget {
  const MissionPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(simulationProvider);
    final l10n = AppLocalizations.of(context)!;
    final scenario = state.currentScenario;
    if (scenario == null || scenario.objectives.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: scenario.objectives.map((obj) {
            final isMet = state.score.metObjectiveIds.contains(obj.id);
            final color = isMet
                ? Colors.green.shade700
                : theme.colorScheme.onSurfaceVariant;

            // Map known objective IDs to localized strings
            String title = obj.title;
            switch (obj.id) {
              case 'clay_yield':
                title = l10n.objectiveProduceBiomass;
                break;
              case 'clay_health':
                title = l10n.objectiveRestoreHealth;
                break;
              case 'leaching_prevention':
                title = l10n.objectivePreventLeaching;
                break;
              case 'yield_target':
                title = l10n.objectiveReachYield;
                break;
              case 'nitrogen_unlock':
                title = l10n.objectiveUnlockNitrogen;
                break;
              case 'crop_vitality':
                title = l10n.objectiveCropVitality;
                break;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  Icon(
                    isMet ? Icons.check_circle : Icons.radio_button_off,
                    color: color,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isMet
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: isMet ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
