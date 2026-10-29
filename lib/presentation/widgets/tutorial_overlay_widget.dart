import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../providers/simulation_provider.dart';
import '../providers/simulation_session_provider.dart';
import '../providers/ui_state_provider.dart';
import '../providers/tutorial_provider.dart';
import 'tutorial/spotlight_painter.dart';
import 'tutorial/quick_guide_dialog.dart';

class TutorialOverlayWidget extends ConsumerStatefulWidget {
  const TutorialOverlayWidget({super.key});

  @override
  ConsumerState<TutorialOverlayWidget> createState() =>
      _TutorialOverlayWidgetState();
}

class _TutorialOverlayWidgetState extends ConsumerState<TutorialOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tutorialState = ref.watch(tutorialProvider);
    final scenarioStep = ref.watch(activeTutorialStepProvider);

    // If quick guide is open, show modal dialog
    if (tutorialState.isQuickGuideOpen) {
      return Material(
        color: Colors.black.withValues(alpha: 0.7),
        child: const QuickGuideDialog(),
      );
    }

    // Regular onboarding tour takes priority when visible
    if (!tutorialState.isVisible) {
      if (scenarioStep != null) {
        return _buildScenarioStepOverlay(context, scenarioStep);
      }
      return const SizedBox.shrink();
    }

    final notifier = ref.read(tutorialProvider.notifier);
    final steps = notifier.steps;
    final currentStep = steps[tutorialState.currentStepIndex];
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 700;

    const cardAlignment = Alignment.center;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // 1. Dynamic Spotlight Background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return CustomPaint(
                  painter: SpotlightPainter(
                    target: currentStep.target,
                    animationProgress: _animController.value,
                    isMobile: isMobile,
                    spotlightGlowColor: theme.colorScheme.primary,
                  ),
                );
              },
            ),
          ),

          // 2. Click interceptor
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                // Keep modal active
              },
            ),
          ),

          // 3. Floating Tutorial Card
          SafeArea(
            child: Align(
              alignment: cardAlignment,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                margin: EdgeInsets.all(isMobile ? 16 : 24),
                constraints: BoxConstraints(
                  maxWidth: isMobile ? double.infinity : 480,
                  maxHeight: screenSize.height * 0.85,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0F172A).withValues(alpha: 0.96),
                      const Color(0xFF1E293B).withValues(alpha: 0.94),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 25,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Step counter & close
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              l10n.tutorialStepCounter(
                                tutorialState.currentStepIndex + 1,
                                steps.length,
                              ),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  notifier.openQuickGuide();
                                },
                                icon: const Icon(
                                  Icons.menu_book_rounded,
                                  size: 16,
                                ),
                                label: Text(
                                  l10n.tutorialQuickGuide,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white70,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                                tooltip: l10n.tutorialSkip,
                                visualDensity: VisualDensity.compact,
                                onPressed: () => notifier.skipTutorial(),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Title with icon
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              currentStep.icon,
                              color: theme.colorScheme.primary,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              currentStep.getTitle(l10n),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (tutorialState.currentStepIndex + 1) /
                              steps.length,
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          color: theme.colorScheme.primary,
                          minHeight: 4,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Scrollable content area (description and bullet points)
                      Flexible(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentStep.getDescription(l10n),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 14),
                              ...currentStep.getPoints(l10n).map(
                                    (point) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 2.0),
                                            child: Icon(
                                              Icons.check_circle_outline_rounded,
                                              size: 16,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              point,
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: Colors.white.withValues(alpha: 0.8),
                                                height: 1.4,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            ],
                          ),
                        ),
                      ),
                      if (currentStep.actionLabel != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.touch_app_rounded,
                                size: 18,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  l10n.tutorialTryAction,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                              FilledButton.tonal(
                                onPressed: () {
                                  currentStep.onAction?.call(ref);
                                },
                                style: FilledButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                ),
                                child: Text(
                                  currentStep.actionLabel!(l10n),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Pinned Navigation buttons
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          TextButton(
                            onPressed: () => notifier.skipTutorial(),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white54,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                            ),
                            child: Text(l10n.tutorialSkip),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (tutorialState.currentStepIndex > 0) ...[
                                OutlinedButton(
                                  onPressed: () => notifier.previousStep(),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white70,
                                    side: BorderSide(
                                      color:
                                          Colors.white.withValues(alpha: 0.2),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  child: Text(l10n.tutorialPrev),
                                ),
                                const SizedBox(width: 8),
                              ],
                              FilledButton.icon(
                                onPressed: () => notifier.nextStep(),
                                style: FilledButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                ),
                                icon: Icon(
                                  tutorialState.currentStepIndex ==
                                          steps.length - 1
                                      ? Icons.check_circle_rounded
                                      : Icons.arrow_forward_rounded,
                                  size: 16,
                                ),
                                label: Text(
                                  tutorialState.currentStepIndex ==
                                          steps.length - 1
                                      ? l10n.tutorialFinish
                                      : l10n.tutorialNext,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioStepOverlay(
      BuildContext context, dynamic step) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Resolve localized title and description if available
    String title = step.title;
    String description = step.description;
    final stepTitle = step.title.toString();

    if (stepTitle.contains('kyntöantura') || stepTitle.contains('Plow Pan')) {
      title = l10n.stepCompactedClay1Title;
      description = l10n.stepCompactedClay1Desc;
    } else if (stepTitle.contains('kuohkeutus') || stepTitle.contains('Loosening')) {
      title = l10n.stepCompactedClay2Title;
      description = l10n.stepCompactedClay2Desc;
    } else if (stepTitle.contains('tunkeutumista') || stepTitle.contains('Root Penetration')) {
      title = l10n.stepCompactedClay3Title;
      description = l10n.stepCompactedClay3Desc;
    } else if (stepTitle.contains('nitraattipitoisuus') || stepTitle.contains('Nitrate Leaching')) {
      title = l10n.stepNitrateLeach1Title;
      description = l10n.stepNitrateLeach1Desc;
    } else if (stepTitle.contains('kerääjäkasveja') || stepTitle.contains('Catch Crops')) {
      title = l10n.stepNitrateLeach2Title;
      description = l10n.stepNitrateLeach2Desc;
    } else if (stepTitle.contains('lehdistössä') || stepTitle.contains('Canopy Nutrient')) {
      title = l10n.stepNitrateLeach3Title;
      description = l10n.stepNitrateLeach3Desc;
    } else if (stepTitle.contains('typpilukko') || stepTitle.contains('Immobilization')) {
      title = l10n.stepNitrogenLock1Title;
      description = l10n.stepNitrogenLock1Desc;
    } else if (stepTitle.contains('Täydennyslannoitus') || stepTitle.contains('Amendment')) {
      title = l10n.stepNitrogenLock2Title;
      description = l10n.stepNitrogenLock2Desc;
    } else if (stepTitle.contains('mineralisaation') || stepTitle.contains('Remineralization')) {
      title = l10n.stepNitrogenLock3Title;
      description = l10n.stepNitrogenLock3Desc;
    } else if (stepTitle.contains('hapenpuute') || stepTitle.contains('Waterlogging')) {
      title = l10n.stepWaterlogging1Title;
      description = l10n.stepWaterlogging1Desc;
    } else if (stepTitle.contains('Hapettomat') || stepTitle.contains('Hypoxia')) {
      title = l10n.stepWaterlogging2Title;
      description = l10n.stepWaterlogging2Desc;
    } else if (stepTitle.contains('ojitusta') || stepTitle.contains('Drainage')) {
      title = l10n.stepWaterlogging3Title;
      description = l10n.stepWaterlogging3Desc;
    }

    // Target information mapping
    final targetId = step.targetId.toString().toLowerCase();
    String targetLabel = '${l10n.tutTargetLabel}: ${step.targetId.toUpperCase()}';
    IconData targetIcon = Icons.biotech_rounded;
    String? actionLabel;
    VoidCallback? onAction;

    if (targetId.contains('control')) {
      targetLabel = l10n.controlPanel;
      targetIcon = Icons.tune_rounded;
      actionLabel = l10n.tutorialActionOpenControls;
      onAction = () => ref.read(sidebarStateProvider.notifier).setRight(true);
    } else if (targetId.contains('dash') || targetId.contains('hud')) {
      targetLabel = l10n.tutorialDashboardTitle;
      targetIcon = Icons.dashboard_rounded;
      actionLabel = l10n.tutorialActionOpenDashboard;
      onAction = () => ref.read(sidebarStateProvider.notifier).setLeft(true);
    } else if (targetId.contains('root') ||
        targetId.contains('microbe') ||
        targetId.contains('rhizo') ||
        targetId.contains('leaf') ||
        targetId.contains('soilstructure')) {
      targetLabel = '${l10n.nanovisionTitle}: ${step.targetId.toUpperCase()}';
      targetIcon = Icons.biotech_rounded;
      actionLabel = l10n.tutorialActionOpenNanovision;
      onAction = () =>
          ref.read(simulationSessionProvider.notifier).toggleMicroscope();
    }

    return Material(
      color: Colors.black.withValues(alpha: 0.65),
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () {},
            ),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              constraints: const BoxConstraints(maxWidth: 480),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.school_rounded,
                          color: theme.colorScheme.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.scenarioMissionGuideBadge,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: Colors.white24),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          targetIcon,
                          color: theme.colorScheme.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            targetLabel,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          ref.read(tutorialProvider.notifier).openQuickGuide();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          side: const BorderSide(color: Colors.white24),
                        ),
                        icon: const Icon(Icons.menu_book_rounded, size: 18),
                        label: Text(l10n.tutorialQuickGuide),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (actionLabel != null && onAction != null) ...[
                            OutlinedButton.icon(
                              onPressed: onAction,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: theme.colorScheme.primary,
                                side: BorderSide(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              icon: const Icon(Icons.touch_app_rounded, size: 18),
                              label: Text(actionLabel),
                            ),
                            const SizedBox(width: 8),
                          ],
                          FilledButton.icon(
                            onPressed: () {
                              ref
                                  .read(activeTutorialStepProvider.notifier)
                                  .setTutorialStep(null);
                              ref.read(simulationProvider.notifier).start();
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                            ),
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: Text(l10n.continueButton),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
