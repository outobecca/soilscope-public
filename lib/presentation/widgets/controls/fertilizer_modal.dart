import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/periodic_table.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/simulation_provider.dart';
import '../../providers/game_provider.dart';
import 'periodic_table_widget.dart';

class FertilizerModal extends ConsumerStatefulWidget {
  const FertilizerModal({super.key});

  @override
  ConsumerState<FertilizerModal> createState() => _FertilizerModalState();
}

class _FertilizerModalState extends ConsumerState<FertilizerModal> {
  final Map<String, double> _pendingNutrients = {};

  void _toggleElement(ElementInfo element) {
    setState(() {
      if (_pendingNutrients.containsKey(element.symbol)) {
        _pendingNutrients.remove(element.symbol);
      } else {
        _pendingNutrients[element.symbol] = 20.0; // Default amount
      }
    });
  }

  void _updateAmount(String symbol, double amount) {
    setState(() {
      _pendingNutrients[symbol] = amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.nutrientApplicationConsole),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: FilledButton.icon(
                onPressed: _pendingNutrients.isEmpty
                    ? null
                    : () {
                        ref
                            .read(simulationProvider.notifier)
                            .applyNutrients(_pendingNutrients);

                        // Trigger visual effect
                        final game = ref.read(soilScopeGameProviderProvider);
                        if (game != null) {
                          final Map<String, Color> colors = {};
                          for (final symbol in _pendingNutrients.keys) {
                            colors[symbol] =
                                PeriodicTable.elements[symbol]?.color ??
                                Colors.white;
                          }
                          game.triggerFertilizerEffect(colors);
                        }

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n.nutrientsAppliedSnackBar(
                                _pendingNutrients.length,
                              ),
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                icon: const Icon(Icons.check),
                label: Text(l10n.applyAll.toUpperCase()),
              ),
            ),
          ],
        ),
        body: Row(
          children: [
            // Left side: Periodic Table
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      l10n.selectNutrients.toUpperCase(),
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.fertilizationMixHint,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 32),
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: PeriodicTableWidget(
                            onSelect: _toggleElement,
                            selectedSymbols: _pendingNutrients.keys.toSet(),
                            preferredCellSize: 50,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Right side: Sliders for selected nutrients
            Container(
              width: 400,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                border: Border(
                  left: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
              ),
              child: _pendingNutrients.isEmpty
                  ? _buildEmptyState(theme, l10n)
                  : _buildNutrientList(theme, l10n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.science_outlined,
            size: 64,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noNutrientsSelected,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              l10n.adjustAmountHint,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientList(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            l10n.applicationMix.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: _pendingNutrients.entries.map((entry) {
              final element = PeriodicTable.elements[entry.key];
              if (element == null) return const SizedBox.shrink();

              return _NutrientSliderRow(
                element: element,
                amount: entry.value,
                onChanged: (val) => _updateAmount(entry.key, val),
                onRemove: () => _toggleElement(element),
              );
            }).toList(),
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.totalElements(_pendingNutrients.length),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => setState(() => _pendingNutrients.clear()),
                child: Text(l10n.clearMix.toUpperCase()),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NutrientSliderRow extends StatelessWidget {
  final ElementInfo element;
  final double amount;
  final ValueChanged<double> onChanged;
  final VoidCallback onRemove;

  const _NutrientSliderRow({
    required this.element,
    required this.amount,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Scale max based on element type
    double maxAmount = 100.0;
    String unit = 'mg/kg';

    if (element.symbol == 'C') {
      maxAmount = 500.0;
    } else if (['N', 'P', 'K'].contains(element.symbol)) {
      maxAmount = 200.0;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: element.color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      element.symbol,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        element.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        element.category.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                  color: theme.colorScheme.error,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SliderTheme(
                    data: theme.sliderTheme.copyWith(
                      trackHeight: 2,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                    ),
                    child: Slider(
                      value: amount,
                      min: 0,
                      max: maxAmount,
                      onChanged: onChanged,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 70,
                  child: Text(
                    '${amount.toStringAsFixed(1)} $unit',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
