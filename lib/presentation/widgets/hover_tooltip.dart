import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../providers/ui_state_provider.dart';

/// The consolidated information overlay for the entire app.
/// Handles both temporary hovers and pinned inspection states.
class HoverTooltip extends ConsumerWidget {
  const HoverTooltip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final info = ref.watch(uIStateProvider);
    if (info == null) return const SizedBox.shrink();

    final isPinned = info.isPinned;
    final accentColor = info.accentColor ?? theme.colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(maxWidth: isPinned ? 320 : 280),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.4),
            width: isPinned ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, ref, info, theme, accentColor),
                const SizedBox(height: 12),
                Text(
                  info.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                    height: 1.4,
                  ),
                ),
                if (info.formula != null) ...[
                  const SizedBox(height: 12),
                  _buildScientificContext(info.formula!, theme, accentColor),
                ],
                if (info.stats != null && info.stats!.isNotEmpty) ...[
                  Divider(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                    height: 24,
                  ),
                  ...info.stats!.entries.map(
                    (e) => _buildStatRow(e.key, e.value, theme),
                  ),
                ],
                if (info.legends != null && info.legends!.isNotEmpty) ...[
                  Divider(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                    height: 24,
                  ),
                  _buildLegendSection(context, info.legends!, theme, accentColor),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    HoverInfo info,
    ThemeData theme,
    Color accentColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                info.isPinned ? "INSPECTION" : "PREVIEW",
                style: TextStyle(
                  color: accentColor.withValues(alpha: 0.6),
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
              Text(
                info.title.toUpperCase(),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontFamily: 'monospace',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (info.isPinned)
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            onPressed: () => ref.read(uIStateProvider.notifier).setHoverInfo(null),
          ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            textAlign: TextAlign.right,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScientificContext(String formula, ThemeData theme, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Text(
        formula,
        style: TextStyle(
          color: accentColor,
          fontSize: 11,
          fontStyle: FontStyle.italic,
          fontFamily: 'serif',
        ),
      ),
    );
  }

  Widget _buildLegendSection(
    BuildContext context,
    List<LegendItem> legends,
    ThemeData theme,
    Color accentColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.visualKey.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: accentColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            fontSize: 9,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: legends
              .map(
                (item) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.icon, size: 14, color: item.color),
                    const SizedBox(width: 6),
                    Text(
                      item.label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ) as Widget,
              )
              .toList(),
        ),
      ],
    );
  }
}
