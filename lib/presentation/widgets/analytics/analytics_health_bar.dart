import 'package:material_ui/material_ui.dart';
import '../../../l10n/app_localizations.dart';

class AnalyticsHealthBar extends StatelessWidget {
  final String label;
  final double value;
  final String? customValueLabel;
  final Color? color;

  const AnalyticsHealthBar({
    super.key,
    required this.label,
    required this.value,
    this.customValueLabel,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final barColor =
        color ??
        (value > 0.6
            ? const Color(0xFF059669) // Emerald 600
            : (value > 0.3
                  ? const Color(0xFFEA580C)
                  : const Color(0xFFDC2626)));

    return Semantics(
      container: true,
      label: label,
      value: customValueLabel ?? '${(value * 100).toStringAsFixed(0)}%',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    label.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  customValueLabel ?? '${(value * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: barColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value.clamp(0, 1),
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                color: barColor,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    l10n.fragile,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    l10n.resilient,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
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
