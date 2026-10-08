import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/simulation_provider.dart';
import '../../providers/simulation_session_provider.dart';
import '../../providers/ui_state_provider.dart';
import '../game/components/process_magnifier_component.dart';
import '../game/logic/microscope_info_helper.dart';

/// Floating HUD controller for the Nanovision microscope inspection views.
/// Provides immediate target switching, magnification telemetry,
/// pedagogical context reopening, and quick dismiss controls.
class MicroscopeHudController extends ConsumerWidget {
  const MicroscopeHudController({super.key});

  static const List<MagnifierType> targets = [
    MagnifierType.leaf,
    MagnifierType.stem,
    MagnifierType.apicalMeristem,
    MagnifierType.root,
    MagnifierType.rhizosphere,
    MagnifierType.microbe,
    MagnifierType.soilStructure,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selectedTypeName = ref.watch(
      simulationSessionProvider.select((s) => s.selectedInspectorType),
    );
    final currentType = MicroscopeInfoHelper.parseType(selectedTypeName) ??
        MagnifierType.rhizosphere;

    final currentMag = MicroscopeInfoHelper.getMagnificationLevel(currentType);
    final currentTitle = MicroscopeInfoHelper.getLocalizedTitle(currentType, l10n);

    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 700;

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isCompact ? screenWidth - 32 : 680,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF090D16).withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF06B6D4).withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF06B6D4).withValues(alpha: 0.2),
              blurRadius: 16,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Row: Title, Magnification Badge, Actions
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF06B6D4).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.biotech_rounded,
                          size: 18,
                          color: Color(0xFF22D3EE),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                l10n.nanovisionTitle.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  fontFamily: 'monospace',
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Magnification & Active Target Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF06B6D4).withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFF22D3EE).withValues(alpha: 0.6),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '$currentTitle ($currentMag)',
                                style: const TextStyle(
                                  color: Color(0xFF67E8F9),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Info / Educational Help Button
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        iconSize: 18,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        icon: const Icon(Icons.info_outline_rounded, color: Colors.white70),
                        tooltip: l10n.moreInfo,
                        onPressed: () {
                          final state = ref.read(simulationProvider);
                          ref.read(uIStateProvider.notifier).setHoverInfo(
                            MicroscopeInfoHelper.createHoverInfo(
                              type: currentType,
                              l: l10n,
                              state: state,
                              isPinned: true,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 4),
                      // Close Microscope Button
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        iconSize: 18,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        icon: const Icon(Icons.close_rounded, color: Colors.white70),
                        tooltip: l10n.turnOffMicroscope,
                        onPressed: () {
                          ref.read(simulationSessionProvider.notifier).toggleMicroscope();
                          ref.read(uIStateProvider.notifier).clearHoverInfo();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Target Selectors Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: targets.map((target) {
                        final isTargetActive = target.name == selectedTypeName;
                        final targetTitle = MicroscopeInfoHelper.getLocalizedTitle(target, l10n);
                        final targetMag = MicroscopeInfoHelper.getMagnificationLevel(target);
                        final icon = MicroscopeInfoHelper.getIcon(target);

                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InkWell(
                            onTap: () {
                              ref.read(simulationSessionProvider.notifier).selectInspector(target.name);
                              final state = ref.read(simulationProvider);
                              ref.read(uIStateProvider.notifier).setHoverInfo(
                                MicroscopeInfoHelper.createHoverInfo(
                                  type: target,
                                  l: l10n,
                                  state: state,
                                  isPinned: true,
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isTargetActive
                                    ? const Color(0xFF06B6D4).withValues(alpha: 0.28)
                                    : Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isTargetActive
                                      ? const Color(0xFF22D3EE)
                                      : Colors.white.withValues(alpha: 0.15),
                                  width: isTargetActive ? 1.5 : 1.0,
                                ),
                                boxShadow: isTargetActive
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF06B6D4).withValues(alpha: 0.4),
                                          blurRadius: 8,
                                          spreadRadius: 0.5,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    icon,
                                    size: 14,
                                    color: isTargetActive
                                        ? const Color(0xFF22D3EE)
                                        : Colors.white70,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    targetTitle,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isTargetActive
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: isTargetActive
                                          ? Colors.white
                                          : Colors.white.withValues(alpha: 0.8),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    targetMag,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.w600,
                                      color: isTargetActive
                                          ? const Color(0xFF67E8F9)
                                          : Colors.white38,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
