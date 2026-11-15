import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/models/reference_dataset.dart';

/// Loads the single active reference profile.
///
/// Replacing the illustrative fixture with measured data is a data change:
/// point [defaultAsset] at the measured JSON and keep the schema documented in
/// docs/validation/README.md. No application code needs to change.
class ReferenceDatasetRepository {
  static const String defaultAsset = 'assets/validation/reference.json';

  static Future<ReferenceDataset>? _cached;

  static Future<ReferenceDataset> loadDefault({AssetBundle? bundle}) {
    return _cached ??= (bundle ?? rootBundle)
        .loadString(defaultAsset)
        .then(
          (raw) => ReferenceDataset.fromJson(
            jsonDecode(raw) as Map<String, dynamic>,
          ),
        );
  }

  /// Test hook: forget the cached asset so a different bundle can be used.
  static void resetCache() => _cached = null;
}
