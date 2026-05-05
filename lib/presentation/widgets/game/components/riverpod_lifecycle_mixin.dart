import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../soil_scope_game.dart';

/// Mixin for Flame components that need to listen to Riverpod providers or
/// external streams with strict lifecycle management and frame-sync buffering.
/// 
/// This mixin solves the asynchronous-synchronous paradigm gap by buffering 
/// Riverpod updates and applying them during the safe 'update' phase of the 
/// Flame game loop, preventing race conditions.
mixin RiverpodLifecycleMixin on Component, HasGameReference<SoilScopeGame> {
  final List<ProviderSubscription> _riverpodSubscriptions = [];
  final List<StreamSubscription> _streamSubscriptions = [];
  
  /// Buffered actions to be applied during the next [update] pass.
  final List<void Function()> _bufferedSyncActions = [];

  /// Listens to a Riverpod provider and buffers the update to be applied 
  /// during the next safe frame update phase ([update]).
  /// 
  /// Use this for any state changes that modify component properties, 
  /// add/remove children, or affect rendering.
  void listenProvider<T>(
    dynamic provider, 
    void Function(T? previous, T next) listener, 
    {bool fireImmediately = false}
  ) {
    final context = game.buildContext;
    if (context == null) return;
    
    final container = ProviderScope.containerOf(context);
    final sub = container.listen<T>(provider, (previous, next) {
      // Buffer the execution until the next update() pass of the game loop
      _bufferedSyncActions.add(() => listener(previous, next));
    }, fireImmediately: fireImmediately);
    
    _riverpodSubscriptions.add(sub);
  }

  /// Listens to a Riverpod provider and executes the listener IMMEDIATELY
  /// upon state change, bypassing the frame buffer.
  /// 
  /// CAUTION: Only use this for non-visual state management or logic that 
  /// does not interact with the Flame component tree or physics properties,
  /// as it may cause race conditions.
  void listenProviderImmediate<T>(
    dynamic provider, 
    void Function(T? previous, T next) listener, 
    {bool fireImmediately = false}
  ) {
    final context = game.buildContext;
    if (context == null) return;
    
    final container = ProviderScope.containerOf(context);
    final sub = container.listen<T>(provider, listener, fireImmediately: fireImmediately);
    _riverpodSubscriptions.add(sub);
  }

  /// Adds an external StreamSubscription and buffers its events to the game loop.
  void addStreamSubscription<T>(Stream<T> stream, void Function(T event) onEvent) {
    final sub = stream.listen((event) {
      _bufferedSyncActions.add(() => onEvent(event));
    });
    _streamSubscriptions.add(sub);
  }

  @override
  void update(double dt) {
    // Apply all buffered Riverpod/Stream updates at the start of the frame
    if (_bufferedSyncActions.isNotEmpty) {
      // Copy the list to avoid concurrent modification if an action adds a new action
      final actions = List<void Function()>.from(_bufferedSyncActions);
      _bufferedSyncActions.clear();
      for (final action in actions) {
        action();
      }
    }
    super.update(dt);
  }

  @override
  void onRemove() {
    // Explicitly close all Riverpod subscriptions
    for (final sub in _riverpodSubscriptions) {
      sub.close();
    }
    _riverpodSubscriptions.clear();

    // Explicitly cancel all Stream subscriptions
    for (final sub in _streamSubscriptions) {
      sub.cancel();
    }
    _streamSubscriptions.clear();
    
    _bufferedSyncActions.clear();
    
    super.onRemove();
  }
}
