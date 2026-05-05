import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/simulation_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../domain/models/soil_layer.dart';
import 'micro_informatics_view.dart';
import 'analysis_view.dart';

class LogicLabView extends ConsumerStatefulWidget {
  final SoilLayer layer;
  const LogicLabView({super.key, required this.layer});

  @override
  ConsumerState<LogicLabView> createState() => _LogicLabViewState();
}

class _LogicLabViewState extends ConsumerState<LogicLabView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final layer = widget.layer;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(l10n.analytics.toUpperCase(), theme),
        AnalysisView(layer: layer, compact: true),
        const SizedBox(height: 24),
        _buildSectionHeader(l10n.microbes.toUpperCase(), theme),
        MicroInformaticsView(layer: layer, compact: true),
        const SizedBox(height: 24),
        _buildSectionHeader(l10n.physicsOverride.toUpperCase(), theme),
        _buildParamSlider(
          'kSat',
          layer.kSat,
          1.0e-7,
          1.0e-3,
          layer.id,
          'm/s (log)',
          theme,
          isLog: true,
        ),
        _buildParamSlider(
          'vgAlpha',
          layer.vgAlpha,
          0.1,
          15.0,
          layer.id,
          '1/m',
          theme,
        ),
        _buildParamSlider('vgN', layer.vgN, 1.1, 3.0, layer.id, '', theme),
        const SizedBox(height: 16),
        _buildSectionHeader(l10n.constituents.toUpperCase(), theme),
        _buildParamSlider(
          l10n.sand,
          layer.sandFraction,
          0.0,
          1.0,
          layer.id,
          '',
          theme,
        ),
        _buildParamSlider(
          l10n.silt,
          layer.siltFraction,
          0.0,
          1.0,
          layer.id,
          '',
          theme,
        ),
        _buildParamSlider(
          l10n.clay,
          layer.clayFraction,
          0.0,
          1.0,
          layer.id,
          '',
          theme,
        ),
        _buildParamSlider(
          l10n.organicCarbon,
          layer.organicCarbon,
          0.0,
          0.1,
          layer.id,
          '',
          theme,
        ),
        const SizedBox(height: 16),
        _buildSectionHeader(l10n.mechanical.toUpperCase(), theme),
        _buildParamSlider(
          l10n.bulkDensity,
          layer.bulkDensity,
          800,
          2000,
          layer.id,
          'kg/m³',
          theme,
        ),
        _buildParamSlider(
          l10n.porosity,
          layer.porosity,
          0.3,
          0.7,
          layer.id,
          'm³/m³',
          theme,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(
        title,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildParamSlider(
    String param,
    double value,
    double min,
    double max,
    String layerId,
    String unit,
    ThemeData theme, {
    bool isLog = false,
  }) {
    final displayValue = isLog ? math.log(value) / math.ln10 : value;
    final displayMin = isLog ? math.log(min) / math.ln10 : min;
    final displayMax = isLog ? math.log(max) / math.ln10 : max;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              param,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              '${isLog ? value.toStringAsExponential(1) : value.toStringAsFixed(3)} $unit',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: theme.sliderTheme.copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: Slider(
            value: displayValue.clamp(displayMin, displayMax),
            min: displayMin,
            max: displayMax,
            activeColor: theme.colorScheme.primary,
            inactiveColor: theme.colorScheme.surfaceContainerHighest,
            onChanged: (v) {
              final newValue = isLog ? math.pow(10, v).toDouble() : v;
              ref
                  .read(simulationProvider.notifier)
                  .updateLayerParameter(layerId, param, newValue);
            },
          ),
        ),
      ],
    );
  }
}
