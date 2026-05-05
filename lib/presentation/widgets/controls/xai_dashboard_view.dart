import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../domain/models/soil_layer.dart';

class XAIDashboardView extends StatelessWidget {
  final SoilLayer layer;
  const XAIDashboardView({super.key, required this.layer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(l10n.causalPathways.toUpperCase(), theme),
        _buildPathwayItem(
          l10n.oxygenRedoxEh,
          l10n.hypoxiaDesc,
          [
            'O₂: ${layer.oxygenContent.toStringAsFixed(2)}',
            'Eh: ${layer.redoxPotential.toStringAsFixed(0)} mV',
          ],
          'Eh = -200 + (O₂ / 8.5) * 800',
          theme,
        ),
        const SizedBox(height: 16),
        _buildPathwayItem(
          l10n.ehDenitrification,
          l10n.denitLowRedoxDesc,
          ['Eh < 250 mV', 'NO₃: ${layer.nitrateContent.toStringAsFixed(1)}'],
          'f(Eh) = exp(-0.01 * (Eh - 250))',
          theme,
        ),
        const SizedBox(height: 16),
        _buildPathwayItem(
          l10n.phPLock,
          l10n.pFixationDesc,
          [
            'pH: ${layer.ph.toStringAsFixed(2)}',
            'P-Sol: ${layer.phosphateContent.toStringAsFixed(1)}',
          ],
          'kLP = 0.1 * (1 + (pH - 6.5)² * 2)',
          theme,
        ),

        const SizedBox(height: 24),
        _buildSectionHeader(l10n.activeFormulas.toUpperCase(), theme),
        _buildFormulaCard(
          l10n.vanGenuchtenTitle,
          'θ(ψ) = θr + (θs - θr) [1 + (α|ψ|)^n]^-m',
          l10n.vanGenuchtenDesc,
          theme,
        ),
        const SizedBox(height: 12),
        _buildFormulaCard(
          l10n.millingtonQuirkTitle,
          'De = D0 * (ε^2 / φ^(2/3))',
          l10n.millingtonQuirkDesc,
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
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildPathwayItem(
    String title,
    String desc,
    List<String> inputs,
    String formula,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: inputs
                .map(
                  (input) => Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      input,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              formula,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.secondary,
                fontFamily: 'monospace',
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulaCard(
    String title,
    String formula,
    String desc,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Text(
            formula,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontFamily: 'monospace',
            ),
          ),
        ),
        Text(
          desc,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
