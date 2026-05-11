with open('lib/presentation/widgets/game/components/process_magnifier.dart', 'r') as f:
    content = f.read()

# Add reusable paints
if "final Paint _sharedFillPaint =" not in content:
    desired_header = """class ProcessMagnifier extends PositionComponent
    with HasGameReference<SoilScopeGame> {
  final Paint _sharedFillPaint = Paint()..style = PaintingStyle.fill;
  final Paint _sharedStrokePaint = Paint()..style = PaintingStyle.stroke;"""
    plain_header = "class ProcessMagnifier extends PositionComponent"
    mixed_header = """class ProcessMagnifier extends PositionComponent
    with HasGameReference<SoilScopeGame> {"""

    if mixed_header in content:
        content = content.replace(mixed_header, desired_header, 1)
    elif plain_header in content:
        content = content.replace(plain_header, desired_header, 1)

with open('lib/presentation/widgets/game/components/process_magnifier.dart', 'w') as f:
    f.write(content)
