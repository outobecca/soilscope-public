import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/simulation_provider.dart';
import '../../providers/simulation_session_provider.dart';
import '../../providers/event_log_provider.dart';
import '../../providers/ui_state_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../controls/fertilizer_modal.dart';
import '../../../../core/cpk_standards.dart';

class FlutterQuickActions extends ConsumerWidget {
  const FlutterQuickActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(simulationProvider);
    final session = ref.watch(simulationSessionProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...[
              // Play/Pause
              _buildActionButton(
                context: context,
                icon: state.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                label: state.isRunning ? l10n.pause : l10n.play,
                isActive: state.isRunning,
                onTap: () {
                  final notifier = ref.read(simulationProvider.notifier);
                  if (state.isRunning) {
                    notifier.stop();
                  } else {
                    notifier.start();
                  }
                },
              ),
              
              // Time Scale
              _buildActionButton(
                context: context,
                icon: Icons.speed_rounded,
                label: '${state.timeScale}x',
                isActive: state.timeScale > 1.0,
                onTap: () {
                  final speeds = [0.5, 1.0, 2.0, 5.0, 10.0];
                  final currentIndex = speeds.indexOf(state.timeScale);
                  final nextIndex = (currentIndex + 1) % speeds.length;
                  ref.read(simulationProvider.notifier).setSpeed(speeds[nextIndex]);
                },
              ),

              // Weather
              _buildActionButton(
                context: context,
                icon: Icons.cloudy_snowing,
                label: l10n.autoWeather,
                isActive: state.autoWeather,
                onTap: () {
                  ref.read(simulationProvider.notifier).toggleAutoWeather();
                },
              ),

              // Rain
              _buildActionButton(
                context: context,
                icon: state.precipitation > 0 ? Icons.water_drop_rounded : Icons.water_drop_outlined,
                label: l10n.rain,
                isActive: state.precipitation > 0,
                onTap: () {
                  final notifier = ref.read(simulationProvider.notifier);
                  notifier.setPrecipitation(state.precipitation > 0 ? 0.0 : 10.0);
                },
              ),

              // Tillage
              _buildActionButton(
                context: context,
                icon: Icons.agriculture_rounded,
                label: l10n.tillage,
                isActive: false,
                onTap: () {
                  ref.read(simulationProvider.notifier).applyTillage();
                },
              ),

              // Cover Crop
              _buildActionButton(
                context: context,
                icon: Icons.eco_rounded,
                label: l10n.coverCrop,
                isActive: state.hasCoverCrop,
                onTap: () {
                  if (!state.hasCoverCrop) {
                    ref.read(simulationProvider.notifier).applyCoverCrop();
                  }
                },
              ),

              // Fertilizer
              _buildActionButton(
                context: context,
                icon: Icons.science_rounded,
                label: l10n.fertilize,
                isActive: false,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => const FertilizerModal(),
                  );
                },
              ),

              // Timeline
              _buildActionButton(
                context: context,
                icon: Icons.linear_scale_rounded,
                label: l10n.timeline,
                isActive: session.isScrubbing,
                onTap: () {
                  final notifier = ref.read(simulationProvider.notifier);
                  if (session.isScrubbing) {
                    notifier.stopScrubbing();
                  } else {
                    notifier.startScrubbing();
                  }
                },
              ),

              // Event Log
              _buildActionButton(
                context: context,
                icon: Icons.history_rounded,
                label: l10n.eventLog,
                isActive: false,
                onTap: () => _showEventLog(context, ref, l10n),
              ),

              // Microscope
              _buildActionButton(
                context: context,
                icon: session.isMicroscopeEnabled ? Icons.biotech_rounded : Icons.biotech_outlined,
                label: l10n.microscope,
                isActive: session.isMicroscopeEnabled,
                onTap: () async {
                  final RenderBox button = context.findRenderObject() as RenderBox;
                  final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
                  final RelativeRect position = RelativeRect.fromRect(
                    Rect.fromPoints(
                      button.localToGlobal(Offset.zero, ancestor: overlay),
                      button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
                    ),
                    Offset.zero & overlay.size,
                  );
                  
                  if (!session.isMicroscopeEnabled) {
                    ref.read(simulationSessionProvider.notifier).toggleMicroscope();
                  }

                  final String? selected = await showMenu<String>(
                    context: context,
                    position: position,
                    items: [
                      PopupMenuItem(value: 'off', child: Text(l10n.turnOffMicroscope)),
                      const PopupMenuDivider(),
                      PopupMenuItem(value: 'leaf', child: Text(l10n.leaf)),
                      PopupMenuItem(value: 'stem', child: Text(l10n.stem)),
                      PopupMenuItem(value: 'root', child: Text(l10n.root)),
                      PopupMenuItem(value: 'rhizosphere', child: Text(l10n.rhizosphere)),
                      PopupMenuItem(value: 'microbe', child: Text(l10n.microbes)),
                      PopupMenuItem(value: 'soilStructure', child: Text(l10n.soilStructure)),
                      PopupMenuItem(value: 'apicalMeristem', child: Text(l10n.apicalMeristem)),
                    ],
                  );
                  
                  if (selected != null) {
                    if (selected == 'off') {
                      ref.read(simulationSessionProvider.notifier).toggleMicroscope();
                      ref.read(simulationSessionProvider.notifier).selectInspector(null);
                    } else {
                      ref.read(simulationSessionProvider.notifier).selectInspector(selected);
                    }
                  }
                },
              ),

              // Logic Lab
              _buildActionButton(
                context: context,
                icon: Icons.science_outlined,
                label: 'Logic Lab',
                isActive: false,
                onTap: () {
                  Navigator.pushNamed(context, '/logic_lab');
                },
              ),

              // Observation Cycle Toggle
              _buildActionButton(
                context: context,
                icon: ref.watch(activeCycleProvider) != ObservationCycle.none ? Icons.published_with_changes : Icons.published_with_changes_outlined,
                label: ref.watch(activeCycleProvider) == ObservationCycle.none ? 'OBSERVATION' : ref.watch(activeCycleProvider).name.toUpperCase(),
                isActive: ref.watch(activeCycleProvider) != ObservationCycle.none,
                onTap: () {
                  final current = ref.read(activeCycleProvider);
                  final values = ObservationCycle.values;
                  final nextIndex = (values.indexOf(current) + 1) % values.length;
                  ref.read(activeCycleProvider.notifier).setCycle(values[nextIndex]);
                },
              ),

              // Flow Toggle
              _buildActionButton(
                context: context,
                icon: ref.watch(particleFlowModeProvider) ? Icons.device_hub_rounded : Icons.device_hub_outlined,
                label: l10n.flows,
                isActive: ref.watch(particleFlowModeProvider),
                onTap: () {
                  ref.read(particleFlowModeProvider.notifier).toggle();
                },
              ),

              // Scenario Builder
              _buildActionButton(
                context: context,
                icon: Icons.edit_rounded,
                label: l10n.modify,
                isActive: false,
                onTap: () {
                  Navigator.pushNamed(context, '/scenario_builder');
                },
              ),
            ].map((btn) => Padding(padding: const EdgeInsets.symmetric(horizontal: 4.0), child: btn)),

            const SizedBox(
              height: 24,
              child: VerticalDivider(
                width: 20,
                thickness: 1,
              ),
            ),

            ...[
              _buildElementButton(ref, 'N', CPKStandards.colorN, '${l10n.nitrate} (N)', session.selectedElementSymbol == 'N'),
            ].map((btn) => Padding(padding: const EdgeInsets.symmetric(horizontal: 2.0), child: btn)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final activeColor = theme.colorScheme.primary;
    final inactiveColor = theme.colorScheme.surfaceContainerHighest;

    return Tooltip(
      message: label,
      child: Material(
        color: isActive ? activeColor : inactiveColor,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              icon,
              color: isActive ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildElementButton(WidgetRef ref, String symbol, Color color, String label, bool isSelected) {
    return Tooltip(
      message: label,
      child: Material(
        color: isSelected ? color : color.withValues(alpha: 0.25),
        shape: CircleBorder(
          side: isSelected ? const BorderSide(color: Colors.white, width: 2) : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            ref.read(simulationSessionProvider.notifier).selectElement(isSelected ? '' : symbol);
          },
          child: Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            child: Text(
              symbol,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: symbol == 'H' && !isSelected ? Colors.white70 : (symbol == 'H' ? Colors.black87 : Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }



  void _showEventLog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final events = ref.read(eventLogProvider);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.eventLog),
        content: SizedBox(
          width: 400,
          height: 500,
          child: events.isEmpty
              ? Center(child: Text(l10n.noEvents))
              : ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) => ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(events[index].getLocalizedMessage(l10n)),
                    subtitle: Text(
                      'T+ ${events[index].timestamp.toStringAsFixed(0)}s',
                    ),
                  ),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.closeAction),
          ),
        ],
      ),
    );
  }
}
