import 'dart:ui';

import 'package:material_ui/material_ui.dart';

/// A frosted-glass surface for floating HUD panels.
///
/// The backdrop blur is an offscreen compositor pass over the panel's bounds.
/// It was the first optimization candidate for the microscope overlay, but an
/// interleaved A/B measured no difference between the blur and a plain panel
/// (see `PERFORMANCE.md`), so the original blurred look stays the default.
///
/// [backdropBlurEnabled] exists only so the profile harness can measure the
/// blur on and off in the same session (`PHASE4_AB`); nothing in the app
/// toggles it at runtime.
class BlurSurface extends StatelessWidget {
  static final ValueNotifier<bool> backdropBlurEnabled = ValueNotifier(true);

  final double sigma;
  final Widget child;

  const BlurSurface({super.key, required this.sigma, required this.child});

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;
    return ValueListenableBuilder<bool>(
      valueListenable: backdropBlurEnabled,
      child: child,
      builder: (context, enabled, panel) {
        if (compact || !enabled) return panel!;
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: panel,
        );
      },
    );
  }
}
