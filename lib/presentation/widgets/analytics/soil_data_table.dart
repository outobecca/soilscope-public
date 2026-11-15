import 'package:material_ui/material_ui.dart';

import '../../../domain/models/soil_profile.dart';
import '../../../l10n/app_localizations.dart';

/// The accessible, printable equivalent of the painted soil column: the same
/// profile as labelled values a screen reader (or a printer) can consume.
class SoilDataTable extends StatelessWidget {
  final SoilProfile profile;

  const SoilDataTable({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (profile.layers.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 16,
        horizontalMargin: 0,
        headingRowHeight: 32,
        dataRowMinHeight: 32,
        dataRowMaxHeight: 40,
        columns: [
          DataColumn(label: Text(l10n.columnLayer)),
          DataColumn(label: Text(l10n.columnDepth)),
          DataColumn(label: Text(l10n.columnMoisture)),
          DataColumn(label: Text(l10n.columnPh)),
          DataColumn(label: Text(l10n.columnNitrate)),
          DataColumn(label: Text(l10n.columnBiomass)),
        ],
        rows: [
          for (final layer in profile.layers)
            DataRow(
              cells: [
                DataCell(Text(layer.name.isNotEmpty ? layer.name : layer.id)),
                DataCell(Text('${layer.depth.toStringAsFixed(2)} m')),
                DataCell(
                  Text('${(layer.waterContent * 100).toStringAsFixed(1)} %'),
                ),
                DataCell(Text(layer.ph.toStringAsFixed(1))),
                DataCell(Text(layer.nitrateContent.toStringAsFixed(0))),
                DataCell(Text(layer.microbialBiomass.toStringAsFixed(0))),
              ],
            ),
        ],
      ),
    );
  }
}
