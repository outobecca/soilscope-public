import 'dart:convert';

import 'package:flutter/services.dart';

import '../core/model_config.dart';

/// Loads the optional runtime model-parameter overrides.
///
/// The checked-in asset is empty, so the defaults in [ModelConfig] are used.
/// A deployment or tuning run can change `parameters` without editing solver
/// code; the resulting values flow into [ModelParameterSet], validation
/// references and saved-session provenance.
class ModelConfigRepository {
  const ModelConfigRepository._();

  static const String defaultAsset = 'assets/config/model_parameters.json';

  /// Reads [defaultAsset] and applies its `parameters` map.
  ///
  /// Throws [FormatException] for malformed JSON or a non-numeric value, and
  /// [ArgumentError] for an unknown key, so a typo cannot silently leave the
  /// model on defaults.
  static Future<void> load({AssetBundle? bundle}) async {
    final raw = await (bundle ?? rootBundle).loadString(defaultAsset);
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Model config must be a JSON object with a parameters map',
      );
    }

    final rawParameters = decoded['parameters'];
    if (rawParameters == null) {
      throw const FormatException('Model config is missing parameters');
    }
    if (rawParameters is! Map<String, dynamic>) {
      throw const FormatException('Model config parameters must be an object');
    }

    final overrides = <String, double>{};
    for (final entry in rawParameters.entries) {
      final value = entry.value;
      if (value is! num) {
        throw FormatException(
          'Model parameter ${entry.key} must be numeric, got $value',
        );
      }
      overrides[entry.key] = value.toDouble();
    }
    ModelConfig.applyOverrides(overrides);
  }
}
