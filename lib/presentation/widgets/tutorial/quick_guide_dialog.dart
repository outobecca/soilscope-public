import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/tutorial_provider.dart';

class QuickGuideDialog extends ConsumerStatefulWidget {
  const QuickGuideDialog({super.key});

  @override
  ConsumerState<QuickGuideDialog> createState() => _QuickGuideDialogState();
}

class _QuickGuideDialogState extends ConsumerState<QuickGuideDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: mathClamp(size.width * 0.9, 320, 800),
          height: mathClamp(size.height * 0.82, 450, 680),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.96),
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
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 16, 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.menu_book_rounded,
                        color: theme.colorScheme.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.quickGuideTitle,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            l10n.quickGuideSubtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      onPressed: () {
                        ref.read(tutorialProvider.notifier).closeQuickGuide();
                      },
                    ),
                  ],
                ),
              ),

              // Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: isMobile,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.6),
                      width: 1,
                    ),
                  ),
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: Colors.white60,
                  tabs: [
                    Tab(
                      icon: const Icon(Icons.touch_app_rounded, size: 20),
                      text: l10n.quickGuideTabUI,
                    ),
                    Tab(
                      icon: const Icon(Icons.eco_rounded, size: 20),
                      text: l10n.quickGuideTabScience,
                    ),
                    Tab(
                      icon: const Icon(Icons.biotech_rounded, size: 20),
                      text: l10n.quickGuideTabBiochemistry,
                    ),
                    Tab(
                      icon: const Icon(Icons.tips_and_updates_rounded, size: 20),
                      text: l10n.quickGuideTabTips,
                    ),
                    Tab(
                      icon: const Icon(Icons.menu_book_rounded, size: 20),
                      text: l10n.quickGuideTabGlossary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildUiTab(context, theme, l10n),
                    _buildScienceTab(context, theme, l10n),
                    _buildBiochemistryTab(context, theme, l10n),
                    _buildTipsTab(context, theme, l10n),
                    _buildGlossaryTab(context, theme, l10n),
                  ],
                ),
              ),

              // Footer Action
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        ref.read(tutorialProvider.notifier).closeQuickGuide();
                        ref.read(tutorialProvider.notifier).startTutorial();
                      },
                      icon: const Icon(Icons.play_circle_outline_rounded),
                      label: Text(l10n.tutorialStartTour),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                      ),
                    ),
                    FilledButton(
                      onPressed: () {
                        ref.read(tutorialProvider.notifier).closeQuickGuide();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.quickGuideClose,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double mathClamp(double val, double min, double max) {
    if (val < min) return min;
    if (val > max) return max;
    return val;
  }

  Widget _buildUiTab(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      children: [
        _buildSectionCard(
          theme: theme,
          icon: Icons.dashboard_rounded,
          title: l10n.quickGuideUiDashboardTitle,
          body: l10n.quickGuideUiDashboardBody,
        ),
        _buildSectionCard(
          theme: theme,
          icon: Icons.tune_rounded,
          title: l10n.quickGuideUiControlsTitle,
          body: l10n.quickGuideUiControlsBody,
        ),
        _buildSectionCard(
          theme: theme,
          icon: Icons.timelapse_rounded,
          title: l10n.quickGuideUiTimelineTitle,
          body: l10n.quickGuideUiTimelineBody,
        ),
        _buildSectionCard(
          theme: theme,
          icon: Icons.biotech_rounded,
          title: l10n.quickGuideUiNanovisionTitle,
          body: l10n.quickGuideUiNanovisionBody,
        ),
      ],
    );
  }

  Widget _buildScienceTab(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      children: [
        _buildSectionCard(
          theme: theme,
          icon: Icons.water_drop_rounded,
          title: l10n.quickGuideSciRichardsTitle,
          body: l10n.quickGuideSciRichardsBody,
        ),
        _buildSectionCard(
          theme: theme,
          icon: Icons.wb_sunny_rounded,
          title: l10n.quickGuideSciPhotosynthesisTitle,
          body: l10n.quickGuideSciPhotosynthesisBody,
        ),
        _buildSectionCard(
          theme: theme,
          icon: Icons.forest_rounded,
          title: l10n.quickGuideSciSpacTitle,
          body: l10n.quickGuideSciSpacBody,
        ),
      ],
    );
  }

  Widget _buildBiochemistryTab(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      children: [
        _buildSectionCard(
          theme: theme,
          icon: Icons.bubble_chart_rounded,
          title: l10n.quickGuideBioNitrogenTitle,
          body: l10n.quickGuideBioNitrogenBody,
        ),
        _buildSectionCard(
          theme: theme,
          icon: Icons.cloud_queue_rounded,
          title: l10n.quickGuideBioRedoxTitle,
          body: l10n.quickGuideBioRedoxBody,
        ),
        _buildSectionCard(
          theme: theme,
          icon: Icons.hub_rounded,
          title: l10n.quickGuideBioCarbonTitle,
          body: l10n.quickGuideBioCarbonBody,
        ),
      ],
    );
  }

  Widget _buildTipsTab(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      children: [
        _buildSectionCard(
          theme: theme,
          icon: Icons.lightbulb_rounded,
          title: l10n.quickGuideTipCompactionTitle,
          body: l10n.quickGuideTipCompactionBody,
        ),
        _buildSectionCard(
          theme: theme,
          icon: Icons.shield_rounded,
          title: l10n.quickGuideTipLeachingTitle,
          body: l10n.quickGuideTipLeachingBody,
        ),
        _buildSectionCard(
          theme: theme,
          icon: Icons.psychology_rounded,
          title: l10n.quickGuideTipLogicLabTitle,
          body: l10n.quickGuideTipLogicLabBody,
        ),
      ],
    );
  }

  Widget _buildGlossaryTab(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      children: [
        _buildSectionCard(
          theme: theme,
          icon: Icons.water_drop_rounded,
          title: l10n.quickGuideGlosThetaTitle,
          body: l10n.quickGuideGlosThetaBody,
        ),
        _buildSectionCard(
          theme: theme,
          icon: Icons.speed_rounded,
          title: l10n.quickGuideGlosKsatTitle,
          body: l10n.quickGuideGlosKsatBody,
        ),
        _buildSectionCard(
          theme: theme,
          icon: Icons.electric_bolt_rounded,
          title: l10n.quickGuideGlosEhTitle,
          body: l10n.quickGuideGlosEhBody,
        ),
        _buildSectionCard(
          theme: theme,
          icon: Icons.layers_rounded,
          title: l10n.quickGuideGlosSomTitle,
          body: l10n.quickGuideGlosSomBody,
        ),
        _buildSectionCard(
          theme: theme,
          icon: Icons.scale_rounded,
          title: l10n.quickGuideGlosCnTitle,
          body: l10n.quickGuideGlosCnBody,
        ),
        _buildSectionCard(
          theme: theme,
          icon: Icons.wb_sunny_rounded,
          title: l10n.quickGuideGlosParTitle,
          body: l10n.quickGuideGlosParBody,
        ),
        _buildSectionCard(
          theme: theme,
          icon: Icons.grass_rounded,
          title: l10n.quickGuideGlosStomataTitle,
          body: l10n.quickGuideGlosStomataBody,
        ),
        _buildSectionCard(
          theme: theme,
          icon: Icons.auto_graph_rounded,
          title: l10n.quickGuideGlosRichardsTitle,
          body: l10n.quickGuideGlosRichardsBody,
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
