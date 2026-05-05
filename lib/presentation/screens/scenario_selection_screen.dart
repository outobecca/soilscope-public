import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../domain/models/scenario.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/simulation_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/scenarios_provider.dart';
import '../providers/theme_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _refreshSavedStateStatus();
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
                    Navigator.of(context).pushNamed('/simulation');
                  } else {
                    _showSnack(context, l10n.resumeFailed);
                  }
                } catch (e, stack) {
                  _showSnack(context, 'Error resuming simulation: $e', background: Colors.red);
                  debugPrint('Error resuming simulation: $e');
                  debugPrintStack(stackTrace: stack);
                }
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
              await _refreshSavedStateStatus();
              if (context.mounted) {
                Navigator.of(context).pushNamed('/simulation');
              }
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
          'Luo uusi skenaario',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Säädä parametrit ja rakenna oma opettavainen skenaario.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        onTap: () {
          Navigator.of(context).pushNamed('/scenario_builder');
        },
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
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
      ),
      child: InkWell(
        onTap: () {
          try {
            ref.read(simulationProvider.notifier).loadScenario(scenario);
            Navigator.of(context).pushNamed('/simulation');
          } catch (e, stack) {
            _showSnack(context, 'Error starting simulation: $e', background: Colors.red);
            debugPrint('Error starting simulation: $e');
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
                    onPressed: () {
                      try {
                        ref
                            .read(simulationProvider.notifier)
                            .loadScenario(scenario);
                        Navigator.of(context).pushNamed('/simulation');
                      } catch (e, stack) {
                        _showSnack(context, 'Error starting simulation: $e', background: Colors.red);
                        debugPrint('Error starting simulation: $e');
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
