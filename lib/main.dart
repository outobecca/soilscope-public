import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart' hide Simulation;
import 'core/debug_log.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/widgets/flame_simulation_view.dart';
import 'presentation/widgets/hud_dashboard.dart';
import 'presentation/widgets/sustainability_panel.dart';
import 'presentation/widgets/event_notification_overlay.dart';
import 'presentation/widgets/hover_tooltip.dart';
import 'presentation/providers/simulation_provider.dart';
import 'presentation/providers/scenarios_provider.dart';
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
import 'presentation/widgets/controls/microscope_hud_controller.dart';
import 'presentation/providers/simulation_session_provider.dart';
import 'presentation/providers/ui_state_provider.dart';
import 'presentation/providers/tutorial_provider.dart';

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
      // No explicit initialRoute: on web this lets defaultRouteName honour
      // the URL (e.g. /#/simulation survives a refresh).
      onGenerateRoute: (settings) {
        final scenarioId = scenarioIdFromRouteName(settings.name);
        if (scenarioId == null) return null;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MainSimulationScreen(scenarioId: scenarioId),
        );
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => const ScenarioSelectionScreen(),
      ),
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

/// Extracts a scenario id from `/simulation/<id>` deep links.
String? scenarioIdFromRouteName(String? routeName) {
  const prefix = '/simulation/';
  if (routeName == null || !routeName.startsWith(prefix)) return null;
  final encoded = routeName.substring(prefix.length);
  if (encoded.isEmpty) return null;
  return Uri.decodeComponent(encoded);
}

class MainSimulationScreen extends ConsumerStatefulWidget {
  final String? scenarioId;

  const MainSimulationScreen({super.key, this.scenarioId});

  @override
  ConsumerState<MainSimulationScreen> createState() =>
      _MainSimulationScreenState();
}

class _MainSimulationScreenState extends ConsumerState<MainSimulationScreen>
    with WidgetsBindingObserver {
  bool _initialized = false;
  bool _initializing = false;
  bool _resumeAfterBackground = false;
  late final Simulation _simulation;

  @override
  void initState() {
    super.initState();
    _simulation = ref.read(simulationProvider.notifier);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width;
      if (screenWidth >= AppTheme.expandedBreakpoint) {
        // Wide desktop: show the dashboard by default.
        ref.read(sidebarStateProvider.notifier).setLeft(true);
      }
      ref.read(tutorialProvider.notifier).checkFirstTimeOnboarding();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // The simulation provider is keep-alive. Leaving this route must stop the
    // engine and persist the current session instead of leaving it running
    // behind the selection screen.
    if (_initialized) {
      // Provider state cannot be modified during dispose(); defer the stop
      // until the current frame has finished unwinding the route.
      Future.microtask(_simulation.stopIfMounted);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final isBackground = state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached;
    if (isBackground) {
      if (!_initialized || _resumeAfterBackground) return;
      _resumeAfterBackground = ref.read(simulationProvider).isRunning;
      // A paused run still needs a final save before the process is suspended.
      _simulation.stop();
      return;
    }

    if (state == AppLifecycleState.resumed &&
        _resumeAfterBackground &&
        _initialized &&
        mounted) {
      _resumeAfterBackground = false;
      _simulation.start();
    }
  }

  void _initSimulation() {
    if (!mounted || _initialized || _initializing) return;
    _initializing = true;

    debugLog('[MainSimulationScreen] _initSimulation START: _initialized=$_initialized');

    Future.microtask(() async {
      try {
        final requestedScenarioId = widget.scenarioId;
        if (requestedScenarioId != null) {
          final scenarios = await ref.read(scenariosProvider.future);
          final scenario = scenarios
              .where((candidate) => candidate.id == requestedScenarioId)
              .firstOrNull;
          if (!mounted) return;
          if (scenario == null) {
            debugLog(
              '[MainSimulationScreen] Unknown scenario id: '
              '$requestedScenarioId',
            );
            Navigator.of(context).pushReplacementNamed('/');
            return;
          }
          ref.read(simulationProvider.notifier).loadScenario(scenario);
        }

        debugLog('[MainSimulationScreen] _initSimulation (microtask): reading session');
        final session = ref.read(simulationSessionProvider);

        debugLog('[MainSimulationScreen] _initSimulation (microtask): isScrubbing=${session.isScrubbing}');
        if (!session.isScrubbing) {
          debugLog('[MainSimulationScreen] _initSimulation (microtask): reading provider notifier');
          final notifier = ref.read(simulationProvider.notifier);

          debugLog('[MainSimulationScreen] _initSimulation (microtask): calling start()');
          notifier.start();
        }

        _initialized = true;
        debugLog('[MainSimulationScreen] _initSimulation SUCCESS: _initialized set to true');
      } catch (e) {
        debugLog('[MainSimulationScreen] Error during _initSimulation: $e');
      } finally {
        _initializing = false;
      }
    });
  }

  void _toggleLeftSidebar() {
    final isOverlay =
        MediaQuery.of(context).size.width < AppTheme.expandedBreakpoint;
    ref.read(sidebarStateProvider.notifier).toggleLeft(isOverlay: isOverlay);
  }

  void _toggleRightSidebar() {
    final isOverlay =
        MediaQuery.of(context).size.width < AppTheme.expandedBreakpoint;
    ref.read(sidebarStateProvider.notifier).toggleRight(isOverlay: isOverlay);
  }

  Widget _buildLeftSidebar(bool isCompact, double screenWidth) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isExpanded = screenWidth >= AppTheme.expandedBreakpoint;
    final sidebarWidth = isCompact
        ? screenWidth
        : (isExpanded ? 320.0 : (screenWidth * 0.55).clamp(320.0, 420.0));
    final isOpen = ref.watch(sidebarStateProvider.select((s) => s.isLeftOpen));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isOpen ? sidebarWidth : 0,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(
          alpha: isExpanded ? 0.85 : 0.97,
        ),
        border: Border(
          right: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: isOpen ? 1 : 0,
          ),
        ),
      ),
      // Keep the dashboard out of the tree while the sidebar is closed; its
      // consumers would otherwise rebuild analytics on every simulation tick.
      child: isOpen
          ? OverflowBox(
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
                          ref.read(sidebarStateProvider.notifier).setLeft(false),
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
      )
          : null,
    );
  }

  Widget _buildRightSidebar(bool isCompact, double screenWidth) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isExpanded = screenWidth >= AppTheme.expandedBreakpoint;
    final sidebarWidth = isCompact
        ? screenWidth
        : (isExpanded ? 320.0 : (screenWidth * 0.55).clamp(320.0, 420.0));
    final isOpen = ref.watch(sidebarStateProvider.select((s) => s.isRightOpen));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isOpen ? sidebarWidth : 0,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(
          alpha: isExpanded ? 0.85 : 0.97,
        ),
        border: Border(
          left: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: isOpen ? 1 : 0,
          ),
        ),
      ),
      // The control panel is expensive, so keep it out of the tree while the
      // sidebar is closed.
      child: isOpen
          ? OverflowBox(
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
                          ref.read(sidebarStateProvider.notifier).setRight(false),
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
      )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isInitializing = ref.watch(simulationProvider.select((s) => s.isInitializing));
    final isRunning = ref.watch(simulationProvider.select((s) => s.isRunning));
    if (kDebugMode) {
      debugLog('[MainSimulationScreen] build: isInitializing=$isInitializing, isRunning=$isRunning, _initialized=$_initialized');
    }

    // 1. Listen for the initialization to complete
    ref.listen(simulationProvider.select((s) => s.isInitializing), (previous, next) {
      debugLog('[MainSimulationScreen] listener: isInitializing changed from $previous to $next');
      if (previous == true && next == false) {
        debugLog('[MainSimulationScreen] listener: triggering _initSimulation');
        _initSimulation();
      }
    });

    // 2. Kick off scenario loading immediately on a deep link, even while the
    // runtime is still initializing; loading the scenario also clears the
    // provider's initialization flag. Generic launches wait for the runtime.
    if (!_initialized && (!isInitializing || widget.scenarioId != null)) {
      debugLog('[MainSimulationScreen] build: scheduling _initSimulation via PostFrameCallback');
      WidgetsBinding.instance.addPostFrameCallback((_) => _initSimulation());
    }

    final l10n = AppLocalizations.of(context);

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
                l10n?.preparingSimulation ?? 'VALMISTELLAAN SIMULAATIOTA...',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n?.launchingEngine ?? 'Käynnistetään simulaatiomoottoria...',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final isMobile = screenWidth < AppTheme.mobileBreakpoint;
    final isExpanded = screenWidth >= AppTheme.expandedBreakpoint;
    final topBarHorizontalPadding = isMobile ? 8.0 : 16.0;
    final topBarVerticalPadding = isMobile ? 8.0 : 16.0;
    final topBarGap = isMobile ? 6.0 : 12.0;
    // Between phone and desktop the labelled top-bar buttons leave the HUD
    // strip too little room, so switch them to icons earlier than a phone.
    final useCompactTopBar = screenWidth < 1000;
    final sidebarState = ref.watch(sidebarStateProvider);
    final isLeftSidebarOpen = sidebarState.isLeftOpen;
    final isRightSidebarOpen = sidebarState.isRightOpen;

    if (l10n == null) {
      debugLog('[MainSimulationScreen] build: L10N is NULL - showing fallback spinner');
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    debugLog('[MainSimulationScreen] build: Rendering MAIN UI (Scaffold)');
    return Scaffold(
      body: MouseRegion(
        onHover: (event) {
          ref
              .read(uIStateProvider.notifier)
              .updateScreenPosition(event.position);
        },
        onExit: (_) {
          // A hover tooltip must not survive after the pointer leaves the
          // window. Pinned inspection cards are intentionally persistent.
          ref.read(uIStateProvider.notifier).clearUnpinnedHover();
        },
        child: SizedBox.expand(
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
                  padding: EdgeInsets.symmetric(
                    horizontal: topBarHorizontalPadding,
                    vertical: topBarVerticalPadding,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Reserve the toggle's space while its sidebar is
                          // open. Otherwise the gamification strip expands and
                          // visibly jumps to the left on every open/close.
                          Visibility(
                            visible: !isLeftSidebarOpen,
                            maintainSize: true,
                            maintainAnimation: true,
                            maintainState: true,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: useCompactTopBar
                                  ? IconButton.filledTonal(
                                      onPressed: _toggleLeftSidebar,
                                      icon: const Icon(Icons.menu),
                                      tooltip: l10n.dashboard,
                                    )
                                  : FilledButton.tonalIcon(
                                      onPressed: _toggleLeftSidebar,
                                      icon: const Icon(Icons.menu),
                                      label: Text(l10n.dashboard.toUpperCase()),
                                    ),
                            ),
                          ),
                          SizedBox(width: topBarGap),
                          const Expanded(child: GamificationBar()),
                          SizedBox(width: topBarGap),
                          Visibility(
                            visible: !isRightSidebarOpen,
                            maintainSize: true,
                            maintainAnimation: true,
                            maintainState: true,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: useCompactTopBar
                                  ? IconButton.filledTonal(
                                      onPressed: _toggleRightSidebar,
                                      icon: const Icon(Icons.settings),
                                      tooltip: l10n.controls,
                                    )
                                  : FilledButton.tonalIcon(
                                      onPressed: _toggleRightSidebar,
                                      icon: const Icon(Icons.settings),
                                      label: Text(l10n.controls.toUpperCase()),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Engine failure banner with a retry action.
            if (ref.watch(engineFailureProvider))
              Positioned(
                top: 76,
                left: 16,
                right: 16,
                child: SafeArea(
                  child: MaterialBanner(
                    content: Text(l10n.engineStartFailed),
                    leading: const Icon(Icons.error_outline),
                    actions: [
                      TextButton(
                        onPressed: () => ref
                            .read(simulationProvider.notifier)
                            .retryInitialization(),
                        child: Text(l10n.retryAction),
                      ),
                    ],
                  ),
                ),
              ),

            // 3. TIMELINE SLIDER
            // These controls are chrome over the whole simulation canvas.
            // Keep them screen-centred instead of re-centring them inside the
            // space left by an open sidebar, which made them slide sideways.
            Positioned(
              left: 16,
              right: 16,
              bottom: 120, // Above quick actions
              child: const SafeArea(
                top: false,
                child: Center(child: TimelineSliderWidget()),
              ),
            ),

            // 4. QUICK ACTIONS (BOTTOM)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: const SafeArea(
                top: false,
                child: Center(child: FlutterQuickActions()),
              ),
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
                final microscopeOpen = ref.watch(
                  simulationSessionProvider.select(
                    (s) => s.isMicroscopeEnabled,
                  ),
                );

                if (!info.isPinned && info.screenPosition != null) {
                  final pos = info.screenPosition!;
                  const tooltipWidth = 290.0;
                  // Card height is typically 240-320px depending on stats & formula
                  final statCount = info.stats?.length ?? 0;
                  final hasFormula = info.formula != null;
                  final hasLegends = info.legends != null && info.legends!.isNotEmpty;
                  final estimatedHeight = 160.0 +
                      (statCount * 26.0) +
                      (hasFormula ? 45.0 : 0.0) +
                      (hasLegends ? 50.0 : 0.0);

                  // Horizontal: try right of anchor, flip to left if it exceeds screen
                  double left = pos.dx + 24;
                  if (left + tooltipWidth > screenWidth - 16) {
                    left = pos.dx - tooltipWidth - 24;
                  }
                  if (left < 16) left = 16;

                  // Vertical: reserve space for timeline slider & bottom action bar
                  final bottomReserve = isMobile ? 120.0 : 160.0;
                  double top = pos.dy + 20;
                  if (top + estimatedHeight > screenHeight - bottomReserve) {
                    top = pos.dy - estimatedHeight - 20;
                  }
                  if (top < 70) top = 70; // Avoid top app bar

                  return Positioned(
                    left: left,
                    top: top,
                    child: const IgnorePointer(
                      ignoring: true,
                      child: HoverTooltip(),
                    ),
                  );
                }

                // The microscope controller spans most of the top strip until
                // the layout is wide enough to leave room beside it. Keep the
                // touch-accessible inspection card below it in that range.
                final microscopeOverlapsCard =
                    microscopeOpen && screenWidth < 1100;
                return Positioned(
                  right: (isRightSidebarOpen && isExpanded) ? 340 : 20,
                  top: isMobile
                      ? (microscopeOverlapsCard ? 210 : 80)
                      : (microscopeOverlapsCard ? 210 : 140),
                  child: const SafeArea(child: HoverTooltip()),
                );
              },
            ),

            // 6.5 NANOVISION MICROSCOPE HUD CONTROLLER
            Consumer(
              builder: (context, ref, child) {
                final isMicroscope = ref.watch(
                  simulationSessionProvider.select((s) => s.isMicroscopeEnabled),
                );
                if (!isMicroscope) return const SizedBox.shrink();

                return Positioned(
                  top: isMobile ? 80 : 88,
                  left: (isLeftSidebarOpen && isExpanded) ? 336 : 16,
                  child: const SafeArea(child: MicroscopeHudController()),
                );
              },
            ),

            // 8. LEFT SIDEBAR (DASHBOARD) - Placed to cover when full width on mobile
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: _buildLeftSidebar(isMobile, screenWidth),
            ),

            // 9. RIGHT SIDEBAR (CONTROLS) - Placed to cover when full width on mobile
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: _buildRightSidebar(isMobile, screenWidth),
            ),

            // 10. TUTORIAL OVERLAY - Placed topmost to spotlight components and guide user
            const Positioned.fill(child: TutorialOverlayWidget()),
            ],
          ),
        ),
      ),
    );
  }
}
