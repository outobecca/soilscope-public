import 'package:flutter/material.dart';
import '../../../core/cpk_standards.dart';

/// Määrittelee yksittäisen input-tyypin.
class InputDefinition {
  final String operation;
  final String label;
  final String description;
  final String unit;
  final IconData icon;
  final Color color;

  const InputDefinition({
    required this.operation,
    required this.label,
    required this.description,
    required this.unit,
    required this.icon,
    required this.color,
  });
}

/// Kaikki tuetut input-kategoriat ja niiden inputit.
final Map<String, List<InputDefinition>> inputCategories = {
  'Maaperän fysiikka': [
    InputDefinition(
      operation: 'temp',
      label: 'Lämpötila',
      description: 'Maakerroksen lämpötila',
      unit: '°C',
      icon: Icons.thermostat,
      color: Colors.orange,
    ),
    InputDefinition(
      operation: 'moisture',
      label: 'Vesipitoisuus',
      description: 'Volumetrinen vesipitoisuus',
      unit: 'm³/m³',
      icon: Icons.water_drop,
      color: const Color(0xFF0284C7),
    ),
    InputDefinition(
      operation: 'saturation',
      label: 'Kyllästysaste',
      description: 'θ/θs suhde',
      unit: '0-1',
      icon: Icons.opacity,
      color: Colors.lightBlue,
    ),
    InputDefinition(
      operation: 'porosity',
      label: 'Huokoisuus',
      description: 'Kokonaishuokostilavuus',
      unit: '0-1',
      icon: Icons.blur_on,
      color: Colors.grey,
    ),
    InputDefinition(
      operation: 'ksat',
      label: 'Ksat',
      description: 'Kyllästysjohtavuus',
      unit: 'm/s',
      icon: Icons.speed,
      color: Colors.teal,
    ),
  ],
  'Maaperän kemia': [
    InputDefinition(
      operation: 'ph',
      label: 'pH',
      description: 'Happamuus',
      unit: '',
      icon: Icons.science,
      color: Colors.purple,
    ),
    InputDefinition(
      operation: 'redox_pe',
      label: 'Redox (pe)',
      description: 'Redox-potentiaali pe-yksikössä',
      unit: 'pe',
      icon: Icons.bolt,
      color: Colors.amber,
    ),
    InputDefinition(
      operation: 'redox_eh',
      label: 'Redox (Eh)',
      description: 'Redox-potentiaali',
      unit: 'mV',
      icon: Icons.bolt,
      color: Colors.amber,
    ),
    InputDefinition(
      operation: 'ec',
      label: 'EC',
      description: 'Sähkönjohtavuus',
      unit: 'dS/m',
      icon: Icons.electrical_services,
      color: Colors.yellow,
    ),
    InputDefinition(
      operation: 'cec',
      label: 'CEC',
      description: 'Kationinvaihtokapasiteetti',
      unit: 'cmol/kg',
      icon: Icons.swap_horiz,
      color: Colors.brown,
    ),
  ],
  'Typpi': [
    InputDefinition(
      operation: 'nh4',
      label: 'NH₄⁺',
      description: 'Ammonium',
      unit: 'mg/kg',
      icon: Icons.circle,
      color: CPKStandards.colorN,
    ),
    InputDefinition(
      operation: 'no3',
      label: 'NO₃⁻',
      description: 'Nitraatti',
      unit: 'mg/kg',
      icon: Icons.circle_outlined,
      color: CPKStandards.colorN.withValues(alpha: 0.8),
    ),
    InputDefinition(
      operation: 'org_n',
      label: 'Org-N',
      description: 'Orgaaninen typpi',
      unit: 'mg/kg',
      icon: Icons.eco,
      color: CPKStandards.colorN.withValues(alpha: 0.6),
    ),
    InputDefinition(
      operation: 'mic_n',
      label: 'Mic-N',
      description: 'Mikrobinen typpi',
      unit: 'mg/kg',
      icon: Icons.bubble_chart,
      color: CPKStandards.colorN.withValues(alpha: 0.4),
    ),
    InputDefinition(
      operation: 'total_n',
      label: 'Total N',
      description: 'Kokonaistyppi',
      unit: 'mg/kg',
      icon: Icons.all_inclusive,
      color: CPKStandards.colorN,
    ),
  ],
  'Fosfori & Kalium': [
    InputDefinition(
      operation: 'p_sol',
      label: 'P (liukoinen)',
      description: 'Liukoinen fosfaatti',
      unit: 'mg/kg',
      icon: Icons.brightness_1,
      color: CPKStandards.colorP,
    ),
    InputDefinition(
      operation: 'p_sorb',
      label: 'P (sorboitu)',
      description: 'Sorboitunut fosfaatti',
      unit: 'mg/kg',
      icon: Icons.brightness_2,
      color: CPKStandards.colorP.withValues(alpha: 0.7),
    ),
    InputDefinition(
      operation: 'k_sol',
      label: 'K (liukoinen)',
      description: 'Liukoinen kalium',
      unit: 'mg/kg',
      icon: Icons.brightness_1,
      color: CPKStandards.colorK,
    ),
    InputDefinition(
      operation: 'k_exch',
      label: 'K (vaihtuva)',
      description: 'Vaihtuva kalium',
      unit: 'mg/kg',
      icon: Icons.brightness_2,
      color: CPKStandards.colorK.withValues(alpha: 0.7),
    ),
  ],
  'Hiili & Orgaaninen': [
    InputDefinition(
      operation: 'org_c',
      label: 'Org-C',
      description: 'Orgaaninen hiili',
      unit: 'kg/m³',
      icon: Icons.forest,
      color: CPKStandards.colorC,
    ),
    InputDefinition(
      operation: 'pom',
      label: 'POM',
      description: 'Partikkelimainen org. aines',
      unit: 'kg/m³',
      icon: Icons.scatter_plot,
      color: CPKStandards.colorC.withValues(alpha: 0.8),
    ),
    InputDefinition(
      operation: 'maom',
      label: 'MAOM',
      description: 'Mineraaleihin sitoutunut org.',
      unit: 'kg/m³',
      icon: Icons.grain,
      color: CPKStandards.colorC.withValues(alpha: 0.6),
    ),
    InputDefinition(
      operation: 'mic_bio',
      label: 'Mic. biomassa',
      description: 'Mikrobinen biomassa',
      unit: 'kg/m³',
      icon: Icons.bubble_chart,
      color: CPKStandards.colorMicrobeZone,
    ),
  ],
  'Kaasut': [
    InputDefinition(
      operation: 'o2',
      label: 'O₂',
      description: 'Happipitoisuus maassa',
      unit: 'mol/m³',
      icon: Icons.air,
      color: CPKStandards.colorO,
    ),
    InputDefinition(
      operation: 'co2',
      label: 'CO₂',
      description: 'Hiilidioksidi maassa',
      unit: 'mol/m³',
      icon: Icons.cloud,
      color: CPKStandards.colorC,
    ),
    InputDefinition(
      operation: 'co2_atm',
      label: 'CO₂ (atm)',
      description: 'Ilmakehän CO₂',
      unit: 'mol/m³',
      icon: Icons.cloud_outlined,
      color: CPKStandards.colorC.withValues(alpha: 0.7),
    ),
  ],
  'Rakenne': [
    InputDefinition(
      operation: 'clay',
      label: 'Savi',
      description: 'Savifraktio',
      unit: '0-1',
      icon: Icons.layers,
      color: Colors.brown,
    ),
    InputDefinition(
      operation: 'sand',
      label: 'Hiekka',
      description: 'Hiekkafraktio',
      unit: '0-1',
      icon: Icons.grain,
      color: Colors.amber,
    ),
    InputDefinition(
      operation: 'silt',
      label: 'Siltti',
      description: 'Silttifraktio',
      unit: '0-1',
      icon: Icons.blur_linear,
      color: Colors.grey,
    ),
    InputDefinition(
      operation: 'agg_stab',
      label: 'Agg. stabiilius',
      description: 'Aggregaattien stabiilius',
      unit: '0-1',
      icon: Icons.hub,
      color: Colors.indigo,
    ),
  ],
  'Biologinen': [
    InputDefinition(
      operation: 'hyphae',
      label: 'Sienirihmasto',
      description: 'Hyphojen tiheys',
      unit: 'm/m³',
      icon: Icons.share,
      color: Colors.purple,
    ),
    InputDefinition(
      operation: 'eps',
      label: 'EPS',
      description: 'Ekstrasellulaarinen polysakkaridi',
      unit: 'mg/kg',
      icon: Icons.blur_circular,
      color: Colors.pink,
    ),
    InputDefinition(
      operation: 'necro',
      label: 'Nekromassa',
      description: 'Kuollut mikrobimassa',
      unit: 'kg/m³',
      icon: Icons.auto_awesome,
      color: Colors.grey,
    ),
  ],
  'Kasvi': [
    InputDefinition(
      operation: 'turgor',
      label: 'Turgor',
      description: 'Nestejännitys',
      unit: 'MPa',
      icon: Icons.spa,
      color: Colors.green,
    ),
    InputDefinition(
      operation: 'lai',
      label: 'LAI',
      description: 'Lehtialaindeksi',
      unit: 'm²/m²',
      icon: Icons.grass,
      color: Colors.lightGreen,
    ),
    InputDefinition(
      operation: 'biomass',
      label: 'Biomassa',
      description: 'Kokonaisbiomassa',
      unit: 'mg',
      icon: Icons.eco,
      color: Colors.green,
    ),
    InputDefinition(
      operation: 'root_bio',
      label: 'Juuristo',
      description: 'Juuriston biomassa',
      unit: 'mg',
      icon: Icons.share,
      color: Colors.brown,
    ),
    InputDefinition(
      operation: 'psi_leaf',
      label: 'ψ_leaf',
      description: 'Lehtien vesipotentiaali',
      unit: 'MPa',
      icon: Icons.water,
      color: Colors.blue,
    ),
    InputDefinition(
      operation: 'n_uptake',
      label: 'N-otto',
      description: 'Typen otto',
      unit: 'mg/d',
      icon: Icons.arrow_upward,
      color: Colors.green,
    ),
    InputDefinition(
      operation: 'h2o_uptake',
      label: 'H₂O-otto',
      description: 'Veden otto',
      unit: 'mm/d',
      icon: Icons.arrow_upward,
      color: Colors.blue,
    ),
  ],
  'Ympäristö': [
    InputDefinition(
      operation: 'precip',
      label: 'Sade',
      description: 'Sademäärä',
      unit: 'mm/h',
      icon: Icons.water_drop,
      color: Colors.blue,
    ),
    InputDefinition(
      operation: 'air_temp',
      label: 'Ilman lämpö',
      description: 'Ilman lämpötila',
      unit: '°C',
      icon: Icons.thermostat,
      color: Colors.orange,
    ),
    InputDefinition(
      operation: 'rh',
      label: 'RH',
      description: 'Suhteellinen kosteus',
      unit: '0-1',
      icon: Icons.water,
      color: Colors.lightBlue,
    ),
    InputDefinition(
      operation: 'time',
      label: 'Aika',
      description: 'Kulunut aika',
      unit: 's',
      icon: Icons.timer,
      color: Colors.grey,
    ),
  ],
  'Mykoritsa': [
    InputDefinition(
      operation: 'myc_colon',
      label: 'Kolonisaatio',
      description: 'Juurten kolonisaatioaste',
      unit: '0-1',
      icon: Icons.share,
      color: Colors.purple,
    ),
    InputDefinition(
      operation: 'myc_c',
      label: 'C→sieni',
      description: 'Hiilen siirto kasvi→sieni',
      unit: 'mg/d',
      icon: Icons.arrow_forward,
      color: Colors.brown,
    ),
    InputDefinition(
      operation: 'myc_p',
      label: 'P→kasvi',
      description: 'Fosforin siirto sieni→kasvi',
      unit: 'mg/d',
      icon: Icons.arrow_back,
      color: Colors.orange,
    ),
    InputDefinition(
      operation: 'myc_hyphae',
      label: 'Hyphat',
      description: 'Mykoritsahyphojen pituus',
      unit: 'm',
      icon: Icons.timeline,
      color: Colors.purple,
    ),
  ],
};

/// Sivupalkki, josta voi valita uusia input-nodeja.
class InputPalette extends StatefulWidget {
  final Function(InputDefinition) onSelect;
  final VoidCallback onClose;

  const InputPalette({
    super.key,
    required this.onSelect,
    required this.onClose,
  });

  @override
  State<InputPalette> createState() => _InputPaletteState();
}

class _InputPaletteState extends State<InputPalette> {
  String _searchQuery = '';
  String? _expandedCategory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          left: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(-10, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.sensors, color: Colors.cyan),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Simulaatio-inputit',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),

          // Search
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Hae...',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
                filled: true,
                fillColor: Colors.black.withValues(alpha: 0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onChanged: (value) =>
                  setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),

          // Categories
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: inputCategories.entries.map((category) {
                final filteredInputs = category.value
                    .where(
                      (input) =>
                          _searchQuery.isEmpty ||
                          input.label.toLowerCase().contains(_searchQuery) ||
                          input.description.toLowerCase().contains(
                            _searchQuery,
                          ) ||
                          input.operation.toLowerCase().contains(_searchQuery),
                    )
                    .toList();

                if (filteredInputs.isEmpty) return const SizedBox.shrink();

                final isExpanded =
                    _expandedCategory == category.key ||
                    _searchQuery.isNotEmpty;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category header
                    InkWell(
                      onTap: () => setState(() {
                        _expandedCategory = isExpanded ? null : category.key;
                      }),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 8,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isExpanded
                                  ? Icons.expand_more
                                  : Icons.chevron_right,
                              color: Colors.white54,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              category.key,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.cyan.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${filteredInputs.length}',
                                style: const TextStyle(
                                  color: Colors.cyan,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Inputs
                    if (isExpanded)
                      ...filteredInputs.map(
                        (input) => _InputTile(
                          input: input,
                          onTap: () => widget.onSelect(input),
                        ),
                      ),

                    const SizedBox(height: 4),
                  ],
                );
              }).toList(),
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
            ),
            child: Text(
              '${inputCategories.values.expand((e) => e).length} inputtia käytettävissä',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _InputTile extends StatelessWidget {
  final InputDefinition input;
  final VoidCallback onTap;

  const _InputTile({required this.input, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 8, bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: input.color.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: input.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(input.icon, color: input.color, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        input.label,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        input.description,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  input.unit,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontFamily: 'monospace',
                    fontSize: 10,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.add_circle_outline,
                  color: Colors.cyan.withValues(alpha: 0.6),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
