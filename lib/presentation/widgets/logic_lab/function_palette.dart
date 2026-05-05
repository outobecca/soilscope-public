import 'package:flutter/material.dart';
import '../../../domain/logic_lab/models.dart';

/// Määrittelee yksittäisen funktion Logic Labiin.
class FunctionDefinition {
  final String operation;
  final String label;
  final String description;
  final String formula;
  final int inputCount;
  final List<String> inputLabels;
  final IconData icon;
  final Color color;
  final NodeType nodeType;

  const FunctionDefinition({
    required this.operation,
    required this.label,
    required this.description,
    required this.formula,
    required this.inputCount,
    required this.inputLabels,
    required this.icon,
    required this.color,
    this.nodeType = NodeType.function,
  });
}

/// Kaikki tuetut funktiot kategorioittain.
const Map<String, List<FunctionDefinition>> functionCategories = {
  'Biofysiikka': [
    FunctionDefinition(
      operation: 'Q10',
      label: 'Q10 (Lämpötila)',
      description: 'Lämpötilakerroin biologiselle aktiivisuudelle',
      formula: 'Q10^((T - 20) / 10)',
      inputCount: 2,
      inputLabels: ['Lämpötila (°C)', 'Q10-arvo'],
      icon: Icons.thermostat,
      color: Colors.orange,
    ),
    FunctionDefinition(
      operation: 'MM',
      label: 'Michaelis-Menten',
      description: 'Entsyymikinetiikka',
      formula: 'Vmax × [S] / (Km + [S])',
      inputCount: 3,
      inputLabels: ['Substraatti [S]', 'Vmax', 'Km'],
      icon: Icons.show_chart,
      color: Colors.purple,
    ),
    FunctionDefinition(
      operation: 'Chemotaxis',
      label: 'Chemotaxis (Fick)',
      description: 'Kemotaksis ja diffuusio (Fickin laki)',
      formula: '-D × (C₂ - C₁) / dx',
      inputCount: 4,
      inputLabels: ['Diffuusio D', 'C₁', 'C₂', 'Etäisyys dx'],
      icon: Icons.grain,
      color: Color(0xFF1E293B), // Slate Night (CPK C)
    ),
    FunctionDefinition(
      operation: 'CostBenefit',
      label: 'Cost-Benefit (Least Energy)',
      description: 'Energiatehokkuus (Vähimmän energian periaate)',
      formula: 'C / (D + P)',
      inputCount: 3,
      inputLabels: ['Konsentraatio C', 'Etäisyys D', 'Rangaistus P'],
      icon: Icons.bolt,
      color: Color(0xFF2563EB), // Royal Blue (CPK N)
    ),
    FunctionDefinition(
      operation: 'VG',
      label: 'van Genuchten',
      description: 'Maan vedenpidätyskyky',
      formula: 'θr + (θs-θr) / [1+|αh|^n]^m',
      inputCount: 5,
      inputLabels: ['Matric h (m)', 'θr', 'θs', 'α', 'n'],
      icon: Icons.water_drop,
      color: Colors.blue,
    ),
    FunctionDefinition(
      operation: 'Farq',
      label: 'Farquhar C3',
      description: 'C3-fotosynteesi (Rubisco-rajoitteinen)',
      formula: 'Vcmax(Ci-Γ*)/(Ci+Kc(1+O/Ko))',
      inputCount: 5,
      inputLabels: ['Ci (µmol/mol)', 'Vcmax', 'Γ*', 'Kc', 'Ko'],
      icon: Icons.eco,
      color: Colors.green,
    ),
    FunctionDefinition(
      operation: 'Redox',
      label: 'Nernst/Redox',
      description: 'Redox-potentiaalin laskenta',
      formula: 'pe0 - (1/n)×log([red]/[ox])',
      inputCount: 4,
      inputLabels: ['pe0', 'n (elektronit)', '[red]', '[ox]'],
      icon: Icons.bolt,
      color: Colors.amber,
    ),
  ],
  'Matematiikka': [
    FunctionDefinition(
      operation: '+',
      label: 'Yhteenlasku',
      description: 'Kahden arvon summa',
      formula: 'A + B',
      inputCount: 2,
      inputLabels: ['A', 'B'],
      icon: Icons.add,
      color: Colors.cyan,
      nodeType: NodeType.math,
    ),
    FunctionDefinition(
      operation: '-',
      label: 'Vähennyslasku',
      description: 'Erotus',
      formula: 'A - B',
      inputCount: 2,
      inputLabels: ['A', 'B'],
      icon: Icons.remove,
      color: Colors.cyan,
      nodeType: NodeType.math,
    ),
    FunctionDefinition(
      operation: '*',
      label: 'Kertolasku',
      description: 'Kahden arvon tulo',
      formula: 'A × B',
      inputCount: 2,
      inputLabels: ['A', 'B'],
      icon: Icons.close,
      color: Colors.cyan,
      nodeType: NodeType.math,
    ),
    FunctionDefinition(
      operation: '/',
      label: 'Jakolasku',
      description: 'Osamäärä',
      formula: 'A / B',
      inputCount: 2,
      inputLabels: ['A', 'B'],
      icon: Icons.safety_divider,
      color: Colors.cyan,
      nodeType: NodeType.math,
    ),
    FunctionDefinition(
      operation: 'pow',
      label: 'Potenssi',
      description: 'A korotettuna B:neen',
      formula: 'A^B',
      inputCount: 2,
      inputLabels: ['Kantaluku A', 'Eksponentti B'],
      icon: Icons.superscript,
      color: Colors.indigo,
      nodeType: NodeType.math,
    ),
    FunctionDefinition(
      operation: 'sqrt',
      label: 'Neliöjuuri',
      description: 'Neliöjuuri',
      formula: '√A',
      inputCount: 1,
      inputLabels: ['A'],
      icon: Icons.square_foot,
      color: Colors.indigo,
      nodeType: NodeType.math,
    ),
    FunctionDefinition(
      operation: 'exp',
      label: 'Eksponentti',
      description: 'e korotettuna A:han',
      formula: 'e^A',
      inputCount: 1,
      inputLabels: ['A'],
      icon: Icons.functions,
      color: Colors.indigo,
      nodeType: NodeType.math,
    ),
    FunctionDefinition(
      operation: 'ln',
      label: 'Luonnollinen log',
      description: 'Luonnollinen logaritmi',
      formula: 'ln(A)',
      inputCount: 1,
      inputLabels: ['A'],
      icon: Icons.functions,
      color: Colors.indigo,
      nodeType: NodeType.math,
    ),
    FunctionDefinition(
      operation: 'log10',
      label: 'Log₁₀',
      description: 'Kymmenkantainen logaritmi',
      formula: 'log₁₀(A)',
      inputCount: 1,
      inputLabels: ['A'],
      icon: Icons.functions,
      color: Colors.indigo,
      nodeType: NodeType.math,
    ),
    FunctionDefinition(
      operation: 'min',
      label: 'Minimi',
      description: 'Pienempi arvoista',
      formula: 'min(A, B)',
      inputCount: 2,
      inputLabels: ['A', 'B'],
      icon: Icons.arrow_downward,
      color: Colors.teal,
      nodeType: NodeType.math,
    ),
    FunctionDefinition(
      operation: 'max',
      label: 'Maksimi',
      description: 'Suurempi arvoista',
      formula: 'max(A, B)',
      inputCount: 2,
      inputLabels: ['A', 'B'],
      icon: Icons.arrow_upward,
      color: Colors.teal,
      nodeType: NodeType.math,
    ),
    FunctionDefinition(
      operation: 'clamp',
      label: 'Clamp',
      description: 'Rajoita arvo välille',
      formula: 'clamp(A, min, max)',
      inputCount: 3,
      inputLabels: ['Arvo A', 'Min', 'Max'],
      icon: Icons.compress,
      color: Colors.teal,
      nodeType: NodeType.math,
    ),
    FunctionDefinition(
      operation: 'abs',
      label: 'Itseisarvo',
      description: 'Absoluuttinen arvo',
      formula: '|A|',
      inputCount: 1,
      inputLabels: ['A'],
      icon: Icons.straighten,
      color: Colors.grey,
      nodeType: NodeType.math,
    ),
  ],
  'Erityiset': [
    FunctionDefinition(
      operation: 'output',
      label: 'Tulos',
      description: 'Näyttää lopputuloksen',
      formula: '→ Arvo',
      inputCount: 1,
      inputLabels: ['Syöte'],
      icon: Icons.output,
      color: Colors.green,
      nodeType: NodeType.output,
    ),
    FunctionDefinition(
      operation: 'const',
      label: 'Vakio',
      description: 'Kiinteä numeroarvo',
      formula: 'C',
      inputCount: 0,
      inputLabels: [],
      icon: Icons.pin,
      color: Colors.amber,
      nodeType: NodeType.constant,
    ),
  ],
  'Toiminnot': [
    FunctionDefinition(
      operation: 'set_irrigation',
      label: 'Kastelunopeus (Output Action)',
      description: 'Asettaa simulaation kastelunopeuden',
      formula: '→ Sadanta (mm/h)',
      inputCount: 1,
      inputLabels: ['Sadanta'],
      icon: Icons.water,
      color: Colors.blueAccent,
      nodeType: NodeType.output,
    ),
  ],
};

/// Sivupalkki funktioiden lisäämiseen.
class FunctionPalette extends StatefulWidget {
  final Function(FunctionDefinition) onSelect;
  final VoidCallback onClose;

  const FunctionPalette({
    super.key,
    required this.onSelect,
    required this.onClose,
  });

  @override
  State<FunctionPalette> createState() => _FunctionPaletteState();
}

class _FunctionPaletteState extends State<FunctionPalette> {
  String _searchQuery = '';
  String? _expandedCategory;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        border: Border(
          left: BorderSide(
            color: Colors.purple.withValues(alpha: 0.3),
            width: 2,
          ),
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
                const Icon(Icons.functions, color: Colors.purple),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Funktiot & Operaatiot',
                    style: TextStyle(
                      color: Colors.white,
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
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Hae...',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
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
              children: functionCategories.entries.map((category) {
                final filteredFuncs = category.value
                    .where(
                      (func) =>
                          _searchQuery.isEmpty ||
                          func.label.toLowerCase().contains(_searchQuery) ||
                          func.description.toLowerCase().contains(
                            _searchQuery,
                          ) ||
                          func.formula.toLowerCase().contains(_searchQuery),
                    )
                    .toList();

                if (filteredFuncs.isEmpty) return const SizedBox.shrink();

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
                              style: const TextStyle(
                                color: Colors.white70,
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
                                color: Colors.purple.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${filteredFuncs.length}',
                                style: const TextStyle(
                                  color: Colors.purple,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Functions
                    if (isExpanded)
                      ...filteredFuncs.map(
                        (func) => _FunctionTile(
                          func: func,
                          onTap: () => widget.onSelect(func),
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
              '${functionCategories.values.expand((e) => e).length} funktiota käytettävissä',
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

class _FunctionTile extends StatelessWidget {
  final FunctionDefinition func;
  final VoidCallback onTap;

  const _FunctionTile({required this.func, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: func.color.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: func.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(func.icon, color: func.color, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            func.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            func.description,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.add_circle_outline,
                      color: Colors.purple.withValues(alpha: 0.6),
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Formula display
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: func.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calculate,
                        size: 12,
                        color: func.color.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        func.formula,
                        style: TextStyle(
                          color: func.color,
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Input labels
                if (func.inputLabels.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 2,
                    children: func.inputLabels
                        .map(
                          (label) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              '→ $label',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 9,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
