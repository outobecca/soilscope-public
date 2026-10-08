import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../core/cpk_standards.dart';
import '../providers/ui_state_provider.dart';

/// The consolidated information overlay for the entire app.
/// Handles both temporary hovers and pinned inspection states with crystal clear contrast.
class HoverTooltip extends ConsumerWidget {
  const HoverTooltip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final info = ref.watch(uIStateProvider);
    if (info == null) return const SizedBox.shrink();

    final isPinned = info.isPinned;
    final Color accentColor = info.accentColor ??
        (info.elementSymbol != null
            ? CPKStandards.getColor(info.elementSymbol!)
            : theme.colorScheme.primary);

    final screenWidth = MediaQuery.of(context).size.width;
    final maxAllowedWidth = screenWidth - 32;
    final targetWidth = isPinned ? 320.0 : 270.0;
    final effectiveMaxWidth = targetWidth > maxAllowedWidth ? maxAllowedWidth : targetWidth;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: accentColor.withValues(alpha: isPinned ? 0.9 : 0.6),
            width: isPinned ? 2.0 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: isPinned ? 0.35 : 0.2),
              blurRadius: 20,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, ref, info, theme, l10n, accentColor),
                const SizedBox(height: 10),
                Text(
                  info.description,
                  style: const TextStyle(
                    color: Color(0xFFF1F5F9),
                    fontSize: 12.5,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (info.formula != null) ...[
                  const SizedBox(height: 10),
                  _buildScientificContext(info.formula!, accentColor),
                ],
                if (info.stats != null && info.stats!.isNotEmpty) ...[
                  Divider(
                    color: Colors.white.withValues(alpha: 0.15),
                    height: 20,
                  ),
                  ...info.stats!.entries.map(
                    (e) => _buildStatRow(e.key, e.value, accentColor),
                  ),
                ],
                if (info.legends != null && info.legends!.isNotEmpty) ...[
                  Divider(
                    color: Colors.white.withValues(alpha: 0.15),
                    height: 20,
                  ),
                  _buildLegendSection(context, info.legends!, l10n),
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
    AppLocalizations? l10n,
    Color accentColor,
  ) {
    final badgeText = info.isPinned
        ? (l10n?.inspectionBadge ?? 'INSPECTION')
        : (l10n?.previewBadge ?? 'PREVIEW');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (info.elementSymbol != null) ...[
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          info.elementSymbol!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 1.0,
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
            icon: const Icon(Icons.close_rounded, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: Colors.white70,
            tooltip: AppLocalizations.of(context)?.closeAction ?? 'Close',
            onPressed: () => ref.read(uIStateProvider.notifier).setHoverInfo(null),
          ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScientificContext(String formula, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        formula,
        style: const TextStyle(
          color: Colors.white,
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
    AppLocalizations? l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.visualKey.toUpperCase() ?? 'MERKKIEN SELITYS',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            fontSize: 9,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: legends
              .map(
                (item) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.icon, size: 13, color: item.color),
                    const SizedBox(width: 5),
                    Text(
                      item.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
