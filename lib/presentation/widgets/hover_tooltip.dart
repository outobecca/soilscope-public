import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../core/cpk_standards.dart';
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
    final Color accentColor = info.accentColor ?? 
        (info.elementSymbol != null ? CPKStandards.getColor(info.elementSymbol!) : theme.colorScheme.primary);

    // If we have a screen position and it's not pinned, we might want to offset it from the cursor
    final tooltip = Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(maxWidth: isPinned ? 320 : 260),
        decoration: BoxDecoration(
          // Use CPK color for background as requested
          color: accentColor.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.4),
            width: isPinned ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 25,
              spreadRadius: 5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, ref, info, theme, Colors.white),
                const SizedBox(height: 12),
                Text(
                  info.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.95),
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (info.formula != null) ...[
                  const SizedBox(height: 12),
                  _buildScientificContext(info.formula!, theme, Colors.white),
                ],
                if (info.stats != null && info.stats!.isNotEmpty) ...[
                  Divider(
                    color: Colors.white.withValues(alpha: 0.2),
                    height: 24,
                  ),
                  ...info.stats!.entries.map(
                    (e) => _buildStatRow(e.key, e.value, theme, Colors.white),
                  ),
                ],
                if (info.legends != null && info.legends!.isNotEmpty) ...[
                  Divider(
                    color: Colors.white.withValues(alpha: 0.2),
                    height: 24,
                  ),
                  _buildLegendSection(context, info.legends!, theme, Colors.white),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    return tooltip;
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    HoverInfo info,
    ThemeData theme,
    Color textColor,
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
                  color: textColor.withValues(alpha: 0.7),
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
              Row(
                children: [
                  if (info.elementSymbol != null) ...[
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          info.elementSymbol!.substring(0, 1),
                          style: TextStyle(
                            color: (info.accentColor ?? CPKStandards.getColor(info.elementSymbol!)),
                            fontSize: 7,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      info.title.toUpperCase(),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontFamily: 'monospace',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (info.isPinned)
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: textColor.withValues(alpha: 0.8),
            onPressed: () => ref.read(uIStateProvider.notifier).setHoverInfo(null),
          ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, ThemeData theme, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: textColor.withValues(alpha: 0.7),
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
              color: textColor,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScientificContext(String formula, ThemeData theme, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Text(
        formula,
        style: TextStyle(
          color: textColor,
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
    Color textColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.visualKey.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: textColor.withValues(alpha: 0.8),
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
                    Icon(item.icon, size: 14, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      item.label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
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
