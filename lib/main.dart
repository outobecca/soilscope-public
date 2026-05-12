import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/widgets/flame_simulation_view.dart';
import 'presentation/widgets/hud_dashboard.dart';
import 'presentation/widgets/sustainability_panel.dart';
import 'presentation/widgets/event_notification_overlay.dart';
import 'presentation/widgets/hover_tooltip.dart';
import 'presentation/providers/simulation_provider.dart';
import 'presentation/widgets/control_panel_section.dart';
import 'presentation/widgets/science_reference_section.dart';
import 'presentation/screens/scenario_selection_screen.dart';
import 'presentation/screens/science_reference_screen.dart';
import 'presentation/screens/logic_lab_screen.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/locale_provider.dart';
import 'presentation/screens/scenario_builder_screen.dart';
import 'presentation/widgets/controls/timeline_slider_widget.dart';
import 'presentation/widgets/tutorial_overlay_widget.dart';
import 'core/app_theme.dart';
import 'presentation/widgets/game/flutter_quick_actions.dart';
import 'presentation/widgets/gamification_bar.dart';
import 'presentation/providers/simulation_session_provider.dart';
import 'presentation/providers/ui_state_provider.dart';

void main() {
  runApp(const ProviderScope(child: SoilScopeApp()));
}

class SoilScopeApp extends ConsumerWidget {
  const SoilScopeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      onGenerateTitle: (context) =>
          AppLocalizations.of(context)?.appTitle ?? 'SoilScope',
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      initialRoute: '/',
      routes: {
        '/': (context) => const ScenarioSelectionScreen(),
        '/simulation': (context) => const MainSimulationScreen(),
        '/science_reference': (context) => const ScienceReferenceScreen(),
        '/logic_lab': (context) => const LogicLabScreen(),
        '/scenario_builder': (context) => const ScenarioBuilderScreen(),
      },
    );
  }
}

class MainSimulationScreen extends ConsumerStatefulWidget {
  const MainSimulationScreen({super.key});

  @override
  ConsumerState<MainSimulationScreen> createState() =>
      _MainSimulationScreenState();
}

class _MainSimulationScreenState extends ConsumerState<MainSimulationScreen> {
  bool _initialized = false;
  bool _isLeftSidebarOpen = false;
  bool _isRightSidebarOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width;
      if (screenWidth >= 1024) {
        // Desktop/Tablet
        setState(() => _isLeftSidebarOpen = true);
      }
    });
  }

  void _initSimulation() {
    if (!mounted) {
      debugPrint('[MainSimulationScreen] _initSimulation ABORTED: not mounted');
      return;
    }
    
    debugPrint(
      '[MainSimulationScreen] _initSimulation START: _initialized=$_initialized',
    );
    try {
      if (!_initialized) {
        final session = ref.read(simulationSessionProvider);
        debugPrint(
          '[MainSimulationScreen] _initSimulation: session.isScrubbing=${session.isScrubbing}',
        );
        if (!session.isScrubbing) {
          debugPrint(
            '[MainSimulationScreen] _initSimulation: CALLING simulationProvider.notifier.start()',
          );
          ref.read(simulationProvider.notifier).start();
        } else {
          debugPrint('[MainSimulationScreen] _initSimulation: SKIPPING start() because scrubbing');
        }
        _initialized = true;
        debugPrint('[MainSimulationScreen] _initSimulation SUCCESS: _initialized set to true');
      } else {
        debugPrint('[MainSimulationScreen] _initSimulation SKIPPED: already initialized');
      }
    } catch (e, stack) {
      debugPrint('[MainSimulationScreen] _initSimulation ERROR: $e');
      debugPrintStack(stackTrace: stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Virhe simulaation käynnistyksessä: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleLeftSidebar() {
    setState(() {
      _isLeftSidebarOpen = !_isLeftSidebarOpen;
      if (_isLeftSidebarOpen &&
          MediaQuery.of(context).size.width < AppTheme.mobileBreakpoint) {
        _isRightSidebarOpen = false;
      }
    });
  }

  void _toggleRightSidebar() {
    setState(() {
      _isRightSidebarOpen = !_isRightSidebarOpen;
      if (_isRightSidebarOpen &&
          MediaQuery.of(context).size.width < AppTheme.mobileBreakpoint) {
        _isLeftSidebarOpen = false;
      }
    });
  }

  Widget _buildLeftSidebar(bool isMobile, double screenWidth) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final sidebarWidth = isMobile ? screenWidth : 320.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: _isLeftSidebarOpen ? sidebarWidth : 0,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(
          alpha: isMobile ? 0.98 : 0.85,
        ),
        border: Border(
          right: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: _isLeftSidebarOpen ? 1 : 0,
          ),
        ),
      ),
      child: OverflowBox(
        alignment: Alignment.topLeft,
        minWidth: sidebarWidth,
        maxWidth: sidebarWidth,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.dashboard.toUpperCase(),
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          setState(() => _isLeftSidebarOpen = false),
                      icon: const Icon(Icons.chevron_left),
                      tooltip: l10n.hideSidebar,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        HUDDashboard(),
                        SizedBox(height: 12),
                        SustainabilityPanel(),
                        SizedBox(height: 12),
                        ScienceReferenceSection(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRightSidebar(bool isMobile, double screenWidth) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final sidebarWidth = isMobile ? screenWidth : 320.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: _isRightSidebarOpen ? sidebarWidth : 0,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(
          alpha: isMobile ? 0.98 : 0.85,
        ),
        border: Border(
          left: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: _isRightSidebarOpen ? 1 : 0,
          ),
        ),
      ),
      child: OverflowBox(
        alignment: Alignment.topRight,
        minWidth: sidebarWidth,
        maxWidth: sidebarWidth,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () =>
                          setState(() => _isRightSidebarOpen = false),
                      icon: const Icon(Icons.chevron_right),
                      tooltip: l10n.hideSidebar,
                    ),
                    Expanded(
                      child: Text(
                        l10n.controlPanel.toUpperCase(),
                        textAlign: TextAlign.right,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Expanded(
                  child: SingleChildScrollView(child: ControlPanelSection()),
                ),
                const SizedBox(height: 12),
                // Theme Toggle
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<ThemeMode>(
                        segments: [
                          ButtonSegment(
                            value: ThemeMode.light,
                            icon: const Icon(Icons.light_mode),
                            label: Text(l10n.lightMode.toUpperCase()),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            icon: const Icon(Icons.dark_mode),
                            label: Text(l10n.darkMode.toUpperCase()),
                          ),
                        ],
                        selected: {ref.watch(themeModeProvider)},
                        onSelectionChanged: (newSelection) {
                          ref
                              .read(themeModeProvider.notifier)
                              .setThemeMode(newSelection.first);
                        },
                        showSelectedIcon: false,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isInitializing = ref.watch(simulationProvider.select((s) => s.isInitializing));
    final isRunning = ref.watch(simulationProvider.select((s) => s.isRunning));
    debugPrint('[MainSimulationScreen] build: isInitializing=$isInitializing, isRunning=$isRunning, _initialized=$_initialized');

    // 1. Listen for the initialization to complete
    ref.listen(simulationProvider.select((s) => s.isInitializing), (previous, next) {
      debugPrint('[MainSimulationScreen] listener: isInitializing changed from $previous to $next');
      if (previous == true && next == false) {
        debugPrint('[MainSimulationScreen] listener: triggering _initSimulation');
        _initSimulation();
      }
    });

    // 2. If we've already finished initializing but haven't triggered start() yet (e.g. on mount)
    if (!isInitializing && !_initialized) {
       debugPrint('[MainSimulationScreen] build: scheduling _initSimulation via PostFrameCallback');
       WidgetsBinding.instance.addPostFrameCallback((_) => _initSimulation());
    }

    if (isInitializing) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B101E),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.cyan),
              const SizedBox(height: 32),
              Text(
                'VALMISTELLAAN SIMULAATIOTA...',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Käynnistetään simulaatiomoottoria...',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppTheme.mobileBreakpoint;

    if (l10n == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: MouseRegion(
        onHover: (event) {
          ref
              .read(uIStateProvider.notifier)
              .updateScreenPosition(event.position);
        },
        child: Stack(
          children: [
            // 1. FULL SCREEN SIMULATION
            const Positioned.fill(child: FlameSimulationView()),

            // 2. TOP BAR (MISSION & SIDEBAR TOGGLES)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!_isLeftSidebarOpen)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: isMobile
                                  ? IconButton.filledTonal(
                                      onPressed: _toggleLeftSidebar,
                                      icon: const Icon(Icons.menu),
                                    )
                                  : FilledButton.tonalIcon(
                                      onPressed: _toggleLeftSidebar,
                                      icon: const Icon(Icons.menu),
                                      label: Text(l10n.dashboard.toUpperCase()),
                                    ),
                            ),
                          if (!_isLeftSidebarOpen) const SizedBox(width: 12),
                          const Expanded(child: GamificationBar()),
                          if (!_isRightSidebarOpen) const SizedBox(width: 12),
                          if (!_isRightSidebarOpen)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: isMobile
                                  ? IconButton.filledTonal(
                                      onPressed: _toggleRightSidebar,
                                      icon: const Icon(Icons.settings),
                                    )
                                  : FilledButton.tonalIcon(
                                      onPressed: _toggleRightSidebar,
                                      icon: const Icon(Icons.settings),
                                      label: Text(l10n.controls.toUpperCase()),
                                    ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. TIMELINE SLIDER
            Positioned(
              left: (_isLeftSidebarOpen && !isMobile) ? 336 : 16,
              right: (_isRightSidebarOpen && !isMobile) ? 336 : 16,
              bottom: 120, // Above quick actions
              child: const Center(child: TimelineSliderWidget()),
            ),

            // 4. QUICK ACTIONS (BOTTOM)
            Positioned(
              left: (_isLeftSidebarOpen && !isMobile) ? 336 : 16,
              right: (_isRightSidebarOpen && !isMobile) ? 336 : 16,
              bottom: 16,
              child: const Center(child: FlutterQuickActions()),
            ),

            // 5. OVERLAYS (NOTIFICATIONS)
            const Positioned(
              top: 16,
              right: 16,
              child: SafeArea(child: EventNotificationOverlay()),
            ),

            // 6. CONSOLIDATED INFORMATION OVERLAY (TOOLTIPS & INSPECTION)
            Consumer(
              builder: (context, ref, child) {
                final info = ref.watch(uIStateProvider);
                if (info == null) return const SizedBox.shrink();

                if (!info.isPinned && info.screenPosition != null) {
                  return Positioned(
                    left: info.screenPosition!.dx + 20,
                    top: info.screenPosition!.dy + 20,
                    child: const HoverTooltip(),
                  );
                }

                return Positioned(
                  right: (_isRightSidebarOpen && !isMobile) ? 340 : 20,
                  top: 140,
                  child: const SafeArea(child: HoverTooltip()),
                );
              },
            ),

            // 7. TUTORIAL OVERLAY
            const Positioned.fill(child: TutorialOverlayWidget()),

            // 8. LEFT SIDEBAR (DASHBOARD) - Placed last in Stack to cover everything when full width on mobile
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: _buildLeftSidebar(isMobile, screenWidth),
            ),

            // 9. RIGHT SIDEBAR (CONTROLS) - Placed last in Stack to cover everything when full width on mobile
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: _buildRightSidebar(isMobile, screenWidth),
            ),
          ],
        ),
      ),
    );
  }
}
