import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/simulation_provider.dart';

class GamificationBar extends ConsumerWidget {
  const GamificationBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(simulationProvider);

    // 1. Soil Health Calculation
    final double soilHealth = (state.score.totalSoilHealth).clamp(0.0, 100.0);

    // 2. Plant Health Calculation
    double plantHealth = 100.0;
    if (state.plants.isNotEmpty) {
      final p = state.plants.first;
      final rwc = p.relativeWaterContent.clamp(0.0, 1.0);
      final turgor = p.turgorPressure.clamp(0.0, 1.0);
      plantHealth = ((rwc * 0.6 + turgor * 0.4) * 100.0).clamp(0.0, 100.0);
    }

    final int totalObjectives = state.currentScenario?.objectives.length ?? 1;
    final int metObjectives = state.score.metObjectiveIds.length;
    final double xpProgress = (metObjectives / totalObjectives).clamp(0.0, 1.0);
    final int currentLevel = 1 + metObjectives;

    final List<Map<String, dynamic>> buffs = [];
    if (state.plants.isNotEmpty && state.plants.first.waterStressIndex > 0.3) {
      buffs.add({'icon': Icons.opacity_rounded, 'color': Colors.redAccent, 'label': 'KUIVUUS'});
    }
    if (state.precipitation > 0.1) {
      buffs.add({'icon': Icons.grain_rounded, 'color': Colors.blueAccent, 'label': 'SADE'});
    }
    if (state.hasCoverCrop) {
      buffs.add({'icon': Icons.shield_rounded, 'color': Colors.greenAccent, 'label': 'PEITEKASVI'});
    }
    if (state.mycorrhizaState != null && state.mycorrhizaState!.rootColonization > 0.1) {
      buffs.add({'icon': Icons.hub_rounded, 'color': Colors.pinkAccent, 'label': 'SYMBIOOSI'});
    }

    if (state.profile.layers.isEmpty) return const SizedBox.shrink();
    final topsoil = state.profile.layers.first;
    final double waterSat = ((topsoil.waterContent / topsoil.porosity) * 100).clamp(0.0, 100.0);
    final double microbeFlux = (topsoil.microbialBiomass * 1.5).clamp(0.0, 100.0);

    final soilColor = soilHealth > 70 ? Colors.greenAccent : (soilHealth > 40 ? Colors.orangeAccent : Colors.redAccent);
    final plantColor = plantHealth > 70 ? Colors.cyanAccent : (plantHealth > 40 ? Colors.amberAccent : Colors.redAccent);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1E293B).withValues(alpha: 0.9),
                const Color(0xFF0F172A).withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // SOIL HEALTH METER
              _buildHealthMeter(
                context,
                title: "MAA TERVEYS",
                value: soilHealth,
                color: soilColor,
                gradient: const LinearGradient(
                  colors: [Colors.brown, Colors.greenAccent],
                ),
                icon: Icons.grass_rounded,
              ),

              // WATER SATURATION
              _buildHealthMeter(
                context,
                title: "KOSTEUS",
                value: waterSat,
                color: Colors.blueAccent,
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.cyanAccent],
                ),
                icon: Icons.water_drop_rounded,
              ),
              
              // CENTER XP & LEVEL
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Level Shield
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1B4B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFC084FC),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFC084FC).withValues(alpha: 0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Text(
                        'TASO $currentLevel',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: const Color(0xFFE9D5FF),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // XP Bar
                Stack(
                  children: [
                    Container(
                      height: 6,
                      width: 160,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: Colors.white10),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      height: 6,
                      width: 160 * xpProgress,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFA855F7), Color(0xFFEC4899)],
                        ),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFA855F7).withValues(alpha: 0.4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'XP $metObjectives / $totalObjectives',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade500,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (state.currentScenario != null && state.currentScenario!.objectives.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: state.currentScenario!.objectives.map((obj) {
                          final isMet = state.score.metObjectiveIds.contains(obj.id);
                          final color = isMet ? Colors.greenAccent : Colors.grey.shade400;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isMet ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                  color: color,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  obj.title,
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 9,
                                    fontWeight: isMet ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                // Buffs / Debuffs
                if (buffs.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    children: buffs.map((b) {
                      return Tooltip(
                        message: b['label'] as String,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: (b['color'] as Color).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: (b['color'] as Color).withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            b['icon'] as IconData,
                            color: b['color'] as Color,
                            size: 14,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),

              // MICROBE FLUX
              _buildHealthMeter(
                context,
                title: "MIKROBIT",
                value: microbeFlux,
                color: Colors.pinkAccent,
                gradient: const LinearGradient(
                  colors: [Colors.purple, Colors.pinkAccent],
                ),
                icon: Icons.hub_rounded,
              ),

              // PLANT HEALTH METER
              _buildHealthMeter(
                context,
                title: "KASVI VITALITEETTI",
                value: plantHealth,
                color: plantColor,
                gradient: const LinearGradient(
                  colors: [Colors.teal, Colors.cyanAccent],
                ),
                icon: Icons.local_florist_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthMeter(
    BuildContext context, {
    required String title,
    required double value,
    required Color color,
    required Gradient gradient,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Expanded(
      child: Row(
        children: [
          // RPG ORB
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer heavy metal frame
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF020617),
                  border: Border.all(
                    color: const Color(0xFF475569), 
                    width: 3.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.25),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              // Inner liquid cavity
              ClipOval(
                child: Container(
                  width: 42,
                  height: 42,
                  color: const Color(0xFF0F172A),
                  child: Stack(
                    children: [
                      // Liquid
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.easeOutCubic,
                          height: 42 * (value / 100.0),
                          decoration: BoxDecoration(
                            gradient: gradient,
                          ),
                        ),
                      ),
                      // Liquid glow effect
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.easeOutCubic,
                          height: (42 * (value / 100.0)) + 4,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                color.withValues(alpha: 0.4),
                                Colors.transparent,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                      // Glass Sheen
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.2),
                              Colors.white.withValues(alpha: 0.0),
                              Colors.black.withValues(alpha: 0.4),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Frame Overlay accent
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
              // Center Metric Label
              Text(
                '${value.toStringAsFixed(0)}%',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  shadows: [
                    const Shadow(color: Colors.black, blurRadius: 4),
                    const Shadow(color: Colors.black, blurRadius: 4),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          // Info Text
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        value > 70 ? "ERINOMAINEN" : (value > 40 ? "KOHTALAINEN" : "KRIITTINEN"),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w800,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
