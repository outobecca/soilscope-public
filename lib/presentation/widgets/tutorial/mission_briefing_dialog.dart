import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/scenario.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/simulation_provider.dart';
import 'quick_guide_dialog.dart';

class MissionBriefingDialog extends ConsumerWidget {
  final Scenario? scenario;

  const MissionBriefingDialog({super.key, this.scenario});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(simulationProvider);
    final activeScenario = scenario ?? state.currentScenario;

    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;

    if (activeScenario == null) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline, color: Colors.white70, size: 40),
                const SizedBox(height: 12),
                Text(
                  l10n.missionNoActiveScenario,
                  style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.closeAction),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final briefing = _getBriefingData(activeScenario.id, l10n);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: mathClamp(size.width * 0.9, 320, 760),
          height: mathClamp(size.height * 0.85, 450, 720),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.97),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.fromLTRB(isMobile ? 16 : 24, 20, 16, 14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.flag_rounded,
                        color: theme.colorScheme.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  l10n.missionBriefingTitle,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _getLocalizedScenarioTitle(activeScenario, l10n),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getLocalizedScenarioDesc(activeScenario, l10n),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Colors.white12),

              // Content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  children: [
                    // Problem analysis
                    _buildSectionHeader(
                      icon: Icons.warning_amber_rounded,
                      title: l10n.missionChallengeTitle,
                      color: Colors.amberAccent,
                      theme: theme,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        briefing.problem,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Action strategy
                    _buildSectionHeader(
                      icon: Icons.checklist_rounded,
                      title: l10n.missionRecommendationsTitle,
                      color: theme.colorScheme.primary,
                      theme: theme,
                    ),
                    const SizedBox(height: 8),
                    ...briefing.steps.asMap().entries.map((entry) {
                      final index = entry.key + 1;
                      final text = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.6),
                                ),
                              ),
                              child: Text(
                                '$index',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                text,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 20),

                    // Objectives
                    if (activeScenario.objectives.isNotEmpty) ...[
                      _buildSectionHeader(
                        icon: Icons.track_changes_rounded,
                        title: l10n.missionObjectivesTitle,
                        color: Colors.greenAccent,
                        theme: theme,
                      ),
                      const SizedBox(height: 8),
                      ...activeScenario.objectives.map((obj) {
                        final isMet = state.score.metObjectiveIds.contains(obj.id);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isMet
                                ? Colors.green.withValues(alpha: 0.12)
                                : Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isMet
                                  ? Colors.greenAccent.withValues(alpha: 0.5)
                                  : Colors.white12,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isMet
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                color: isMet ? Colors.greenAccent : Colors.white54,
                                size: 18,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _getLocalizedObjectiveTitle(obj, l10n),
                                  style: TextStyle(
                                    color: isMet ? Colors.greenAccent : Colors.white,
                                    fontWeight: isMet ? FontWeight.bold : FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Text(
                                isMet ? l10n.missionStatusAchieved : l10n.missionStatusPending,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isMet ? Colors.greenAccent : Colors.white38,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 20),
                    ],

                    // Science background
                    _buildSectionHeader(
                      icon: Icons.science_rounded,
                      title: l10n.missionScienceTitle,
                      color: const Color(0xFF38BDF8),
                      theme: theme,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        briefing.science,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.white10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        showDialog(
                          context: context,
                          builder: (context) => const QuickGuideDialog(),
                        );
                      },
                      icon: const Icon(Icons.menu_book_rounded, size: 18),
                      label: Text(l10n.missionOpenQuickGuide),
                      style: TextButton.styleFrom(foregroundColor: Colors.white70),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: Text(
                        l10n.missionStartActions,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double mathClamp(double val, double min, double max) {
    if (val < min) return min;
    if (val > max) return max;
    return val;
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  String _getLocalizedScenarioTitle(Scenario scenario, AppLocalizations l10n) {
    switch (scenario.id) {
      case 'compacted_clay':
        return l10n.compactedClayTitle;
      case 'nitrate_leaching':
        return l10n.nitrateLeachingTitle;
      case 'nitrogen_lock':
        return l10n.nitrogenLockTitle;
      case 'waterlogging':
        return l10n.waterloggingTitle;
      default:
        return scenario.title;
    }
  }

  String _getLocalizedScenarioDesc(Scenario scenario, AppLocalizations l10n) {
    switch (scenario.id) {
      case 'compacted_clay':
        return l10n.compactedClayDesc;
      case 'nitrate_leaching':
        return l10n.nitrateLeachingDesc;
      case 'nitrogen_lock':
        return l10n.nitrogenLockDesc;
      case 'waterlogging':
        return l10n.waterloggingDesc;
      default:
        return scenario.description;
    }
  }

  String _getLocalizedObjectiveTitle(MissionObjective obj, AppLocalizations l10n) {
    switch (obj.id) {
      case 'clay_yield':
        return l10n.objectiveProduceBiomass;
      case 'clay_health':
        return l10n.objectiveRestoreHealth;
      case 'leaching_prevention':
        return l10n.objectivePreventLeaching;
      case 'yield_target':
        return l10n.objectiveReachYield;
      case 'nitrogen_unlock':
        return l10n.objectiveUnlockNitrogen;
      case 'crop_vitality':
        return l10n.objectiveCropVitality;
      case 'wet_yield':
        return l10n.objectiveMaintainTurgor;
      case 'wet_eh':
        return l10n.objectiveRestoreAerobic;
      default:
        return obj.title;
    }
  }

  _BriefingData _getBriefingData(String scenarioId, AppLocalizations l10n) {
    switch (scenarioId) {
      case 'compacted_clay':
        return _BriefingData(
          problem: l10n.briefingCompactionProblem,
          steps: [
            l10n.briefingCompactionStep1,
            l10n.briefingCompactionStep2,
            l10n.briefingCompactionStep3,
            l10n.briefingCompactionStep4,
          ],
          science: l10n.briefingCompactionScience,
        );

      case 'nitrate_leaching':
        return _BriefingData(
          problem: l10n.briefingLeachingProblem,
          steps: [
            l10n.briefingLeachingStep1,
            l10n.briefingLeachingStep2,
            l10n.briefingLeachingStep3,
            l10n.briefingLeachingStep4,
          ],
          science: l10n.briefingLeachingScience,
        );

      case 'nitrogen_lock':
        return _BriefingData(
          problem: l10n.briefingLockProblem,
          steps: [
            l10n.briefingLockStep1,
            l10n.briefingLockStep2,
            l10n.briefingLockStep3,
            l10n.briefingLockStep4,
          ],
          science: l10n.briefingLockScience,
        );

      case 'waterlogging':
        return _BriefingData(
          problem: l10n.briefingWaterloggingProblem,
          steps: [
            l10n.briefingWaterloggingStep1,
            l10n.briefingWaterloggingStep2,
            l10n.briefingWaterloggingStep3,
            l10n.briefingWaterloggingStep4,
          ],
          science: l10n.briefingWaterloggingScience,
        );

      default:
        return _BriefingData(
          problem: l10n.briefingDefaultProblem,
          steps: [
            l10n.briefingDefaultStep1,
            l10n.briefingDefaultStep2,
            l10n.briefingDefaultStep3,
          ],
          science: l10n.briefingDefaultScience,
        );
    }
  }
}

class _BriefingData {
  final String problem;
  final List<String> steps;
  final String science;

  const _BriefingData({
    required this.problem,
    required this.steps,
    required this.science,
  });
}
