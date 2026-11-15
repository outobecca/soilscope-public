// Profile capture for the Phase 4 (H7) performance matrix.
//
// The Linux desktop is the reference environment: it has real GPU acceleration,
// does not thermally throttle, and every run starts from the same fresh
// scenario, so three runs give a usable median. Run it with:
//
//   flutter drive --profile -d linux \
//     --driver=test_driver/integration_test.dart \
//     --target=integration_test/performance_profile_test.dart
//
// The same command works on a physical Android or iOS device (use its device
// id); those captures are lower bounds, so record the run-to-run spread before
// comparing anything. A single run is not a before/after.
//
// The harness loads the real `compacted_clay` scenario, warms up, then records
// frame timings for the four states in PERFORMANCE.md: steady simulation,
// pinned inspection, open microscope and pan/zoom. FrameTiming is only
// populated in profile/release builds, so debug runs report no numbers.
//
// Results are printed as `PHASE4_RESULT <json>` and written to the driver's
// integration response data. Nothing is asserted against an FPS budget: the
// capture exists to inform decisions, not to gate CI on a device.

import 'dart:convert';

import 'package:flame/components.dart' show Vector2;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soilscope/main.dart';
import 'package:soilscope/presentation/providers/game_provider.dart';
import 'package:soilscope/presentation/providers/simulation_provider.dart';
import 'package:soilscope/presentation/providers/simulation_session_provider.dart';
import 'package:soilscope/presentation/providers/ui_state_provider.dart';
import 'package:soilscope/presentation/widgets/game/soil_scope_game.dart';

const String _scenarioId = 'compacted_clay';
// Attribution phases split per-tick simulation work and decorative animation
// from the baseline scene: run with --dart-define=PHASE4_ATTRIBUTION=true.
const bool _attribution = bool.fromEnvironment('PHASE4_ATTRIBUTION');
const Duration _warmUp = Duration(seconds: 20);
const Duration _steadyWindow = Duration(seconds: 30);
const Duration _stateWindow = Duration(seconds: 10);
const double _frameBudgetMs = 1000 / 60;

class _PhaseStats {
  final String name;
  final int frames;
  final double windowSeconds;
  final List<int> buildUs;
  final List<int> rasterUs;
  final List<int> totalUs;

  _PhaseStats({
    required this.name,
    required this.windowSeconds,
    required List<FrameTiming> timings,
  }) : frames = timings.length,
       buildUs = _sortedMicros(timings.map((t) => t.buildDuration)),
       rasterUs = _sortedMicros(timings.map((t) => t.rasterDuration)),
       totalUs = _sortedMicros(timings.map((t) => t.totalSpan));

  static List<int> _sortedMicros(Iterable<Duration> values) {
    final list = values.map((d) => d.inMicroseconds).toList()..sort();
    return list;
  }

  double get fps => windowSeconds <= 0 ? 0 : frames / windowSeconds;

  int _percentile(List<int> values, double p) {
    if (values.isEmpty) return 0;
    final index = ((values.length - 1) * p).round().clamp(0, values.length - 1);
    return values[index];
  }

  int get buildP50 => _percentile(buildUs, 0.50);
  int get buildP95 => _percentile(buildUs, 0.95);
  int get rasterP50 => _percentile(rasterUs, 0.50);
  int get rasterP95 => _percentile(rasterUs, 0.95);
  int get totalP50 => _percentile(totalUs, 0.50);
  int get totalP95 => _percentile(totalUs, 0.95);
  int get totalMax => totalUs.isEmpty ? 0 : totalUs.last;

  int get jankyFrames =>
      totalUs.where((us) => us > _frameBudgetMs * 1000).length;
  int get rasterJankyFrames =>
      rasterUs.where((us) => us > _frameBudgetMs * 1000).length;

  Map<String, Object?> toJson() => {
    'phase': name,
    'frames': frames,
    'windowSeconds': windowSeconds,
    'fps': _ms(fps * 1000),
    'buildP50Ms': _ms(buildP50),
    'buildP95Ms': _ms(buildP95),
    'rasterP50Ms': _ms(rasterP50),
    'rasterP95Ms': _ms(rasterP95),
    'totalP50Ms': _ms(totalP50),
    'totalP95Ms': _ms(totalP95),
    'totalMaxMs': _ms(totalMax),
    'jankyFrames': jankyFrames,
    'rasterJankyFrames': rasterJankyFrames,
    'jankPercent': frames == 0
        ? 0.0
        : double.parse((jankyFrames * 100 / frames).toStringAsFixed(1)),
  };
}

double _ms(num micros) => double.parse((micros / 1000).toStringAsFixed(2));

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // Let the engine drive frames at vsync; the harness only observes them.
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('phase 4 device profile capture', (tester) async {
    SharedPreferences.setMockInitialValues({
      'gesture_intro_seen_v1': true,
      'soilscope_onboarding_completed_v1': true,
    });
    tester.binding.platformDispatcher.defaultRouteNameTestValue =
        '/simulation/$_scenarioId';
    addTearDown(
      tester.binding.platformDispatcher.clearDefaultRouteNameTestValue,
    );

    await tester.pumpWidget(const ProviderScope(child: SoilScopeApp()));
    await tester.pump();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MainSimulationScreen)),
      listen: false,
    );

    SoilScopeGame? game() => container.read(soilScopeGameProviderProvider);

    await _waitFor(
      tester,
      () =>
          container.read(simulationProvider).isRunning &&
          (game()?.children.isNotEmpty ?? false),
      label: 'the simulation to start',
    );

    final media = MediaQuery.of(
      tester.element(find.byType(MainSimulationScreen)),
    );

    // Let textures, particles and the isolate reach steady state before the
    // first capture; startup frames are excluded from every window.
    await _idle(tester, _warmUp);

    final results = <_PhaseStats>[];

    results.add(await _capture(tester, 'steady_simulation', _steadyWindow));

    // Pinned inspection: the same card a canvas tap opens.
    game()
      ?..focusNextInspectable()
      ..activateKeyboardTarget();
    await _idle(tester, const Duration(seconds: 2));
    results.add(await _capture(tester, 'pinned_inspection', _stateWindow));

    // Close the inspection card before the next phase: the same hover/pin
    // channel a second tap on the layer clears.
    container.read(uIStateProvider.notifier).setHoverInfo(null);
    container.read(simulationSessionProvider.notifier).selectLayer(null);
    game()?.clearKeyboardTarget();
    await _idle(tester, const Duration(seconds: 2));

    container.read(simulationSessionProvider.notifier).toggleMicroscope();
    await _idle(tester, const Duration(seconds: 3));
    results.add(await _capture(tester, 'microscope_open', _stateWindow));

    container.read(simulationSessionProvider.notifier).toggleMicroscope();
    await _idle(tester, const Duration(seconds: 2));

    var panStep = 0;
    results.add(
      await _capture(
        tester,
        'pan_zoom',
        _stateWindow,
        everySlice: () {
          final target = game();
          if (target == null) return;
          panStep++;
          final direction = panStep.isEven ? 1.0 : -1.0;
          target.panCameraBy(Vector2(140 * direction, 0));
          target.zoomCameraBy(panStep.isEven ? 1.08 : 1 / 1.08);
        },
      ),
    );
    game()?.resetCamera();
    await _idle(tester, const Duration(seconds: 2));

    if (_attribution) {
      // Paused: the engine stops ticking, so per-tick state merges, provider
      // rebuilds and simulation-driven repaints disappear; rendering remains.
      container.read(simulationProvider.notifier).stop();
      await _idle(tester, const Duration(seconds: 2));
      results.add(await _capture(tester, 'paused_simulation', _stateWindow));
      container.read(simulationProvider.notifier).start();
      await _idle(tester, const Duration(seconds: 2));

      // Reduced motion freezes decorative clocks only; simulation data keeps
      // flowing.
      game()?.setReducedMotion(true);
      await _idle(tester, const Duration(seconds: 2));
      results.add(await _capture(tester, 'reduced_motion', _stateWindow));
      game()?.setReducedMotion(false);
      await _idle(tester, const Duration(seconds: 2));

      // Control run at the end of the session: a large difference against
      // steady_simulation means thermal throttling or drift confounds the
      // attribution windows above.
      results.add(await _capture(tester, 'steady_control', _stateWindow));
    }

    final payload = <String, Object?>{
      'scenario': _scenarioId,
      'profileMode': kProfileMode,
      'device': {
        'platform': defaultTargetPlatform.name,
        'logicalWidth': _round(media.size.width),
        'logicalHeight': _round(media.size.height),
        'devicePixelRatio': media.devicePixelRatio,
      },
      'frameBudgetMs': double.parse(_frameBudgetMs.toStringAsFixed(2)),
      'phases': results.map((r) => r.toJson()).toList(),
    };

    binding.reportData = {'phase4': payload};
    debugPrint('PHASE4_RESULT ${jsonEncode(payload)}');

    expect(results, hasLength(_attribution ? 7 : 4));
    if (kProfileMode) {
      final captured = results.fold<int>(0, (sum, r) => sum + r.frames);
      expect(
        captured,
        greaterThan(60),
        reason:
            'profile mode should report FrameTiming for every rendered '
            'frame; $captured frames across four phases means the harness did '
            'not observe real frames',
      );
    } else {
      debugPrint(
        'PHASE4_WARNING debug build: FrameTiming is not reported. '
        'Run with --profile for device numbers.',
      );
    }
  }, timeout: const Timeout(Duration(minutes: 8)));
}

double _round(double value) => double.parse(value.toStringAsFixed(1));

Future<void> _waitFor(
  WidgetTester tester,
  bool Function() condition, {
  required String label,
  Duration timeout = const Duration(seconds: 90),
}) async {
  final clock = Stopwatch()..start();
  while (clock.elapsed < timeout) {
    if (condition()) return;
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();
  }
  fail('Timed out waiting for $label after ${timeout.inSeconds}s');
}

/// Waits in real time so the engine keeps presenting vsync-driven frames.
Future<void> _idle(WidgetTester tester, Duration duration) async {
  await _capture(tester, 'warmup', duration, report: false);
}

Future<_PhaseStats> _capture(
  WidgetTester tester,
  String name,
  Duration duration, {
  void Function()? everySlice,
  bool report = true,
}) async {
  final timings = <FrameTiming>[];
  void collect(List<FrameTiming> batch) => timings.addAll(batch);

  SchedulerBinding.instance.addTimingsCallback(collect);
  final clock = Stopwatch()..start();
  try {
    while (clock.elapsed < duration) {
      everySlice?.call();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
    }
  } finally {
    SchedulerBinding.instance.removeTimingsCallback(collect);
  }

  final rendered = timings
      .where(
        (t) =>
            t.buildDuration > Duration.zero || t.rasterDuration > Duration.zero,
      )
      .toList();
  final stats = _PhaseStats(
    name: name,
    windowSeconds: clock.elapsedMicroseconds / 1000000,
    timings: rendered,
  );
  if (report) {
    debugPrint('PHASE4_PHASE ${jsonEncode(stats.toJson())}');
  }
  return stats;
}
