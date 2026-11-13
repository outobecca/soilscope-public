import 'dart:ui';

import 'package:flutter/material.dart';

/// A frosted-glass surface on wide screens, and a plain translucent panel on
/// phones, where the full-screen offscreen blur pass is expensive on low-end
/// GPUs.
class BlurSurface extends StatelessWidget {
  final double sigma;
  final Widget child;

  const BlurSurface({super.key, required this.sigma, required this.child});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width < 600) return child;
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      child: child,
    );
  }
}
