import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/debug_log.dart';
import '../../l10n/app_localizations.dart';
import '../../domain/models/scenario.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/simulation_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/scenarios_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/tutorial/quick_guide_dialog.dart';

class ScenarioSelectionScreen extends ConsumerStatefulWidget {
  const ScenarioSelectionScreen({super.key});

  @override
  ConsumerState<ScenarioSelectionScreen> createState() =>
      _ScenarioSelectionScreenState();
}

class _ScenarioSelectionScreenState
    extends ConsumerState<ScenarioSelectionScreen> {
  bool _isCheckingSavedState = true;
  bool _hasSavedState = false;

  static const _gestureIntroSeenKey = 'gesture_intro_seen_v1';

  @override
  void initState() {
    super.initState();
    _refreshSavedStateStatus();
    _maybeShowGestureIntro();
  }

  /// Three cards that teach pan/zoom/tap before the first run, instead of
  /// dropping a new mobile user into a full-screen canvas with no affordance.
  Future<void> _maybeShowGestureIntro() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_gestureIntroSeenKey) ?? false) return;
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await showDialog<void>(
          context: context,
          builder: (_) => const _GestureIntroDialog(),
        );
        await prefs.setBool(_gestureIntroSeenKey, true);
      });
    } catch (_) {
      // No preferences available (e.g. widget tests): skip the intro.
    }
  }

  Future<void> _refreshSavedStateStatus() async {
    bool hasSavedState = false;
    try {
      hasSavedState = await ref
          .read(simulationProvider.notifier)
          .hasSavedState();
    } catch (_) {
      hasSavedState = false;
    }

    if (!mounted) return;
    setState(() {
      _hasSavedState = hasSavedState;
      _isCheckingSavedState = false;
    });
  }

  void _showSnack(BuildContext context, String message, {Color? background}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: background),
    );
  }

  /// Opens a child route and refreshes the saved-session status when the user
  /// comes back. Without this the resume card keeps the state it had when the
  /// screen was first built.
  Future<void> _openRoute(String route) async {
    await Navigator.of(context).pushNamed(route);
    if (!mounted) return;
    await _refreshSavedStateStatus();
  }

  Future<void> _openSimulation({String? scenarioId}) => _openRoute(
        scenarioId == null
            ? '/simulation'
            : '/simulation/${Uri.encodeComponent(scenarioId)}',
      );

  @override
  Widget build(BuildContext context) {
    final scenariosAsync = ref.watch(scenariosProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selectScenario),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.school_rounded),
            tooltip: l10n.tutorialHelpTooltip,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const QuickGuideDialog(),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.translate),
            tooltip: l10n.language,
            onSelected: (String code) {
              ref.read(appLocaleProvider.notifier).setLocale(code);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(value: 'en', child: Text(l10n.english)),
              PopupMenuItem<String>(value: 'fi', child: Text(l10n.finnish)),
            ],
          ),
        ],
      ),
      body: scenariosAsync.when(
        data: (scenarios) => RefreshIndicator(
          onRefresh: _refreshSavedStateStatus,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            children: [
              _buildHeaderCard(context, l10n, theme),
              const SizedBox(height: 32),
              Text(
                l10n.quickActions.toUpperCase(),
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              _buildResumeCard(context, l10n, theme),
              const SizedBox(height: 12),
              _buildTutorialGuideCard(context, l10n, theme),
              const SizedBox(height: 12),
              _buildImportCard(context, l10n, theme),
              const SizedBox(height: 12),
              _buildCreateScenarioCard(context, l10n, theme),
              const SizedBox(height: 40),
              Text(
                l10n.scenarioLibrary.toUpperCase(),
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              if (scenarios.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        l10n.noScenariosAvailable,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                )
              else
                ...scenarios.map(
                  (scenario) =>
                      _buildScenarioCard(context, l10n, scenario, theme),
                ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text(l10n.errorLoadingScenarios(err.toString()))),
      ),
    );
  }

  Widget _buildHeaderCard(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Transform.rotate(
                    angle: (1.0 - value) * 2.0 * 3.14159,
                    child: child,
                  ),
                );
              },
              child: SvgPicture.asset(
                'assets/images/logo.svg',
                width: 32,
                height: 32,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.appTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  l10n.atmosphereSimulator,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumeCard(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final canResume = !_isCheckingSavedState && _hasSavedState;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: canResume
              ? theme.colorScheme.primary.withValues(alpha: 0.5)
              : theme.colorScheme.outlineVariant,
          width: 1.5,
        ),
      ),
      color: canResume
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.1)
          : theme.colorScheme.surface,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        leading: Icon(
          Icons.history,
          color: canResume
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
          size: 28,
        ),
        title: Text(
          l10n.resumeLastSession,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: canResume
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        subtitle: Text(
          canResume ? l10n.resumeLastSessionDesc : l10n.noSavedSession,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: _isCheckingSavedState
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                canResume ? Icons.play_circle_fill : Icons.lock_outline,
                color: canResume
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
                size: 32,
              ),
        onTap: _isCheckingSavedState
            ? null
            : () async {
                try {
                  if (!canResume) {
                    _showSnack(context, l10n.noSavedSession);
                    return;
                  }
                  final loaded = await ref
                      .read(simulationProvider.notifier)
                      .loadLastState();
                  if (!context.mounted) {
                    return;
                  }
                  if (loaded) {
                    await _openSimulation();
                  } else {
                    _showSnack(context, l10n.resumeFailed);
                  }
                } catch (e, stack) {
                  if (!context.mounted) return;
                  _showSnack(context, 'Error resuming simulation: $e', background: Colors.red);
                  debugLog('Error resuming simulation: $e');
                  debugPrintStack(stackTrace: stack);
                }
              },
      ),
    );
  }

  Widget _buildTutorialGuideCard(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.08),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        leading: Icon(
          Icons.school_rounded,
          color: theme.colorScheme.primary,
          size: 28,
        ),
        title: Text(
          l10n.tutorialGuideCardTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        subtitle: Text(
          l10n.tutorialGuideCardDesc,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: theme.colorScheme.primary,
          size: 18,
        ),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => const QuickGuideDialog(),
          );
        },
      ),
    );
  }

  Widget _buildImportCard(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        leading: Icon(
          Icons.input,
          color: theme.colorScheme.secondary,
          size: 28,
        ),
        title: Text(
          l10n.importScenario,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          l10n.importFromClipboardDesc,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        onTap: () async {
          final data = await Clipboard.getData(Clipboard.kTextPlain);
          final clipboardText = data?.text?.trim();
          if (clipboardText == null || clipboardText.isEmpty) {
            if (context.mounted) {
              _showSnack(
                context,
                l10n.clipboardEmpty,
                background: Colors.orange,
              );
            }
            return;
          }

          try {
            final decoded = jsonDecode(clipboardText);
            if (decoded is! Map<String, dynamic>) {
              throw const FormatException(
                'Clipboard JSON root must be an object',
              );
            }
            final scenario = Scenario.fromJson(decoded);
            ref.read(simulationProvider.notifier).loadScenario(scenario);
            if (context.mounted) {
              _showSnack(context, l10n.importSuccess);
              await _openSimulation();
            }
          } catch (_) {
            if (context.mounted) {
              _showSnack(
                context,
                l10n.importError,
                background: Colors.redAccent,
              );
            }
          }
        },
      ),
    );
  }

  Widget _buildCreateScenarioCard(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        leading: Icon(
          Icons.add_circle_outline,
          color: theme.colorScheme.primary,
          size: 28,
        ),
        title: Text(
          l10n.createNewScenario,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          l10n.createNewScenarioDesc,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        onTap: () => _openRoute('/scenario_builder'),
      ),
    );
  }

  Widget _buildScenarioCard(
    BuildContext context,
    AppLocalizations l10n,
    Scenario scenario,
    ThemeData theme,
  ) {
    // Determine localized strings
    String title = scenario.title;
    String desc = scenario.description;
    if (scenario.id == 'compacted_clay') {
      title = l10n.compactedClayTitle;
      desc = l10n.compactedClayDesc;
    } else if (scenario.id == 'nitrate_leaching') {
      title = l10n.nitrateLeachingTitle;
      desc = l10n.nitrateLeachingDesc;
    } else if (scenario.id == 'nitrogen_lock') {
      title = l10n.nitrogenLockTitle;
      desc = l10n.nitrogenLockDesc;
    } else if (scenario.id == 'waterlogging') {
      title = l10n.waterloggingTitle;
      desc = l10n.waterloggingDesc;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
      ),
      child: InkWell(
        onTap: () async {
          try {
            ref.read(simulationProvider.notifier).loadScenario(scenario);
            await _openSimulation(scenarioId: scenario.id);
          } catch (e, stack) {
            if (!context.mounted) return;
            _showSnack(context, 'Error starting simulation: $e', background: Colors.red);
            debugLog('Error starting simulation: $e');
            debugPrintStack(stackTrace: stack);
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (scenario.objectives.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        l10n
                            .objectivesCount(scenario.objectives.length)
                            .toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                desc,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              if (scenario.features.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: scenario.features
                      .map(
                        (f) => Chip(
                          label: Text(
                            f,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          side: BorderSide.none,
                          padding: const EdgeInsets.all(4),
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () async {
                      try {
                        ref
                            .read(simulationProvider.notifier)
                            .loadScenario(scenario);
                        await _openSimulation(scenarioId: scenario.id);
                      } catch (e, stack) {
                        if (!context.mounted) return;
                        _showSnack(context, 'Error starting simulation: $e', background: Colors.red);
                        debugLog('Error starting simulation: $e');
                        debugPrintStack(stackTrace: stack);
                      }
                    },
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(l10n.openScenario.toUpperCase()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GestureIntroDialog extends StatefulWidget {
  const _GestureIntroDialog();

  @override
  State<_GestureIntroDialog> createState() => _GestureIntroDialogState();
}

class _GestureIntroDialogState extends State<_GestureIntroDialog> {
  final PageController _controller = PageController();
  int _page = 0;

  static const _icons = [
    Icons.eco_rounded,
    Icons.zoom_in_rounded,
    Icons.touch_app_rounded,
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final pages = [
      (l10n.introTitle1, l10n.introBody1),
      (l10n.introTitle2, l10n.introBody2),
      (l10n.introTitle3, l10n.introBody3),
    ];
    final isLast = _page == pages.length - 1;

    return AlertDialog(
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 380,
          maxHeight: MediaQuery.sizeOf(context).height * 0.6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              // AlertDialog asks its content for an intrinsic width, which a
              // PageView cannot provide. Give the pager a concrete width so
              // the dialog can lay out instead of crashing on first launch.
              width: 320,
              height: 220,
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (index) => setState(() => _page = index),
                itemBuilder: (context, index) => SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _icons[index],
                        size: 56,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        pages[index].$1,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(pages[index].$2, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.introSkip),
                ),
                Row(
                  children: List.generate(
                    pages.length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == _page
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    if (isLast) {
                      Navigator.of(context).pop();
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                  child: Text(isLast ? l10n.introStart : l10n.introNext),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
