import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../domain/models/soil_layer.dart';
import '../analytics/analytics_value_card.dart';
import '../analytics/analytics_section_header.dart';
import '../analytics/analytics_health_bar.dart';

/// Detailed analytical view for a single soil layer.
/// Uses modular analytics components for a consistent UI.
class AnalysisView extends ConsumerWidget {
  final SoilLayer layer;
  final bool compact;
  const AnalysisView({super.key, required this.layer, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!compact) AnalyticsSectionHeader(title: l10n.physical),
        AnalyticsValueCard(
          label: l10n.waterContent,
          value: layer.waterContent,
          unit: 'm³/m³',
          compact: compact,
          formatter: (v) => v.toStringAsFixed(3),
        ),
        AnalyticsValueCard(
          label: l10n.temperature,
          value: layer.temperature - 273.15,
          unit: '°C',
          compact: compact,
          formatter: (v) => v.toStringAsFixed(1),
        ),
        AnalyticsValueCard(
          label: l10n.oxygenLabel,
          value: layer.oxygenContent,
          unit: l10n.unitMolM3,
          compact: compact,
          formatter: (v) => v.toStringAsFixed(2),
        ),

        if (!compact) AnalyticsSectionHeader(title: l10n.chemical),
        AnalyticsValueCard(
          label: l10n.phLevel,
          value: layer.ph,
          unit: '',
          compact: compact,
          formatter: (v) => v.toStringAsFixed(2),
          color: _getpHColor(layer.ph),
        ),
        AnalyticsValueCard(
          label: l10n.nitrate,
          value: layer.nitrateContent,
          unit: l10n.unitMgKg,
          compact: compact,
          formatter: (v) => v.toStringAsFixed(1),
        ),
        AnalyticsValueCard(
          label: l10n.ammonium,
          value: layer.ammoniumContent,
          unit: l10n.unitMgKg,
          compact: compact,
          formatter: (v) => v.toStringAsFixed(1),
        ),
        AnalyticsValueCard(
          label: l10n.organicN,
          value: layer.organicNitrogen,
          unit: l10n.unitMgKg,
          compact: compact,
          formatter: (v) => v.toStringAsFixed(1),
        ),

        AnalyticsValueCard(
          label: l10n.calciumTitle,
          value: layer.solutionCalcium,
          unit: l10n.unitMgKg,
          compact: compact,
          formatter: (v) => v.toStringAsFixed(1),
        ),
        AnalyticsValueCard(
          label: l10n.magnesiumTitle,
          value: layer.solutionMagnesium,
          unit: l10n.unitMgKg,
          compact: compact,
          formatter: (v) => v.toStringAsFixed(1),
        ),

        if (!compact) AnalyticsSectionHeader(title: l10n.carbonTitle),
        AnalyticsValueCard(
          label: l10n.labileC,
          value: layer.labileCarbon,
          unit: 'kg/m³',
          compact: compact,
          formatter: (v) => v.toStringAsFixed(1),
        ),
        AnalyticsValueCard(
          label: l10n.stableC,
          value: layer.stableCarbon,
          unit: 'kg/m³',
          compact: compact,
          formatter: (v) => v.toStringAsFixed(1),
        ),

        if (!compact) AnalyticsSectionHeader(title: l10n.biological),
        AnalyticsValueCard(
          label: l10n.microbialBiomass,
          value: layer.microbialBiomass,
          unit: 'kg/m³',
          compact: compact,
          formatter: (v) => v.toStringAsFixed(1),
        ),
        AnalyticsValueCard(
          label: l10n.fungalHyphae,
          value: layer.fungalHyphaeDensity * 100,
          unit: '%',
          compact: compact,
          formatter: (v) => v.toStringAsFixed(1),
        ),
        AnalyticsValueCard(
          label: l10n.bioGlue,
          value: layer.epsContent,
          unit: l10n.unitMgKg,
          compact: compact,
          formatter: (v) => v.toStringAsFixed(1),
        ),

        if (!compact) ...[
          const SizedBox(height: 24),
          AnalyticsHealthBar(
            label: l10n.structureHP,
            value: layer.aggregateStability,
            customValueLabel: l10n.stabilityLabel(
              (layer.aggregateStability * 100).toStringAsFixed(0),
            ),
          ),
        ],
      ],
    );
  }

  Color _getpHColor(double ph) {
    if (ph < 5.5) return Colors.red;
    if (ph < 6.0) return Colors.orange;
    if (ph > 7.5) return Colors.purple;
    if (ph > 7.0) return Colors.blue;
    return Colors.green;
  }
}
