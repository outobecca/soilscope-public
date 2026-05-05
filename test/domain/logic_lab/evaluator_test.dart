import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/domain/logic_lab/models.dart';
import 'package:soilscope/domain/logic_lab/evaluator.dart';
import 'package:soilscope/domain/models/biophysical_state.dart';
import 'package:soilscope/domain/models/soil_profile.dart';
import 'package:soilscope/domain/models/soil_layer.dart';
import 'package:soilscope/domain/models/plant.dart';

/// Luo testitila LogicEvaluator-testeille.
BiophysicalState _createTestState() {
  final layer = SoilLayer(
    id: 'layer1',
    depth: 0.0,
    thickness: 0.2,
    kSat: 1e-5,
    porosity: 0.45,
    thetaR: 0.05,
    vgAlpha: 0.036,
    vgN: 1.56,
    bulkDensity: 1300,
    waterContent: 0.25,
    temperature: 293.15, // 20°C
    heatCapacity: 1500,
    ph: 6.5,
    ec: 0.5,
    redoxPotential: 400,
    nitrateContent: 50,
    ammoniumContent: 20,
    phosphateContent: 5,
    sandFraction: 0.4,
    siltFraction: 0.3,
    clayFraction: 0.3,
    particulateOrganicMatter: 10.0,
    maomNitrogen: 10.0,
    microbialBiomass: 10.0,
    fungalHyphaeDensity: 10.0,
    aggregateStability: 0.5,
    epsContent: 10.0,
    necromass: 10.0,
    organicCarbon: 10.0,
    mineralAssociatedOrganicMatter: 10.0,
    nitrogenContent: 1.0,
  );

  return BiophysicalState(
    profile: SoilProfile(
      id: 'test',
      name: 'Test Profile',
      surfaceAlbedo: 0.1,
      slope: 0.0,
      layers: [layer],
    ),
    plants: [const Plant(
      id: 'test_plant',
      species: 'Test',
      age: 30,
      height: 0.5,
      lai: 2.0,
      turgorPressure: 0.8,
      rootSystem: [],
      nitrogenUptake: 0.1,
      waterUptake: 0.01,
    )],
    timeElapsed: 0.0,
    precipitation: 0.0,
  );
}

void main() {
  group('LogicEvaluator', () {
    late BiophysicalState testState;

    setUp(() {
      testState = _createTestState();
    });

    test('Q10 function calculates temperature effect correctly', () {
      // Q10 = 2 @ 20°C → kerroin = 1.0
      // Q10 = 2 @ 30°C → kerroin = 2.0
      // Q10 = 2 @ 10°C → kerroin = 0.5
      final graph = LogicGraph(
        nodes: [
          LogicNode(
            id: 'temp',
            label: 'Temp',
            type: NodeType.constant,
            value: 30.0,
          ),
          LogicNode(
            id: 'q10',
            label: 'Q10',
            type: NodeType.constant,
            value: 2.0,
          ),
          LogicNode(
            id: 'func',
            label: 'Q10 Func',
            type: NodeType.function,
            operation: 'Q10',
          ),
        ],
        connections: [
          NodeConnection(
            fromNodeId: 'temp',
            fromPortIndex: 0,
            toNodeId: 'func',
            toPortIndex: 0,
          ),
          NodeConnection(
            fromNodeId: 'q10',
            fromPortIndex: 0,
            toNodeId: 'func',
            toPortIndex: 1,
          ),
        ],
      );

      final result = LogicEvaluator.evaluate(graph, testState);
      final funcNode = result.nodes.firstWhere((n) => n.id == 'func');

      // 30°C, Q10=2: 2^((30-20)/10) = 2^1 = 2.0
      expect(funcNode.value, closeTo(2.0, 0.001));
    });

    test('Michaelis-Menten calculates enzyme kinetics', () {
      // v = Vmax * S / (Km + S)
      // Vmax=1, S=10, Km=10 → v = 1 * 10 / (10 + 10) = 0.5
      final graph = LogicGraph(
        nodes: [
          LogicNode(id: 's', label: 'S', type: NodeType.constant, value: 10.0),
          LogicNode(
            id: 'vmax',
            label: 'Vmax',
            type: NodeType.constant,
            value: 1.0,
          ),
          LogicNode(
            id: 'km',
            label: 'Km',
            type: NodeType.constant,
            value: 10.0,
          ),
          LogicNode(
            id: 'func',
            label: 'MM',
            type: NodeType.function,
            operation: 'MM',
          ),
        ],
        connections: [
          NodeConnection(
            fromNodeId: 's',
            fromPortIndex: 0,
            toNodeId: 'func',
            toPortIndex: 0,
          ),
          NodeConnection(
            fromNodeId: 'vmax',
            fromPortIndex: 0,
            toNodeId: 'func',
            toPortIndex: 1,
          ),
          NodeConnection(
            fromNodeId: 'km',
            fromPortIndex: 0,
            toNodeId: 'func',
            toPortIndex: 2,
          ),
        ],
      );

      final result = LogicEvaluator.evaluate(graph, testState);
      final funcNode = result.nodes.firstWhere((n) => n.id == 'func');

      expect(funcNode.value, closeTo(0.5, 0.001));
    });

    test('van Genuchten calculates water retention', () {
      // θ(h) = θr + (θs - θr) / [1 + |αh|^n]^m
      // h=100cm, θr=0.05, θs=0.45, α=0.036, n=1.56
      final graph = LogicGraph(
        nodes: [
          LogicNode(id: 'h', label: 'h', type: NodeType.constant, value: 100.0),
          LogicNode(
            id: 'tr',
            label: 'θr',
            type: NodeType.constant,
            value: 0.05,
          ),
          LogicNode(
            id: 'ts',
            label: 'θs',
            type: NodeType.constant,
            value: 0.45,
          ),
          LogicNode(
            id: 'alpha',
            label: 'α',
            type: NodeType.constant,
            value: 0.036,
          ),
          LogicNode(
            id: 'func',
            label: 'VG',
            type: NodeType.function,
            operation: 'VG',
          ),
        ],
        connections: [
          NodeConnection(
            fromNodeId: 'h',
            fromPortIndex: 0,
            toNodeId: 'func',
            toPortIndex: 0,
          ),
          NodeConnection(
            fromNodeId: 'tr',
            fromPortIndex: 0,
            toNodeId: 'func',
            toPortIndex: 1,
          ),
          NodeConnection(
            fromNodeId: 'ts',
            fromPortIndex: 0,
            toNodeId: 'func',
            toPortIndex: 2,
          ),
          NodeConnection(
            fromNodeId: 'alpha',
            fromPortIndex: 0,
            toNodeId: 'func',
            toPortIndex: 3,
          ),
        ],
      );

      final result = LogicEvaluator.evaluate(graph, testState);
      final funcNode = result.nodes.firstWhere((n) => n.id == 'func');

      // Tarkistetaan että arvo on välillä θr < θ < θs
      expect(funcNode.value, greaterThan(0.05));
      expect(funcNode.value, lessThan(0.45));
    });

    test('Farquhar calculates photosynthesis rate', () {
      // Ac = Vcmax × (Ci - Γ*) / (Ci + Kc(1 + O/Ko))
      final graph = LogicGraph(
        nodes: [
          LogicNode(
            id: 'ci',
            label: 'Ci',
            type: NodeType.constant,
            value: 250.0,
          ),
          LogicNode(
            id: 'vcmax',
            label: 'Vcmax',
            type: NodeType.constant,
            value: 80.0,
          ),
          LogicNode(
            id: 'kc',
            label: 'Kc',
            type: NodeType.constant,
            value: 404.0,
          ),
          LogicNode(id: 'o', label: 'O', type: NodeType.constant, value: 210.0),
          LogicNode(
            id: 'func',
            label: 'Farquhar',
            type: NodeType.function,
            operation: 'Farquhar',
          ),
        ],
        connections: [
          NodeConnection(
            fromNodeId: 'ci',
            fromPortIndex: 0,
            toNodeId: 'func',
            toPortIndex: 0,
          ),
          NodeConnection(
            fromNodeId: 'vcmax',
            fromPortIndex: 0,
            toNodeId: 'func',
            toPortIndex: 1,
          ),
          NodeConnection(
            fromNodeId: 'kc',
            fromPortIndex: 0,
            toNodeId: 'func',
            toPortIndex: 2,
          ),
          NodeConnection(
            fromNodeId: 'o',
            fromPortIndex: 0,
            toNodeId: 'func',
            toPortIndex: 3,
          ),
        ],
      );

      final result = LogicEvaluator.evaluate(graph, testState);
      final funcNode = result.nodes.firstWhere((n) => n.id == 'func');

      // Tarkistetaan että tulos on positiivinen ja järkevä
      expect(funcNode.value, greaterThan(0));
      expect(funcNode.value, lessThan(100)); // Tyypillinen max ~80 µmol/m²/s
    });

    test('Redox (Nernst) calculates pe correctly', () {
      // pe = pe0 - (1/n) × log10([red]/[ox])
      // pe0=13.75, ratio=1, n=4 → pe = 13.75 - 0 = 13.75
      final graph = LogicGraph(
        nodes: [
          LogicNode(
            id: 'pe0',
            label: 'pe0',
            type: NodeType.constant,
            value: 13.75,
          ),
          LogicNode(
            id: 'ratio',
            label: 'ratio',
            type: NodeType.constant,
            value: 1.0,
          ),
          LogicNode(id: 'n', label: 'n', type: NodeType.constant, value: 4.0),
          LogicNode(
            id: 'func',
            label: 'Redox',
            type: NodeType.function,
            operation: 'Redox',
          ),
        ],
        connections: [
          NodeConnection(
            fromNodeId: 'pe0',
            fromPortIndex: 0,
            toNodeId: 'func',
            toPortIndex: 0,
          ),
          NodeConnection(
            fromNodeId: 'ratio',
            fromPortIndex: 0,
            toNodeId: 'func',
            toPortIndex: 1,
          ),
          NodeConnection(
            fromNodeId: 'n',
            fromPortIndex: 0,
            toNodeId: 'func',
            toPortIndex: 2,
          ),
        ],
      );

      final result = LogicEvaluator.evaluate(graph, testState);
      final funcNode = result.nodes.firstWhere((n) => n.id == 'func');

      // ratio=1 → log(1)=0 → pe = pe0
      expect(funcNode.value, closeTo(13.75, 0.001));
    });

    test('Input nodes read simulation state', () {
      final graph = LogicGraph(
        nodes: [
          LogicNode(
            id: 'temp',
            label: 'Temp',
            type: NodeType.input,
            operation: 'temp',
          ),
          LogicNode(
            id: 'moist',
            label: 'Moisture',
            type: NodeType.input,
            operation: 'moisture',
          ),
          LogicNode(
            id: 'ph',
            label: 'pH',
            type: NodeType.input,
            operation: 'ph',
          ),
        ],
        connections: [],
      );

      final result = LogicEvaluator.evaluate(graph, testState);

      final tempNode = result.nodes.firstWhere((n) => n.id == 'temp');
      final moistNode = result.nodes.firstWhere((n) => n.id == 'moist');
      final phNode = result.nodes.firstWhere((n) => n.id == 'ph');

      expect(tempNode.value, closeTo(20.0, 0.1)); // 293.15K - 273.15 = 20°C
      expect(moistNode.value, closeTo(0.25, 0.001));
      expect(phNode.value, closeTo(6.5, 0.001));
    });

    test('Math operations work correctly', () {
      final graph = LogicGraph(
        nodes: [
          LogicNode(id: 'a', label: 'A', type: NodeType.constant, value: 10.0),
          LogicNode(id: 'b', label: 'B', type: NodeType.constant, value: 5.0),
          LogicNode(
            id: 'add',
            label: 'Add',
            type: NodeType.math,
            operation: '+',
          ),
          LogicNode(
            id: 'mul',
            label: 'Mul',
            type: NodeType.math,
            operation: '*',
          ),
          LogicNode(
            id: 'sub',
            label: 'Sub',
            type: NodeType.math,
            operation: '-',
          ),
          LogicNode(
            id: 'div',
            label: 'Div',
            type: NodeType.math,
            operation: '/',
          ),
        ],
        connections: [
          NodeConnection(
            fromNodeId: 'a',
            fromPortIndex: 0,
            toNodeId: 'add',
            toPortIndex: 0,
          ),
          NodeConnection(
            fromNodeId: 'b',
            fromPortIndex: 0,
            toNodeId: 'add',
            toPortIndex: 1,
          ),
          NodeConnection(
            fromNodeId: 'a',
            fromPortIndex: 0,
            toNodeId: 'mul',
            toPortIndex: 0,
          ),
          NodeConnection(
            fromNodeId: 'b',
            fromPortIndex: 0,
            toNodeId: 'mul',
            toPortIndex: 1,
          ),
          NodeConnection(
            fromNodeId: 'a',
            fromPortIndex: 0,
            toNodeId: 'sub',
            toPortIndex: 0,
          ),
          NodeConnection(
            fromNodeId: 'b',
            fromPortIndex: 0,
            toNodeId: 'sub',
            toPortIndex: 1,
          ),
          NodeConnection(
            fromNodeId: 'a',
            fromPortIndex: 0,
            toNodeId: 'div',
            toPortIndex: 0,
          ),
          NodeConnection(
            fromNodeId: 'b',
            fromPortIndex: 0,
            toNodeId: 'div',
            toPortIndex: 1,
          ),
        ],
      );

      final result = LogicEvaluator.evaluate(graph, testState);

      expect(
        result.nodes.firstWhere((n) => n.id == 'add').value,
        closeTo(15.0, 0.001),
      );
      expect(
        result.nodes.firstWhere((n) => n.id == 'mul').value,
        closeTo(50.0, 0.001),
      );
      expect(
        result.nodes.firstWhere((n) => n.id == 'sub').value,
        closeTo(5.0, 0.001),
      );
      expect(
        result.nodes.firstWhere((n) => n.id == 'div').value,
        closeTo(2.0, 0.001),
      );
    });
  });

  group('LogicNode', () {
    test('inputPortCount returns correct count for functions', () {
      expect(getInputPortCount('Q10', NodeType.function), 2);
      expect(getInputPortCount('MM', NodeType.function), 3);
      expect(getInputPortCount('VG', NodeType.function), 4);
      expect(getInputPortCount('Farquhar', NodeType.function), 4);
      expect(getInputPortCount('Redox', NodeType.function), 3);
      expect(getInputPortCount('+', NodeType.math), 2);
      expect(getInputPortCount(null, NodeType.input), 0);
      expect(getInputPortCount(null, NodeType.constant), 0);
    });

    test('getPortLabel returns correct labels', () {
      expect(getPortLabel('Q10', 0, true), 'T');
      expect(getPortLabel('Q10', 1, true), 'Q₁₀');
      expect(getPortLabel('MM', 0, true), '[S]');
      expect(getPortLabel('MM', 1, true), 'Vmax');
      expect(getPortLabel('MM', 2, true), 'Km');
      expect(getPortLabel('Farquhar', 0, true), 'Ci');
    });
  });
}
