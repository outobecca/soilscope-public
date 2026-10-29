import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/scenario.dart';
import '../../l10n/app_localizations.dart';

enum TutorialTargetArea {
  welcome,
  canvas,
  inspection,
  dashboard,
  controls,
  timeline,
  observation,
  gamification,
}

class TutorialStepItem {
  final String id;
  final TutorialTargetArea target;
  final IconData icon;
  final String Function(AppLocalizations l10n) getTitle;
  final String Function(AppLocalizations l10n) getDescription;
  final List<String> Function(AppLocalizations l10n) getPoints;
  final String Function(AppLocalizations l10n)? actionLabel;
  final void Function(WidgetRef ref)? onAction;

  const TutorialStepItem({
    required this.id,
    required this.target,
    required this.icon,
    required this.getTitle,
    required this.getDescription,
    required this.getPoints,
    this.actionLabel,
    this.onAction,
  });
}

class TutorialState {
  final bool isVisible;
  final int currentStepIndex;
  final bool isCompleted;
  final bool isQuickGuideOpen;
  final ScenarioTutorialStep? scenarioStep;

  const TutorialState({
    this.isVisible = false,
    this.currentStepIndex = 0,
    this.isCompleted = false,
    this.isQuickGuideOpen = false,
    this.scenarioStep,
  });

  TutorialState copyWith({
    bool? isVisible,
    int? currentStepIndex,
    bool? isCompleted,
    bool? isQuickGuideOpen,
    ScenarioTutorialStep? Function()? scenarioStep,
  }) {
    return TutorialState(
      isVisible: isVisible ?? this.isVisible,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      isCompleted: isCompleted ?? this.isCompleted,
      isQuickGuideOpen: isQuickGuideOpen ?? this.isQuickGuideOpen,
      scenarioStep: scenarioStep != null ? scenarioStep() : this.scenarioStep,
    );
  }
}

class TutorialNotifier extends Notifier<TutorialState> {
  static const String _prefKey = 'soilscope_onboarding_completed_v1';

  late final List<TutorialStepItem> steps = [
    const TutorialStepItem(
      id: 'welcome',
      target: TutorialTargetArea.welcome,
      icon: Icons.eco_rounded,
      getTitle: _getWelcomeTitle,
      getDescription: _getWelcomeDesc,
      getPoints: _getWelcomePoints,
    ),
    const TutorialStepItem(
      id: 'canvas',
      target: TutorialTargetArea.canvas,
      icon: Icons.biotech_rounded,
      getTitle: _getCanvasTitle,
      getDescription: _getCanvasDesc,
      getPoints: _getCanvasPoints,
    ),
    const TutorialStepItem(
      id: 'dashboard',
      target: TutorialTargetArea.dashboard,
      icon: Icons.dashboard_rounded,
      getTitle: _getDashboardTitle,
      getDescription: _getDashboardDesc,
      getPoints: _getDashboardPoints,
    ),
    const TutorialStepItem(
      id: 'controls',
      target: TutorialTargetArea.controls,
      icon: Icons.tune_rounded,
      getTitle: _getControlsTitle,
      getDescription: _getControlsDesc,
      getPoints: _getControlsPoints,
    ),
    const TutorialStepItem(
      id: 'timeline',
      target: TutorialTargetArea.timeline,
      icon: Icons.timelapse_rounded,
      getTitle: _getTimelineTitle,
      getDescription: _getTimelineDesc,
      getPoints: _getTimelinePoints,
    ),
    const TutorialStepItem(
      id: 'observation',
      target: TutorialTargetArea.observation,
      icon: Icons.visibility_rounded,
      getTitle: _getObservationTitle,
      getDescription: _getObservationDesc,
      getPoints: _getObservationPoints,
    ),
    const TutorialStepItem(
      id: 'gamification',
      target: TutorialTargetArea.gamification,
      icon: Icons.military_tech_rounded,
      getTitle: _getGamificationTitle,
      getDescription: _getGamificationDesc,
      getPoints: _getGamificationPoints,
    ),
  ];

  static String _getWelcomeTitle(AppLocalizations l10n) => l10n.tutorialWelcomeTitle;
  static String _getWelcomeDesc(AppLocalizations l10n) => l10n.tutorialWelcomeDesc;
  static List<String> _getWelcomePoints(AppLocalizations l10n) => [
        l10n.tutorialWelcomePoint1,
        l10n.tutorialWelcomePoint2,
        l10n.tutorialWelcomePoint3,
      ];

  static String _getCanvasTitle(AppLocalizations l10n) => l10n.tutorialCanvasTitle;
  static String _getCanvasDesc(AppLocalizations l10n) => l10n.tutorialCanvasDesc;
  static List<String> _getCanvasPoints(AppLocalizations l10n) => [
        l10n.tutorialCanvasPoint1,
        l10n.tutorialCanvasPoint2,
      ];

  static String _getDashboardTitle(AppLocalizations l10n) => l10n.tutorialDashboardTitle;
  static String _getDashboardDesc(AppLocalizations l10n) => l10n.tutorialDashboardDesc;
  static List<String> _getDashboardPoints(AppLocalizations l10n) => [
        l10n.tutorialDashboardPoint1,
        l10n.tutorialDashboardPoint2,
        l10n.tutorialDashboardPoint3,
      ];

  static String _getControlsTitle(AppLocalizations l10n) => l10n.tutorialControlsTitle;
  static String _getControlsDesc(AppLocalizations l10n) => l10n.tutorialControlsDesc;
  static List<String> _getControlsPoints(AppLocalizations l10n) => [
        l10n.tutorialControlsPoint1,
        l10n.tutorialControlsPoint2,
        l10n.tutorialControlsPoint3,
      ];

  static String _getTimelineTitle(AppLocalizations l10n) => l10n.tutorialTimelineTitle;
  static String _getTimelineDesc(AppLocalizations l10n) => l10n.tutorialTimelineDesc;
  static List<String> _getTimelinePoints(AppLocalizations l10n) => [
        l10n.tutorialTimelinePoint1,
        l10n.tutorialTimelinePoint2,
        l10n.tutorialTimelinePoint3,
      ];

  static String _getObservationTitle(AppLocalizations l10n) => l10n.tutorialObservationTitle;
  static String _getObservationDesc(AppLocalizations l10n) => l10n.tutorialObservationDesc;
  static List<String> _getObservationPoints(AppLocalizations l10n) => [
        l10n.tutorialObservationPoint1,
        l10n.tutorialObservationPoint2,
        l10n.tutorialObservationPoint3,
      ];

  static String _getGamificationTitle(AppLocalizations l10n) => l10n.tutorialGamificationTitle;
  static String _getGamificationDesc(AppLocalizations l10n) => l10n.tutorialGamificationDesc;
  static List<String> _getGamificationPoints(AppLocalizations l10n) => [
        l10n.tutorialGamificationPoint1,
        l10n.tutorialGamificationPoint2,
        l10n.tutorialGamificationPoint3,
      ];

  @override
  TutorialState build() {
    _initPersistence();
    return const TutorialState();
  }

  Future<void> _initPersistence() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool(_prefKey) ?? false;
    state = state.copyWith(isCompleted: completed);
  }

  Future<void> checkFirstTimeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool(_prefKey) ?? false;
    if (!completed && !state.isVisible) {
      startTutorial();
    }
  }

  void startTutorial() {
    state = state.copyWith(
      isVisible: true,
      currentStepIndex: 0,
      scenarioStep: () => null,
      isQuickGuideOpen: false,
    );
  }

  void nextStep() {
    if (state.currentStepIndex < steps.length - 1) {
      state = state.copyWith(currentStepIndex: state.currentStepIndex + 1);
    } else {
      completeTutorial();
    }
  }

  void previousStep() {
    if (state.currentStepIndex > 0) {
      state = state.copyWith(currentStepIndex: state.currentStepIndex - 1);
    }
  }

  void goToStep(int index) {
    if (index >= 0 && index < steps.length) {
      state = state.copyWith(currentStepIndex: index);
    }
  }

  void skipTutorial() {
    state = state.copyWith(
      isVisible: false,
      isCompleted: true,
      scenarioStep: () => null,
    );
    _markCompleted();
  }

  void completeTutorial() {
    _markCompleted();
    state = state.copyWith(
      isVisible: false,
      isCompleted: true,
      scenarioStep: () => null,
    );
  }

  Future<void> _markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, true);
    state = state.copyWith(isCompleted: true);
  }

  void setScenarioStep(ScenarioTutorialStep? step) {
    state = state.copyWith(
      scenarioStep: () => step,
      isVisible: step != null,
    );
  }

  void openQuickGuide() {
    state = state.copyWith(isQuickGuideOpen: true);
  }

  void closeQuickGuide() {
    state = state.copyWith(isQuickGuideOpen: false);
  }

  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
    state = state.copyWith(isCompleted: false);
    startTutorial();
  }
}

final tutorialProvider =
    NotifierProvider<TutorialNotifier, TutorialState>(TutorialNotifier.new);
