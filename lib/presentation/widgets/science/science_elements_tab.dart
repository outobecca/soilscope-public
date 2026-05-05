import 'package:flutter/material.dart';
import '../../../../core/periodic_table.dart';
import '../../../l10n/app_localizations.dart';
import '../controls/periodic_table_widget.dart';

class ScienceElementsTab extends StatefulWidget {
  const ScienceElementsTab({super.key});

  @override
  State<ScienceElementsTab> createState() => _ScienceElementsTabState();
}

class _ScienceElementsTabState extends State<ScienceElementsTab> {
  ElementInfo? _selectedElement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: PeriodicTableWidget(
            selectedElement: _selectedElement,
            onSelect: (el) => setState(() => _selectedElement = el),
          ),
        ),
        _buildElementDetailPanel(theme, l10n),
      ],
    );
  }

  Widget _buildElementDetailPanel(ThemeData theme, AppLocalizations l10n) {
    if (_selectedElement == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        child: Center(
          child: Text(
            l10n.selectElementRole,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final el = _selectedElement!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  el.symbol,
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: el.cpkColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: el.cpkColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: el.cpkColor.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      el.typicalCharge > 0
                          ? '+'
                          : (el.typicalCharge < 0 ? '-' : ''),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Text(el.name, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            _buildInfoChip(l10n.atomicNumber, el.atomicNumber.toString(), theme),
            _buildInfoChip(
              l10n.cpkColor,
              '#${el.cpkColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
              theme,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.biologicalRole,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(el.soilRole, style: theme.textTheme.bodyMedium),
          ],
        ),
    );
  }

  Widget _buildInfoChip(String label, String value, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $value',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
