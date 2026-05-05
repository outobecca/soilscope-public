import 'package:flutter/material.dart';

/// A mixin designed to compute text bounds and adjust rendering footprints
/// based on spatial content requirements.
mixin ScalingContentMixin {
  /// Calculates the bounding size for a block of text.
  Size calculateTextBounds(String text, TextStyle style, {double maxWidth = double.infinity}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    return Size(tp.width, tp.height);
  }
}
