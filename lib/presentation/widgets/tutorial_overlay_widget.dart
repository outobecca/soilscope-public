import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ui_state_provider.dart';
import '../providers/simulation_provider.dart';

class TutorialOverlayWidget extends ConsumerWidget {
  const TutorialOverlayWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(activeTutorialStepProvider);
    
    if (step == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Material(
      color: Colors.black.withValues(alpha: 0.4), // Dim background
      child: Stack(
        children: [
          // Semi-transparent interceptor for clicks outside
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                // Do nothing, force user to click "Jatka"
              },
            ),
          ),
          
          // Tutorial Box
          Center(
            child: Container(
              margin: const EdgeInsets.all(32),
              padding: const EdgeInsets.all(24),
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
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
                      Icon(
                        Icons.school,
                        color: theme.colorScheme.primary,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          step.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Text(
                    step.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Kohde: ${step.targetId.toUpperCase()}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FilledButton.icon(
                        onPressed: () {
                          // Dismiss tutorial
                          ref.read(activeTutorialStepProvider.notifier).setTutorialStep(null);
                          // Resume simulation
                          ref.read(simulationProvider.notifier).start();
                        },
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('JATKA'),
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
