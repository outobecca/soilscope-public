import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../providers/simulation_provider.dart';
import '../../providers/ui_state_provider.dart';
import '../../../../core/nitrogen_forms.dart';
import '../../../../domain/models/soil_layer.dart';

/// Aggregate of the nitrogen pools across the whole profile.
///
/// The explainer shows totals so the values stay readable while the student
/// pans across layers; tapping individual particles still reveals the
/// layer-level detail.
class NitrogenPoolTotals {
  const NitrogenPoolTotals({
    required this.organic,
    required this.ammonium,
    required this.nitrate,
    required this.nitrousOxide,
  });

  final double organic;
  final double ammonium;
  final double nitrate;
  final double nitrousOxide;

  factory NitrogenPoolTotals.fromLayers(List<SoilLayer> layers) {
    var organic = 0.0;
    var ammonium = 0.0;
    var nitrate = 0.0;
    var nitrousOxide = 0.0;
    for (final layer in layers) {
      organic +=
          layer.organicNitrogen +
          layer.maomNitrogen +
          layer.microbialNitrogen;
      ammonium += layer.ammoniumContent;
      nitrate += layer.nitrateContent;
      nitrousOxide += layer.nitrousOxideContent;
    }
    return NitrogenPoolTotals(
      organic: organic,
      ammonium: ammonium,
      nitrate: nitrate,
      nitrousOxide: nitrousOxide,
    );
  }
}

/// Positions [NitrogenCycleExplainer] inside the canvas.
///
/// The card is clamped to the space left between [topInset] and
/// [bottomReserve], so it cannot run off screen on a narrow phone or a short
/// window. A minimum height keeps the panel reachable on very short surfaces
/// by reducing the preferred top inset instead of letting the card vanish.
class NitrogenCycleOverlay extends ConsumerWidget {
  const NitrogenCycleOverlay({
    super.key,
    required this.topInset,
    required this.bottomReserve,
    this.maxWidth = 330,
    this.maxHeight = 620,
  });

  final double topInset;
  final double bottomReserve;
  final double maxWidth;
  final double maxHeight;

  static const double _horizontalMargin = 12;
  static const double _minCardHeight = 160;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeCycleProvider) == ObservationCycle.nitrogen;
    if (!active) return const SizedBox.shrink();

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final top = math.min(
            topInset,
            math.max(
              0.0,
              constraints.maxHeight - bottomReserve - _minCardHeight,
            ),
          );
          final availableWidth =
              constraints.maxWidth - _horizontalMargin * 2;
          final availableHeight =
              constraints.maxHeight - top - bottomReserve;
          if (availableWidth <= 0 || availableHeight <= 0) {
            return const SizedBox.shrink();
          }

          final width = math.min(maxWidth, availableWidth);
          final height = math.min(maxHeight, availableHeight);
          return Stack(
            children: [
              Positioned(
                left: _horizontalMargin,
                top: top,
                width: width,
                height: height,
                child: NitrogenCycleExplainer(
                  maxWidth: width,
                  maxHeight: height,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Explains the nitrogen cycle while the nitrogen observation layer is
/// active.
///
/// Each form carries the same colour that its particles use on the canvas, so
/// the card doubles as the legend for the highlight.
class NitrogenCycleExplainer extends ConsumerWidget {
  const NitrogenCycleExplainer({
    super.key,
    this.maxWidth = 320,
    this.maxHeight = 560,
  });

  final double maxWidth;
  final double maxHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cycle = ref.watch(activeCycleProvider);
    if (cycle != ObservationCycle.nitrogen) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final layers = ref.watch(
      displayedSimulationStateProvider.select((s) => s.profile.layers),
    );
    final pools = NitrogenPoolTotals.fromLayers(layers);

    return Semantics(
      container: true,
      label: l10n.nitrogenCycleTitle,
      child: Container(
        key: const ValueKey('nitrogen-cycle-card'),
        width: maxWidth,
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: NitrogenForm.nitrate.color.withValues(alpha: 0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(ref, l10n, theme),
                const SizedBox(height: 8),
                _buildHint(l10n, theme),
                const SizedBox(height: 12),
                Text(
                  l10n.nitrogenLivePools,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                _buildStep(
                  theme: theme,
                  form: NitrogenForm.organic,
                  name: l10n.nitrogenFormOrganic,
                  description: l10n.nitrogenFormOrganicDesc,
                  value: pools.organic,
                  unit: l10n.nitrogenUnitMass,
                ),
                _Connector(
                  theme: theme,
                  label: l10n.nitrogenProcessMineralization,
                  description: l10n.nitrogenProcessMineralizationDesc,
                ),
                _buildStep(
                  theme: theme,
                  form: NitrogenForm.ammonium,
                  name: l10n.nitrogenFormAmmonium,
                  description: l10n.nitrogenFormAmmoniumDesc,
                  value: pools.ammonium,
                  unit: l10n.nitrogenUnitMass,
                ),
                _Connector(
                  theme: theme,
                  label: l10n.nitrogenProcessNitrification,
                  description: l10n.nitrogenProcessNitrificationDesc,
                ),
                _buildStep(
                  theme: theme,
                  form: NitrogenForm.nitrate,
                  name: l10n.nitrogenFormNitrate,
                  description: l10n.nitrogenFormNitrateDesc,
                  value: pools.nitrate,
                  unit: l10n.nitrogenUnitMass,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 18, top: 6, bottom: 2),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _flowChip(
                        theme,
                        Icons.eco_rounded,
                        l10n.nitrogenProcessUptake,
                        const Color(0xFF34D399),
                      ),
                      _flowChip(
                        theme,
                        Icons.water_drop_rounded,
                        l10n.nitrogenProcessLeaching,
                        const Color(0xFF22D3EE),
                      ),
                    ],
                  ),
                ),
                _Connector(
                  theme: theme,
                  label: l10n.nitrogenProcessDenitrification,
                  description: l10n.nitrogenProcessDenitrificationDesc,
                ),
                _buildStep(
                  theme: theme,
                  form: NitrogenForm.nitrousOxide,
                  name: l10n.nitrogenFormGas,
                  description: l10n.nitrogenFormGasDesc,
                  value: pools.nitrousOxide,
                  unit: l10n.nitrogenUnitGas,
                ),
                _buildFixationInput(l10n, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    WidgetRef ref,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final accent = NitrogenForm.nitrate.color;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent.withValues(alpha: 0.16),
            border: Border.all(color: accent.withValues(alpha: 0.55)),
          ),
          child: Center(
            child: Text(
              'N',
              style: TextStyle(
                color: accent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.nitrogenCycleTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l10n.nitrogenCycleSubtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  height: 1.25,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close_rounded, size: 18),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          tooltip: l10n.closeAction,
          onPressed: () => ref
              .read(activeCycleProvider.notifier)
              .setCycle(ObservationCycle.none),
        ),
      ],
    );
  }

  Widget _buildHint(AppLocalizations l10n, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.touch_app_rounded,
          size: 13,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            l10n.nitrogenCycleHint,
            style: theme.textTheme.bodySmall?.copyWith(
              height: 1.25,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep({
    required ThemeData theme,
    required NitrogenForm form,
    required String name,
    required String description,
    required double value,
    required String unit,
  }) {
    final color = form.color;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          key: ValueKey('nitrogen-form-dot-${form.name}'),
          margin: const EdgeInsets.only(top: 4),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.55),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    form.formula,
                    key: ValueKey('nitrogen-form-label-${form.name}'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    value.toStringAsFixed(1),
                    key: ValueKey('nitrogen-total-${form.name}'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    unit,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  height: 1.3,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _flowChip(
    ThemeData theme,
    IconData icon,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFixationInput(AppLocalizations l10n, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.air_rounded,
            size: 15,
            color: NitrogenForm.ammonium.color,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${l10n.nitrogenProcessFixation} · ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: l10n.nitrogenProcessFixationDesc,
                    style: theme.textTheme.bodySmall?.copyWith(
                      height: 1.3,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
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

/// A labelled arrow between two forms in the pathway.
class _Connector extends StatelessWidget {
  const _Connector({
    required this.theme,
    required this.label,
    required this.description,
  });

  final ThemeData theme;
  final String label;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 3, top: 6, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.south_rounded,
            size: 14,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$label · ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  TextSpan(
                    text: description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      height: 1.3,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
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
