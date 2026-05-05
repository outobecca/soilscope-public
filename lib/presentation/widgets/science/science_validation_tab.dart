import 'package:flutter/material.dart';
import '../../../domain/models/biophysical_state.dart';
import '../../../domain/solvers/validation_framework.dart';

class ScienceValidationTab extends StatelessWidget {
  final BiophysicalState state;

  const ScienceValidationTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                'Kerätään tietoja...',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Anna simulaation pyöriä vähintään 5 askelta nähdäksesi tieteellisen validoinnin.',
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
        _buildHeader(theme),
        const SizedBox(height: 16),
        _buildOverallScore(comparison, theme),
        const SizedBox(height: 24),
        Text(
          'MUUTTUJAKOHTAISET TULOKSET',
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        ...comparison.variableResults.entries.map((entry) => _buildVariableCard(entry.key, entry.value, theme)),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme) {
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
                  'Tieteellinen validointi',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Malli verrattuna FLUXNET/LUCAS -referenssidataan.',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallScore(ValidationComparison comparison, ThemeData theme) {
    final nse = comparison.overallNSE;
    final assessment = _getOverallAssessment(nse);
    final color = _getAssessmentColor(assessment);

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
              'YLEISARVOSANA',
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

  Widget _buildVariableCard(String variable, ValidationResult result, ThemeData theme) {
    final color = _getAssessmentColor(result.qualitativeAssessment);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ExpansionTile(
        title: Text(
          _translateVariable(variable),
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            result.qualitativeAssessment,
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
                _buildMetricRow('RMSE (Keskivirhe)', result.rmse.toStringAsFixed(4)),
                _buildMetricRow('MAE (Absoluuttinen virhe)', result.mae.toStringAsFixed(4)),
                _buildMetricRow('R² (Selitysaste)', result.r2.toStringAsFixed(4)),
                _buildMetricRow('Bias (Harha)', result.bias.toStringAsFixed(4)),
                _buildMetricRow('Index of Agreement (d)', result.indexOfAgreement.toStringAsFixed(4)),
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

  String _getOverallAssessment(double nse) {
    if (nse.isNaN) return 'N/A';
    if (nse > 0.75) return 'Excellent';
    if (nse > 0.65) return 'Good';
    if (nse > 0.50) return 'Satisfactory';
    if (nse > 0.0) return 'Acceptable';
    return 'Poor';
  }

  Color _getAssessmentColor(String assessment) {
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

  String _translateVariable(String variable) {
    switch (variable) {
      case 'waterContent':
        return 'Vesipitoisuus (θ)';
      case 'temperature':
        return 'Maan lämpötila';
      case 'lai':
        return 'Lehtialaindeksi (LAI)';
      case 'nitrateContent':
        return 'Nitraatti (NO3)';
      case 'ammoniumContent':
        return 'Ammonium (NH4)';
      case 'microbialBiomass':
        return 'Mikrobimassa';
      default:
        return variable;
    }
  }
}
