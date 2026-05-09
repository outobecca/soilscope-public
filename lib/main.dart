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
      _initSimulation();
    });
  }

  void _initSimulation() {
    try {
      if (!_initialized) {
        final session = ref.read(simulationSessionProvider);
        if (!session.isScrubbing) {
          ref.read(simulationProvider.notifier).start();
        }
        _initialized = true;
      }
    } catch (e, stack) {
      debugPrint('Error starting simulation from MainSimulationScreen: $e');
      debugPrintStack(stackTrace: stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start simulation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleLeftSidebar() {
    setState(() {
      _isLeftSidebarOpen = !_isLeftSidebarOpen;
      if (_isLeftSidebarOpen && MediaQuery.of(context).size.width < 600) {
        _isRightSidebarOpen = false;
      }
    });
  }

  void _toggleRightSidebar() {
    setState(() {
      _isRightSidebarOpen = !_isRightSidebarOpen;
      if (_isRightSidebarOpen && MediaQuery.of(context).size.width < 600) {
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
        color: theme.colorScheme.surface.withValues(alpha: isMobile ? 0.98 : 0.85),
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
                    onPressed: () => setState(() => _isLeftSidebarOpen = false),
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
        color: theme.colorScheme.surface.withValues(alpha: isMobile ? 0.98 : 0.85),
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
                    onPressed: () => setState(() => _isRightSidebarOpen = false),
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
                child: SingleChildScrollView(
                  child: ControlPanelSection(),
                ),
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
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      body: Stack(
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
            child: const Center(
              child: TimelineSliderWidget(),
            ),
          ),

          // 4. QUICK ACTIONS (BOTTOM)
          Positioned(
            left: (_isLeftSidebarOpen && !isMobile) ? 336 : 16,
            right: (_isRightSidebarOpen && !isMobile) ? 336 : 16,
            bottom: 16,
            child: const Center(
              child: FlutterQuickActions(),
            ),
          ),

          // 5. OVERLAYS (NOTIFICATIONS)
          const Positioned(
            top: 16,
            right: 16,
            child: SafeArea(child: EventNotificationOverlay()),
          ),

          // 6. CONSOLIDATED INFORMATION OVERLAY (TOOLTIPS & INSPECTION)
          Positioned(
            right: (_isRightSidebarOpen && !isMobile) ? 340 : 20,
            top: 140,
            child: SafeArea(child: HoverTooltip()),
          ),

          // 7. TUTORIAL OVERLAY
          const Positioned.fill(
            child: TutorialOverlayWidget(),
          ),

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
    );
  }
}
