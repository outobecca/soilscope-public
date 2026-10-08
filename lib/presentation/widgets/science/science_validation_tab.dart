import 'package:flutter/material.dart';
import '../../../domain/models/biophysical_state.dart';
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
              Icon(Icons.hourglass_empty, size: 48, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                l10n.gatheringData,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.minStepsForValidation,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    // Run validation against temperate grassland scenario
    final referenceData = ValidationScenarios.temperateGrassland();
    // Map reference data points (1-8) to simulation time elapsed
    final referenceTimes = List.generate(8, (i) => (i + 1) * (state.timeElapsed / 8.0));

    final comparison = ValidationFramework.compareToReference(
      state.history,
      referenceData,
      referenceTimes,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeader(theme, l10n),
        const SizedBox(height: 16),
        _buildOverallScore(comparison, theme, l10n),
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
        ...comparison.variableResults.entries.map((entry) => _buildVariableCard(entry.key, entry.value, theme, l10n)),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.verified, color: theme.colorScheme.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.scientificValidation,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  l10n.validationModelRef,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallScore(ValidationComparison comparison, ThemeData theme, AppLocalizations l10n) {
    final nse = comparison.overallNSE;
    final assessment = _getOverallAssessment(nse, l10n);
    final color = _getAssessmentColor(comparison.overallNSE);

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
              l10n.overallScore,
              style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Text(
              assessment.toUpperCase(),
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              'Nash-Sutcliffe Efficiency (NSE): ${nse.isNaN ? "N/A" : nse.toStringAsFixed(3)}',
              style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVariableCard(String variable, ValidationResult result, ThemeData theme, AppLocalizations l10n) {
    final color = _getAssessmentColorForResult(result.qualitativeAssessment);
    final localizedAssessment = _localizeAssessment(result.qualitativeAssessment, l10n);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ExpansionTile(
        title: Text(
          _translateVariable(variable, l10n),
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            localizedAssessment,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
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
                _buildMetricRow(l10n.rmseLabel, result.rmse.toStringAsFixed(4)),
                _buildMetricRow(l10n.maeLabel, result.mae.toStringAsFixed(4)),
                _buildMetricRow(l10n.r2Label, result.r2.toStringAsFixed(4)),
                _buildMetricRow(l10n.biasLabel, result.bias.toStringAsFixed(4)),
                _buildMetricRow(l10n.ioaLabel, result.indexOfAgreement.toStringAsFixed(4)),
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
          child: Text(value, style: const TextStyle(fontSize: 12, fontFamily: 'monospace'), textAlign: TextAlign.right),
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
