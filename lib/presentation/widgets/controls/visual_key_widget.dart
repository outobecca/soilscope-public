import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../../core/cpk_standards.dart';
import '../../providers/simulation_session_provider.dart';

class VisualKeyWidget extends ConsumerWidget {
  const VisualKeyWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: 300,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF334155).withValues(alpha: 0.7),
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.legend_toggle, size: 16, color: Colors.white70),
              const SizedBox(width: 8),
              Text(
                l10n.visualKey.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white12, height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildKeyItem(ref, CPKStandards.colorN, l10n.nitrogenN, 'N'),
                    _buildKeyItem(ref, CPKStandards.colorC, l10n.carbonC, 'C'),
                    _buildKeyItem(ref, Colors.cyan, l10n.moleculeWaterTitle, 'H2O'),
                    _buildKeyItem(ref, CPKStandards.colorO, l10n.oxygenO2, 'O2'),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    _buildKeyItem(ref, CPKStandards.colorP, l10n.cecSites, 'CEC', isCircle: false),
                    _buildKeyItem(ref, const Color(0xFFFACC15), l10n.microbes, 'BIO', isCircle: true, isAura: true),
                    _buildKeyItem(
                      ref,
                      Colors.purpleAccent,
                      l10n.enzymes,
                      'ENZYME',
                      isCircle: false,
                      isAura: true,
                    ),
                    _buildKeyItem(ref, Colors.white70, "MYCORRHIZAE", 'ROOT', isCircle: false, isCross: true),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: Colors.white12),
          _buildKeyItem(ref, const Color(0xFFFFD700), "PAR (SUNLIGHT)", 'PAR', isCircle: false, isAura: true),
          _buildKeyItem(ref, Colors.pinkAccent, "GAS EMISSIONS (N2O/CH4)", 'GAS'),
        ],
      ),
    );
  }

  Widget _buildKeyItem(
    WidgetRef ref,
    Color color,
    String label,
    String symbol, {
    bool isCircle = true,
    bool isAura = false,
    bool isCross = false,
  }) {
    final session = ref.watch(simulationSessionProvider);
    final currentSymbol = session.selectedElementSymbol;
    final isSelected = currentSymbol?.toUpperCase() == symbol.toUpperCase();

    return InkWell(
      onTap: () {
        if (isSelected) {
          ref.read(simulationSessionProvider.notifier).selectElement(null);
        } else {
          ref.read(simulationSessionProvider.notifier).selectElement(symbol);
        }
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? color.withValues(alpha: 0.3) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            _buildIcon(color, isCircle, isAura, isCross, isSelected),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(Color color, bool isCircle, bool isAura, bool isCross, bool isSelected) {
    final double scale = isSelected ? 1.25 : 1.0;
    
    if (isCircle) {
      return Transform.scale(
        scale: scale,
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.8),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
        ),
      );
    } else if (isAura) {
      return Transform.scale(
        scale: scale,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.8),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      );
    } else if (isCross) {
      return Transform.scale(
        scale: scale,
        child: SizedBox(
          width: 12,
          height: 12,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(width: 10, height: 1.5, color: color),
              Container(width: 1.5, height: 10, color: color),
            ],
          ),
        ),
      );
    } else {
      // Square/CEC
      return Transform.scale(
        scale: scale,
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
    }
  }
}
