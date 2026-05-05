import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/simulation_provider.dart';
import '../providers/simulation_session_provider.dart';
import '../providers/event_log_provider.dart';
import '../../core/cpk_standards.dart';
import 'controls/fertilizer_modal.dart';

class SimulationActions extends ConsumerWidget {
  const SimulationActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isRunning = ref.watch(simulationProvider.select((s) => s.isRunning));
    final session = ref.watch(simulationSessionProvider);
    final timeScale = ref.watch(simulationProvider.select((s) => s.timeScale));
    final hasCoverCrop = ref.watch(
      simulationProvider.select((s) => s.hasCoverCrop),
    );
    final autoWeatherEnabled = ref.watch(
      simulationProvider.select((s) => s.autoWeather),
    );

    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.tune, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                l10n.quickActions.toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 6,
            runSpacing: 8,
            alignment: WrapAlignment.start,
            children: [
              _ActionIcon(
                icon: isRunning ? Icons.pause : Icons.play_arrow,
                label: isRunning ? l10n.pause : l10n.play,
                isActive: isRunning,
                onPressed: () {
                  final notifier = ref.read(simulationProvider.notifier);
                  if (isRunning) {
                    notifier.stop();
                  } else {
                    notifier.start();
                  }
                },
              ),
              _ActionIcon(
                icon: Icons.speed,
                label: l10n.speed(
                  timeScale.toStringAsFixed(timeScale < 1 ? 1 : 0),
                ),
                onPressed: () {
                  final speeds = [0.5, 1.0, 2.0, 5.0, 10.0];
                  final currentIndex = speeds.indexOf(timeScale);
                  final nextIndex = (currentIndex + 1) % speeds.length;
                  final nextSpeed = speeds[nextIndex];
                  ref.read(simulationProvider.notifier).setSpeed(nextSpeed);
                },
              ),
              _ActionIcon(
                icon: Icons.cloudy_snowing,
                label: l10n.autoWeather.split(' ').first,
                isActive: autoWeatherEnabled,
                onPressed: () {
                  ref.read(simulationProvider.notifier).toggleAutoWeather();
                },
              ),
              _ActionIcon(
                icon: Icons.agriculture,
                label: l10n.tillage,
                onPressed: () {
                  final success = ref
                      .read(simulationProvider.notifier)
                      .applyTillage();
                  _showSnack(
                    context,
                    success ? l10n.tillageSuccess : l10n.tillageFailure,
                  );
                },
              ),
              _ActionIcon(
                icon: Icons.eco,
                label: l10n.coverCrop.split(' ').first,
                isActive: hasCoverCrop,
                onPressed: () {
                  if (!hasCoverCrop) {
                    ref.read(simulationProvider.notifier).applyCoverCrop();
                  }
                },
              ),
              _ActionIcon(
                icon: Icons.science,
                label: l10n.fertilize,
                onPressed: () => _showFertilizerModal(context),
              ),
              _ActionIcon(
                icon: Icons.history,
                label: l10n.eventLog.split(' ').last,
                onPressed: () => _showEventLog(context, ref, l10n),
              ),
              _ActionIcon(
                icon: session.isMicroscopeEnabled
                    ? Icons.biotech
                    : Icons.biotech_outlined,
                label: l10n.microscope.split(' ').first,
                isActive: session.isMicroscopeEnabled,
                onPressed: () => ref.read(simulationSessionProvider.notifier).toggleMicroscope(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),
          _ElementToolbar(),
          if (session.isMicroscopeEnabled) ...[
            const SizedBox(height: 8),
            _MicroscopeToolbar(),
          ],
        ],
      ),
    ),);
  }

  void _showEventLog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final events = ref.watch(eventLogProvider);
          return AlertDialog(
            title: Text(l10n.eventLog),
            content: SizedBox(
              width: 400,
              height: 500,
              child: events.isEmpty
                  ? Center(child: Text(l10n.noEvents))
                  : ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (context, index) => ListTile(
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
                child: Text(l10n.cancelAction),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showFertilizerModal(BuildContext context) {
    showDialog(context: context, builder: (context) => const FertilizerModal());
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isActive;

  const _ActionIcon({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isActive
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    return SizedBox(
      width: 64,
      child: Column(
        children: [
          IconButton.filledTonal(
            onPressed: onPressed,
            icon: Icon(icon, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: isActive
                  ? theme.colorScheme.primaryContainer
                  : null,
              foregroundColor: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 9,
              color: color,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class ActionBar extends SimulationActions {
  const ActionBar({super.key});
}

class _ElementToolbar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            "VISUALIZED ELEMENTS",
            style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _ElementButton(symbol: 'N', color: CPKStandards.colorN, label: "Nitrogen"),
              _ElementButton(symbol: 'C', color: CPKStandards.colorC, label: "Carbon"),
              _ElementButton(symbol: 'H', color: CPKStandards.colorH, label: "Hydrogen"),
              _ElementButton(symbol: 'O', color: CPKStandards.colorO, label: "Oxygen"),
              _ElementButton(symbol: 'P', color: CPKStandards.colorP, label: "Phos."),
              _ElementButton(symbol: 'S', color: CPKStandards.colorS, label: "Sulfur"),
            ],
          ),
        ),
      ],
    );
  }
}

class _ElementButton extends ConsumerWidget {
  final String symbol;
  final Color color;
  final String label;

  const _ElementButton({required this.symbol, required this.color, required this.label});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(simulationSessionProvider.select((s) => s.selectedElementSymbol));
    final isActive = selected == symbol;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () {
          final notifier = ref.read(simulationSessionProvider.notifier);
          if (isActive) {
            notifier.selectElement("");
          } else {
            notifier.selectElement(symbol);
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 50,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? color.withValues(alpha: 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? color : theme.colorScheme.outlineVariant,
              width: isActive ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: isActive ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 4)] : null,
                ),
                child: Center(
                  child: Text(
                    symbol,
                    style: TextStyle(
                      color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(fontSize: 9),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MicroscopeToolbar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            "MICROSCOPE HOTSPOTS",
            style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.tertiary, fontWeight: FontWeight.bold),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _HotspotButton(type: 'leaf', icon: Icons.eco, label: "Leaf"),
              _HotspotButton(type: 'stem', icon: Icons.straighten, label: "Stem"),
              _HotspotButton(type: 'root', icon: Icons.account_tree, label: "Root"),
              _HotspotButton(type: 'rhizosphere', icon: Icons.grain, label: "Rhizo."),
              _HotspotButton(type: 'microbe', icon: Icons.bug_report, label: "Microbe"),
              _HotspotButton(type: 'soilStructure', icon: Icons.layers, label: "Soil Struct."),
            ],
          ),
        ),
      ],
    );
  }
}

class _HotspotButton extends ConsumerWidget {
  final String type;
  final IconData icon;
  final String label;

  const _HotspotButton({required this.type, required this.icon, required this.label});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(simulationSessionProvider.select((s) => s.selectedInspectorType));
    final isActive = selected == type;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: _ActionIcon(
        icon: icon,
        label: label,
        isActive: isActive,
        onPressed: () {
          final notifier = ref.read(simulationSessionProvider.notifier);
          if (isActive) {
            notifier.selectInspector(null);
          } else {
            notifier.selectInspector(type);
          }
        },
      ),
    );
  }
}
