import 'package:flutter/material.dart';

import '../../../data/reference_dataset_repository.dart';
import '../../../domain/models/biophysical_state.dart';
import '../../../domain/models/reference_dataset.dart';
import '../../../domain/solvers/validation_framework.dart';
import '../../../l10n/app_localizations.dart';

class ScienceValidationTab extends StatelessWidget {
  final BiophysicalState state;

  const ScienceValidationTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (state.history.length < 5) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.hourglass_empty,
                size: 48,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.gatheringData,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.minStepsForValidation,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    return FutureBuilder<ReferenceDataset>(
      future: ReferenceDatasetRepository.loadDefault(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.validationReferenceUnavailable,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        final reference = snapshot.data;
        if (reference == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildContent(context, reference, theme, l10n);
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    ReferenceDataset reference,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    // Compare the full run at the reference sample times. Absolute measured
    // times are used as-is; synthetic patterns scale with the run. This is a
    // reference check, not a field-data validation.
    final runHistory = state.history;
    // The live clock can sit at the start after a pre-calculation while the
    // timeline extends forward. Use the history end as the run duration.
    final runEnd = runHistory.isNotEmpty
        ? runHistory.last.timeElapsed
        : state.timeElapsed;
    final referenceTimes = reference.timesFor(runEnd);
    final comparison = ValidationFramework.compareToReferenceSeries(
      runHistory,
      reference.series,
      referenceTimes,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeader(theme, l10n, reference),
        const SizedBox(height: 12),
        _buildProvenanceCard(theme, l10n, reference),
        if (comparison.uncoveredSeries.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildCoverageWarning(comparison, theme, l10n),
        ],
        const SizedBox(height: 12),
        _buildOverallScore(comparison, theme, l10n, reference),
        const SizedBox(height: 24),
        Text(
          l10n.variableSpecificResults,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        for (final profile in reference.series)
          if (comparison.variableResults[profile.key] case final result?)
            _buildVariableCard(
              profile,
              result,
              theme,
              l10n,
            ),
      ],
    );
  }

  Widget _buildHeader(
    ThemeData theme,
    AppLocalizations l10n,
    ReferenceDataset reference,
  ) {
    final isIllustrative = reference.isIllustrative;
    final badge = isIllustrative
        ? l10n.validationIllustrativeBadge
        : l10n.validationMeasuredBadge;
    final badgeColor =
        isIllustrative ? theme.colorScheme.tertiary : theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isIllustrative ? Icons.science_outlined : Icons.fact_check,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isIllustrative
                      ? l10n.illustrativePatternCheck
                      : l10n.scientificValidation,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: badgeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reference.source,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          Text(
            isIllustrative
                ? l10n.validationPatternDisclaimer
                : l10n.validationMeasuredDisclaimer,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isIllustrative
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: isIllustrative ? FontWeight.w600 : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProvenanceCard(
    ThemeData theme,
    AppLocalizations l10n,
    ReferenceDataset reference,
  ) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.validationReferenceProvenance,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            _provenanceRow(
              theme,
              l10n.validationReferenceSampling,
              reference.sampling,
            ),
            _provenanceRow(
              theme,
              l10n.validationReferenceGenerated,
              reference.generatedBy,
            ),
            _provenanceRow(
              theme,
              l10n.validationProvenanceNotes,
              reference.provenanceNotes,
            ),
            const SizedBox(height: 4),
            Text(
              '${l10n.validationGateLabel}: '
              '${reference.series.map((profile) => '${_translateVariable(profile.variable, l10n)} ${profile.layerLabel} NSE ≥ ${profile.threshold.nse} / RMSE ≤ ${profile.threshold.rmse}').join('; ')}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _provenanceRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.bodySmall,
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverageWarning(
    ValidationComparison comparison,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: theme.colorScheme.error),
              const SizedBox(width: 8),
              Text(
                l10n.validationCoverageTitle,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${l10n.validationCoverageGap} '
            '${comparison.uncoveredSeries.keys.join(', ')}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onErrorContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.validationCoverageHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallScore(
    ValidationComparison comparison,
    ThemeData theme,
    AppLocalizations l10n,
    ReferenceDataset reference,
  ) {
    final nse = comparison.overallNSE;
    final assessment = _getOverallAssessment(nse, l10n);
    final color = _getAssessmentColor(nse);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              reference.isIllustrative
                  ? l10n.patternAgreement
                  : l10n.overallScore,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              assessment.toUpperCase(),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Nash-Sutcliffe Efficiency (NSE): ${nse.isNaN ? "N/A" : nse.toStringAsFixed(3)}',
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontFamily: 'monospace'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVariableCard(
    ReferenceSeries profile,
    ValidationResult result,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final color = _getAssessmentColorForResult(result.qualitativeAssessment);
    final localizedAssessment = _localizeAssessment(
      result.qualitativeAssessment,
      l10n,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ExpansionTile(
        title: Text(
          '${_translateVariable(profile.variable, l10n)} · ${profile.layerLabel}',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${profile.unit} · gate NSE ≥ ${profile.threshold.nse}',
          style: theme.textTheme.bodySmall?.copyWith(
            fontFamily: 'monospace',
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            localizedAssessment,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
              },
              children: [
                _buildMetricRow(
                  'NSE (Nash–Sutcliffe Efficiency)',
                  result.nse.toStringAsFixed(4),
                ),
                _buildMetricRow(l10n.rmseLabel, result.rmse.toStringAsFixed(4)),
                _buildMetricRow(l10n.maeLabel, result.mae.toStringAsFixed(4)),
                _buildMetricRow(l10n.r2Label, result.r2.toStringAsFixed(4)),
                _buildMetricRow(l10n.biasLabel, result.bias.toStringAsFixed(4)),
                _buildMetricRow(
                  l10n.ioaLabel,
                  result.indexOfAgreement.toStringAsFixed(4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildMetricRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(label, style: const TextStyle(fontSize: 12)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  String _getOverallAssessment(double nse, AppLocalizations l10n) {
    if (nse.isNaN) return 'N/A';
    if (nse > 0.75) return l10n.assessmentExcellent;
    if (nse > 0.65) return l10n.assessmentGood;
    if (nse > 0.50) return l10n.assessmentSatisfactory;
    if (nse > 0.0) return l10n.assessmentAcceptable;
    return l10n.assessmentPoor;
  }

  String _localizeAssessment(String assessment, AppLocalizations l10n) {
    switch (assessment.toLowerCase()) {
      case 'excellent':
        return l10n.assessmentExcellent;
      case 'good':
        return l10n.assessmentGood;
      case 'satisfactory':
        return l10n.assessmentSatisfactory;
      case 'acceptable':
        return l10n.assessmentAcceptable;
      case 'poor':
        return l10n.assessmentPoor;
      default:
        return assessment;
    }
  }

  Color _getAssessmentColor(double nse) {
    if (nse.isNaN) return Colors.grey;
    if (nse > 0.75) return Colors.green;
    if (nse > 0.65) return Colors.lightGreen;
    if (nse > 0.50) return Colors.orange;
    if (nse > 0.0) return Colors.amber;
    return Colors.red;
  }

  Color _getAssessmentColorForResult(String assessment) {
    switch (assessment) {
      case 'Excellent':
        return Colors.green;
      case 'Good':
        return Colors.lightGreen;
      case 'Satisfactory':
        return Colors.orange;
      case 'Acceptable':
        return Colors.amber;
      default:
        return Colors.red;
    }
  }

  String _translateVariable(String variable, AppLocalizations l10n) {
    switch (variable) {
      case 'waterContent':
        return '${l10n.soilMoisture} (θ)';
      case 'temperature':
        return l10n.temperature;
      case 'lai':
        return '${l10n.laiLabel} (LAI)';
      case 'nitrateContent':
        return '${l10n.nitrate} (NO3)';
      case 'ammoniumContent':
        return '${l10n.ammonium} (NH4)';
      case 'microbialBiomass':
        return l10n.microbialBiomass;
      default:
        return variable;
    }
  }
}
