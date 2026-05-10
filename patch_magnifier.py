import re

with open('lib/presentation/widgets/game/components/process_magnifier.dart', 'r') as f:
    content = f.read()

# Add reusable paints
if "final Paint _sharedFillPaint =" not in content:
    content = content.replace(
        "class ProcessMagnifier extends PositionComponent",
        """class ProcessMagnifier extends PositionComponent
    with HasGameReference<SoilScopeGame> {
  final Paint _sharedFillPaint = Paint()..style = PaintingStyle.fill;
  final Paint _sharedStrokePaint = Paint()..style = PaintingStyle.stroke;"""
    )
    content = content.replace("with HasGameReference<SoilScopeGame> {\n  final Paint _sharedFillPaint", "{\n  final Paint _sharedFillPaint")

with open('lib/presentation/widgets/game/components/process_magnifier.dart', 'w') as f:
    f.write(content)
