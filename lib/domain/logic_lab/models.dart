import 'package:flutter/material.dart';

/// Tuetut node-tyypit.
enum NodeType {
  input, // Simulaatiodata (temp, moisture, pH)
  constant, // Kiinteä luku (esim. Vmax)
  math, // Peruslasku (+, -, *, /)
  function, // Monimutkainen (Q10, Michaelis-Menten, van Genuchten, Farquhar)
  output, // Lopputulos (reaktionopeus)
}

/// Portille kuuluva tieto.
class NodePort {
  final String label;
  final PortType type;
  final int index;

  const NodePort({
    required this.label,
    required this.type,
    required this.index,
  });
}

/// Palauttaa noden sisääntulevien porttien lukumäärän.
int getInputPortCount(String? operation, NodeType type) {
  if (type == NodeType.input || type == NodeType.constant) return 0;
  if (type == NodeType.output) return 1;

  switch (operation) {
    case '+':
    case '*':
    case '-':
    case '/':
      return 2;
    case 'Q10':
      return 2; // temp, base
    case 'MM':
      return 3; // S, Vmax, Km
    case 'VG':
      return 4; // h, θr, θs, α
    case 'Farquhar':
      return 4; // Ci, Vcmax, Kc, O
    case 'Redox':
      return 3; // pe0, [red]/[ox] ratio, n
    case 'Chemotaxis':
      return 4; // D, C1, C2, dx
    case 'CostBenefit':
      return 3; // C, D, P
    default:
      return 1;
  }
}

/// Palauttaa portin nimen operaation ja indeksin perusteella.
String getPortLabel(String? operation, int index, bool isInput) {
  if (!isInput) return 'out';

  switch (operation) {
    case 'Q10':
      return ['T', 'Q₁₀'][index];
    case 'MM':
      return ['[S]', 'Vmax', 'Km'][index];
    case 'VG':
      return ['h', 'θr', 'θs', 'α'][index];
    case 'Farquhar':
      return ['Ci', 'Vcmax', 'Kc', 'O'][index];
    case 'Redox':
      return ['pe₀', 'ratio', 'n'][index];
    case 'Chemotaxis':
      return ['D', 'C₁', 'C₂', 'dx'][index];
    case 'CostBenefit':
      return ['C', 'D', 'P'][index];
    case '+':
    case '*':
      return ['a', 'b'][index];
    case '-':
    case '/':
      return ['a', 'b'][index];
    default:
      return 'in$index';
  }
}

/// Node-portin tyyppi (sisään/ulos).
enum PortType { input, output }

/// Node-yhteys (lanka kahden portin välillä).
class NodeConnection {
  final String fromNodeId;
  final int fromPortIndex;
  final String toNodeId;
  final int toPortIndex;

  NodeConnection({
    required this.fromNodeId,
    required this.fromPortIndex,
    required this.toNodeId,
    required this.toPortIndex,
  });
}

/// Yksittäinen logiikkanode.
class LogicNode {
  final String id;
  final String label;
  final NodeType type;
  Offset position;
  final List<double> inputs;
  final String? operation; // Esim. '+', 'Q10', 'VG', 'Farquhar', 'Redox'
  final double value;
  final bool isEditable; // Constant-nodet ovat muokattavissa
  final Color? color; // Valinnainen väri (esim. CPK-standardi)

  LogicNode({
    required this.id,
    required this.label,
    required this.type,
    this.position = Offset.zero,
    this.inputs = const [],
    this.operation,
    this.value = 0.0,
    this.isEditable = false,
    this.color,
  });

  /// Palauttaa sisääntulevien porttien lukumäärän.
  int get inputPortCount => getInputPortCount(operation, type);

  /// Palauttaa true jos nodella on ulostuloporetti.
  bool get hasOutput => type != NodeType.output;

  /// Kopioi noden uudella positiolla tai arvolla.
  LogicNode copyWith({
    Offset? position,
    double? value,
    bool? isEditable,
    Color? color,
  }) {
    return LogicNode(
      id: id,
      label: label,
      type: type,
      position: position ?? this.position,
      inputs: inputs,
      operation: operation,
      value: value ?? this.value,
      isEditable: isEditable ?? this.isEditable,
      color: color ?? this.color,
    );
  }
}

/// Koko logiikkagraafi.
class LogicGraph {
  final List<LogicNode> nodes;
  final List<NodeConnection> connections;

  LogicGraph({required this.nodes, required this.connections});
}
