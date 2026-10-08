import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/simulation_provider.dart';
import '../../providers/simulation_session_provider.dart';
import '../../providers/event_log_provider.dart';
import '../../providers/ui_state_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../controls/fertilizer_modal.dart';
import '../controls/element_selection_modal.dart';
import '../../../../core/cpk_standards.dart';
import '../../../../core/periodic_table.dart';
import 'components/process_magnifier_component.dart';
import 'logic/microscope_info_helper.dart';

class FlutterQuickActions extends ConsumerWidget {
  const FlutterQuickActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRunning = ref.watch(simulationProvider.select((s) => s.isRunning));
    final timeScale = ref.watch(simulationProvider.select((s) => s.timeScale));
    final autoWeather = ref.watch(simulationProvider.select((s) => s.autoWeather));
    final precipitation = ref.watch(simulationProvider.select((s) => s.precipitation));
    final hasCoverCrop = ref.watch(simulationProvider.select((s) => s.hasCoverCrop));
    
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
                icon: isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                label: isRunning ? l10n.pause : l10n.play,
                isActive: isRunning,
                onTap: () {
                  final notifier = ref.read(simulationProvider.notifier);
                  if (isRunning) {
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
                label: '${timeScale}x',
                isActive: timeScale > 1.0,
                onTap: () {
                  final speeds = [0.5, 1.0, 2.0, 5.0, 10.0];
                  final currentIndex = speeds.indexOf(timeScale);
                  final nextIndex = (currentIndex + 1) % speeds.length;
                  ref.read(simulationProvider.notifier).setSpeed(speeds[nextIndex]);
                },
              ),
              
              // Weather
              _buildActionButton(
                context: context,
                icon: Icons.cloudy_snowing,
                label: l10n.autoWeather,
                isActive: autoWeather,
                onTap: () {
                  ref.read(simulationProvider.notifier).toggleAutoWeather();
                },
              ),

              // Rain
              _buildActionButton(
                context: context,
                icon: precipitation > 0 ? Icons.water_drop_rounded : Icons.water_drop_outlined,
                label: l10n.rain,
                isActive: precipitation > 0,
                onTap: () {
                  final notifier = ref.read(simulationProvider.notifier);
                  notifier.setPrecipitation(precipitation > 0 ? 0.0 : 10.0);
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
                isActive: hasCoverCrop,
                onTap: () {
                  if (!hasCoverCrop) {
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
                onTap: () {
                  final sessionNotifier = ref.read(simulationSessionProvider.notifier);
                  final uiNotifier = ref.read(uIStateProvider.notifier);
                  final wasEnabled = session.isMicroscopeEnabled;
                  sessionNotifier.toggleMicroscope();
                  if (!wasEnabled) {
                    final targetName = session.selectedInspectorType ?? 'rhizosphere';
                    final targetType = MicroscopeInfoHelper.parseType(targetName) ?? MagnifierType.rhizosphere;
                    final state = ref.read(simulationProvider);
                    uiNotifier.setHoverInfo(
                      MicroscopeInfoHelper.createHoverInfo(
                        type: targetType,
                        l: l10n,
                        state: state,
                        isPinned: true,
                      ),
                    );
                  } else {
                    uiNotifier.clearHoverInfo();
                  }
                },
              ),

              // Science Reference
              _buildActionButton(
                context: context,
                icon: Icons.menu_book_rounded,
                label: l10n.scienceReference.toUpperCase(),
                isActive: false,
                onTap: () {
                  Navigator.pushNamed(context, '/science_reference');
                },
              ),

              // Logic Lab
              _buildActionButton(
                context: context,
                icon: Icons.science_outlined,
                label: l10n.logicLab,
                isActive: false,
                onTap: () {
                  Navigator.pushNamed(context, '/logic_lab');
                },
              ),

              // Observation Cycle Toggle
              _buildActionButton(
                context: context,
                icon: ref.watch(activeCycleProvider) != ObservationCycle.none ? Icons.published_with_changes : Icons.published_with_changes_outlined,
                label: ref.watch(activeCycleProvider) == ObservationCycle.none ? l10n.observation.toUpperCase() : ref.watch(activeCycleProvider).name.toUpperCase(),
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

              // Schematic Toggle
              _buildActionButton(
                context: context,
                icon: ref.watch(visualLayoutModeStateProvider) == VisualLayoutMode.schematic ? Icons.account_tree_rounded : Icons.account_tree_outlined,
                label: l10n.schematic.toUpperCase(),
                isActive: ref.watch(visualLayoutModeStateProvider) == VisualLayoutMode.schematic,
                onTap: () {
                  ref.read(visualLayoutModeStateProvider.notifier).toggle();
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
              ...['N', 'P', 'K', 'Ca', 'Mg', 'S', 'C', 'O', 'Fe']
                  .map((sym) => _buildElementButton(
                        context: context,
                        ref: ref,
                        symbol: sym,
                        isSelected: session.selectedElementSymbol == sym,
                      )),
              if (session.selectedElementSymbol != null &&
                  session.selectedElementSymbol!.isNotEmpty &&
                  !['N', 'P', 'K', 'Ca', 'Mg', 'S', 'C', 'O', 'Fe']
                      .contains(session.selectedElementSymbol))
                _buildElementButton(
                  context: context,
                  ref: ref,
                  symbol: session.selectedElementSymbol!,
                  isSelected: true,
                ),
              _buildPeriodicTableLauncher(context, l10n),
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
      preferBelow: false,
      verticalOffset: 24,
      waitDuration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
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

  Widget _buildElementButton({
    required BuildContext context,
    required WidgetRef ref,
    required String symbol,
    required bool isSelected,
  }) {
    final lang = Localizations.localeOf(context).languageCode;
    final element = PeriodicTable.getBySymbol(symbol);
    final color = element?.cpkColor ?? CPKStandards.getColor(symbol);
    final name = element?.localizedName(lang) ?? symbol;
    final role = element?.localizedAgronomicRole(lang) ?? '';
    final tooltipText = role.isNotEmpty ? '$name ($symbol) - $role' : '$name ($symbol)';

    return Tooltip(
      message: tooltipText,
      preferBelow: false,
      verticalOffset: 24,
      waitDuration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      child: Material(
        color: isSelected ? color : color.withValues(alpha: 0.25),
        shape: CircleBorder(
          side: isSelected ? const BorderSide(color: Colors.white, width: 2) : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            final isCurrentlySelected =
                ref.read(simulationSessionProvider).selectedElementSymbol == symbol;
            final sessionNotifier = ref.read(simulationSessionProvider.notifier);
            final uiNotifier = ref.read(uIStateProvider.notifier);
            if (isCurrentlySelected) {
              sessionNotifier.selectElement(null);
              uiNotifier.setHoverInfo(null);
            } else {
              sessionNotifier.selectElement(symbol);
              if (element != null) {
                uiNotifier.setHoverInfo(element.toHoverInfo(lang, isPinned: true));
              }
            }
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
                color: (color.computeLuminance() > 0.5 && isSelected)
                    ? Colors.black
                    : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodicTableLauncher(BuildContext context, AppLocalizations l10n) {
    return Tooltip(
      message: l10n.allElements,
      preferBelow: false,
      verticalOffset: 24,
      waitDuration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white24,
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      child: Material(
        color: Colors.white.withValues(alpha: 0.12),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => ElementSelectionModal.show(context),
          child: Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            child: const Icon(
              Icons.grid_view_rounded,
              size: 15,
              color: Colors.white,
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
