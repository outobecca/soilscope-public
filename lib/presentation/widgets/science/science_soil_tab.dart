import 'package:flutter/material.dart';
import '../../../../core/biophysics_utils.dart';
import '../../../../domain/models/soil_layer.dart';
import '../../../l10n/app_localizations.dart';
import '../diagrams/soil_texture_triangle.dart';

class ScienceSoilTab extends StatefulWidget {
  final SoilLayer layer;
  const ScienceSoilTab({super.key, required this.layer});

  @override
  State<ScienceSoilTab> createState() => _ScienceSoilTabState();
}

class _ScienceSoilTabState extends State<ScienceSoilTab> {
  double? _probedSand;
  double? _probedSilt;
  double? _probedClay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final currentSand = _probedSand ?? widget.layer.sandFraction;
    final currentSilt = _probedSilt ?? widget.layer.siltFraction;
    final currentClay = _probedClay ?? widget.layer.clayFraction;

    final texture = BiophysicsUtils.getSoilTextureClass(
      currentSand,
      currentSilt,
      currentClay,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.3,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Soil Texture Triangle',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SoilTextureTriangle(
                    sand: currentSand,
                    silt: currentSilt,
                    clay: currentClay,
                    onProbe: (sa, si, cl) => setState(() {
                      _probedSand = sa;
                      _probedSilt = si;
                      _probedClay = cl;
                    }),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildTextureDetails(
            texture,
            currentSand,
            currentSilt,
            currentClay,
            theme,
            l10n,
          ),
        ],
      ),
    );
  }

  Widget _buildTextureDetails(
    SoilTexture texture,
    double sa,
    double si,
    double cl,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.classification.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _getLocalizedTextureName(texture, l10n),
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 24),
        _buildStatRow(
          l10n.sandFraction,
          '${(sa * 100).toStringAsFixed(1)}%',
          theme,
        ),
        _buildStatRow(
          l10n.siltFraction,
          '${(si * 100).toStringAsFixed(1)}%',
          theme,
        ),
        _buildStatRow(
          l10n.clayFraction,
          '${(cl * 100).toStringAsFixed(1)}%',
          theme,
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label, 
              style: theme.textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getLocalizedTextureName(SoilTexture texture, AppLocalizations l10n) {
    return switch (texture) {
      SoilTexture.sand => l10n.sand,
      SoilTexture.loamySand => l10n.loamySand,
      SoilTexture.sandyLoam => l10n.sandyLoam,
      SoilTexture.loam => l10n.loam,
      SoilTexture.silt => l10n.silt,
      SoilTexture.siltLoam => l10n.siltLoam,
      SoilTexture.sandyClayLoam => l10n.sandyClayLoam,
      SoilTexture.clayLoam => l10n.clayLoam,
      SoilTexture.siltyClayLoam => l10n.siltyClayLoam,
      SoilTexture.sandyClay => l10n.sandyClay,
      SoilTexture.siltyClay => l10n.siltyClay,
      SoilTexture.clay => l10n.clay,
    };
  }
}
