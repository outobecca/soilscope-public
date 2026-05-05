import 'package:flutter/material.dart';
import '../../../core/periodic_table.dart';

class PeriodicTableWidget extends StatelessWidget {
  final ElementInfo? selectedElement;
  final Set<String> selectedSymbols;
  final Function(ElementInfo) onSelect;
  final double? preferredCellSize;

  const PeriodicTableWidget({
    super.key,
    this.selectedElement,
    this.selectedSymbols = const {},
    required this.onSelect,
    this.preferredCellSize,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // If preferredCellSize is null, calculate a responsive size but don't let it get too small.
        final double calcSize = (constraints.maxWidth / 18).clamp(30.0, 60.0);
        final double cellSize = preferredCellSize ?? calcSize;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(7, (p) {
              final period = p + 1;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(18, (g) {
                  final group = g + 1;
                  final element = PeriodicTable.elements.values
                      .where((e) => e.group == group && e.period == period)
                      .firstOrNull;
                  return Container(
                    width: cellSize,
                    height: cellSize,
                    padding: const EdgeInsets.all(1),
                    child: element == null
                        ? const SizedBox.shrink()
                        : _ElementTile(
                            element: element,
                            size: cellSize,
                            isSelected:
                                selectedElement?.symbol == element.symbol ||
                                selectedSymbols.contains(element.symbol),
                            onTap: () => onSelect(element),
                          ),
                  );
                }),
              );
            }),
          ),
        );
      },
    );
  }
}

class _ElementTile extends StatefulWidget {
  final ElementInfo element;
  final double size;
  final bool isSelected;
  final VoidCallback onTap;

  const _ElementTile({
    required this.element,
    required this.size,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_ElementTile> createState() => _ElementTileState();
}

class _ElementTileState extends State<_ElementTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool active = widget.isSelected || _isHovered;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: widget.element.cpkColor.withValues(alpha: active ? 1.0 : 0.4),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: widget.isSelected
                  ? theme.colorScheme.primary
                  : (active
                        ? theme.colorScheme.primary.withValues(alpha: 0.5)
                        : theme.colorScheme.outlineVariant),
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: widget.element.color.withValues(alpha: 0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              widget.element.symbol,
              style: TextStyle(
                fontSize: widget.size * (active ? 0.45 : 0.4),
                fontWeight: FontWeight.bold,
                color: active
                    ? Colors.white
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
