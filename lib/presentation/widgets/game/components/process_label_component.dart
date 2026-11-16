import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:material_ui/material_ui.dart' hide PointerMoveEvent;
import '../soil_scope_game.dart';
import '../../../providers/ui_state_provider.dart';
import 'canvas_hit_testing.dart';

enum ProcessMarkerType {
  nitrification,
  mineralization,
  adsorption,
  denitrification,
  leaching,
  photosynthesis,
  transpiration,
  nutrientUptake,
}

class ProcessLabel extends PositionComponent
    with HasGameReference<SoilScopeGame>, TapCallbacks, HoverCallbacks {
  final ProcessMarkerType type;
  final Color color;
  final bool isStatic;
  final bool showTitle;
  final double lifeTime = 5.0;
  double _elapsed = 0;
  bool _isHovered = false;
  bool _isPinned = false;
  late final String _infoSourceId =
      'process-${type.name}-${identityHashCode(this)}';
  TextPainter? _textPainter;
  Rect? _labelRect;
  RRect? _labelRRect;

  ProcessLabel({
    required this.type,
    required this.color,
    required Vector2 position,
    this.isStatic = false,
    this.showTitle = false,
  }) : super(
          position: position,
          size: Vector2.all(36),
          anchor: Anchor.center,
          priority: 1600,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Bound both the total marker population and each process type. Without
    // this a high nitrification flux can fill the screen before its labels
    // fade, hiding the other active processes.
    final active = game.world.children.query<ProcessLabel>();
    final sameType = active.where((label) => label.type == type).length;
    if (active.length >= 8 || sameType >= 2) {
      removeFromParent();
      return;
    }
    if (showTitle) {
      _prepareLabel();
    }
  }

  void _prepareLabel() {
    final l = game.l10n;
    String text = "";
    switch (type) {
      case ProcessMarkerType.nitrification:
        text = l.nitrificationTitle.toUpperCase();
        break;
      case ProcessMarkerType.mineralization:
        text = l.mineralizationTitle.toUpperCase();
        break;
      case ProcessMarkerType.adsorption:
        text = l.adsorptionTitle.toUpperCase();
        break;
      case ProcessMarkerType.denitrification:
        text = l.denitrification.toUpperCase();
        break;
      case ProcessMarkerType.leaching:
        text = l.leachingTitle.toUpperCase();
        break;
      case ProcessMarkerType.photosynthesis:
        text = l.photosynthesis.toUpperCase();
        break;
      case ProcessMarkerType.transpiration:
        text = l.transpirationLabel;
        break;
      case ProcessMarkerType.nutrientUptake:
        text = l.nutrientUptakeTitle.toUpperCase();
        break;
    }

    _textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final paddingH = 8.0;
    final paddingV = 4.0;
    _labelRect = Rect.fromCenter(
      center: const Offset(0, -28), // Relative to component center
      width: _textPainter!.width + paddingH * 2,
      height: _textPainter!.height + paddingV * 2,
    );
    _labelRRect = RRect.fromRectAndRadius(_labelRect!, const Radius.circular(4));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!(game.simulationState?.isRunning ?? false)) return;
    if (!isStatic && !_isPinned) {
      _elapsed += dt;

      final layoutMode = game.ref.read(visualLayoutModeStateProvider);
      final isSchematic = layoutMode == VisualLayoutMode.schematic;

      // Stabilize: Slower rise and NO jitter in schematic mode
      final speed = isSchematic ? 5.0 : (showTitle ? 25.0 : 10.0);
      position.y -= speed * dt;

      if (showTitle && !isSchematic) {
        position.x += math.sin(_elapsed * 4) * 0.2;
      }
    }
    if (!isStatic && _elapsed >= lifeTime && !_isPinned) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final double opacity = (isStatic || _isPinned)
        ? 1.0
        : (1.0 - _elapsed / lifeTime).clamp(0.0, 1.0);
    final isHighlighted = _isHovered || _isPinned;
    final center = Offset(size.x / 2, size.y / 2);
    final zoom = game.camera.viewfinder.zoom;

    // Process markers live in the world, but their explanatory UI should keep
    // a constant on-screen size. Scaling around the marker center prevents
    // them from becoming tiny at low zoom or overwhelming the canvas when
    // the user inspects the soil closely.
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(1 / zoom);
    final localCenter = Offset.zero;

    // Layered translucent rings read as a glow without a per-label blur.
    final glowRadius = isHighlighted ? 16.0 : 12.0;
    canvas.drawCircle(
      localCenter,
      glowRadius * 1.45,
      Paint()
        ..color = color.withValues(
          alpha: (isHighlighted ? 0.10 : 0.06) * opacity,
        ),
    );
    canvas.drawCircle(
      localCenter,
      glowRadius,
      Paint()
        ..color = color.withValues(
          alpha: (isHighlighted ? 0.18 : 0.11) * opacity,
        ),
    );

    final framePaint = Paint()
      ..color = color.withValues(alpha: (isHighlighted ? 1.0 : 0.8) * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isHighlighted ? 2.5 : 1.8;

    final fillPaint = Paint()
      ..color = const Color(0xFF0F172A).withValues(alpha: 0.9 * opacity)
      ..style = PaintingStyle.fill;

    // Draw the circular icon frame
    canvas.drawCircle(localCenter, 11, fillPaint);
    canvas.drawCircle(localCenter, 11, framePaint);

    _drawMarkerSymbol(canvas, localCenter, framePaint, opacity);

    if (showTitle) {
      _drawFloatingLabel(canvas, localCenter, opacity);
    }

    // Visual feedback for selection - no more floating text boxes here
    if (_isPinned) {
      canvas.drawCircle(
        localCenter,
        14.5,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.4 * opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }

    canvas.restore();
  }

  double get _hitRadius => CanvasHitTesting.worldRadius(
        zoom: game.camera.viewfinder.zoom,
        screenRadius: 24,
        visualWorldRadius: 11,
        minWorld: 7,
        maxWorld: 36,
      );

  @override
  bool containsLocalPoint(Vector2 point) {
    final center = size / 2;
    return point.distanceTo(center) <= _hitRadius;
  }

  @override
  void onTapUp(TapUpEvent event) {
    _isPinned = !_isPinned;
    if (_isPinned) {
      _showProcessInfo(pinned: true);
    } else {
      game.ref.read(uIStateProvider.notifier).setHoverInfo(null);
    }
    event.handled = true;
  }

  @override
  void onHoverEnter() {
    _isHovered = true;
    final currentInfo = game.ref.read(uIStateProvider);
    if (currentInfo == null || !currentInfo.isPinned) {
      _showProcessInfo(pinned: false);
    }
  }

  @override
  void onHoverExit() {
    _isHovered = false;
    if (!_isPinned) {
      final currentInfo = game.ref.read(uIStateProvider);
      if (currentInfo == null || !currentInfo.isPinned) {
        game.ref.read(uIStateProvider.notifier).setHoverInfo(null);
      }
    }
  }

  void _showProcessInfo({bool pinned = false}) {
    final l = game.l10n;
    String description = l.biogeochemical;
    String title = l.process.toUpperCase();
    Map<String, String> stats = {l.type: l.process, l.stateLabel: l.active};

    switch (type) {
      case ProcessMarkerType.nitrification:
        title = l.nitrificationTitle.toUpperCase();
        description = l.nitrificationDesc;
        break;
      case ProcessMarkerType.mineralization:
        title = l.mineralizationTitle.toUpperCase();
        description = l.mineralizationDesc;
        break;
      case ProcessMarkerType.adsorption:
        title = l.adsorptionTitle.toUpperCase();
        description = l.adsorptionDesc;
        break;
      case ProcessMarkerType.denitrification:
        title = l.denitrification.toUpperCase();
        description = l.denitrificationDesc;
        break;
      case ProcessMarkerType.leaching:
        title = l.leachingTitle.toUpperCase();
        description = l.leachingDesc;
        break;
      case ProcessMarkerType.photosynthesis:
        title = l.photosynthesis.toUpperCase();
        description = l.photosynthesisDesc;
        stats = {l.source: l.atmosphere, l.productLabel: l.sugarCompound};
        break;
      case ProcessMarkerType.transpiration:
        title = l.transpiration.toUpperCase();
        description = l.transpirationDesc;
        stats = {l.source: l.root, l.driverLabel: l.vpdLabel};
        break;
      case ProcessMarkerType.nutrientUptake:
        title = l.nutrientUptakeTitle.toUpperCase();
        description = l.nutrientUptakeDesc;
        stats = {l.source: l.root, l.processLabel: l.active};
        break;
    }

    String? symbol;
    switch (type) {
      case ProcessMarkerType.photosynthesis:
        symbol = 'C';
        break;
      case ProcessMarkerType.transpiration:
        symbol = 'O';
        break;
      case ProcessMarkerType.adsorption:
        symbol = null;
        break;
      default:
        symbol = 'N';
    }
    final logicLabModel = switch (type) {
      ProcessMarkerType.photosynthesis => 'farquhar',
      ProcessMarkerType.transpiration => 'vangenuchten',
      ProcessMarkerType.nutrientUptake => 'chemotaxis',
      ProcessMarkerType.denitrification => 'redox',
      _ => 'nitrification',
    };

    game.ref
        .read(uIStateProvider.notifier)
        .setHoverInfo(
          HoverInfo(
            title: title,
            description: description,
            stats: stats,
            isPinned: pinned,
            sourceId: _infoSourceId,
            logicLabModel: logicLabModel,
            isAtmosphere:
                type == ProcessMarkerType.photosynthesis ||
                type == ProcessMarkerType.transpiration,
            onDismiss: () => _isPinned = false,
            accentColor: color,
            elementSymbol: symbol,
            screenPosition: game.worldToScreen(absolutePosition).toOffset(),
          ),
        );
  }

  void _drawMarkerSymbol(
    Canvas canvas,
    Offset center,
    Paint framePaint,
    double opacity,
  ) {
    switch (type) {
      case ProcessMarkerType.nitrification:
        final drop = Path()
          ..moveTo(center.dx, center.dy - 5.5)
          ..quadraticBezierTo(
            center.dx - 4.2,
            center.dy - 1.2,
            center.dx,
            center.dy + 5.8,
          )
          ..quadraticBezierTo(
            center.dx + 4.2,
            center.dy - 1.2,
            center.dx,
            center.dy - 5.5,
          )
          ..close();
        canvas.drawPath(
          drop,
          Paint()
            ..color = color.withValues(alpha: 0.85 * opacity)
            ..style = PaintingStyle.fill,
        );
        break;
      case ProcessMarkerType.mineralization:
        final sparkPaint = Paint()
          ..color = color.withValues(alpha: 0.95 * opacity)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;
        canvas.drawLine(
          center + const Offset(-4, 0),
          center + const Offset(4, 0),
          sparkPaint,
        );
        canvas.drawLine(
          center + const Offset(0, -4),
          center + const Offset(0, 4),
          sparkPaint,
        );
        canvas.drawCircle(
          center,
          1.4,
          Paint()..color = Colors.white.withValues(alpha: opacity),
        );
        break;
      case ProcessMarkerType.adsorption:
        canvas.drawCircle(
          center,
          5.2,
          Paint()
            ..color = color.withValues(alpha: 0.9 * opacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.8,
        );
        canvas.drawCircle(
          center,
          1.7,
          Paint()..color = color.withValues(alpha: 0.95 * opacity),
        );
        break;
      case ProcessMarkerType.denitrification:
        final tri = Path()
          ..moveTo(center.dx - 4.8, center.dy - 3.8)
          ..lineTo(center.dx + 4.8, center.dy - 3.8)
          ..lineTo(center.dx, center.dy + 5.2)
          ..close();
        canvas.drawPath(
          tri,
          Paint()
            ..color = color.withValues(alpha: 0.9 * opacity)
            ..style = PaintingStyle.fill,
        );
        break;
      case ProcessMarkerType.leaching:
        final arrowPaint = Paint()
          ..color = color.withValues(alpha: 0.9 * opacity)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;
        canvas.drawLine(
          center + const Offset(0, -5),
          center + const Offset(0, 5),
          arrowPaint,
        );
        canvas.drawLine(
          center + const Offset(0, 5),
          center + const Offset(-3.5, 1.5),
          arrowPaint,
        );
        canvas.drawLine(
          center + const Offset(0, 5),
          center + const Offset(3.5, 1.5),
          arrowPaint,
        );
        break;
      case ProcessMarkerType.photosynthesis:
        final sunPaint = Paint()
          ..color = color.withValues(alpha: 0.9 * opacity)
          ..strokeWidth = 1.8
          ..style = PaintingStyle.stroke;
        canvas.drawCircle(center, 3.8, sunPaint);
        for (var i = 0; i < 4; i++) {
          final angle = i * math.pi / 2;
          final direction = Offset(math.cos(angle), math.sin(angle));
          canvas.drawLine(
            center + direction * 6.0,
            center + direction * 9.0,
            sunPaint,
          );
        }
        break;
      case ProcessMarkerType.transpiration:
        final vaporPaint = Paint()
          ..color = color.withValues(alpha: 0.9 * opacity)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;
        canvas.drawLine(
          center + const Offset(0, 5),
          center + const Offset(0, -5),
          vaporPaint,
        );
        canvas.drawLine(
          center + const Offset(0, -5),
          center + const Offset(-3.5, -1.5),
          vaporPaint,
        );
        canvas.drawLine(
          center + const Offset(0, -5),
          center + const Offset(3.5, -1.5),
          vaporPaint,
        );
        break;
      case ProcessMarkerType.nutrientUptake:
        final uptakePaint = Paint()
          ..color = color.withValues(alpha: 0.9 * opacity)
          ..strokeWidth = 1.8
          ..style = PaintingStyle.stroke;
        canvas.drawLine(
          center + const Offset(-4, 4),
          center + const Offset(4, -4),
          uptakePaint,
        );
        canvas.drawLine(
          center + const Offset(4, -4),
          center + const Offset(4, 0),
          uptakePaint,
        );
        canvas.drawLine(
          center + const Offset(4, -4),
          center + const Offset(0, -4),
          uptakePaint,
        );
        break;
    }

    if (_isPinned) {
      canvas.drawCircle(
        center,
        13.5,
        framePaint
          ..strokeWidth = 1.3
          ..color = Colors.white.withValues(alpha: 0.7 * opacity),
      );
    }
  }

  void _drawFloatingLabel(Canvas canvas, Offset center, double opacity) {
    if (_textPainter == null || _labelRRect == null) return;

    // Shift canvas to center to use relative rects
    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Tooltip background
    canvas.drawRRect(
      _labelRRect!,
      Paint()..color = const Color(0xFF0F172A).withValues(alpha: 0.85 * opacity),
    );

    // CPK colored border
    canvas.drawRRect(
      _labelRRect!,
      Paint()
        ..color = color.withValues(alpha: 0.6 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    _textPainter!.text = TextSpan(
      text: _textPainter!.text!.toPlainText(),
      style: TextStyle(
        color: Colors.white.withValues(alpha: opacity),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
    _textPainter!.layout(); // Still need to layout if opacity changed?
    // Actually, setting text is expensive. Let's just use opacity in the Paint if possible?
    // TextPainter doesn't support opacity in paint directly easily without color in style.

    _textPainter!.paint(
      canvas,
      _labelRect!.topLeft + Offset(8, 4), // Padding compensation
    );

    canvas.restore();
  }
}
