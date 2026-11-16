part of '../logic_lab_screen.dart';

/// Example graphs for the Logic Lab. Kept apart from the screen lifecycle
/// so the widget file stays focused on interaction and layout.
extension _LogicLabExamples on _LogicLabScreenState {
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
    // Seed the hydraulic constants from the selected layer. Without this the
    // graph uses the generic textbook defaults and no longer agrees with the
    // layer's water content even though its input is layer-derived.
    final state = ref.read(displayedSimulationStateProvider);
    final layer = _layerFor(state, _targetLayerId(state));
    final thetaR = (layer?.thetaR ?? 0.05).clamp(0.0, 0.4);
    final thetaS = (layer?.porosity ?? 0.45).clamp(
      (thetaR + 0.01).clamp(0.0, 1.0),
      1.0,
    );
    // The simulation stores alpha in 1/m; this graph works in 1/cm.
    final alpha = ((layer?.vgAlpha ?? 3.6) / 100.0).clamp(0.001, 0.5);
    final n = (layer?.vgN ?? 1.56).clamp(1.01, 5.0);

    // van Genuchten vedenpidätys
    final nodes = [
      LogicNode(
        id: 'in_h',
        label: 'Matric Head h (cm)',
        type: NodeType.input,
        operation: 'matric_head',
        position: const Offset(50, 80),
      ),
      LogicNode(
        id: 'const_tr',
        label: 'θr (residual)',
        type: NodeType.constant,
        value: thetaR,
        isEditable: true,
        position: const Offset(50, 180),
      ),
      LogicNode(
        id: 'const_ts',
        label: 'θs (saturated)',
        type: NodeType.constant,
        value: thetaS,
        isEditable: true,
        position: const Offset(50, 280),
      ),
      LogicNode(
        id: 'const_alpha',
        label: 'α (1/cm)',
        type: NodeType.constant,
        value: alpha,
        isEditable: true,
        position: const Offset(50, 380),
      ),
      LogicNode(
        id: 'const_n',
        label: 'n',
        type: NodeType.constant,
        value: n,
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
        fromNodeId: 'const_n',
        fromPortIndex: 0,
        toNodeId: 'func_vg',
        toPortIndex: 4,
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
}
