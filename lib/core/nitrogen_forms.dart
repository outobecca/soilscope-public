import 'package:material_ui/material_ui.dart';

/// The nitrogen forms a student can follow in the observation layer.
///
/// The colours are shared by the scene highlight and the explainer so the
/// legend always matches what is glowing in the soil.
enum NitrogenForm { organic, ammonium, nitrate, nitrousOxide }

extension NitrogenFormStyle on NitrogenForm {
  Color get color {
    switch (this) {
      case NitrogenForm.organic:
        return const Color(0xFFB08968); // Humus brown
      case NitrogenForm.ammonium:
        return const Color(0xFFF59E0B); // Amber
      case NitrogenForm.nitrate:
        return const Color(0xFF38BDF8); // Water blue
      case NitrogenForm.nitrousOxide:
        return const Color(0xFFA78BFA); // Gas violet
    }
  }

  /// Short label used in the legend and on molecule halos.
  String get formula {
    switch (this) {
      case NitrogenForm.organic:
        return 'N org';
      case NitrogenForm.ammonium:
        return 'NH₄⁺';
      case NitrogenForm.nitrate:
        return 'NO₃⁻';
      case NitrogenForm.nitrousOxide:
        return 'N₂O';
    }
  }
}
