import 'package:flutter/material.dart';
import '../../../core/periodic_table.dart';
import '../../../l10n/app_localizations.dart';

enum PeriodicFilterCategory {
  all,
  macronutrients,
  micronutrients,
  beneficial,
  toxic,
  structural,
}

enum PeriodicViewMode {
  grid,
  cards,
}

class PeriodicTableWidget extends StatefulWidget {
  final ElementInfo? selectedElement;
  final Set<String> selectedSymbols;
  final Function(ElementInfo) onSelect;
  final double? preferredCellSize;
  final bool showControls;

  const PeriodicTableWidget({
    super.key,
    this.selectedElement,
    this.selectedSymbols = const {},
    required this.onSelect,
    this.preferredCellSize,
    this.showControls = true,
  });

  @override
  State<PeriodicTableWidget> createState() => _PeriodicTableWidgetState();
}

class _PeriodicTableWidgetState extends State<PeriodicTableWidget> {
  String _searchQuery = '';
  PeriodicFilterCategory _filterCategory = PeriodicFilterCategory.all;
  PeriodicViewMode _viewMode = PeriodicViewMode.grid;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesFilter(ElementInfo element, String lang) {
    if (_filterCategory != PeriodicFilterCategory.all) {
      switch (_filterCategory) {
        case PeriodicFilterCategory.macronutrients:
          if (element.agronomicRole != ElementAgronomicRole.macronutrient) {
            return false;
          }
          break;
        case PeriodicFilterCategory.micronutrients:
          if (element.agronomicRole != ElementAgronomicRole.micronutrient) {
            return false;
          }
          break;
        case PeriodicFilterCategory.beneficial:
          if (element.agronomicRole != ElementAgronomicRole.beneficial) {
            return false;
          }
          break;
        case PeriodicFilterCategory.toxic:
          if (element.agronomicRole != ElementAgronomicRole.toxic) {
            return false;
          }
          break;
        case PeriodicFilterCategory.structural:
          if (element.agronomicRole != ElementAgronomicRole.structural) {
            return false;
          }
          break;
        case PeriodicFilterCategory.all:
          break;
      }
    }

    if (_searchQuery.trim().isEmpty) return true;
    final q = _searchQuery.trim().toLowerCase();

    final sym = element.symbol.toLowerCase();
    final nameFi = element.nameFi.toLowerCase();
    final nameEn = element.nameEn.toLowerCase();
    final numStr = element.atomicNumber.toString();

    return sym.contains(q) ||
        nameFi.contains(q) ||
        nameEn.contains(q) ||
        numStr == q;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isUnbounded = !constraints.maxWidth.isFinite;
        const double fallbackWidth = 900.0;
        final double effectiveWidth = isUnbounded ? fallbackWidth : constraints.maxWidth;

        Widget content = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.showControls) ...[
              _buildControlBar(theme, l10n, lang),
              const SizedBox(height: 12),
            ],
            if (_viewMode == PeriodicViewMode.grid)
              _buildGridView(theme, lang, effectiveWidth)
            else
              _buildCardsView(theme, lang),
          ],
        );

        if (isUnbounded) {
          content = SizedBox(
            width: fallbackWidth,
            child: content,
          );
        }

        return content;
      },
    );
  }

  Widget _buildControlBar(
    ThemeData theme,
    AppLocalizations? l10n,
    String lang,
  ) {
    final isFi = lang.startsWith('fi');

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search bar + View Toggle
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 40,
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: l10n?.searchElement ??
                        (isFi ? 'Hae alkuainetta...' : 'Search element...'),
                    hintStyle: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.6,
                      ),
                    ),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outlineVariant
                            .withValues(alpha: 0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Mode toggle
            SegmentedButton<PeriodicViewMode>(
              segments: [
                ButtonSegment(
                  value: PeriodicViewMode.grid,
                  icon: const Icon(Icons.grid_view_rounded, size: 18),
                  tooltip: l10n?.gridView ?? (isFi ? 'Taulukko' : 'Table'),
                ),
                ButtonSegment(
                  value: PeriodicViewMode.cards,
                  icon: const Icon(Icons.view_agenda_rounded, size: 18),
                  tooltip: l10n?.listView ?? (isFi ? 'Luettelo' : 'List'),
                ),
              ],
              selected: {_viewMode},
              onSelectionChanged: (set) {
                setState(() => _viewMode = set.first);
              },
              showSelectedIcon: false,
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Filter chips horizontal scroll
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(
                PeriodicFilterCategory.all,
                l10n?.allElements ?? (isFi ? 'Kaikki' : 'All'),
                theme,
              ),
              const SizedBox(width: 6),
              _buildFilterChip(
                PeriodicFilterCategory.macronutrients,
                l10n?.macronutrients ??
                    (isFi ? 'Pääravinteet (N, P, K...)' : 'Macronutrients'),
                theme,
                color: const Color(0xFF2563EB),
              ),
              const SizedBox(width: 6),
              _buildFilterChip(
                PeriodicFilterCategory.micronutrients,
                l10n?.micronutrients ??
                    (isFi ? 'Hivenravinteet (Fe, Zn...)' : 'Micronutrients'),
                theme,
                color: const Color(0xFF0D9488),
              ),
              const SizedBox(width: 6),
              _buildFilterChip(
                PeriodicFilterCategory.beneficial,
                l10n?.beneficialElements ??
                    (isFi ? 'Hyödylliset (Si, Se...)' : 'Beneficial'),
                theme,
                color: const Color(0xFF16A34A),
              ),
              const SizedBox(width: 6),
              _buildFilterChip(
                PeriodicFilterCategory.toxic,
                l10n?.toxicElements ??
                    (isFi ? 'Raskasmetallit & Myrkyt' : 'Toxins & Metals'),
                theme,
                color: const Color(0xFFDC2626),
              ),
              const SizedBox(width: 6),
              _buildFilterChip(
                PeriodicFilterCategory.structural,
                l10n?.structuralElements ??
                    (isFi ? 'Rakenne & Kaasut' : 'Structural & Gases'),
                theme,
                color: const Color(0xFF475569),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    PeriodicFilterCategory category,
    String label,
    ThemeData theme, {
    Color? color,
  }) {
    final isSelected = _filterCategory == category;
    return FilterChip(
      selected: isSelected,
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected
              ? (color ?? theme.colorScheme.primary)
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
      onSelected: (_) {
        setState(() => _filterCategory = category);
      },
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.3,
      ),
      selectedColor: (color ?? theme.colorScheme.primary).withValues(
        alpha: 0.15,
      ),
      side: BorderSide(
        color: isSelected
            ? (color ?? theme.colorScheme.primary)
            : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        width: isSelected ? 1.5 : 1.0,
      ),
      showCheckmark: false,
    );
  }

  Widget _buildGridView(ThemeData theme, String lang, [double? availableWidth]) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = availableWidth ?? (constraints.maxWidth.isFinite ? constraints.maxWidth : 900.0);
        final double calcSize = (width / 18).clamp(36.0, 56.0);
        final double cellSize = widget.preferredCellSize ?? calcSize;

        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.15,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          padding: const EdgeInsets.all(8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(7, (p) {
                final period = p + 1;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(18, (g) {
                    final group = g + 1;
                    final element = PeriodicTable.getByPosition(period, group);

                    if (element == null) {
                      return SizedBox(
                        width: cellSize,
                        height: cellSize,
                      );
                    }

                    final matches = _matchesFilter(element, lang);
                    final isSelected =
                        widget.selectedElement?.symbol == element.symbol ||
                            widget.selectedSymbols.contains(element.symbol);

                    return Container(
                      width: cellSize,
                      height: cellSize,
                      padding: const EdgeInsets.all(1.5),
                      child: _ElementTile(
                        element: element,
                        size: cellSize,
                        isSelected: isSelected,
                        isDimmed: !matches,
                        onTap: () => widget.onSelect(element),
                      ),
                    );
                  }),
                );
              }),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardsView(ThemeData theme, String lang) {
    final elements = PeriodicTable.elements.values
        .where((e) => _matchesFilter(e, lang))
        .toList();

    if (elements.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: Text(
          lang.startsWith('fi')
              ? 'Ei hakuehtoja vastaavia alkuaineita.'
              : 'No elements match the current criteria.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 400),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: elements.length,
        separatorBuilder: (context, index) => const SizedBox(height: 6),
        itemBuilder: (context, idx) {
          final el = elements[idx];
          final isSelected = widget.selectedElement?.symbol == el.symbol ||
              widget.selectedSymbols.contains(el.symbol);

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => widget.onSelect(el),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.35,
                        )
                      : theme.colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.25,
                        ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant.withValues(
                            alpha: 0.4,
                          ),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    // CPK Avatar
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: el.cpkColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        el.symbol,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Name & Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                el.localizedName(lang),
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '#${el.atomicNumber}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: el.color.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  el.localizedAgronomicRole(lang),
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            el.localizedRole(lang),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.check_circle,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ElementTile extends StatefulWidget {
  final ElementInfo element;
  final double size;
  final bool isSelected;
  final bool isDimmed;
  final VoidCallback onTap;

  const _ElementTile({
    required this.element,
    required this.size,
    required this.isSelected,
    this.isDimmed = false,
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
    final double opacity = widget.isDimmed ? 0.25 : (active ? 1.0 : 0.6);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: widget.element.cpkColor.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: widget.isSelected
                  ? theme.colorScheme.primary
                  : (active
                      ? theme.colorScheme.primary.withValues(alpha: 0.8)
                      : theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.4,
                        )),
              width: widget.isSelected ? 2.5 : 1,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: widget.element.cpkColor.withValues(alpha: 0.5),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.element.symbol,
                style: TextStyle(
                  fontSize: widget.size * (active ? 0.38 : 0.34),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: const [
                    Shadow(color: Colors.black54, blurRadius: 2),
                  ],
                ),
              ),
              if (widget.size >= 40)
                Text(
                  '${widget.element.atomicNumber}',
                  style: TextStyle(
                    fontSize: widget.size * 0.18,
                    color: Colors.white.withValues(alpha: 0.85),
                    fontFamily: 'monospace',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
