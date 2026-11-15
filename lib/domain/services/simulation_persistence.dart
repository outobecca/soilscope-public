import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/debug_log.dart';
import '../models/biophysical_state.dart';
import '../models/model_parameter_set.dart';

/// A loaded session together with the model parameter set that produced it.
class SavedSession {
  final BiophysicalState state;
  final ModelParameterSet? model;

  const SavedSession({required this.state, this.model});
}

/// Reads and writes the resumable session in platform preferences.
///
/// Session state is not a secret. Keeping it out of secure storage avoids the
/// platform and web failure modes of that plugin while still using an
/// on-device, non-sensitive store. Saves carry a small version envelope so a
/// future format can be migrated or rejected deliberately instead of being
/// mistaken for a valid session.
class SimulationPersistence {
  static const String stateKey = 'simulation_session';
  static const String legacyStateKey = 'last_biophysical_state';
  static const int formatVersion = 1;

  final Future<SharedPreferences> Function() _preferences;

  SimulationPersistence({Future<SharedPreferences> Function()? preferences})
    : _preferences = preferences ?? SharedPreferences.getInstance;

  Future<void> save(BiophysicalState state) async {
    try {
      final prefs = await _preferences();
      final written = await prefs.setString(stateKey, _encode(state));
      if (written) {
        await prefs.remove(legacyStateKey);
      }
    } catch (error) {
      debugLog('Error saving state: $error');
    }
  }

  Future<bool> hasSavedState({required bool hasLiveRun}) async {
    try {
      final prefs = await _preferences();
      return prefs.containsKey(stateKey) ||
          prefs.containsKey(legacyStateKey) ||
          hasLiveRun;
    } catch (error) {
      debugLog('Error checking saved state: $error');
      return hasLiveRun;
    }
  }

  Future<BiophysicalState?> load() async => (await loadSession())?.state;

  /// Loads the saved session and the model parameter set recorded with it.
  ///
  /// A missing model block (legacy or pre-versioning save) is allowed. A
  /// different fingerprint is logged rather than rejected: the state is still
  /// resumable, but the caller can tell that the physics changed under it.
  Future<SavedSession?> loadSession() async {
    final SharedPreferences prefs;
    try {
      prefs = await _preferences();
    } catch (error) {
      debugLog('Error opening saved state: $error');
      return null;
    }

    final encoded = prefs.getString(stateKey);
    if (encoded != null) {
      final session = _decodeVersioned(encoded);
      if (session == null) {
        await _discard(prefs, stateKey);
      }
      return session;
    }

    final legacy = prefs.getString(legacyStateKey);
    if (legacy == null) return null;

    final state = _decodeLegacy(legacy);
    if (state == null) {
      await _discard(prefs, legacyStateKey);
      return null;
    }

    // Upgrade the pre-versioned raw JSON. save() removes the legacy key only
    // after the versioned value has been written successfully.
    await save(state);
    return SavedSession(state: state, model: ModelParameterSet.current);
  }

  String _encode(BiophysicalState state) => jsonEncode({
    'version': formatVersion,
    'model': ModelParameterSet.current.toJson(),
    'state': state.toJson(),
  });

  SavedSession? _decodeVersioned(String encoded) {
    try {
      final envelope = jsonDecode(encoded);
      if (envelope is! Map<String, dynamic>) return null;
      if (envelope['version'] != formatVersion) return null;
      final data = envelope['state'];
      if (data is! Map<String, dynamic>) return null;
      final model = ModelParameterSet.fromJson(envelope['model']);
      if (model != null && !model.sameAsCurrent()) {
        debugLog(
          'Saved session was produced by ${model.label}; '
          'current model is ${ModelParameterSet.current.label}',
        );
      }
      return SavedSession(state: BiophysicalState.fromJson(data), model: model);
    } catch (error) {
      debugLog('Error loading saved state: $error');
      return null;
    }
  }

  BiophysicalState? _decodeLegacy(String encoded) {
    try {
      final data = jsonDecode(encoded);
      if (data is! Map<String, dynamic>) return null;
      return BiophysicalState.fromJson(data);
    } catch (error) {
      debugLog('Error loading legacy saved state: $error');
      return null;
    }
  }

  Future<void> _discard(SharedPreferences prefs, String key) async {
    debugLog('Discarding unreadable saved state at $key');
    try {
      await prefs.remove(key);
    } catch (error) {
      debugLog('Error clearing unreadable saved state: $error');
    }
  }
}
