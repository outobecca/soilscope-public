import 'package:flutter/material.dart';

/// A reusable widget to display a single biophysical metric with trend indicators.
class AnalyticsValueCard extends StatefulWidget {
  final String label;
  final double value;
  final String unit;
  final String Function(double)? formatter;
  final Color? color;
  final bool compact;

  const AnalyticsValueCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    this.formatter,
    this.color,
    this.compact = false,
  });

  @override
  State<AnalyticsValueCard> createState() => _AnalyticsValueCardState();
}

class _AnalyticsValueCardState extends State<AnalyticsValueCard> {
  double? _previousValue;

  @override
  void didUpdateWidget(AnalyticsValueCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayValue =
        widget.formatter?.call(widget.value) ?? widget.value.toStringAsFixed(2);

    final diff = _previousValue != null ? widget.value - _previousValue! : 0.0;
    IconData? trendIcon;
    Color trendColor = Colors.transparent;

    if (diff.abs() > 1e-7) {
      trendIcon = diff > 0 ? Icons.trending_up : Icons.trending_down;
      trendColor = diff > 0 ? Colors.green.shade600 : Colors.red.shade600;
    }

    if (widget.compact) {
      return _buildCompact(theme, displayValue, trendIcon, trendColor);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              widget.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          if (trendIcon != null)
            Icon(trendIcon, size: 14, color: trendColor.withValues(alpha: 0.7)),
          const SizedBox(width: 8),
          Text(
            '$displayValue ${widget.unit}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: widget.color ?? theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompact(
    ThemeData theme,
    String displayValue,
    IconData? trendIcon,
    Color trendColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trendIcon != null) Icon(trendIcon, size: 10, color: trendColor),
            const SizedBox(width: 2),
            Text(
              displayValue,
              style: theme.textTheme.bodySmall?.copyWith(
                color: widget.color ?? theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(width: 2),
            Text(
              widget.unit,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 7,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
