import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/biophysical_state.dart';

/// Reads and writes the resumable session, including the one-way migration
/// from SharedPreferences to secure storage.
///
/// Keeping this out of the notifier leaves the provider to own the runtime and
/// command flow, which is what makes the save/load path testable in isolation.
class SimulationPersistence {
  static const String stateKey = 'last_biophysical_state';

  final FlutterSecureStorage _storage;
  final Future<SharedPreferences> Function() _preferences;

  SimulationPersistence({
    FlutterSecureStorage? storage,
    Future<SharedPreferences> Function()? preferences,
  })  : _storage =
            storage ?? const FlutterSecureStorage(aOptions: AndroidOptions()),
        _preferences = preferences ?? SharedPreferences.getInstance;

  Future<void> save(BiophysicalState state) async {
    try {
      await _storage.write(key: stateKey, value: jsonEncode(state.toJson()));
    } catch (error) {
      debugPrint('Error saving state: $error');
    }
  }

  Future<bool> hasSavedState({required bool hasLiveRun}) async {
    try {
      if (await _storage.containsKey(key: stateKey)) return true;
    } catch (error) {
      debugPrint('Error checking secure storage for saved state: $error');
    }

    try {
      final prefs = await _preferences();
      if (prefs.containsKey(stateKey)) return true;
    } catch (error) {
      debugPrint('Error checking saved state in preferences: $error');
    }

    return hasLiveRun;
  }

  Future<BiophysicalState?> load() async {
    String? jsonStr;
    try {
      jsonStr = await _storage.read(key: stateKey);
    } catch (error) {
      debugPrint('Error reading secure storage for saved state: $error');
    }

    if (jsonStr == null) {
      try {
        final prefs = await _preferences();
        jsonStr = prefs.getString(stateKey);
        if (jsonStr != null) {
          try {
            await _storage.write(key: stateKey, value: jsonStr);
            await prefs.remove(stateKey);
          } catch (error) {
            debugPrint('Error migrating saved state: $error');
          }
        }
      } catch (error) {
        debugPrint('Error reading saved state from preferences: $error');
      }
    }

    if (jsonStr == null) return null;
    try {
      return BiophysicalState.fromJson(
        jsonDecode(jsonStr) as Map<String, dynamic>,
      );
    } catch (error) {
      debugPrint('Error loading saved state: $error');
      return null;
    }
  }
}
