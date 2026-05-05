import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../domain/logic_lab/models.dart';
import '../../../l10n/app_localizations.dart';

class NodeWidget extends StatelessWidget {
  final LogicNode node;
  final Function(Offset) onDrag;
  final Function(double)? onValueChanged;

  const NodeWidget({
    super.key,
    required this.node,
    required this.onDrag,
    this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final inputPorts = node.inputPortCount;
    final hasOutput = node.hasOutput;
    // Korkeus riippuu porttien määrästä
    final minHeight = 80.0 + (inputPorts > 2 ? (inputPorts - 2) * 20.0 : 0.0);

    return Positioned(
      left: node.position.dx,
      top: node.position.dy,
      child: Tooltip(
        message: _getTooltipMessage(l10n),
        child: GestureDetector(
          onPanUpdate: (details) => onDrag(node.position + details.delta),
          child: Container(
            width: 160,
            constraints: BoxConstraints(minHeight: minHeight),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _getNodeColor().withValues(alpha: 0.6),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _getNodeColor().withValues(alpha: 0.25),
                  blurRadius: 12,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                _buildHeader(),
                const Divider(height: 1, color: Colors.white24),

                // Body with ports
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Input ports (left side)
                      if (inputPorts > 0)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                            inputPorts,
                            (i) => _buildPort(
                              getPortLabel(node.operation, i, true),
                              isInput: true,
                              index: i,
                            ),
                          ),
                        ),

                      const Spacer(),

                      // Output port (right side)
                      if (hasOutput) _buildPort('out', isInput: false, index: 0),
                    ],
                  ),
                ),

                // Value display / editor
                _buildValueSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _getNodeColor().withValues(alpha: 0.15),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Row(
        children: [
          Icon(_getNodeIcon(), color: _getNodeColor(), size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              node.label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPort(String label, {required bool isInput, required int index}) {
    final color = isInput ? Colors.cyan : Colors.greenAccent;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isInput) ...[
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.8),
                border: Border.all(color: color, width: 1.5),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 10,
                fontFamily: 'monospace',
              ),
            ),
          ] else ...[
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 10,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.8),
                border: Border.all(color: color, width: 1.5),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildValueSection() {
    final isEditable = node.type == NodeType.constant;

    return Container(
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(6),
        border: isEditable
            ? Border.all(color: Colors.amber.withValues(alpha: 0.5), width: 1)
            : null,
      ),
      child: Row(
        children: [
          if (isEditable) const Icon(Icons.edit, size: 12, color: Colors.amber),
          if (isEditable) const SizedBox(width: 4),
          Expanded(
            child: isEditable
                ? _EditableValueField(
                    value: node.value,
                    onChanged: onValueChanged,
                  )
                : Text(
                    _formatValueWithUnit(node.value),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: _getNodeColor(),
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _formatValueWithUnit(double value) {
    final formattedValue = _formatValue(value);
    if (node.type == NodeType.output) {
      final unit = _getOutputUnit();
      return '$formattedValue $unit'.trim();
    }
    return formattedValue;
  }

  String _getOutputUnit() {
    final label = node.label.toLowerCase();
    if (label.contains('nitrification')) {
      return 'mol/m²/s';
    } else if (label.contains('theta') || label.contains('water content') || label.contains('moisture')) {
      return 'm³/m³';
    } else if (label.contains('photosynthesis') || label.contains('photo')) {
      return 'µmol/m²/s';
    } else if (label.contains('pe')) {
      return 'pe';
    } else if (label.contains('eh')) {
      return 'mV';
    }
    return '';
  }

  String _getTooltipMessage(AppLocalizations l10n) {
    String name = node.label;
    String? functionStr;

    if (node.type == NodeType.input) {
      name = _getInputFullName(node.operation, l10n);
    }

    switch (node.operation) {
      case 'Q10':
        name = l10n.tempFactor;
        functionStr = 'f(T) = Q10^((T - 20) / 10)';
        break;
      case 'MM':
        name = l10n.mmKinetics;
        functionStr = 'v = Vmax * [S] / (Km + [S])';
        break;
      case 'VG':
        name = l10n.vgWaterRetention;
        functionStr = 'θ(h) = θr + (θs - θr) / [1 + |αh|^n]^m';
        break;
      case 'Farquhar':
        name = l10n.farquharPhotosynthesis;
        functionStr = 'Ac = Vcmax * (Ci - Γ*) / (Ci + Kc(1 + O/Ko))';
        break;
      case 'Redox':
        name = l10n.nernstRedox;
        functionStr = 'pe = pe0 - (1/n) * log10([red]/[ox])';
        break;
      case '+':
        functionStr = 'a + b';
        break;
      case '-':
        functionStr = 'a - b';
        break;
      case '*':
        functionStr = 'a * b';
        break;
      case '/':
        functionStr = 'a / b';
        break;
    }

    if (functionStr != null) {
      return '$name\nFormula: $functionStr';
    }
    return name;
  }

  String _getInputFullName(String? op, AppLocalizations l10n) {
    switch (op) {
      case 'temp': return l10n.soilTempCelsius;
      case 'moisture': return l10n.soilWaterContentPressureHead;
      case 'saturation': return l10n.soilWaterSaturation;
      case 'nh4': return l10n.ammoniumContentLabel;
      case 'no3': return l10n.nitrateContentLabel;
      case 'o2': return l10n.oxygenContentLabel;
      case 'co2': return l10n.co2ContentLabel;
      default: return node.label;
    }
  }

  String _formatValue(double value) {
    if (value.abs() >= 1000) {
      return value.toStringAsExponential(2);
    } else if (value.abs() < 0.01 && value != 0) {
      return value.toStringAsExponential(2);
    }
    return value.toStringAsFixed(3);
  }

  Color _getNodeColor() {
    if (node.color != null) return node.color!;

    switch (node.type) {
      case NodeType.input:
        return Colors.blueAccent;
      case NodeType.constant:
        return Colors.amber;
      case NodeType.math:
        return Colors.orangeAccent;
      case NodeType.function:
        return Colors.purpleAccent;
      case NodeType.output:
        return Colors.greenAccent;
    }
  }

  IconData _getNodeIcon() {
    switch (node.type) {
      case NodeType.input:
        return Icons.sensors;
      case NodeType.constant:
        return Icons.pin;
      case NodeType.math:
        return Icons.calculate;
      case NodeType.function:
        return Icons.hub;
      case NodeType.output:
        return Icons.output;
    }
  }
}

/// Muokattava numeroarvo constant-nodeille.
class _EditableValueField extends StatefulWidget {
  final double value;
  final Function(double)? onChanged;

  const _EditableValueField({required this.value, this.onChanged});

  @override
  State<_EditableValueField> createState() => _EditableValueFieldState();
}

class _EditableValueFieldState extends State<_EditableValueField> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toStringAsFixed(2));
  }

  @override
  void didUpdateWidget(_EditableValueField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isEditing && oldWidget.value != widget.value) {
      _controller.text = widget.value.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _isEditing = false);
    final parsed = double.tryParse(_controller.text);
    if (parsed != null && widget.onChanged != null) {
      widget.onChanged!(parsed);
    } else {
      _controller.text = widget.value.toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isEditing = true),
      child: _isEditing
          ? TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.\-]')),
              ],
              style: const TextStyle(
                color: Colors.amber,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _submit(),
              onEditingComplete: _submit,
            )
          : Text(
              widget.value.toStringAsFixed(2),
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.amber,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
    );
  }
}
