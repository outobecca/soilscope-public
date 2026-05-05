import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../l10n/app_localizations.dart';
import '../providers/simulation_provider.dart';

class SustainabilityPanel extends ConsumerWidget {
  const SustainabilityPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(simulationProvider);
    final score = state.score;
    // Simple reward proxy
    final rewardValue =
        (score.totalSoilHealth * 0.5 +
            score.carbonScore * 0.3 +
            score.yieldScore * 0.2) /
        10.0;
    final l10n = AppLocalizations.of(context)!;

    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Transform.rotate(
                      angle: (1.0 - value) * 2.0 * 3.14159,
                      child: child,
                    ),
                  );
                },
                child: SvgPicture.asset(
                  'assets/images/logo.svg',
                  width: 18,
                  height: 18,
                  colorFilter: ColorFilter.mode(
                    Colors.green.shade600,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.systemHealth.toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildRadialScore(score.totalSoilHealth, l10n, theme),
          const SizedBox(height: 24),
          _buildMiniBar(
            l10n.productivity,
            score.yieldScore / 100,
            Colors.amber.shade700,
            theme,
          ),
          const SizedBox(height: 12),
          _buildMiniBar(
            l10n.carbonSink,
            score.carbonScore / 100,
            Colors.cyan.shade700,
            theme,
          ),
          const SizedBox(height: 12),
          _buildMiniBar(
            l10n.bioActivity, // Reuse bioActivity instead of Bio-Diversity for consistency
            score.biodiversityScore / 100,
            Colors.lightGreen.shade700,
            theme,
          ),
          const SizedBox(height: 12),
          _buildMiniBar(
            l10n.impact,
            score.environmentalImpact / 100,
            Colors.red.shade700,
            theme,
            isPenalty: true,
          ),
          const SizedBox(height: 16),
          Divider(color: theme.colorScheme.outlineVariant, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.reward,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                rewardValue.toStringAsFixed(2),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRadialScore(
    double score,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final color = _getScoreColor(score);
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(
              value: (score / 100).clamp(0, 1),
              strokeWidth: 6,
              color: color,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                score.toStringAsFixed(0),
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                ),
              ),
              Text(
                l10n.index.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBar(
    String label,
    double value,
    Color color,
    ThemeData theme, {
    bool isPenalty = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '${(value * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                color: color,
                fontSize: 10,
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
            minHeight: 4,
            color: color,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score > 80) return Colors.green.shade600;
    if (score > 50) return Colors.amber.shade600;
    if (score > 30) return Colors.orange.shade600;
    return Colors.red.shade600;
  }
}
