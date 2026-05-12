import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/biophysical_state.dart';
import '../../domain/models/soil_layer.dart';
import '../../domain/models/soil_profile.dart';
import '../providers/simulation_provider.dart';
import '../providers/simulation_session_provider.dart';
import 'analytics/analytics_health_bar.dart';
import 'controls/visual_key_widget.dart';
import 'controls/teaching_key_widget.dart';
import 'controls/informatics_view.dart';
import 'controls/analysis_view.dart';
import '../../core/biophysics_utils.dart';
import 'controls/micro_informatics_view.dart';

class HUDDashboard extends ConsumerWidget {
  const HUDDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    if (l10n == null) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HUDHeader(),
            const SizedBox(height: 16),
            const _HUDSustainabilityMetrics(),
            const _HUDScrubber(),
            Divider(color: theme.colorScheme.outlineVariant, height: 16),
            const _HUDIndices(),
            const _HUDSelectedLayerDetails(),
            Divider(color: theme.colorScheme.outlineVariant, height: 16),
            const _HUDPlantVitality(),
            const SizedBox(height: 8),
            const _HUDZoomIndicator(),
            const Divider(height: 16),
            ExpansionTile(
              title: Text(
                l10n.visualKey.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              dense: true,
              tilePadding: EdgeInsets.zero,
              children: const [
                VisualKeyWidget(),
                SizedBox(height: 8),
                TeachingKeyWidget(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HUDHeader extends ConsumerWidget {
  const _HUDHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isScrubbing = ref.watch(
      simulationSessionProvider.select((s) => s.isScrubbing),
    );

    return Row(
      children: [
        Icon(
          Icons.analytics_outlined,
          color: theme.colorScheme.primary,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            l10n.fieldMetrics.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.info_outline, size: 18),
          onPressed: () => _showInfoDialog(context, l10n),
          tooltip: l10n.index,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 8),
        if (isScrubbing)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange.shade800,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              l10n.historyMode.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  void _showInfoDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.index),
        content: const SizedBox(
          width: 500,
          height: 600,
          child: InformaticsView(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _HUDSustainabilityMetrics extends ConsumerWidget {
  const _HUDSustainabilityMetrics();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // Watch only the profile for metrics
    final profile = ref.watch(
      displayedSimulationStateProvider.select((s) => s.profile),
    );

    return Column(
      children: [
        AnalyticsHealthBar(
          label: l10n.soilStructure,
          value: _calculateStructureHP(profile),
          color: Colors.teal,
        ),
        const SizedBox(height: 12),
        AnalyticsHealthBar(
          label: l10n.bioActivity,
          value: _calculateBioScore(profile),
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        AnalyticsHealthBar(
          label: l10n.leachingRisk,
          value: _calculatePollutionMeter(profile),
          color: Colors.orange,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _HUDScrubber extends ConsumerWidget {
  const _HUDScrubber();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final historyEmpty = ref.watch(
      simulationProvider.select((s) => s.history.isEmpty),
    );
    if (historyEmpty) return const SizedBox.shrink();

    final isRunning = ref.watch(simulationProvider.select((s) => s.isRunning));
    final isScrubbing = ref.watch(
      simulationSessionProvider.select((s) => s.isScrubbing),
    );
    final viewTime = ref.watch(
      simulationSessionProvider.select((s) => s.viewTime),
    );
    final minTime = ref.watch(
      simulationProvider.select((s) => s.history.first.timeElapsed),
    );
    final maxTime = ref.watch(
      simulationProvider.select((s) => s.timeElapsed),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isScrubbing ? 'AIKAJANA (SIRTOLA)' : 'REAAALIAIKA',
              style: theme.textTheme.labelSmall?.copyWith(
                color: isScrubbing
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    isRunning ? Icons.pause : Icons.play_arrow,
                    size: 16,
                  ),
                  onPressed: () => isRunning
                      ? ref.read(simulationProvider.notifier).stop()
                      : ref.read(simulationProvider.notifier).start(),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    isScrubbing ? Icons.close : Icons.history,
                    size: 16,
                  ),
                  onPressed: () => isScrubbing
                      ? ref.read(simulationProvider.notifier).stopScrubbing()
                      : ref.read(simulationProvider.notifier).startScrubbing(),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ],
        ),
        if (isScrubbing)
          Slider(
            value: viewTime.clamp(minTime, maxTime),
            min: minTime,
            max: maxTime > minTime ? maxTime : minTime + 1.0,
            onChanged: (value) =>
                ref.read(simulationSessionProvider.notifier).scrubTo(value),
          ),
      ],
    );
  }
}

class _HUDIndices extends ConsumerWidget {
  const _HUDIndices();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(
      displayedSimulationStateProvider.select((s) => s.profile),
    );

    final topLayer = profile.layers.isNotEmpty ? profile.layers.first : null;
    if (topLayer == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          _buildIndexChip(
            icon: Icons.water_drop,
            label: 'θ',
            value: '${(topLayer.waterContent * 100).toStringAsFixed(1)}%',
            color: Colors.cyan,
            theme: theme,
          ),
          _buildIndexChip(
            icon: Icons.science,
            label: 'pH',
            value: topLayer.ph.toStringAsFixed(1),
            color: _getpHColor(topLayer.ph),
            theme: theme,
          ),
          _buildIndexChip(
            icon: Icons.bolt,
            label: 'N',
            value: topLayer.nitrateContent.toStringAsFixed(0),
            color: Colors.green,
            theme: theme,
          ),
          _buildIndexChip(
            icon: Icons.thermostat,
            label: 'T',
            value: '${(topLayer.temperature - 273.15).toStringAsFixed(1)}°C',
            color: Colors.orange,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildIndexChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            '$label: ',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            width: 52,
            child: Text(
              value,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                fontFamily: 'monospace',
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _HUDSelectedLayerDetails extends ConsumerWidget {
  const _HUDSelectedLayerDetails();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final selectedLayerId = ref.watch(
      simulationSessionProvider.select((s) => s.selectedLayerId),
    );

    if (selectedLayerId == null) return const SizedBox.shrink();

    final state = ref.watch(displayedSimulationStateProvider);

    return Column(
      children: [
        Divider(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          height: 16,
        ),
        if (selectedLayerId == "atmosphere")
          _buildAtmosphereAnalytics(state, theme, l10n)
        else
          _buildSelectedLayerAnalytics(
            state.profile,
            selectedLayerId,
            theme,
            l10n,
          ),
      ],
    );
  }

  Widget _buildAtmosphereAnalytics(
    BiophysicalState state,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.atmosphere.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  l10n.fieldDiagnostics.toUpperCase(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const Icon(Icons.cloud_outlined, size: 24, color: Colors.cyan),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.2,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildSimpleDiagnostic(
                  l10n.temperature,
                  '${(state.airTemperature - 273.15).toStringAsFixed(1)}°C',
                  Colors.orange,
                  theme,
                ),
              ),
              Expanded(
                child: _buildSimpleDiagnostic(
                  l10n.relativeHumidity,
                  '${(state.relativeHumidity * 100).toStringAsFixed(0)}%',
                  Colors.blue,
                  theme,
                ),
              ),
              Expanded(
                child: _buildSimpleDiagnostic(
                  'PRECIP',
                  state.precipitation.toStringAsFixed(1),
                  Colors.cyan,
                  theme,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedLayerAnalytics(
    SoilProfile profile,
    String layerId,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final layer = profile.layers.cast<SoilLayer?>().firstWhere(
      (l) => l?.id == layerId,
      orElse: () => null,
    );
    if (layer == null) return const SizedBox.shrink();

    final fluxColor = layer.verticalFlux > 0 ? Colors.blue : Colors.orange;
    final fluxIcon = layer.verticalFlux > 0
        ? Icons.arrow_downward
        : Icons.arrow_upward;

    final texture = BiophysicsUtils.getSoilTextureClass(
      layer.sandFraction,
      layer.siltFraction,
      layer.clayFraction,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10n.layerLabel.toUpperCase()} #${profile.layers.indexOf(layer) + 1} ${l10n.fieldDiagnostics.toUpperCase()}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${BiophysicsUtils.getLocalizedTextureName(texture, l10n)} / ${BiophysicsUtils.getLocalizedFinnishTextureName(BiophysicsUtils.getFinnishSoilTextureClass(layer.sandFraction, layer.siltFraction, layer.clayFraction), l10n)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                Icon(fluxIcon, size: 10, color: fluxColor),
                const SizedBox(width: 2),
                Text(
                  '${(layer.verticalFlux.abs() * 1000).toStringAsFixed(3)} mm/s',
                  style: TextStyle(
                    color: fluxColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ],
        ),
        ExpansionTile(
          title: Text(
            l10n.analytics,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          dense: true,
          childrenPadding: EdgeInsets.zero,
          tilePadding: EdgeInsets.zero,
          children: [
            AnalysisView(layer: layer, compact: true),
          ],
        ),
        ExpansionTile(
          title: Text(
            l10n.microbes,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          dense: true,
          childrenPadding: EdgeInsets.zero,
          tilePadding: EdgeInsets.zero,
          children: [
            MicroInformaticsView(layer: layer, compact: true),
          ],
        ),
        const SizedBox(height: 12),
        _buildDiagnosticGrid(layer, theme, l10n),
      ],
    );
  }

  Widget _buildDiagnosticGrid(
    SoilLayer layer,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final cnRatio = layer.cnRatio;
    final activity = layer.microbialActivity;
    final eh = layer.redoxPotential;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSimpleDiagnostic(
                  l10n.cnRatioLabel,
                  '${cnRatio.toStringAsFixed(0)}:1',
                  cnRatio > 25
                      ? Colors.orange
                      : (cnRatio < 10 ? Colors.cyan : Colors.green),
                  theme,
                ),
              ),
              Expanded(
                child: _buildSimpleDiagnostic(
                  l10n.redoxEh,
                  '${eh.toStringAsFixed(0)} mV',
                  _getEhColor(eh),
                  theme,
                ),
              ),
              Expanded(
                child: _buildSimpleDiagnostic(
                  l10n.bioActivity,
                  activity.toStringAsFixed(2),
                  activity > 5 ? Colors.green : Colors.orange,
                  theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildTeaStatus(eh, l10n, theme),
        ],
      ),
    );
  }
}

class _HUDPlantVitality extends ConsumerWidget {
  const _HUDPlantVitality();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final plant = ref.watch(
      displayedSimulationStateProvider.select((s) => s.plant),
    );
    final timeElapsed = ref.watch(
      displayedSimulationStateProvider.select((s) => s.timeElapsed),
    );

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.grass, size: 14, color: Colors.green.shade600),
                const SizedBox(width: 4),
                Text(
                  l10n.plantTitle.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              '${(plant.turgorPressure * 100).toStringAsFixed(1)}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: _buildSmallStat(
                Icons.height,
                '${(plant.height * 100).toStringAsFixed(1)} cm',
                theme,
              ),
            ),
            Flexible(
              child: _buildSmallStat(
                Icons.layers,
                'LAI: ${plant.lai.toStringAsFixed(2)}',
                theme,
              ),
            ),
            Flexible(
              child: _buildSmallStat(
                Icons.schedule,
                _formatTime(timeElapsed),
                theme,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HUDZoomIndicator extends ConsumerWidget {
  const _HUDZoomIndicator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final timeElapsed = ref.watch(
      displayedSimulationStateProvider.select((s) => s.timeElapsed),
    );
    final hours = (timeElapsed % 86400 / 3600).floor();
    final isDay = hours > 6 && hours < 18;
    final int day = (timeElapsed / 86400).floor() + 1;
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Icon(
          isDay ? Icons.wb_sunny : Icons.nightlight_round,
          size: 16,
          color: isDay ? Colors.orange : Colors.indigo,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            l10n.dayLabel(day).toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.zoom_in, size: 16, color: theme.colorScheme.primary),
      ],
    );
  }
}

// Helper Functions

Widget _buildSimpleDiagnostic(
  String label,
  String value,
  Color color,
  ThemeData theme,
) {
  return Column(
    children: [
      Text(
        label.toUpperCase(),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 2),
      SizedBox(
        width: 70,
        child: Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: 'monospace',
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    ],
  );
}

Widget _buildTeaStatus(double eh, AppLocalizations l10n, ThemeData theme) {
  String status = "AEROBIC";
  IconData icon = Icons.air;
  Color color = Colors.cyan;

  if (eh < -200) {
    status = "METHANOGENIC";
    icon = Icons.waves;
    color = Colors.orange;
  } else if (eh < -100) {
    status = "SULFATE RED.";
    icon = Icons.warning_amber;
    color = Colors.deepOrange;
  } else if (eh < 100) {
    status = "IRON RED.";
    icon = Icons.opacity;
    color = Colors.brown;
  } else if (eh < 250) {
    status = "DENITRIFYING";
    icon = Icons.science;
    color = Colors.purple;
  }

  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, size: 10, color: color),
      const SizedBox(width: 4),
      Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 1.1,
        ),
      ),
    ],
  );
}

Color _getEhColor(double eh) {
  if (eh > 300) return Colors.cyan;
  if (eh > 100) return Colors.green;
  if (eh > -100) return Colors.orange;
  return Colors.red;
}

Widget _buildSmallStat(IconData icon, String value, ThemeData theme) {
  return FittedBox(
    fit: BoxFit.scaleDown,
    child: Row(
      children: [
        Icon(icon, size: 10, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 2),
        Text(
          value,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontSize: 9,
            fontFamily: 'monospace',
          ),
        ),
      ],
    ),
  );
}

String _formatTime(double seconds) {
  if (seconds.isNaN) return '00:00';
  final int totalMinutes = (seconds / 60).floor();
  final int hours = ((totalMinutes % 1440) / 60).floor();
  final int minutes = totalMinutes % 60;
  return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
}

double _calculateStructureHP(SoilProfile profile) {
  if (profile.layers.isEmpty) return 0.0;
  return profile.layers.fold(0.0, (sum, l) => sum + l.aggregateStability) /
      profile.layers.length;
}

double _calculateBioScore(SoilProfile profile) {
  if (profile.layers.isEmpty) return 0.0;
  final avgBiomass =
      profile.layers.fold(0.0, (sum, l) => sum + l.microbialBiomass) /
      profile.layers.length;
  final avgEh =
      profile.layers.fold(0.0, (sum, l) => sum + l.redoxPotential) /
      profile.layers.length;
  return ((avgBiomass / 500.0).clamp(0.0, 1.0) * 0.6 +
      ((avgEh + 200) / 800).clamp(0.0, 1.0) * 0.4);
}

double _calculatePollutionMeter(SoilProfile profile) {
  if (profile.layers.isEmpty) return 0.0;
  final bottomLayer = profile.layers.last;
  return (bottomLayer.nitrateContent /
          50.0 *
          (bottomLayer.waterContent / bottomLayer.porosity).clamp(0.0, 1.0))
      .clamp(0.0, 1.0);
}

Color _getpHColor(double ph) {
  if (ph < 5.0) return Colors.red;
  if (ph < 6.0) return Colors.orange;
  if (ph < 7.5) return Colors.green;
  if (ph < 8.5) return Colors.blue;
  return Colors.purple;
}
