import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../domain/logic_lab/models.dart';
import '../../domain/logic_lab/evaluator.dart';
import '../providers/simulation_provider.dart';
import '../widgets/logic_lab/node_widget.dart';
import '../widgets/logic_lab/connection_painter.dart';
import '../widgets/logic_lab/input_palette.dart';
import '../widgets/logic_lab/function_palette.dart';

enum PaletteType { none, inputs, functions }

class LogicLabScreen extends ConsumerStatefulWidget {
  const LogicLabScreen({super.key});

  @override
  ConsumerState<LogicLabScreen> createState() => _LogicLabScreenState();
}

class _LogicLabScreenState extends ConsumerState<LogicLabScreen> {
  late LogicGraph _graph;
  String _currentExample = 'nitrification';
  PaletteType _activePalette = PaletteType.none;
  int _nodeCounter = 100;

  @override
  void initState() {
    super.initState();
    _initNitrificationGraph();
  }

  void _initNitrificationGraph() {
    _currentExample = 'nitrification';
    // Nitrifikaatio: Q10 × Michaelis-Menten
    final nodes = [
      LogicNode(
        id: 'in_temp',
        label: 'Soil Temp',
        type: NodeType.input,
        operation: 'temp',
        position: const Offset(50, 80),
      ),
      LogicNode(
        id: 'const_q10',
        label: 'Q10 Base',
        type: NodeType.constant,
        value: 2.0,
        isEditable: true,
        position: const Offset(50, 180),
      ),
      LogicNode(
        id: 'func_q10',
        label: 'Temp Effect',
        type: NodeType.function,
        operation: 'Q10',
        position: const Offset(280, 130),
      ),

      LogicNode(
        id: 'in_nh4',
        label: 'NH4 Content',
        type: NodeType.input,
        operation: 'nh4',
        position: const Offset(50, 320),
      ),
      LogicNode(
        id: 'const_vmax',
        label: 'Vmax',
        type: NodeType.constant,
        value: 0.5,
        isEditable: true,
        position: const Offset(50, 420),
      ),
      LogicNode(
        id: 'const_km',
        label: 'Km',
        type: NodeType.constant,
        value: 10.0,
        isEditable: true,
        position: const Offset(50, 520),
      ),
      LogicNode(
        id: 'func_mm',
        label: 'Michaelis-Menten',
        type: NodeType.function,
        operation: 'MM',
        position: const Offset(280, 420),
      ),

      LogicNode(
        id: 'math_mul',
        label: 'Combined Rate',
        type: NodeType.math,
        operation: '*',
        position: const Offset(520, 280),
      ),
      LogicNode(
        id: 'out_nitri',
        label: 'Nitrification',
        type: NodeType.output,
        operation: 'out',
        position: const Offset(720, 280),
      ),
    ];

    final connections = [
      NodeConnection(
        fromNodeId: 'in_temp',
        fromPortIndex: 0,
        toNodeId: 'func_q10',
        toPortIndex: 0,
      ),
      NodeConnection(
        fromNodeId: 'const_q10',
        fromPortIndex: 0,
        toNodeId: 'func_q10',
        toPortIndex: 1,
      ),

      NodeConnection(
        fromNodeId: 'in_nh4',
        fromPortIndex: 0,
        toNodeId: 'func_mm',
        toPortIndex: 0,
      ),
      NodeConnection(
        fromNodeId: 'const_vmax',
        fromPortIndex: 0,
        toNodeId: 'func_mm',
        toPortIndex: 1,
      ),
      NodeConnection(
        fromNodeId: 'const_km',
        fromPortIndex: 0,
        toNodeId: 'func_mm',
        toPortIndex: 2,
      ),

      NodeConnection(
        fromNodeId: 'func_q10',
        fromPortIndex: 0,
        toNodeId: 'math_mul',
        toPortIndex: 0,
      ),
      NodeConnection(
        fromNodeId: 'func_mm',
        fromPortIndex: 0,
        toNodeId: 'math_mul',
        toPortIndex: 1,
      ),

      NodeConnection(
        fromNodeId: 'math_mul',
        fromPortIndex: 0,
        toNodeId: 'out_nitri',
        toPortIndex: 0,
      ),
    ];

    _graph = LogicGraph(nodes: nodes, connections: connections);
  }

  void _initVanGenuchtenGraph() {
    _currentExample = 'vangenuchten';
    // van Genuchten vedenpidätys
    final nodes = [
      LogicNode(
        id: 'in_h',
        label: 'Pressure Head',
        type: NodeType.input,
        operation: 'moisture',
        position: const Offset(50, 80),
      ),
      LogicNode(
        id: 'const_tr',
        label: 'θr (residual)',
        type: NodeType.constant,
        value: 0.05,
        isEditable: true,
        position: const Offset(50, 180),
      ),
      LogicNode(
        id: 'const_ts',
        label: 'θs (saturated)',
        type: NodeType.constant,
        value: 0.45,
        isEditable: true,
        position: const Offset(50, 280),
      ),
      LogicNode(
        id: 'const_alpha',
        label: 'α (1/cm)',
        type: NodeType.constant,
        value: 0.036,
        isEditable: true,
        position: const Offset(50, 380),
      ),
      LogicNode(
        id: 'const_n',
        label: 'n',
        type: NodeType.constant,
        value: 1.56,
        isEditable: true,
        position: const Offset(50, 480),
      ),

      LogicNode(
        id: 'func_vg',
        label: 'van Genuchten',
        type: NodeType.function,
        operation: 'VG',
        position: const Offset(300, 280),
      ),
      LogicNode(
        id: 'out_theta',
        label: 'Water Content θ',
        type: NodeType.output,
        operation: 'out',
        position: const Offset(540, 280),
      ),
    ];

    final connections = [
      NodeConnection(
        fromNodeId: 'in_h',
        fromPortIndex: 0,
        toNodeId: 'func_vg',
        toPortIndex: 0,
      ),
      NodeConnection(
        fromNodeId: 'const_tr',
        fromPortIndex: 0,
        toNodeId: 'func_vg',
        toPortIndex: 1,
      ),
      NodeConnection(
        fromNodeId: 'const_ts',
        fromPortIndex: 0,
        toNodeId: 'func_vg',
        toPortIndex: 2,
      ),
      NodeConnection(
        fromNodeId: 'const_alpha',
        fromPortIndex: 0,
        toNodeId: 'func_vg',
        toPortIndex: 3,
      ),
      NodeConnection(
        fromNodeId: 'func_vg',
        fromPortIndex: 0,
        toNodeId: 'out_theta',
        toPortIndex: 0,
      ),
    ];

    _graph = LogicGraph(nodes: nodes, connections: connections);
  }

  void _initFarquharGraph() {
    _currentExample = 'farquhar';
    // Farquhar fotosynteesi
    final nodes = [
      LogicNode(
        id: 'const_ci',
        label: 'Ci (µmol/mol)',
        type: NodeType.constant,
        value: 250.0,
        isEditable: true,
        position: const Offset(50, 80),
      ),
      LogicNode(
        id: 'const_vcmax',
        label: 'Vcmax',
        type: NodeType.constant,
        value: 80.0,
        isEditable: true,
        position: const Offset(50, 180),
      ),
      LogicNode(
        id: 'const_kc',
        label: 'Kc',
        type: NodeType.constant,
        value: 404.0,
        isEditable: true,
        position: const Offset(50, 280),
      ),
      LogicNode(
        id: 'const_o',
        label: 'O (mmol/mol)',
        type: NodeType.constant,
        value: 210.0,
        isEditable: true,
        position: const Offset(50, 380),
      ),

      LogicNode(
        id: 'func_farq',
        label: 'Farquhar An',
        type: NodeType.function,
        operation: 'Farquhar',
        position: const Offset(300, 220),
      ),
      LogicNode(
        id: 'out_an',
        label: 'Photosynthesis',
        type: NodeType.output,
        operation: 'out',
        position: const Offset(540, 220),
      ),
    ];

    final connections = [
      NodeConnection(
        fromNodeId: 'const_ci',
        fromPortIndex: 0,
        toNodeId: 'func_farq',
        toPortIndex: 0,
      ),
      NodeConnection(
        fromNodeId: 'const_vcmax',
        fromPortIndex: 0,
        toNodeId: 'func_farq',
        toPortIndex: 1,
      ),
      NodeConnection(
        fromNodeId: 'const_kc',
        fromPortIndex: 0,
        toNodeId: 'func_farq',
        toPortIndex: 2,
      ),
      NodeConnection(
        fromNodeId: 'const_o',
        fromPortIndex: 0,
        toNodeId: 'func_farq',
        toPortIndex: 3,
      ),
      NodeConnection(
        fromNodeId: 'func_farq',
        fromPortIndex: 0,
        toNodeId: 'out_an',
        toPortIndex: 0,
      ),
    ];

    _graph = LogicGraph(nodes: nodes, connections: connections);
  }

  void _initRedoxGraph() {
    _currentExample = 'redox';
    // Redox TEA (Terminal Electron Acceptors)
    final nodes = [
      LogicNode(
        id: 'const_pe0',
        label: 'pe⁰ (O₂→H₂O)',
        type: NodeType.constant,
        value: 13.75,
        isEditable: true,
        position: const Offset(50, 80),
      ),
      LogicNode(
        id: 'in_ratio',
        label: '[red]/[ox]',
        type: NodeType.input,
        operation: 'saturation',
        position: const Offset(50, 180),
      ),
      LogicNode(
        id: 'const_n',
        label: 'Electrons (n)',
        type: NodeType.constant,
        value: 4.0,
        isEditable: true,
        position: const Offset(50, 280),
      ),

      LogicNode(
        id: 'func_redox',
        label: 'Nernst Eq.',
        type: NodeType.function,
        operation: 'Redox',
        position: const Offset(300, 180),
      ),
      LogicNode(
        id: 'out_pe',
        label: 'Redox pe',
        type: NodeType.output,
        operation: 'out',
        position: const Offset(540, 180),
      ),
    ];

    final connections = [
      NodeConnection(
        fromNodeId: 'const_pe0',
        fromPortIndex: 0,
        toNodeId: 'func_redox',
        toPortIndex: 0,
      ),
      NodeConnection(
        fromNodeId: 'in_ratio',
        fromPortIndex: 0,
        toNodeId: 'func_redox',
        toPortIndex: 1,
      ),
      NodeConnection(
        fromNodeId: 'const_n',
        fromPortIndex: 0,
        toNodeId: 'func_redox',
        toPortIndex: 2,
      ),
      NodeConnection(
        fromNodeId: 'func_redox',
        fromPortIndex: 0,
        toNodeId: 'out_pe',
        toPortIndex: 0,
      ),
    ];

    _graph = LogicGraph(nodes: nodes, connections: connections);
  }

  void _initChemotaxisGraph() {
    _currentExample = 'chemotaxis';
    final nodes = [
      LogicNode(
        id: 'const_d',
        label: 'Diff. Coeff (D)',
        type: NodeType.constant,
        value: 1.0e-9,
        isEditable: true,
        position: const Offset(50, 80),
      ),
      LogicNode(
        id: 'in_c1',
        label: 'C1 (Soil)',
        type: NodeType.input,
        operation: 'nh4',
        position: const Offset(50, 180),
      ),
      LogicNode(
        id: 'in_c2',
        label: 'C2 (Rhizosphere)',
        type: NodeType.input,
        operation: 'org_n',
        position: const Offset(50, 280),
      ),
      LogicNode(
        id: 'const_dx',
        label: 'Distance (dx)',
        type: NodeType.constant,
        value: 0.05,
        isEditable: true,
        position: const Offset(50, 380),
      ),

      LogicNode(
        id: 'func_chemo',
        label: 'Chemotaxis',
        type: NodeType.function,
        operation: 'Chemotaxis',
        position: const Offset(300, 220),
      ),
      LogicNode(
        id: 'out_flux',
        label: 'Nutrient Flux J',
        type: NodeType.output,
        operation: 'out',
        position: const Offset(540, 220),
      ),
    ];

    final connections = [
      NodeConnection(
        fromNodeId: 'const_d',
        fromPortIndex: 0,
        toNodeId: 'func_chemo',
        toPortIndex: 0,
      ),
      NodeConnection(
        fromNodeId: 'in_c1',
        fromPortIndex: 0,
        toNodeId: 'func_chemo',
        toPortIndex: 1,
      ),
      NodeConnection(
        fromNodeId: 'in_c2',
        fromPortIndex: 0,
        toNodeId: 'func_chemo',
        toPortIndex: 2,
      ),
      NodeConnection(
        fromNodeId: 'const_dx',
        fromPortIndex: 0,
        toNodeId: 'func_chemo',
        toPortIndex: 3,
      ),
      NodeConnection(
        fromNodeId: 'func_chemo',
        fromPortIndex: 0,
        toNodeId: 'out_flux',
        toPortIndex: 0,
      ),
    ];

    _graph = LogicGraph(nodes: nodes, connections: connections);
  }

  void _updateConstantValue(String nodeId, double newValue) {
    setState(() {
      final index = _graph.nodes.indexWhere((n) => n.id == nodeId);
      if (index >= 0) {
        _graph.nodes[index] = _graph.nodes[index].copyWith(value: newValue);
      }
    });
  }

  void _addNode(InputDefinition input) {
    setState(() {
      _nodeCounter++;
      final newNode = LogicNode(
        id: 'node_$_nodeCounter',
        label: input.label,
        type: NodeType.input,
        operation: input.operation,
        color: input.color,
        position: Offset(100, 100 + (_graph.nodes.length * 20.0) % 400),
      );
      _graph = LogicGraph(
        nodes: [..._graph.nodes, newNode],
        connections: _graph.connections,
      );
      _activePalette = PaletteType.none;
    });
  }

  void _addFunctionNode(FunctionDefinition func) {
    setState(() {
      _nodeCounter++;
      final newNode = LogicNode(
        id: 'node_$_nodeCounter',
        label: func.label,
        type: func.nodeType,
        operation: func.operation,
        value: func.nodeType == NodeType.constant ? 1.0 : 0.0,
        isEditable: func.nodeType == NodeType.constant,
        position: Offset(300, 100 + (_graph.nodes.length * 20.0) % 400),
      );
      _graph = LogicGraph(
        nodes: [..._graph.nodes, newNode],
        connections: _graph.connections,
      );
      _activePalette = PaletteType.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    final simulationState = ref.watch(displayedSimulationStateProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Suoritetaan laskenta aina kun simulaatio päivittyy
    _graph = LogicEvaluator.evaluate(_graph, simulationState);

    // Apply Output Actions to the simulation (Pedagogical Feedback Sandbox)
    for (final node in _graph.nodes) {
      if (node.type == NodeType.output && node.operation != null) {
        if (node.operation == 'set_irrigation') {
          Future.microtask(() {
            ref.read(simulationProvider.notifier).setPrecipitation(node.value);
          });
        }
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.logicLabTitle),
        elevation: 0,
        actions: [
          // Esimerkkivalitsin
          PopupMenuButton<String>(
            icon: const Icon(Icons.science),
            tooltip: 'Select Example',
            onSelected: (value) {
              setState(() {
                switch (value) {
                  case 'nitrification':
                    _initNitrificationGraph();
                    break;
                  case 'vangenuchten':
                    _initVanGenuchtenGraph();
                    break;
                  case 'farquhar':
                    _initFarquharGraph();
                    break;
                  case 'redox':
                    _initRedoxGraph();
                    break;
                  case 'chemotaxis':
                    _initChemotaxisGraph();
                    break;
                }
              });
            },
            itemBuilder: (context) => [
              _buildMenuItem(
                'nitrification',
                'Nitrification (Q10 × M-M)',
                Icons.thermostat,
              ),
              _buildMenuItem(
                'vangenuchten',
                'van Genuchten (θ-h)',
                Icons.water_drop,
              ),
              _buildMenuItem('farquhar', 'Farquhar (C3 Photo)', Icons.eco),
              _buildMenuItem('redox', 'Redox TEA (Nernst)', Icons.bolt),
              _buildMenuItem('chemotaxis', 'Chemotaxis (Fick)', Icons.grain),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Graph',
            onPressed: () {
              setState(() {
                switch (_currentExample) {
                  case 'nitrification':
                    _initNitrificationGraph();
                    break;
                  case 'vangenuchten':
                    _initVanGenuchtenGraph();
                    break;
                  case 'farquhar':
                    _initFarquharGraph();
                    break;
                  case 'redox':
                    _initRedoxGraph();
                    break;
                  case 'chemotaxis':
                    _initChemotaxisGraph();
                    break;
                }
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Ruudukko taustalla
          const Positioned.fill(child: GridBackground()),

          // Langat
          CustomPaint(
            size: Size.infinite,
            painter: ConnectionPainter(
              nodes: _graph.nodes,
              connections: _graph.connections,
            ),
          ),

          // Nodet
          ..._graph.nodes.map(
            (node) => NodeWidget(
              node: node,
              onDrag: (newPos) {
                setState(() {
                  final index = _graph.nodes.indexWhere((n) => n.id == node.id);
                  _graph.nodes[index] = node.copyWith(position: newPos);
                });
              },
              onValueChanged: node.type == NodeType.constant
                  ? (newValue) => _updateConstantValue(node.id, newValue)
                  : null,
            ),
          ),

          // Input-paletti
          if (_activePalette == PaletteType.inputs)
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              width: 320,
              child: InputPalette(
                onSelect: _addNode,
                onClose: () =>
                    setState(() => _activePalette = PaletteType.none),
              ),
            ),

          // Funktio-paletti
          if (_activePalette == PaletteType.functions)
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              width: 360,
              child: FunctionPalette(
                onSelect: _addFunctionNode,
                onClose: () =>
                    setState(() => _activePalette = PaletteType.none),
              ),
            ),
        ],
      ),
      // FAB for adding nodes
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'inputs',
            onPressed: () => setState(() {
              _activePalette = _activePalette == PaletteType.inputs
                  ? PaletteType.none
                  : PaletteType.inputs;
            }),
            icon: Icon(
              _activePalette == PaletteType.inputs
                  ? Icons.close
                  : Icons.sensors,
            ),
            label: Text(
              _activePalette == PaletteType.inputs ? l10n.closeAction : l10n.inputs,
            ),
            backgroundColor: _activePalette == PaletteType.inputs
                ? theme.colorScheme.surfaceContainerHighest
                : theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          FloatingActionButton.extended(
            heroTag: 'functions',
            onPressed: () => setState(() {
              _activePalette = _activePalette == PaletteType.functions
                  ? PaletteType.none
                  : PaletteType.functions;
            }),
            icon: Icon(
              _activePalette == PaletteType.functions
                  ? Icons.close
                  : Icons.functions,
            ),
            label: Text(
              _activePalette == PaletteType.functions ? l10n.closeAction : l10n.functions,
            ),
            backgroundColor: _activePalette == PaletteType.functions
                ? theme.colorScheme.surfaceContainerHighest
                : theme.colorScheme.secondary,
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(
    String value,
    String label,
    IconData icon,
  ) {
    final isSelected = _currentExample == value;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.cyan : Colors.white54,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: isSelected ? Colors.cyan : Colors.white),
          ),
        ],
      ),
    );
  }

}

class GridBackground extends StatelessWidget {
  const GridBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: GridPainter());
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.1)
      ..strokeWidth = 1.0;

    const spacing = 40.0;
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
