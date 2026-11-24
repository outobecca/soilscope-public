import 'package:material_ui/material_ui.dart';
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

enum _QuickActionCategory { all, actions, environment, view, elements, navigate }

/// Core playback and observation controls stay on the canvas. Field actions
/// open in a categorised sheet so the toolbar remains thumb-reachable on a
/// phone without hiding scenario-critical interventions behind a flat list.
class FlutterQuickActions extends ConsumerWidget {
  const FlutterQuickActions({super.key});

  static const List<String> _quickElements = [
    'N',
    'P',
    'K',
    'Ca',
    'Mg',
    'S',
    'C',
    'O',
    'Fe',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRunning = ref.watch(simulationProvider.select((s) => s.isRunning));
    final timeScale = ref.watch(simulationProvider.select((s) => s.timeScale));
    final session = ref.watch(simulationSessionProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildActionButton(
            context: context,
            icon: isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
            label: isRunning ? l10n.pause : l10n.play,
            isActive: isRunning,
            onTap: () {
              final notifier = ref.read(simulationProvider.notifier);
              isRunning ? notifier.stop() : notifier.start();
            },
          ),
          _buildActionButton(
            context: context,
            icon: Icons.speed_rounded,
            label: '${timeScale}x',
            isActive: timeScale > 1.0,
            onTap: () {
              const speeds = [0.5, 1.0, 2.0, 5.0, 10.0];
              final next = (speeds.indexOf(timeScale) + 1) % speeds.length;
              ref.read(simulationProvider.notifier).setSpeed(speeds[next]);
            },
          ),
          _buildActionButton(
            context: context,
            icon: Icons.linear_scale_rounded,
            label: l10n.timeline,
            isActive: session.isScrubbing,
            onTap: () {
              final notifier = ref.read(simulationProvider.notifier);
              session.isScrubbing
                  ? notifier.stopScrubbing()
                  : notifier.startScrubbing();
            },
          ),
          _buildActionButton(
            context: context,
            icon: Icons.bolt_rounded,
            label: l10n.quickActions,
            isActive: false,
            onTap: () => _showActionMenu(
              context,
              ref,
              l10n,
              initialCategory: _QuickActionCategory.actions,
            ),
          ),
          _buildActionButton(
            context: context,
            icon: session.isMicroscopeEnabled
                ? Icons.biotech_rounded
                : Icons.biotech_outlined,
            label: l10n.microscope,
            isActive: session.isMicroscopeEnabled,
            onTap: () => _toggleMicroscope(ref, l10n, session),
          ),
          _buildActionButton(
            context: context,
            icon: Icons.more_horiz_rounded,
            label: l10n.moreActions,
            isActive: false,
            onTap: () => _showActionMenu(context, ref, l10n),
          ),
        ],
      ),
    );
  }

  void _toggleMicroscope(
    WidgetRef ref,
    AppLocalizations l10n,
    SimulationSessionState session,
  ) {
    final sessionNotifier = ref.read(simulationSessionProvider.notifier);
    final uiNotifier = ref.read(uIStateProvider.notifier);
    final wasEnabled = session.isMicroscopeEnabled;
    sessionNotifier.toggleMicroscope();
    if (!wasEnabled) {
      final targetName = session.selectedInspectorType ?? 'rhizosphere';
      final targetType =
          MicroscopeInfoHelper.parseType(targetName) ?? MagnifierType.rhizosphere;
      uiNotifier.setHoverInfo(
        MicroscopeInfoHelper.createHoverInfo(
          type: targetType,
          l: l10n,
          state: ref.read(displayedSimulationStateProvider),
          isPinned: true,
        ),
      );
    } else {
      sessionNotifier.selectInspector(null);
      uiNotifier.clearHoverInfo();
    }
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        preferBelow: false,
        verticalOffset: 24,
        child: Material(
          color: isActive
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            // 48 dp minimum touch target.
            child: SizedBox(
              width: 48,
              height: 48,
              child: Icon(
                icon,
                color: isActive
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showActionMenu(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n, {
    _QuickActionCategory initialCategory = _QuickActionCategory.all,
  }) {
    final parentContext = context;
    var selectedCategory = initialCategory;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) {
        void close() => Navigator.of(sheetContext).pop();
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.62,
              minChildSize: 0.35,
              maxChildSize: 0.92,
              builder: (context, controller) {
                // The sheet is part of the read-only presentation of the
                // current snapshot, so active states must follow the timeline
                // while scrubbing just like the HUD and canvas.
                final autoWeather = ref.watch(
                  displayedSimulationStateProvider.select((s) => s.autoWeather),
                );
                final precipitation = ref.watch(
                  displayedSimulationStateProvider
                      .select((s) => s.precipitation),
                );
                final hasCoverCrop = ref.watch(
                  displayedSimulationStateProvider.select((s) => s.hasCoverCrop),
                );
                final session = ref.watch(simulationSessionProvider);
                final cycle = ref.watch(activeCycleProvider);
                final flowOn = ref.watch(particleFlowModeProvider);
                final schematic =
                    ref.watch(visualLayoutModeStateProvider) ==
                        VisualLayoutMode.schematic;

                final showActions =
                    selectedCategory == _QuickActionCategory.all ||
                        selectedCategory == _QuickActionCategory.actions;
                final showEnvironment =
                    selectedCategory == _QuickActionCategory.all ||
                        selectedCategory == _QuickActionCategory.environment;
                final showView =
                    selectedCategory == _QuickActionCategory.all ||
                        selectedCategory == _QuickActionCategory.view;
                final showElements =
                    selectedCategory == _QuickActionCategory.all ||
                        selectedCategory == _QuickActionCategory.elements;
                final showNavigate =
                    selectedCategory == _QuickActionCategory.all ||
                        selectedCategory == _QuickActionCategory.navigate;

                return ListView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                  children: [
                    _buildCategoryChips(
                      context,
                      l10n,
                      selectedCategory,
                      (next) => setSheetState(() => selectedCategory = next),
                    ),
                    if (showActions) ...[
                      _sectionTitle(l10n.quickActions.toUpperCase(), context),
                      _buildActionTile(
                        context: context,
                        icon: Icons.agriculture_rounded,
                        label: l10n.tillage,
                        isActive: false,
                        onTap: () {
                          ref.read(simulationProvider.notifier).applyTillage();
                          close();
                        },
                      ),
                      _buildActionTile(
                        context: context,
                        icon: Icons.eco_rounded,
                        label: l10n.coverCrop,
                        isActive: hasCoverCrop,
                        onTap: () {
                          if (!hasCoverCrop) {
                            ref
                                .read(simulationProvider.notifier)
                                .setCoverCrop(true);
                          }
                          close();
                        },
                      ),
                      _buildActionTile(
                        context: context,
                        icon: Icons.water_drop_rounded,
                        label: l10n.irrigate,
                        isActive: false,
                        onTap: () {
                          ref
                              .read(simulationProvider.notifier)
                              .applyIrrigation();
                          close();
                        },
                      ),
                      _buildActionTile(
                        context: context,
                        icon: Icons.grass_rounded,
                        label: l10n.applyNitrogen,
                        isActive: false,
                        onTap: () {
                          ref
                              .read(simulationProvider.notifier)
                              .applyQuickNutrient('N');
                          close();
                        },
                      ),
                      _buildActionTile(
                        context: context,
                        icon: Icons.compost_rounded,
                        label: l10n.addOrganicMatter,
                        isActive: false,
                        onTap: () {
                          ref
                              .read(simulationProvider.notifier)
                              .applyOrganicMatter();
                          close();
                        },
                      ),
                      _buildActionTile(
                        context: context,
                        icon: Icons.water_damage_rounded,
                        label: l10n.drainSoil,
                        isActive: false,
                        onTap: () {
                          ref
                              .read(simulationProvider.notifier)
                              .applyDrainage();
                          close();
                        },
                      ),
                      _buildActionTile(
                        context: context,
                        icon: Icons.science_rounded,
                        label: l10n.fertilize,
                        isActive: false,
                        onTap: () {
                          close();
                          showDialog(
                            context: parentContext,
                            builder: (_) => const FertilizerModal(),
                          );
                        },
                      ),
                    ],
                    if (showEnvironment) ...[
                      const SizedBox(height: 8),
                      _sectionTitle(l10n.environmentSection, context),
                      _buildActionTile(
                        context: context,
                        icon: Icons.cloudy_snowing,
                        label: l10n.autoWeather,
                        isActive: autoWeather,
                        onTap: () {
                          // Apply the state the user saw, not the opposite of
                          // whatever the live engine holds behind the timeline.
                          ref
                              .read(simulationProvider.notifier)
                              .setAutoWeather(!autoWeather);
                          close();
                        },
                      ),
                      _buildActionTile(
                        context: context,
                        icon: precipitation > 0
                            ? Icons.water_drop_rounded
                            : Icons.water_drop_outlined,
                        label: l10n.rain,
                        isActive: precipitation > 0,
                        onTap: () {
                          ref
                              .read(simulationProvider.notifier)
                              .setPrecipitation(precipitation > 0 ? 0.0 : 10.0);
                          close();
                        },
                      ),
                      _buildActionTile(
                        context: context,
                        icon: Icons.wb_sunny_rounded,
                        label: l10n.heatWave,
                        isActive: false,
                        onTap: () {
                          ref
                              .read(simulationProvider.notifier)
                              .triggerHeatWave();
                          close();
                        },
                      ),
                      _buildActionTile(
                        context: context,
                        icon: Icons.flood_rounded,
                        label: l10n.flashFlood,
                        isActive: false,
                        onTap: () {
                          ref
                              .read(simulationProvider.notifier)
                              .triggerFlashFlood();
                          close();
                        },
                      ),
                    ],
                    if (showView) ...[
                      const SizedBox(height: 8),
                      _sectionTitle(l10n.viewSection, context),
                      _buildActionTile(
                        context: context,
                        icon: Icons.history_rounded,
                        label: l10n.eventLog,
                        isActive: false,
                        onTap: () {
                          close();
                          _showEventLog(parentContext, ref, l10n);
                        },
                      ),
                      _buildActionTile(
                        context: context,
                        icon: Icons.published_with_changes,
                        label: cycle == ObservationCycle.none
                            ? l10n.observation.toUpperCase()
                            : cycle.name.toUpperCase(),
                        isActive: cycle != ObservationCycle.none,
                        onTap: () {
                          final values = ObservationCycle.values;
                          final next =
                              (values.indexOf(cycle) + 1) % values.length;
                          ref
                              .read(activeCycleProvider.notifier)
                              .setCycle(values[next]);
                          close();
                        },
                      ),
                      _buildActionTile(
                        context: context,
                        icon: Icons.loop_rounded,
                        label: l10n.nitrogenCycleTitle,
                        isActive: cycle == ObservationCycle.nitrogen,
                        onTap: () {
                          ref
                              .read(activeCycleProvider.notifier)
                              .setCycle(ObservationCycle.nitrogen);
                          close();
                        },
                      ),
                      _buildActionTile(
                        context: context,
                        icon: flowOn
                            ? Icons.device_hub_rounded
                            : Icons.device_hub_outlined,
                        label: l10n.flows,
                        isActive: flowOn,
                        onTap: () {
                          ref
                              .read(particleFlowModeProvider.notifier)
                              .toggle();
                          close();
                        },
                      ),
                      _buildActionTile(
                        context: context,
                        icon: schematic
                            ? Icons.account_tree_rounded
                            : Icons.account_tree_outlined,
                        label: l10n.schematic.toUpperCase(),
                        isActive: schematic,
                        onTap: () {
                          ref
                              .read(visualLayoutModeStateProvider.notifier)
                              .toggle();
                          close();
                        },
                      ),
                    ],
                    if (showElements) ...[
                      const SizedBox(height: 8),
                      _sectionTitle(l10n.elementsSection, context),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ..._quickElements.map(
                            (symbol) => _buildElementButton(
                              context: context,
                              ref: ref,
                              symbol: symbol,
                              isSelected:
                                  session.selectedElementSymbol == symbol,
                              onChanged: close,
                            ),
                          ),
                          if (session.selectedElementSymbol != null &&
                              session.selectedElementSymbol!.isNotEmpty &&
                              !_quickElements
                                  .contains(session.selectedElementSymbol))
                            _buildElementButton(
                              context: context,
                              ref: ref,
                              symbol: session.selectedElementSymbol!,
                              isSelected: true,
                              onChanged: close,
                            ),
                          _buildPeriodicTableLauncher(
                            context,
                            l10n,
                            onOpen: () {
                              close();
                              ElementSelectionModal.show(parentContext);
                            },
                          ),
                        ],
                      ),
                    ],
                    if (showNavigate) ...[
                      const SizedBox(height: 8),
                      _sectionTitle(l10n.navigateSection, context),
                      _buildNavigationTile(
                        context: context,
                        parentContext: parentContext,
                        icon: Icons.menu_book_rounded,
                        label: l10n.scienceReference,
                        route: '/science_reference',
                      ),
                      _buildNavigationTile(
                        context: context,
                        parentContext: parentContext,
                        icon: Icons.science_outlined,
                        label: l10n.logicLab,
                        route: '/logic_lab',
                      ),
                      _buildNavigationTile(
                        context: context,
                        parentContext: parentContext,
                        icon: Icons.edit_rounded,
                        label: l10n.modify,
                        route: '/scenario_builder',
                      ),
                    ],
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryChips(
    BuildContext context,
    AppLocalizations l10n,
    _QuickActionCategory selected,
    ValueChanged<_QuickActionCategory> onSelected,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final category in _QuickActionCategory.values)
          ChoiceChip(
            label: Text(_categoryLabel(category, l10n)),
            selected: selected == category,
            onSelected: (_) => onSelected(category),
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }

  String _categoryLabel(
    _QuickActionCategory category,
    AppLocalizations l10n,
  ) {
    return switch (category) {
      _QuickActionCategory.all => l10n.allCategories,
      _QuickActionCategory.actions => l10n.quickActions,
      _QuickActionCategory.environment => l10n.environmentSection,
      _QuickActionCategory.view => l10n.viewSection,
      _QuickActionCategory.elements => l10n.elementsSection,
      _QuickActionCategory.navigate => l10n.navigateSection,
    };
  }

  Widget _sectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: isActive ? theme.colorScheme.primary : null,
      ),
      title: Text(label),
      trailing: isActive ? const Icon(Icons.check_rounded) : null,
      onTap: onTap,
    );
  }

  Widget _buildNavigationTile({
    required BuildContext context,
    required BuildContext parentContext,
    required IconData icon,
    required String label,
    required String route,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () {
        Navigator.of(context).pop();
        Navigator.pushNamed(parentContext, route);
      },
    );
  }

  Widget _buildElementButton({
    required BuildContext context,
    required WidgetRef ref,
    required String symbol,
    required bool isSelected,
    required VoidCallback onChanged,
  }) {
    final lang = Localizations.localeOf(context).languageCode;
    final element = PeriodicTable.getBySymbol(symbol);
    final color = element?.cpkColor ?? CPKStandards.getColor(symbol);
    final name = element?.localizedName(lang) ?? symbol;

    return Tooltip(
      message: name,
      child: Material(
        color: isSelected ? color : color.withValues(alpha: 0.25),
        shape: CircleBorder(
          side: isSelected
              ? const BorderSide(color: Colors.white, width: 2)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            final isCurrentlySelected =
                ref.read(simulationSessionProvider).selectedElementSymbol ==
                    symbol;
            final sessionNotifier =
                ref.read(simulationSessionProvider.notifier);
            final uiNotifier = ref.read(uIStateProvider.notifier);
            if (isCurrentlySelected) {
              sessionNotifier.selectElement(null);
              uiNotifier.setHoverInfo(null);
            } else {
              sessionNotifier.selectElement(symbol);
              if (element != null) {
                uiNotifier.setHoverInfo(
                  element.toHoverInfo(
                    lang,
                    l10n: AppLocalizations.of(context)!,
                    isPinned: true,
                  ),
                );
              }
            }
            onChanged();
          },
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: Text(
                symbol,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: (color.computeLuminance() > 0.5 && isSelected)
                      ? Colors.black
                      : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodicTableLauncher(
    BuildContext context,
    AppLocalizations l10n, {
    required VoidCallback onOpen,
  }) {
    return Tooltip(
      message: l10n.allElements,
      child: Material(
        color: Colors.white.withValues(alpha: 0.12),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onOpen,
          child: const SizedBox(
            width: 48,
            height: 48,
            child: Icon(
              Icons.grid_view_rounded,
              size: 20,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _showEventLog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final events = ref.read(eventLogProvider);
    // A ListView cannot provide an intrinsic width to AlertDialog. Give the
    // dialog content a concrete width so opening the log cannot break layout.
    final contentWidth =
        (MediaQuery.sizeOf(context).width - 80).clamp(280.0, 400.0).toDouble();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.eventLog),
        content: SizedBox(
          width: contentWidth,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.6,
            ),
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
