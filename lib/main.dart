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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width;
      if (screenWidth >= 1024) {
        // Desktop/Tablet
        ref.read(sidebarStateProvider.notifier).setLeft(true);
      }
      ref.read(tutorialProvider.notifier).checkFirstTimeOnboarding();
    });
  }

  void _initSimulation() {
    if (!mounted || _initialized) return;
    
    debugPrint('[MainSimulationScreen] _initSimulation START: _initialized=$_initialized');
    
    Future.microtask(() {
      try {
        debugPrint('[MainSimulationScreen] _initSimulation (microtask): reading session');
        final session = ref.read(simulationSessionProvider);
        
        debugPrint('[MainSimulationScreen] _initSimulation (microtask): isScrubbing=${session.isScrubbing}');
        if (!session.isScrubbing) {
          debugPrint('[MainSimulationScreen] _initSimulation (microtask): reading provider notifier');
          final notifier = ref.read(simulationProvider.notifier);
          
          debugPrint('[MainSimulationScreen] _initSimulation (microtask): calling start()');
          notifier.start();
        }
        
        _initialized = true;
        debugPrint('[MainSimulationScreen] _initSimulation SUCCESS: _initialized set to true');
      } catch (e) {
        debugPrint('[MainSimulationScreen] Error during _initSimulation: $e');
      }
    });
  }

  void _toggleLeftSidebar() {
    final isMobile =
        MediaQuery.of(context).size.width < AppTheme.mobileBreakpoint;
    ref.read(sidebarStateProvider.notifier).toggleLeft(isMobile: isMobile);
  }

  void _toggleRightSidebar() {
    final isMobile =
        MediaQuery.of(context).size.width < AppTheme.mobileBreakpoint;
    ref.read(sidebarStateProvider.notifier).toggleRight(isMobile: isMobile);
  }

  Widget _buildLeftSidebar(bool isMobile, double screenWidth) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final sidebarWidth = isMobile ? screenWidth : 320.0;
    final isOpen = ref.watch(sidebarStateProvider.select((s) => s.isLeftOpen));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isOpen ? sidebarWidth : 0,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(
          alpha: isMobile ? 0.98 : 0.85,
        ),
        border: Border(
          right: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: isOpen ? 1 : 0,
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
      ),
    );
  }

  Widget _buildRightSidebar(bool isMobile, double screenWidth) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final sidebarWidth = isMobile ? screenWidth : 320.0;
    final isOpen = ref.watch(sidebarStateProvider.select((s) => s.isRightOpen));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isOpen ? sidebarWidth : 0,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(
          alpha: isMobile ? 0.98 : 0.85,
        ),
        border: Border(
          left: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: isOpen ? 1 : 0,
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
    final sidebarState = ref.watch(sidebarStateProvider);
    final isLeftSidebarOpen = sidebarState.isLeftOpen;
    final isRightSidebarOpen = sidebarState.isRightOpen;

    if (l10n == null) {
      debugPrint('[MainSimulationScreen] build: L10N is NULL - showing fallback spinner');
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    debugPrint('[MainSimulationScreen] build: Rendering MAIN UI (Scaffold)');
    return Scaffold(
      body: MouseRegion(
        onHover: (event) {
          ref
              .read(uIStateProvider.notifier)
              .updateScreenPosition(event.position);
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
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isLeftSidebarOpen)
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
                          if (!isLeftSidebarOpen) const SizedBox(width: 12),
                          const Expanded(child: GamificationBar()),
                          if (!isRightSidebarOpen) const SizedBox(width: 12),
                          if (!isRightSidebarOpen)
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
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: isMobile
                                ? IconButton.filledTonal(
                                    onPressed: () {
                                      ref
                                          .read(tutorialProvider.notifier)
                                          .startTutorial();
                                    },
                                    icon: const Icon(Icons.school_rounded),
                                    tooltip: l10n.tutorialHelpTooltip,
                                  )
                                : FilledButton.tonalIcon(
                                    onPressed: () {
                                      ref
                                          .read(tutorialProvider.notifier)
                                          .startTutorial();
                                    },
                                    icon: const Icon(Icons.school_rounded),
                                    label: Text(l10n.tutorialTab.toUpperCase()),
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
              left: (isLeftSidebarOpen && !isMobile) ? 336 : 16,
              right: (isRightSidebarOpen && !isMobile) ? 336 : 16,
              bottom: 120, // Above quick actions
              child: const Center(child: TimelineSliderWidget()),
            ),

            // 4. QUICK ACTIONS (BOTTOM)
            Positioned(
              left: (isLeftSidebarOpen && !isMobile) ? 336 : 16,
              right: (isRightSidebarOpen && !isMobile) ? 336 : 16,
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

                return Positioned(
                  right: (isRightSidebarOpen && !isMobile) ? 340 : 20,
                  top: isMobile ? 80 : 140,
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
                  left: (isLeftSidebarOpen && !isMobile) ? 336 : 16,
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
