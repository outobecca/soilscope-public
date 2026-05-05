import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/periodic_table.dart';
import '../../../../domain/models/biophysical_state.dart';
import '../../../../domain/models/soil_layer.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/simulation_provider.dart';
import '../../providers/simulation_session_provider.dart';
import 'periodic_table_widget.dart';

class ElementsInformaticsView extends ConsumerStatefulWidget {
  final BiophysicalState state;
  final SoilLayer? layer;

  const ElementsInformaticsView({super.key, required this.state, this.layer});

  @override
  ConsumerState<ElementsInformaticsView> createState() =>
      _ElementsInformaticsViewState();
}

class _ElementsInformaticsViewState
    extends ConsumerState<ElementsInformaticsView> {
  ElementInfo? _selectedElement;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      children: [
        PeriodicTableWidget(
          selectedElement: _selectedElement,
          onSelect: (el) {
            setState(() => _selectedElement = el);
            ref.read(simulationSessionProvider.notifier).selectElement(el.symbol);
          },
        ),
        if (_selectedElement != null) ...[
          const SizedBox(height: 24),
          Text(
            _selectedElement!.name,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedElement!.soilRole,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.layer != null) ...[
            const SizedBox(height: 20),
            _buildNutrientSlider(widget.layer!, _selectedElement!, theme),
          ],
        ] else ...[
          const SizedBox(height: 24),
          Text(
            l10n.selectElementRole,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildNutrientSlider(
    SoilLayer layer,
    ElementInfo element,
    ThemeData theme,
  ) {
    final l10n = AppLocalizations.of(context)!;
    double value = 0;
    double max = 100;
    String unit = l10n.unitMgKg;
    switch (element.symbol) {
      case 'N':
        value = layer.nitrateContent;
        max = 500;
        break;
      case 'P':
        value = layer.phosphateContent;
        max = 500;
        break;
      case 'K':
        value = layer.potassiumContent;
        max = 500;
        break;
      case 'Ca':
        value = layer.solutionCalcium;
        max = 2000;
        break;
      case 'Mg':
        value = layer.solutionMagnesium;
        max = 500;
        break;
      case 'C':
        value = layer.organicCarbon;
        max = 0.1;
        unit = l10n.unitFraction;
        break;
      case 'O':
        value = layer.oxygenContent;
        max = 10;
        unit = l10n.unitMolM3;
        break;
      default:
        value = layer.traceElements[element.symbol] ?? 0.0;
        max = 50.0;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.concentration(layer.id),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '${value.toStringAsFixed(value < 0.1 ? 4 : 1)} $unit',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: value.clamp(0, max),
          min: 0,
          max: max,
          onChanged: (v) => ref
              .read(simulationProvider.notifier)
              .updateNutrient(layer.id, element.symbol, v),
        ),
      ],
    );
  }
}
