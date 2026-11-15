import 'dart:math' as math;

/// How the canvas should advance its visual clock.
enum AnimationMode { live, paused, history, inspection, hidden }

/// Central, frame-rate-safe clock for the animation layer.
///
/// Flame supplies a variable frame delta. A long frame (tab resume, GC pause,
/// or a slow engine tick) must not teleport particles or make a breathing
/// animation jump. The clock clamps the frame delta and separates the visual
/// time used by cosmetic motion from the simulation clock owned by the engine.
class AnimationClock {
  AnimationClock({this.maxFrameDelta = 0.05});

  /// Longest frame accepted by the visual layer. Fifty milliseconds is three
  /// 60 Hz frames; anything longer is treated as a stall and motion resumes
  /// smoothly from the current pose.
  final double maxFrameDelta;

  double _frameDt = 0;
  double _visualElapsed = 0;
  double _uiElapsed = 0;
  bool _reducedMotion = false;
  AnimationMode _mode = AnimationMode.paused;

  /// Clamped delta for the current frame.
  double get frameDt => _frameDt;

  /// Delta that may advance simulation-driven cosmetic motion.
  ///
  /// Only live playback advances this clock. Paused, history, inspection and
  /// hidden states freeze visual elapsed time, matching the pre-existing
  /// `currentTime()` behavior while making the rule explicit. Reduced motion
  /// also freezes it, even while the simulation itself is running.
  double get visualDt =>
      _mode == AnimationMode.live && !_reducedMotion ? _frameDt : 0;

  /// Monotonic clock for ambient/cosmetic animation.
  double get visualElapsed => _visualElapsed;

  /// Clock used by viewport HUD/selection animations. Like the visual clock,
  /// it advances only during live playback so canvas overlays do not keep
  /// moving while the simulation is paused, scrubbed, inspected or hidden.
  /// Reduced motion freezes it as well.
  double get uiElapsed => _uiElapsed;

  AnimationMode get mode => _mode;

  bool get isLive => _mode == AnimationMode.live;

  void tick(
    double rawDt, {
    required bool isRunning,
    required bool isScrubbing,
    required bool inspectionPaused,
    bool appVisible = true,
    bool reducedMotion = false,
  }) {
    _frameDt = _sanitizeDelta(rawDt);
    _reducedMotion = reducedMotion;
    _mode = _resolveMode(
      isRunning: isRunning,
      isScrubbing: isScrubbing,
      inspectionPaused: inspectionPaused,
      appVisible: appVisible,
    );

    if (_mode == AnimationMode.live && !reducedMotion) {
      _visualElapsed += _frameDt;
      _uiElapsed += _frameDt;
    }
  }

  /// Reset monotonic clocks when the game is detached or a new scene is
  /// loaded, so a resumed route does not inherit an old animation phase.
  void reset() {
    _frameDt = 0;
    _visualElapsed = 0;
    _uiElapsed = 0;
    _reducedMotion = false;
    _mode = AnimationMode.paused;
  }

  double _sanitizeDelta(double rawDt) {
    if (!rawDt.isFinite || rawDt <= 0) return 0;
    return math.min(rawDt, maxFrameDelta);
  }

  AnimationMode _resolveMode({
    required bool isRunning,
    required bool isScrubbing,
    required bool inspectionPaused,
    required bool appVisible,
  }) {
    if (!appVisible) return AnimationMode.hidden;
    if (inspectionPaused) return AnimationMode.inspection;
    if (isScrubbing) return AnimationMode.history;
    if (isRunning) return AnimationMode.live;
    return AnimationMode.paused;
  }
}
