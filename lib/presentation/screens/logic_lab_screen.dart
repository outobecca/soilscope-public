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

part 'logic_lab/logic_lab_examples.dart';
part 'logic_lab/grid_background.dart';

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
  TransformationController? _graphController;

  @override
  void initState() {
    super.initState();
    _initNitrificationGraph();
  }

  @override
  void dispose() {
    _graphController?.dispose();
    super.dispose();
  }

  /// Keeps the palette usable when the screen is narrower than its width.
  double _paletteWidth(BuildContext context, double preferred) {
    final width = MediaQuery.sizeOf(context).width;
    return width < 600 ? width * 0.85 : preferred;
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
    final isFi = Localizations.localeOf(context).languageCode == 'fi';
    setState(() {
      _nodeCounter++;
      final newNode = LogicNode(
        id: 'node_$_nodeCounter',
        label: input.labelFor(isFi),
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
    final isFi = Localizations.localeOf(context).languageCode == 'fi';
    setState(() {
      _nodeCounter++;
      final newNode = LogicNode(
        id: 'node_$_nodeCounter',
        label: func.labelFor(isFi),
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

  /// The single explicit side effect of the written graph.
  void _applyOutputsToSimulation() {
    final outputs = _graph.nodes.where(
      (n) => n.type == NodeType.output && n.operation == 'set_irrigation',
    );
    for (final node in outputs) {
      ref.read(simulationProvider.notifier).setPrecipitation(node.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final simulationState = ref.watch(displayedSimulationStateProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Evaluate for display only. The authored graph is the source of truth,
    // and build() must not issue simulation commands: doing so re-applied
    // irrigation on every unrelated rebuild.
    final evaluatedGraph = LogicEvaluator.evaluate(_graph, simulationState);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.logicLabTitle),
        elevation: 0,
        actions: [
          if (_graph.nodes.any(
            (n) => n.type == NodeType.output && n.operation == 'set_irrigation',
          ))
            IconButton(
              icon: const Icon(Icons.play_circle_outline),
              tooltip: l10n.applyToSimulation,
              onPressed: _applyOutputsToSimulation,
            ),
          // Esimerkkivalitsin
          PopupMenuButton<String>(
            icon: const Icon(Icons.science),
            tooltip: l10n.selectExample,
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
            tooltip: l10n.resetGraph,
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
          // The canvas is pannable and zoomable; the node layout is wider than
          // a phone screen, so this is what makes it reachable on mobile.
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final fitScale = (constraints.maxWidth / 1200)
                    .clamp(0.35, 1.0)
                    .toDouble();
                _graphController ??= TransformationController(
                  Matrix4.diagonal3Values(fitScale, fitScale, 1),
                );
                return InteractiveViewer(
                  transformationController: _graphController,
                  constrained: false,
                  minScale: 0.25,
                  maxScale: 2.5,
                  boundaryMargin: const EdgeInsets.all(600),
                  child: SizedBox(
                    width: 1200,
                    height: 900,
                    child: Stack(
                      children: [
                        // Ruudukko taustalla
                        const Positioned.fill(child: GridBackground()),

                        // Langat
                        CustomPaint(
                          size: Size.infinite,
                          painter: ConnectionPainter(
                            nodes: evaluatedGraph.nodes,
                            connections: evaluatedGraph.connections,
                          ),
                        ),

                        // Nodet
                        ...evaluatedGraph.nodes.map(
                          (node) => NodeWidget(
                            node: node,
                            onDrag: (newPos) {
                              setState(() {
                                final index = _graph.nodes.indexWhere(
                                  (n) => n.id == node.id,
                                );
                                _graph.nodes[index] = node.copyWith(
                                  position: newPos,
                                );
                              });
                            },
                            onValueChanged: node.type == NodeType.constant
                                ? (newValue) =>
                                      _updateConstantValue(node.id, newValue)
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Input-paletti
          if (_activePalette == PaletteType.inputs)
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              width: _paletteWidth(context, 320),
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
              width: _paletteWidth(context, 360),
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
              _activePalette == PaletteType.inputs
                  ? l10n.closeAction
                  : l10n.inputs,
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
              _activePalette == PaletteType.functions
                  ? l10n.closeAction
                  : l10n.functions,
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
