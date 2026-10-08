import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/periodic_table.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/simulation_session_provider.dart';
import '../../providers/ui_state_provider.dart';
import 'periodic_table_widget.dart';

/// Modal dialog for exploring and selecting any chemical element from the periodic table.
/// Directly synchronizes selection with the simulation and reveals rich educational insights.
class ElementSelectionModal extends ConsumerStatefulWidget {
  const ElementSelectionModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (context) => const ElementSelectionModal(),
    );
  }

  @override
  ConsumerState<ElementSelectionModal> createState() => _ElementSelectionModalState();
}

class _ElementSelectionModalState extends ConsumerState<ElementSelectionModal> {
  ElementInfo? _selectedElement;

  @override
  void initState() {
    super.initState();
    final currentSymbol = ref.read(simulationSessionProvider).selectedElementSymbol;
    if (currentSymbol != null && currentSymbol.isNotEmpty) {
      _selectedElement = PeriodicTable.getBySymbol(currentSymbol);
    }
  }

  void _onElementSelected(ElementInfo element, String lang) {
    final sessionNotifier = ref.read(simulationSessionProvider.notifier);
    final uiNotifier = ref.read(uIStateProvider.notifier);

    if (_selectedElement?.symbol == element.symbol) {
      setState(() => _selectedElement = null);
      sessionNotifier.selectElement(null);
      uiNotifier.setHoverInfo(null);
    } else {
      setState(() => _selectedElement = element);
      sessionNotifier.selectElement(element.symbol);
      uiNotifier.setHoverInfo(element.toHoverInfo(lang, isPinned: true));
    }
  }

  void _clearSelection() {
    setState(() => _selectedElement = null);
    ref.read(simulationSessionProvider.notifier).selectElement(null);
    ref.read(uIStateProvider.notifier).setHoverInfo(null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final screenSize = MediaQuery.of(context).size;
    final isCompact = screenSize.width < 700;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isCompact ? 10 : 32,
        vertical: isCompact ? 16 : 24,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 850),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.science_rounded,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.allElements,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              l10n.selectElementRole,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 11.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white70),
                        tooltip: l10n.closeAction,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white12, height: 1),

                // 2. Periodic Table Body
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: PeriodicTableWidget(
                      selectedElement: _selectedElement,
                      showControls: true,
                      onSelect: (el) => _onElementSelected(el, lang),
                    ),
                  ),
                ),

                const Divider(color: Colors.white12, height: 1),

                // 3. Footer / Active Selection Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      if (_selectedElement != null) ...[
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: _selectedElement!.cpkColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white70, width: 1.5),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _selectedElement!.symbol,
                            style: TextStyle(
                              color: _selectedElement!.cpkColor.computeLuminance() > 0.5
                                  ? Colors.black
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${_selectedElement!.localizedName(lang)} (${_selectedElement!.localizedAgronomicRole(lang)})',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                _selectedElement!.localizedSoilRole(lang),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _clearSelection,
                          icon: const Icon(Icons.clear, size: 16),
                          label: Text(l10n.clearSelection),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white70,
                          ),
                        ),
                      ] else ...[
                        Expanded(
                          child: Text(
                            l10n.selectElement,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        child: Text(l10n.closeAction),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
