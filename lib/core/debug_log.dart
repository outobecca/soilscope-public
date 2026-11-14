import 'package:flutter/foundation.dart';

/// Writes a diagnostic message only in debug builds.
///
/// Hot paths (per-tick simulation loops and per-build widget traces) use this
/// instead of calling [debugPrint] directly so release builds stay silent.
void debugLog(String message) {
  if (kDebugMode) {
    debugPrint(message);
  }
}
