import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../domain/logic_lab/models.dart';
import '../../domain/logic_lab/evaluator.dart';
import '../../domain/models/biophysical_state.dart';
import '../../domain/models/soil_layer.dart';
import '../providers/simulation_provider.dart';
import '../providers/simulation_session_provider.dart';
import '../providers/ui_state_provider.dart';
import 'logic_lab/logic_lab_context.dart';
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
  LogicLabLaunchContext? _context;
  bool _routeContextLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_routeContextLoaded) return;
    _routeContextLoaded = true;

    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is LogicLabLaunchContext) {
      _context = arguments;
      _loadExample(arguments.process.exampleKey);
    } else {
      // Quick actions open the Lab without route arguments. If an inspection
      // card is still selected, keep that hotspot as the Lab context instead
      // of falling back to the generic nitrification example.
      final info = ref.read(uIStateProvider);
      if (info != null) {
        _context = LogicLabLaunchContext.fromHoverInfo(
          info: info,
          state: ref.read(displayedSimulationStateProvider),
          selectedLayerId: ref.read(simulationSessionProvider).selectedLayerId,
        );
        _loadExample(_context!.process.exampleKey);
      } else {
        _initNitrificationGraph();
      }
    }
  }

  @override
  void dispose() {
    _graphController?.dispose();
    super.dispose();
  }

  /// Loads an example without rebuilding; callers run inside [setState].
  void _loadExample(String value) {
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
    _syncHydraulicConstant(nodeId, newValue);
  }

  /// The van Genuchten constants map directly onto the selected layer's
  /// hydraulic parameters, so editing them in the Lab changes the simulation
  /// rather than only the diagram.
  void _syncHydraulicConstant(String nodeId, double value) {
    if (_currentExample != 'vangenuchten') return;
    final layerId = _targetLayerId();
    if (layerId == null) return;
    final notifier = ref.read(simulationProvider.notifier);

    switch (nodeId) {
      case 'const_tr':
        notifier.updateLayerParameter(layerId, 'thetaR', value);
        break;
      case 'const_ts':
        notifier.updateLayerParameter(
          layerId,
          'porosity',
          value.clamp(0.25, 0.65),
        );
        break;
      case 'const_alpha':
        // The graph uses 1/cm; the simulation stores 1/m.
        notifier.updateLayerParameter(
          layerId,
          'vgAlpha',
          (value * 100).clamp(0.1, 20.0),
        );
        break;
      case 'const_n':
        notifier.updateLayerParameter(
          layerId,
          'vgN',
          value.clamp(1.01, 5.0),
        );
        break;
    }
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

  /// Resolves the layer the hotspot belongs to, then the current selection,
  /// and finally the topsoil. Keeping the hotspot layer first makes the Lab
  /// location-aware even after the user taps another layer on the canvas.
  String? _targetLayerId([BiophysicalState? state]) {
    final BiophysicalState current =
        state ?? ref.read(displayedSimulationStateProvider);
    if (current.profile.layers.isEmpty) return null;

    bool exists(String id) =>
        current.profile.layers.any((layer) => layer.id == id);

    final contextLayer = _context?.layerId;
    if (contextLayer != null && exists(contextLayer)) return contextLayer;

    final selected = ref.read(simulationSessionProvider).selectedLayerId;
    if (selected != null && selected != 'atmosphere' && exists(selected)) {
      return selected;
    }
    return current.profile.layers.first.id;
  }

  String? _resolvedLayerId(BiophysicalState state, String? selectedLayerId) {
    if (state.profile.layers.isEmpty) return null;

    bool exists(String id) =>
        state.profile.layers.any((layer) => layer.id == id);

    final contextLayer = _context?.layerId;
    if (contextLayer != null && exists(contextLayer)) return contextLayer;
    if (selectedLayerId != null &&
        selectedLayerId != 'atmosphere' &&
        exists(selectedLayerId)) {
      return selectedLayerId;
    }
    return null;
  }

  SoilLayer? _layerFor(BiophysicalState state, String? layerId) {
    if (state.profile.layers.isEmpty) return null;
    if (layerId == null) return state.profile.layers.first;
    return state.profile.layers.firstWhere(
      (layer) => layer.id == layerId,
      orElse: () => state.profile.layers.first,
    );
  }

  double _linkedValue(
    BiophysicalState state,
    LogicLabSimulationLink link,
    String? layerId,
  ) {
    final layer = _layerFor(state, layerId);
    switch (link) {
      case LogicLabSimulationLink.solarRadiation:
        return state.solarRadiation.clamp(0.0, 1200.0);
      case LogicLabSimulationLink.waterContent:
        return (layer?.waterContent ?? 0.0).clamp(0.0, 1.0);
      case LogicLabSimulationLink.ammonium:
        return (layer?.ammoniumContent ?? 0.0).clamp(0.0, 100.0);
      case LogicLabSimulationLink.redoxPotential:
        return (layer?.redoxPotential ?? 0.0).clamp(-300.0, 600.0);
      case LogicLabSimulationLink.organicNitrogen:
        return (layer?.organicNitrogen ?? 0.0).clamp(0.0, 500.0);
    }
  }

  ({double min, double max}) _linkedRange(
    BiophysicalState state,
    LogicLabSimulationLink link,
    String? layerId,
  ) {
    final layer = _layerFor(state, layerId);
    switch (link) {
      case LogicLabSimulationLink.solarRadiation:
        return (min: 0.0, max: 1200.0);
      case LogicLabSimulationLink.waterContent:
        final min = layer?.thetaR ?? 0.01;
        final max = ((layer?.porosity ?? 0.45) * 0.98).clamp(min + 0.01, 1.0);
        return (min: min, max: max);
      case LogicLabSimulationLink.ammonium:
        return (min: 0.0, max: 100.0);
      case LogicLabSimulationLink.redoxPotential:
        return (min: -300.0, max: 600.0);
      case LogicLabSimulationLink.organicNitrogen:
        return (min: 0.0, max: 500.0);
    }
  }

  void _updateLinkedValue(double value) {
    final context = _context;
    if (context == null) return;
    final layerId = _targetLayerId();
    final notifier = ref.read(simulationProvider.notifier);

    switch (context.link) {
      case LogicLabSimulationLink.solarRadiation:
        notifier.updateSolarRadiation(value);
        break;
      case LogicLabSimulationLink.waterContent:
        if (layerId != null) {
          notifier.updateLayerParameter(layerId, 'waterContent', value);
        }
        break;
      case LogicLabSimulationLink.ammonium:
        if (layerId != null) {
          notifier.updateLayerParameter(layerId, 'ammoniumContent', value);
        }
        break;
      case LogicLabSimulationLink.redoxPotential:
        if (layerId != null) {
          notifier.updateLayerParameter(layerId, 'redoxPotential', value);
        }
        break;
      case LogicLabSimulationLink.organicNitrogen:
        if (layerId != null) {
          notifier.updateLayerParameter(layerId, 'organicNitrogen', value);
        }
        break;
    }
  }

  String _linkLabel(AppLocalizations l10n, LogicLabSimulationLink link) {
    switch (link) {
      case LogicLabSimulationLink.ammonium:
        return l10n.logicLabAmmonium;
      case LogicLabSimulationLink.waterContent:
        return l10n.logicLabWaterContent;
      case LogicLabSimulationLink.solarRadiation:
        return l10n.logicLabSolarRadiation;
      case LogicLabSimulationLink.redoxPotential:
        return l10n.logicLabRedoxPotential;
      case LogicLabSimulationLink.organicNitrogen:
        return l10n.logicLabOrganicNitrogen;
    }
  }

  String _linkUnit(LogicLabSimulationLink link) {
    switch (link) {
      case LogicLabSimulationLink.waterContent:
        return 'm³/m³';
      case LogicLabSimulationLink.solarRadiation:
        return 'W/m²';
      case LogicLabSimulationLink.redoxPotential:
        return 'mV';
      case LogicLabSimulationLink.ammonium:
      case LogicLabSimulationLink.organicNitrogen:
        return 'mg/kg';
    }
  }

  String _formatLinkedValue(double value, LogicLabSimulationLink link) {
    switch (link) {
      case LogicLabSimulationLink.waterContent:
        return value.toStringAsFixed(3);
      case LogicLabSimulationLink.redoxPotential:
        return value.toStringAsFixed(0);
      case LogicLabSimulationLink.solarRadiation:
      case LogicLabSimulationLink.ammonium:
      case LogicLabSimulationLink.organicNitrogen:
        return value.toStringAsFixed(1);
    }
  }

  String _processLabel(AppLocalizations l10n, LogicLabProcess process) {
    switch (process) {
      case LogicLabProcess.nitrification:
        return l10n.nitrificationTitle;
      case LogicLabProcess.waterRetention:
        return l10n.waterFlux;
      case LogicLabProcess.photosynthesis:
        return l10n.photosynthesis;
      case LogicLabProcess.redox:
        return l10n.redoxPotentialTitle;
      case LogicLabProcess.diffusion:
        return l10n.diffusionTitle;
    }
  }

  Widget _buildContextBanner(
    BuildContext context,
    AppLocalizations l10n,
    BiophysicalState state,
    String? layerId,
    LogicGraph evaluatedGraph,
  ) {
    final hotspot = _context!;
    final theme = Theme.of(context);
    final accent = hotspot.accentColor ?? theme.colorScheme.primary;
    final layer = _layerFor(state, layerId);
    final outputNodes = evaluatedGraph.nodes
        .where((node) => node.type == NodeType.output)
        .toList();
    final liveValue = outputNodes.isEmpty ? null : outputNodes.first.value;
    final link = hotspot.link;
    final linkValue = _linkedValue(state, link, layerId);
    final range = _linkedRange(state, link, layerId);
    final location = layer?.name.isNotEmpty == true
        ? layer!.name
        : (layerId ?? l10n.layerLabel);
    final locatedAt = hotspot.isAtmosphere
        ? l10n.atmosphere
        : '${l10n.layerLabel}: $location';
    final stats = hotspot.stats.entries.take(5).toList();

    return Material(
      color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.96),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: accent.withValues(alpha: 0.35)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.link_rounded, size: 16, color: accent),
                const SizedBox(width: 6),
                Text(
                  l10n.logicLabLinkedHotspot.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    locatedAt,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    hotspot.title.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _processLabel(l10n, hotspot.process),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (hotspot.description.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                hotspot.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
            ],
            if (stats.isNotEmpty || liveValue != null) ...[
              const SizedBox(height: 7),
              SizedBox(
                height: 28,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: stats.length + (liveValue == null ? 0 : 1),
                  separatorBuilder: (_, _) => const SizedBox(width: 6),
                  itemBuilder: (context, index) {
                    if (index == stats.length) {
                      return _bannerChip(
                        l10n.logicLabLiveResult,
                        liveValue!.toStringAsPrecision(3),
                        accent,
                      );
                    }
                    final entry = stats[index];
                    return _bannerChip(entry.key, entry.value, accent);
                  },
                ),
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.bolt_rounded, size: 14, color: accent),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _linkLabel(l10n, link),
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${_formatLinkedValue(linkValue, link)} ${_linkUnit(link)}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2.5,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              ),
              child: Slider(
                value: linkValue.clamp(range.min, range.max),
                min: range.min,
                max: range.max,
                activeColor: accent,
                onChanged: _updateLinkedValue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bannerChip(String label, String value, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final simulationState = ref.watch(displayedSimulationStateProvider);
    final selectedLayerId = ref.watch(
      simulationSessionProvider.select((session) => session.selectedLayerId),
    );
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final layerId = _resolvedLayerId(simulationState, selectedLayerId);

    // Evaluate for display only. The authored graph is the source of truth,
    // and build() must not issue simulation commands: doing so re-applied
    // irrigation on every unrelated rebuild.
    final evaluatedGraph = LogicEvaluator.evaluate(
      _graph,
      simulationState,
      layerId: layerId,
    );

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
                _context = null;
                _loadExample(value);
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
              setState(() => _loadExample(_currentExample));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_context != null)
            _buildContextBanner(
              context,
              l10n,
              simulationState,
              layerId,
              evaluatedGraph,
            ),
          Expanded(
            child: Stack(
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
                                      ? (newValue) => _updateConstantValue(
                                          node.id,
                                          newValue,
                                        )
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
