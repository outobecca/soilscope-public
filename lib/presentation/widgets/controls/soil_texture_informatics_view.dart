import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/biophysics_utils.dart';
import '../../../../domain/models/soil_layer.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/simulation_provider.dart';
import '../diagrams/soil_texture_triangle.dart';

class SoilTextureInformaticsView extends ConsumerWidget {
  final SoilLayer layer;

  const SoilTextureInformaticsView({super.key, required this.layer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final textureName = _getLocalizedTextureName(
      layer.sandFraction,
      layer.siltFraction,
      layer.clayFraction,
      l10n,
    );

    return Column(
      children: [
        SizedBox(
          height: 280,
          child: SoilTextureTriangle(
            key: ValueKey('texture_${layer.id}'),
            sand: layer.sandFraction,
            silt: layer.siltFraction,
            clay: layer.clayFraction,
            onProbe: (sa, si, cl) {
              ref
                  .read(simulationProvider.notifier)
                  .updateLayerParameter(layer.id, 'sandFraction', sa);
              ref
                  .read(simulationProvider.notifier)
                  .updateLayerParameter(layer.id, 'siltFraction', si);
              ref
                  .read(simulationProvider.notifier)
                  .updateLayerParameter(layer.id, 'clayFraction', cl);
            },
          ),
        ),
        const SizedBox(height: 16),
        Text(
          textureName.toUpperCase(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildMiniProperty(
          l10n.sandFraction,
          '${(layer.sandFraction * 100).toStringAsFixed(1)}%',
          theme,
        ),
        _buildMiniProperty(
          l10n.siltFraction,
          '${(layer.siltFraction * 100).toStringAsFixed(1)}%',
          theme,
        ),
        _buildMiniProperty(
          l10n.clayFraction,
          '${(layer.clayFraction * 100).toStringAsFixed(1)}%',
          theme,
        ),
      ],
    );
  }

  String _getLocalizedTextureName(
    double sand,
    double silt,
    double clay,
    AppLocalizations l10n,
  ) {
    final finnishTexture =
        BiophysicsUtils.getFinnishSoilTextureClass(sand, silt, clay);
    return switch (finnishTexture) {
      FinnishSoilTexture.as => l10n.textureAS,
      FinnishSoilTexture.hts => l10n.textureHtS,
      FinnishSoilTexture.hes => l10n.textureHeS,
      FinnishSoilTexture.hss => l10n.textureHsS,
      FinnishSoilTexture.ht => l10n.textureHt,
      FinnishSoilTexture.he => l10n.textureHe,
      FinnishSoilTexture.hs => l10n.textureHs,
    };
  }

  Widget _buildMiniProperty(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
