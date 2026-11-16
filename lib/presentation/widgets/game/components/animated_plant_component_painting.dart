part of 'animated_plant_component.dart';

/// Drawing and visual-particle helpers, split from the component lifecycle.
extension _PlantVisuals on AnimatedPlantComponent {
  void _drawBranches(
    Canvas canvas,
    int branchCount,
    double lastBranchPartial,
    double shootScale,
    double droopAngle,
    double sway,
    double topX,
    double topY,
    double cp1X,
    double cp1Y,
    double cp2X,
    double cp2Y,
    double turgor,
    Color activeStemColor,
    String? inspectorType,
  ) {
    for (int i = 0; i < branchCount + 1; i++) {
      if (i >= 12) break;
      final heightFactor = 0.15 + (i / 12.0) * 0.75;
      if (heightFactor > 0.9) continue;

      // Only draw the partial branch if it's the last one
      final isLast = i == branchCount;
      final unfoldingScale = isLast ? lastBranchPartial : 1.0;
      if (unfoldingScale < 0.05) continue;

      final t = heightFactor;

      // Interpolate start point based on stem straightening
      final organicStartX = _cubicBezier(0, cp1X, cp2X, topX, t);
      final organicStartY = _cubicBezier(0, cp1Y, cp2Y, topY, t);
      final schematicStartX = 0.0;
      final schematicStartY = -topY.abs() * t;

      final bIsLeft = i % 2 == 0;
      final bLength = 65.0 * shootScale * (1.1 - t * 0.5) * unfoldingScale;
      // Sway is stronger at the top
      final heightSway = sway * (1.0 + t * 0.5);

      // --- Angle Calculation ---
      // Organic: Stochastic based on side and turgor
      final organicAngle =
          (bIsLeft ? -math.pi / 2.8 : math.pi / 2.8) *
              (0.8 + (1.0 - turgor) * 0.5) +
          droopAngle +
          heightSway;

      // Schematic: Radial Graph distribution centered at base
      // Main stem provides context, branches radiate fully outwards.
      final bool isSchematic = _layoutProgress > 0.5;
      const double radialSweep = math.pi * 1.5; // Spread around the center
      final schematicAngle = branchCount > 0
          ? (-radialSweep / 2 + (i / branchCount) * radialSweep) - math.pi / 2
          : (bIsLeft ? -math.pi / 3 : math.pi / 3) - math.pi / 2;

      final currentAngle = lerpDouble(
        organicAngle,
        schematicAngle,
        _layoutProgress,
      )!;

      // In radial schematic mode, branches extend outward from origin (0,0) or low on the stem
      final targetStartX = isSchematic ? 0.0 : schematicStartX;
      final targetStartY = isSchematic ? 0.0 : schematicStartY;

      final currentStartX = lerpDouble(
        organicStartX,
        targetStartX,
        _layoutProgress,
      )!;
      final currentStartY = lerpDouble(
        organicStartY,
        targetStartY,
        _layoutProgress,
      )!;

      final schematicLength =
          bLength *
          1.5; // Make them slightly longer in radial view to stand out
      final currentLength = lerpDouble(
        bLength,
        schematicLength,
        _layoutProgress,
      )!;

      final bEndX = currentStartX + math.sin(currentAngle) * currentLength;
      final bEndY = currentStartY - math.cos(currentAngle) * currentLength;

      _branchPaint
        ..color = activeStemColor
        ..strokeWidth = 4.0 * shootScale * (1.1 - t * 0.6) * unfoldingScale;

      canvas.drawLine(
        Offset(currentStartX, currentStartY),
        Offset(bEndX, bEndY),
        _branchPaint,
      );

      // Branch leaf
      final bLeafScale = shootScale * 0.9 * unfoldingScale;
      _drawLeaf(
        canvas,
        Vector2(bEndX, bEndY),
        droopAngle,
        heightSway,
        bLeafScale,
        turgor,
        bIsLeft,
        seed: i + 50,
        highlighted: inspectorType == 'leaf',
      );
    }
  }

  void _drawMainStemLeaves(
    Canvas canvas,
    double biomass,
    double shootScale,
    double droopAngle,
    double sway,
    double topX,
    double topY,
    double cp1X,
    double cp1Y,
    double cp2X,
    double cp2Y,
    double turgor,
    String? inspectorType,
  ) {
    // Main Stem Leaves with smooth unfolding
    final leafProgress = 2.0 + (biomass / 120.0);
    final leafCount = leafProgress.floor().clamp(2, 14);
    final lastLeafPartial = (leafProgress - leafProgress.floor()).clamp(
      0.0,
      1.0,
    );

    for (int i = 0; i < leafCount + 1; i++) {
      if (i >= 14) break;
      final heightFactor = 0.1 + (i / 14.0) * 0.85;
      final isLeft = i % 2 == 0;

      final isLast = i == leafCount;
      final unfoldingScale = isLast ? lastLeafPartial : 1.0;
      if (unfoldingScale < 0.05) continue;

      final leafScale = (1.2 - (i / 14.0) * 0.5) * shootScale * unfoldingScale;
      final t = heightFactor;
      final organicX = _cubicBezier(0, cp1X, cp2X, topX, t);
      final organicY = _cubicBezier(0, cp1Y, cp2Y, topY, t);
      final schematicX = 0.0;
      final schematicY = -topY.abs() * t;

      final lX = lerpDouble(organicX, schematicX, _layoutProgress)!;
      final lY = lerpDouble(organicY, schematicY, _layoutProgress)!;
      final heightSway = sway * (1.0 + t * 0.6);

      _drawLeaf(
        canvas,
        Vector2(lX, lY),
        droopAngle,
        heightSway,
        leafScale,
        turgor,
        isLeft,
        seed: i,
        highlighted: inspectorType == 'leaf',
      );
    }
  }

  void _drawGrowthTip(
    Canvas canvas,
    double topX,
    double topY,
    double shootScale,
    double turgor,
  ) {
    _tipGlowPaint
      ..color = const Color(0xFFA7F3D0).withValues(alpha: 0.3 * turgor)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(Offset(topX, topY), 8.0 * shootScale, _tipGlowPaint);
  }

  void _drawLabels(
    Canvas canvas,
    Plant plant,
    double worldWidth,
    double soilHeight,
    double zoom,
  ) {
    if (isHovered || _isPinned) {
      // Info handled via global overlay
    }

    if (_hoveredRootIndex != null || _pinnedRootIndex != null) {
      final index = _hoveredRootIndex ?? _pinnedRootIndex!;
      if (index < plant.rootSystem.length) {
        final node = plant.rootSystem[index];
        final pos = _mapRootToLocal(
          node,
          index,
          plant.baseX,
          worldWidth,
          soilHeight,
        );

        canvas.drawCircle(
          pos.toOffset(),
          12 / zoom,
          Paint()
            ..color = const Color(0xFF34D399).withValues(alpha: 0.8)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0 / zoom,
        );
        canvas.drawCircle(
          pos.toOffset(),
          6 / zoom,
          Paint()
            ..color = const Color(0xFF34D399).withValues(alpha: 0.3)
            ..style = PaintingStyle.fill,
        );
      }
    }
  }

  void _drawTaperedStem(
    Canvas canvas,
    double h,
    double droop,
    double sway,
    double scale,
    double turgor, {
    bool highlighted = false,
  }) {
    final plant = _plantData;
    final biomass = plant?.totalBiomass ?? 500.0;

    // Vitality-based coloring: Deep emerald to healthy lime
    final chlorophyllDensity =
        (turgor * 0.7 + (biomass / 2000).clamp(0.0, 0.3));
    final baseColor = Color.lerp(
      const Color(0xFF451A03),
      const Color(0xFF065F46),
      chlorophyllDensity,
    )!;
    final color = Color.lerp(baseColor, const Color(0xFF10B981), turgor)!;

    final topX = math.sin(droop + sway) * h * 0.4;
    final topY = -h;
    final cp1X = math.sin(droop + sway) * h * 0.1;
    final cp1Y = -h * 0.4;
    final cp2X = topX * 0.8;
    final cp2Y = topY * 0.7;

    final leftPath = Path();
    final rightPath = Path();
    final List<Offset> centers = [];
    final List<double> widths = [];

    final int segments = 20;
    for (int i = 0; i <= segments; i++) {
      final t = i / segments;

      // Organic positions
      final organicX = _cubicBezier(0, cp1X, cp2X, topX, t);
      final organicY = _cubicBezier(0, cp1Y, cp2Y, topY, t);

      // Schematic positions: Straight vertical line
      final schematicX = 0.0;
      final schematicY = -h * t;

      final currentX = lerpDouble(organicX, schematicX, _layoutProgress)!;
      final currentY = lerpDouble(organicY, schematicY, _layoutProgress)!;

      centers.add(Offset(currentX, currentY));

      // Allometric scaling: stem is thicker at base
      final width = (12.0 * (1.1 - t * 0.75)) * scale;
      widths.add(width);

      double dx, dy;
      if (i < segments) {
        final nextT = (i + 1) / segments;
        final nextOrganicX = _cubicBezier(0, cp1X, cp2X, topX, nextT);
        final nextOrganicY = _cubicBezier(0, cp1Y, cp2Y, topY, nextT);
        final nextSchematicX = 0.0;
        final nextSchematicY = -h * nextT;

        final nextX = lerpDouble(
          nextOrganicX,
          nextSchematicX,
          _layoutProgress,
        )!;
        final nextY = lerpDouble(
          nextOrganicY,
          nextSchematicY,
          _layoutProgress,
        )!;

        dx = nextX - currentX;
        dy = nextY - currentY;
      } else {
        final prevT = (i - 1) / segments;
        final prevOrganicX = _cubicBezier(0, cp1X, cp2X, topX, prevT);
        final prevOrganicY = _cubicBezier(0, cp1Y, cp2Y, topY, prevT);
        final prevSchematicX = 0.0;
        final prevSchematicY = -h * prevT;

        final prevX = lerpDouble(
          prevOrganicX,
          prevSchematicX,
          _layoutProgress,
        )!;
        final prevY = lerpDouble(
          prevOrganicY,
          prevSchematicY,
          _layoutProgress,
        )!;

        dx = currentX - prevX;
        dy = currentY - prevY;
      }
      final len = math.sqrt(dx * dx + dy * dy);
      final nx = -dy / len * width;
      final ny = dx / len * width;

      if (i == 0) {
        leftPath.moveTo(currentX + nx, currentY + ny);
        rightPath.moveTo(currentX - nx, currentY - ny);
      } else {
        leftPath.lineTo(currentX + nx, currentY + ny);
        rightPath.lineTo(currentX - nx, currentY - ny);
      }
    }

    final fullPath = Path();
    fullPath.addPath(leftPath, Offset.zero);
    final rightMetrics = rightPath.computeMetrics().toList();
    if (rightMetrics.isNotEmpty) {
      final m = rightMetrics.first;
      for (double d = m.length; d >= 0; d -= 2) {
        final pos = m.getTangentForOffset(d)?.position;
        if (pos != null) fullPath.lineTo(pos.dx, pos.dy);
      }
    }
    fullPath.close();

    // Main stem fill
    canvas.drawPath(fullPath, Paint()..color = color);

    // Subtle longitudinal vascular bundles (textures)
    final vascularPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5 * scale;

    for (double offsetMult in [-0.4, 0.0, 0.4]) {
      final vPath = Path();
      for (int i = 0; i < centers.length; i++) {
        final w = widths[i];
        // Calculate tangent for offset
        double dx, dy;
        if (i < centers.length - 1) {
          dx = centers[i + 1].dx - centers[i].dx;
          dy = centers[i + 1].dy - centers[i].dy;
        } else {
          dx = centers[i].dx - centers[i - 1].dx;
          dy = centers[i].dy - centers[i - 1].dy;
        }
        final len = math.sqrt(dx * dx + dy * dy);
        final nx = -dy / len * (w * offsetMult);
        final ny = dx / len * (w * offsetMult);

        if (i == 0) {
          vPath.moveTo(centers[i].dx + nx, centers[i].dy + ny);
        } else {
          vPath.lineTo(centers[i].dx + nx, centers[i].dy + ny);
        }
      }
      canvas.drawPath(vPath, vascularPaint);
    }

    // Specular highlight for cylindrical look
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * scale;
    final hPath = Path();
    for (int i = 0; i < centers.length; i++) {
      final w = widths[i];
      double dx, dy;
      if (i < centers.length - 1) {
        dx = centers[i + 1].dx - centers[i].dx;
        dy = centers[i + 1].dy - centers[i].dy;
      } else {
        dx = centers[i].dx - centers[i - 1].dx;
        dy = centers[i].dy - centers[i - 1].dy;
      }
      final len = math.sqrt(dx * dx + dy * dy);
      final nx = -dy / len * (w * -0.3);
      final ny = dx / len * (w * -0.3);
      if (i == 0) {
        hPath.moveTo(centers[i].dx + nx, centers[i].dy + ny);
      } else {
        hPath.lineTo(centers[i].dx + nx, centers[i].dy + ny);
      }
    }
    canvas.drawPath(hPath, highlightPaint);

    if (highlighted) {
      final zoom = game.camera.viewfinder.zoom;
      final pulse = 0.5 + 0.5 * math.sin(game.currentTime() * 8);
      canvas.drawPath(
        fullPath,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.6 * pulse)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5 / zoom
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }

    // Root collar transition
    final collarPulse = 0.5 + 0.5 * math.sin(game.currentTime() * 1.5);
    final collarGlow = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.12 * collarPulse)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(Offset.zero, 14.0 * scale * collarPulse, collarGlow);

    final collarPaint = Paint()
      ..color = Color.lerp(color, const Color(0xFF451A03), 0.6)!
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: 13.2 * scale,
        height: 7.0 * scale,
      ),
      collarPaint,
    );
  }

  double _cubicBezier(double p0, double p1, double p2, double p3, double t) {
    final u = 1 - t;
    return u * u * u * p0 +
        3 * u * u * t * p1 +
        3 * u * t * t * p2 +
        t * t * t * p3;
  }

  void _drawRootSystem(
    Canvas canvas,
    List<RootNode> nodes,
    double turgor,
    double baseX,
    double shootScale, {
    bool highlighted = false,
  }) {
    if (nodes.isEmpty) return;
    final zoom = game.camera.viewfinder.zoom;
    final worldWidth = SoilScopeGame.soilColumnWidth;
    final soilHeight = game.soilColumnHeight;
    final time = game.currentTime();

    _ensureRootTopology(nodes);
    final taprootNodeIndices = _taprootNodeIndices;
    final childCount = _rootChildCounts;
    final hairPath = Path();
    var hasRootHairs = false;
    // At the normal scene scale each root is only a few pixels wide. Batched
    // centreline strokes preserve the measured architecture while avoiding
    // hundreds of tapered-fill paths and hair curves per frame. The full
    // anatomical rendering returns as soon as the user zooms in.
    final batchedRoots = zoom < 1.25;
    final batchedTaproot = Path();
    final batchedLaterals = Path();
    // Hair detail is only resolvable up close. At normal zoom a sparse,
    // batched set keeps the root texture without thousands of draw calls.
    final detailedHairs = zoom >= 1.8;
    final taperSegments = detailedHairs ? 10 : 6;

    Vector2 map(RootNode n, int index) =>
        _mapRootToLocal(n, index, baseX, worldWidth, soilHeight);

    // --- Draw each root segment as a filled tapered shape ---
    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      if (node.parentIndex == null || node.parentIndex! >= nodes.length) {
        continue;
      }

      final parentNode = nodes[node.parentIndex!];
      final isTaproot =
          taprootNodeIndices.contains(i) &&
          taprootNodeIndices.contains(node.parentIndex!);

      final o1 = map(parentNode, node.parentIndex!).toOffset();
      final o2 = map(node, i).toOffset();
      final dx = o2.dx - o1.dx;
      final dy = o2.dy - o1.dy;
      final segLen = math.sqrt(dx * dx + dy * dy);
      if (segLen < 0.5) continue;

      // --- Organic Bezier curvature ---
      // Roots follow gravitropism (+Y/Z downward).
      // Reduced noise amplitude and removed time-based wiggling to ensure a stable, natural path.
      final noiseAmplitude = (isTaproot ? 0.8 : 3.0) / zoom;
      final noisePhase =
          node.z * 8.0 + i * 0.5; // Static phase (no time component)
      final noiseX = math.sin(noisePhase) * noiseAmplitude;
      final noiseX2 = math.cos(noisePhase * 0.8) * (noiseAmplitude * 0.4);

      final spine = Path()..moveTo(o1.dx, o1.dy);

      if (_layoutProgress > 0.8) {
        // Layered Graph Style: Orthogonal (L-shaped) connections
        // Roots spread wide horizontally in the topsoil first, then straight down
        spine.lineTo(o2.dx, o1.dy);
        spine.lineTo(o2.dx, o2.dy);
      } else {
        // Organic: Cubic Bezier spine with reduced horizontal swing for the taproot
        final cpIntensity = isTaproot ? 0.05 : 0.15;
        spine.cubicTo(
          o1.dx + noiseX + dx * cpIntensity, // CP1x
          o1.dy + dy * 0.35, // CP1y
          o2.dx + noiseX2 - dx * cpIntensity, // CP2x
          o1.dy + dy * 0.65, // CP2y
          o2.dx,
          o2.dy,
        );
      }

      // Growth age is needed for both LOD paths. Mature segments can be
      // collected without computing metrics or tapered edges.
      final birthTime = _nodeBirthTimes[i] ?? 0.0;
      final growthAge = (time - birthTime).clamp(0.0, 1.0);
      if (batchedRoots && growthAge >= 1.0) {
        (isTaproot ? batchedTaproot : batchedLaterals).addPath(
          spine,
          Offset.zero,
        );
        continue;
      }

      // --- Width tapering ---
      // Parent width: feeds from the stem base (which is 13.2 * scale)
      // At the surface (z=0), we match the stem base exactly.
      final double rootCollarWidth = 13.2 * shootScale;
      final double parentWidth = isTaproot
          ? (rootCollarWidth *
                (1.0 +
                    (childCount[node.parentIndex!] *
                        0.05 *
                        (parentNode.z > 0 ? 1 : 0))))
          : ((node.radius * 350.0).clamp(2.5, 20.0) *
                    (1.0 + childCount[node.parentIndex!] * 0.06)) /
                zoom;
      final depthTaperParent = (1.0 - (parentNode.z * 0.4).clamp(0.0, 0.7));
      final wStart = parentWidth * depthTaperParent;

      // Child width: thinner than parent
      final double childWidthBase = isTaproot
          ? (9.0 * shootScale)
          : ((node.radius * 280.0).clamp(1.5, 16.0)) / zoom;
      final depthTaperChild = (1.0 - (node.z * 0.5).clamp(0.0, 0.85));
      final wEnd = childWidthBase * depthTaperChild;

      // --- Trace left and right edges along the spine to create filled tapered path ---
      final metrics = spine.computeMetrics().toList();
      if (metrics.isEmpty) continue;
      final metric = metrics.first;
      final mLen = metric.length;

      // Smoothly interpolate the length of the segment for newly grown nodes
      final activeLen = mLen * growthAge;
      if (activeLen < 0.1) continue;

      final List<Offset> leftEdge = [];
      final List<Offset> rightEdge = [];

      for (int s = 0; s <= taperSegments; s++) {
        final t = s / taperSegments;
        final tangent = metric.getTangentForOffset(activeLen * t);
        if (tangent == null) continue;

        final pos = tangent.position;
        final normal = Offset(-tangent.vector.dy, tangent.vector.dx);
        // Smooth cubic interpolation for tapering (not linear, looks more organic)
        final tSmooth = t * t * (3.0 - 2.0 * t); // smoothstep
        final halfWidth = (wStart + (wEnd - wStart) * tSmooth) / 2.0;

        leftEdge.add(pos + normal * halfWidth);
        rightEdge.add(pos - normal * halfWidth);
      }

      if (leftEdge.length < 2) continue;

      // Build filled shape
      final taperedPath = Path()..moveTo(leftEdge.first.dx, leftEdge.first.dy);
      for (int s = 1; s < leftEdge.length; s++) {
        taperedPath.lineTo(leftEdge[s].dx, leftEdge[s].dy);
      }
      // Trace back along the right edge (reversed)
      for (int s = rightEdge.length - 1; s >= 0; s--) {
        taperedPath.lineTo(rightEdge[s].dx, rightEdge[s].dy);
      }
      taperedPath.close();

      // --- Color: creamy white/beige for taproot, paler whitish for laterals ---
      final branchColor = isTaproot
          ? Color.lerp(
              const Color(0xFFFDE68A),
              const Color(0xFFFEF3C7),
              (node.z).clamp(0.0, 1.0),
            )!
          : Color.lerp(
              const Color(0xFFFEF3C7),
              const Color(0xFFFAFAF9),
              (node.z).clamp(0.0, 1.0),
            )!;

      // Smooth fade-in for newly grown segments (based on node index as proxy for age)
      final double fadeIn = (time - (i * 0.02)).clamp(0.0, 1.0);
      canvas.drawPath(
        taperedPath,
        _rootFillPaint..color = branchColor.withValues(alpha: fadeIn),
      );

      // --- Specular highlight for 3D volume illusion ---
      // Lateral highlights are sub-pixel at normal zoom; the taproot keeps its
      // volume cue because it anchors the silhouette.
      if (wStart > 2.0 / zoom && (isTaproot || zoom >= 1.2)) {
        final highlightPath = Path()
          ..moveTo(leftEdge.first.dx, leftEdge.first.dy);
        for (int s = 1; s < leftEdge.length; s++) {
          highlightPath.lineTo(leftEdge[s].dx, leftEdge[s].dy);
        }
        canvas.drawPath(
          highlightPath,
          _rootHighlightPaint
            ..color = Colors.white.withValues(alpha: 0.12 * fadeIn)
            ..strokeWidth = math.max(0.5, (wStart * 0.2)),
        );
      }
      // --- Root hairs on lateral roots ---
      if (!isTaproot &&
          node.z > 0.08 &&
          zoom > 0.8 &&
          (detailedHairs || i.isEven)) {
        _appendRootHairs(
          hairPath,
          metric,
          activeLen,
          wEnd,
          zoom,
          time,
          node.z,
          i,
          detailedHairs: detailedHairs,
        );
        hasRootHairs = true;
      }

      // --- Inspector highlight ---
      if (highlighted) {
        final pulse = 0.5 + 0.5 * math.sin(time * 8);
        canvas.drawPath(
          taperedPath,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.3 * pulse * fadeIn)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0 / zoom
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
        );
      }
    }

    if (hasRootHairs) {
      canvas.drawPath(
        hairPath,
        _rootHairPaint
          ..color = const Color(0xFFFEF3C7).withValues(alpha: 0.22)
          ..strokeWidth = 0.4 / zoom,
      );
    }

    if (batchedRoots) {
      final taprootPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFFDE68A);
      final lateralPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFFEF3C7);
      if (highlighted) {
        final pulse = 0.5 + 0.5 * math.sin(time * 8);
        taprootPaint.color = Colors.white.withValues(alpha: 0.45 * pulse);
        lateralPaint.color = Colors.white.withValues(alpha: 0.35 * pulse);
      }
      if (batchedLaterals.getBounds().isEmpty == false) {
        canvas.drawPath(
          batchedLaterals,
          lateralPaint..strokeWidth = 4.0 / zoom,
        );
      }
      if (batchedTaproot.getBounds().isEmpty == false) {
        canvas.drawPath(
          batchedTaproot,
          taprootPaint
            ..strokeWidth = (8.5 * shootScale).clamp(2.0, 14.0),
        );
      }
    }
  }

  /// Appends organic, curved root hairs to [hairPath].
  ///
  /// The caller batches every hair into one path, so the detail survives even
  /// when the root system holds hundreds of nodes.
  void _appendRootHairs(
    Path hairPath,
    PathMetric metric,
    double metricLength,
    double rootTipWidth,
    double zoom,
    double time,
    double depth,
    int nodeIndex, {
    required bool detailedHairs,
  }) {
    // More hairs deeper in soil (absorption zone), fewer at surface.
    final rawHairCount = (4 + depth * 8).toInt();
    final int hairCount = detailedHairs
        ? rawHairCount.clamp(3, 10)
        : rawHairCount.clamp(2, 4);

    for (int i = 1; i <= hairCount; i++) {
      final t = i / (hairCount + 1);
      final tangent = metric.getTangentForOffset(metricLength * t);
      if (tangent == null) {
        continue;
      }

      final pos = tangent.position;
      final normal = Offset(-tangent.vector.dy, tangent.vector.dx);

      // Hair length varies with subtle animation
      final baseLen = (2.5 + depth * 3.0) / zoom;
      final wiggle = math.sin(time * 1.8 + i * 1.1 + nodeIndex * 0.3) * 0.4;
      final hairLen = baseLen * (0.7 + 0.3 * math.sin(i * 2.3 + nodeIndex));

      // Append both sides as curved quadratic beziers for organic waviness.
      final tipL = pos + normal * hairLen;
      final cpL =
          pos + normal * (hairLen * 0.6) + Offset(wiggle / zoom, wiggle / zoom);
      hairPath
        ..moveTo(pos.dx, pos.dy)
        ..quadraticBezierTo(cpL.dx, cpL.dy, tipL.dx, tipL.dy);

      final tipR = pos - normal * hairLen;
      final cpR =
          pos -
          normal * (hairLen * 0.6) +
          Offset(-wiggle / zoom, wiggle / zoom);
      hairPath
        ..moveTo(pos.dx, pos.dy)
        ..quadraticBezierTo(cpR.dx, cpR.dy, tipR.dx, tipR.dy);
    }
  }

  void _drawRhizosphereGlow(
    Canvas canvas,
    List<RootNode> nodes,
    double time,
    double baseX, {
    bool highlighted = false,
  }) {
    if (nodes.isEmpty) return;
    final state = game.simulationState;
    if (state == null) return;

    final worldWidth = SoilScopeGame.soilColumnWidth;
    final soilHeight = game.soilColumnHeight;
    final zoom = game.camera.viewfinder.zoom;

    // Global physiological sync: Glow pulses faster with plant vitality
    final plant = state.plants.isNotEmpty ? state.plants.first : state.plant;
    final vitality = (1.0 - plant.waterStressIndex).clamp(0.1, 1.0);
    final waterContent = state.profile.layers.first.waterContent;

    final pulseSpeed = 1.5 + vitality * 3.0;
    final pulse = 0.5 + 0.5 * math.sin(time * pulseSpeed);

    // LOD: fade the effect out when zoomed far out.
    final zoomLOD = (zoom - 0.4).clamp(0.0, 1.0);
    if (zoomLOD <= 0) return;

    Vector2 map(RootNode n, int index) =>
        _mapRootToLocal(n, index, baseX, worldWidth, soilHeight);

    // A rhizosphere is continuous along the root system. Drawing a gradient
    // for every one of hundreds of nodes produced nearly identical,
    // overlapping glows and dominated raster time. A representative sample
    // preserves the continuous haze while keeping the effect bounded.
    final glowBudget = highlighted ? 32 : (zoom >= 1.8 ? 24 : 12);
    final glowCount = math.min(nodes.length, glowBudget);
    final reachBase = 8.0 + waterContent * 10.0;
    final alphaFactor = (highlighted ? 0.25 : 0.08) * zoomLOD;

    for (int g = 0; g < glowCount; g++) {
      final i = glowCount == nodes.length
          ? g
          : (g * nodes.length / glowCount)
                .floor()
                .clamp(0, nodes.length - 1)
                .toInt();
      final node = nodes[i];
      final activity =
          (1.0 - (node.z * 0.4).clamp(0.0, 1.0)) *
          (node.isTip ? 1.6 : 1.0) *
          vitality;
      if (activity <= 0.1) continue;

      final rPos = map(node, i).toOffset();
      final glowRadius = (reachBase + 6.0 * pulse * activity) * 0.5;

      // 1. Inner Active Core (enzymatic concentration). At normal zoom this
      // sits inside the outer gradient and is not resolvable.
      if (zoom >= 1.2) {
        canvas.drawCircle(
          rPos,
          glowRadius * 0.4,
          Paint()
            ..shader =
                RadialGradient(
                  colors: [
                    const Color(0xFF84CC16).withValues(
                      alpha: (alphaFactor * activity * 1.5).clamp(0.0, 0.12),
                    ),
                    const Color(0xFF84CC16).withValues(alpha: 0.0),
                  ],
                ).createShader(
                  Rect.fromCircle(center: rPos, radius: glowRadius * 0.4),
                )
            ..blendMode = BlendMode.screen,
        );
      }

      // 2. Outer rhizosphere influence
      canvas.drawCircle(
        rPos,
        glowRadius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFF84CC16).withValues(
                alpha: (alphaFactor * activity * 0.5).clamp(0.0, 0.1),
              ),
              const Color(0xFF84CC16).withValues(alpha: 0.0),
            ],
            stops: const [0.3, 1.0],
          ).createShader(Rect.fromCircle(center: rPos, radius: glowRadius))
          ..blendMode = BlendMode.screen,
      );

      // 3. Enzymatic mining particles are only legible up close.
      if (zoom >= 1.5 && node.isTip && activity > 0.6 && i.isEven) {
        _drawMiningParticles(canvas, rPos, time + i, activity);
      }
    }

    // Batch every tip halo into one blurred path. A few hundred individual
    // blurred circles were a major raster cost; one path is visually
    // equivalent at these sub-pixel radii.
    final tipHaloPath = Path();
    final tipCorePath = Path();
    var hasTips = false;
    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      if (!node.isTip) continue;
      hasTips = true;
      final pos = map(node, i).toOffset();
      tipHaloPath.addOval(
        Rect.fromCircle(center: pos, radius: (9 + pulse * 4) / zoom),
      );
      tipCorePath.addOval(
        Rect.fromCircle(center: pos, radius: (6 + pulse * 3) / zoom),
      );
    }
    if (hasTips) {
      if (zoom >= 1.2) {
        canvas.drawPath(
          tipHaloPath,
          Paint()
            ..color = const Color(
              0xFFBEF264,
            ).withValues(alpha: 0.025 + pulse * 0.012),
        );
      }
      canvas.drawPath(
        tipCorePath,
        Paint()
          ..color = const Color(
            0xFFBEF264,
          ).withValues(alpha: 0.04 + pulse * 0.02),
      );
    }
  }

  void _drawMiningParticles(
    Canvas canvas,
    Offset center,
    double time,
    double activity,
  ) {
    const int count = 2; // Reduced count
    for (int j = 0; j < count; j++) {
      final t = (time * 0.6 + j / count) % 1.0;
      final angle = (j / count) * math.pi * 2 + time * 0.3;

      // Particles move FROM soil TO root (Nutrient Uptake / Symbiosis)
      final dist = 25 * (1.0 - t); // Tighter distance
      final pPos =
          center + Offset(math.cos(angle) * dist, math.sin(angle) * dist);

      // CPK Colors: Nitrate (Blue), Carbon (Black/Grey)
      final color = j % 2 == 0
          ? const Color(0xFF3B82F6)
          : const Color(0xFF475569);
      final pAlpha = (t * (1.0 - t) * 4.0).clamp(0.0, 1.0) * activity * 0.6;

      canvas.drawCircle(
        pPos,
        1.5,
        Paint()
          ..color = color.withValues(alpha: pAlpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1),
      );
    }
  }

  void _drawRhizosheath(Canvas canvas, List<RootNode> nodes, double baseX) {
    if (nodes.isEmpty) return;
    final worldWidth = SoilScopeGame.soilColumnWidth;
    final soilHeight = game.soilColumnHeight;
    final zoom = game.camera.viewfinder.zoom;
    if (zoom < 2.0) {
      return;
    } // Only visible when zoomed in

    final crumbPaint = Paint()
      ..color = const Color(0xFF451A03).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final rand = math.Random(42);

    Vector2 map(RootNode n, int index) =>
        _mapRootToLocal(n, index, baseX, worldWidth, soilHeight);

    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      if (rand.nextDouble() > 0.3) continue; // Sparse crumbs

      final pos = map(node, i).toOffset();
      final size = (2.0 + rand.nextDouble() * 3.0) / zoom;
      final offset = Offset(
        (rand.nextDouble() - 0.5) * 12 / zoom,
        (rand.nextDouble() - 0.5) * 12 / zoom,
      );

      // Draw a small irregular "crumb"
      canvas.drawCircle(pos + offset, size, crumbPaint);

      // Add "glue" aura (EPS)
      if (rand.nextDouble() > 0.8) {
        canvas.drawCircle(
          pos + offset,
          size * 1.5,
          Paint()
            ..color = const Color(0xFF84CC16).withValues(alpha: 0.1)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2 / zoom),
        );
      }
    }
  }

  void _drawNutrientDepletionZone(
    Canvas canvas,
    List<RootNode> nodes,
    double baseX,
  ) {
    if (nodes.isEmpty) return;
    final worldWidth = SoilScopeGame.soilColumnWidth;
    final soilHeight = game.soilColumnHeight;
    final zoom = game.camera.viewfinder.zoom;

    final shadowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    Vector2 map(RootNode n, int index) =>
        _mapRootToLocal(n, index, baseX, worldWidth, soilHeight);

    // The depletion zone is a continuous field around the root system, not a
    // separate blur per segment. Collecting the segments into one path avoids
    // hundreds of blurred offscreen passes per frame.
    final zonePath = Path();
    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      if (node.parentIndex == null || node.parentIndex! >= nodes.length) {
        continue;
      }

      final o1 = map(nodes[node.parentIndex!], node.parentIndex!).toOffset();
      final o2 = map(node, i).toOffset();
      zonePath
        ..moveTo(o1.dx, o1.dy)
        ..lineTo(o2.dx, o2.dy);
    }

    // A screen-sized 20 px Gaussian blur per frame was one of the most
    // expensive raster operations in the scene. Layered translucent strokes
    // create the same soft depletion halo without an offscreen blur pass.
    const widths = [68.0, 56.0, 45.0];
    const alphas = [0.010, 0.015, 0.024];
    for (int i = 0; i < widths.length; i++) {
      canvas.drawPath(
        zonePath,
        shadowPaint
          ..strokeWidth = widths[i] / zoom
          ..color = Colors.black.withValues(alpha: alphas[i]),
      );
    }
  }

  void _drawRootPressure(
    Canvas canvas,
    List<RootNode> nodes,
    double baseX,
    double turgor,
  ) {
    if (nodes.isEmpty || turgor < 0.7) return;
    final worldWidth = SoilScopeGame.soilColumnWidth;
    final soilHeight = game.soilColumnHeight;
    final zoom = game.camera.viewfinder.zoom;
    final time = game.currentTime();

    // Pulse traveling UP (from tip to collar)
    final pathPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    _ensureRootTopology(nodes);
    final branches = _rootBranchIndices;

    Vector2 map(RootNode n, int index) =>
        _mapRootToLocal(n, index, baseX, worldWidth, soilHeight);

    for (final branch in branches.values) {
      if (branch.length < 5) continue;

      // Calculate pulse position along the branch (upward). The tip index is
      // stable across list rebuilds, so the pulse does not jump when roots
      // grow.
      final phase = (branch.last * 0.61803398875) % 1.0;
      final progress = (time * 0.8 + phase) % 1.0;
      final reversedProgress = 1.0 - progress;
      final position = (reversedProgress * (branch.length - 1)).floor();

      if (position > 0 && position < branch.length) {
        final parentIndex = branch[position - 1];
        final nodeIndex = branch[position];
        final p1 = map(nodes[parentIndex], parentIndex).toOffset();
        final p2 = map(nodes[nodeIndex], nodeIndex).toOffset();
        canvas.drawLine(p1, p2, pathPaint..strokeWidth = 3.0 / zoom);
      }
    }
  }

  Vector2 _mapRootToLocal(
    RootNode n,
    int index,
    double baseX,
    double worldWidth,
    double soilHeight,
  ) {
    final p = _plantData;
    final collarNode = (p != null && p.rootSystem.isNotEmpty)
        ? p.rootSystem.first
        : null;
    final collarX = collarNode?.x ?? SimulationPlot.centerNormalizedX;
    final collarZ = collarNode?.z ?? 0.0;

    // Organic world position. The plot mapper is shared with world-space
    // components so the drawn root and its hit tests stay on the same 1 m²
    // extent.
    final organic = Vector2(
      SceneCoordinateMapper.rootOffsetX(n.x, collarX, worldWidth),
      ((n.z - collarZ) * soilHeight).clamp(0.0, soilHeight).toDouble(),
    );

    if (_layoutProgress <= 0.001) return organic;

    // Schematic position (Tidier Tree)
    final schematic = _schematicRootPositions[index];
    if (schematic == null) return organic;

    // Interpolate
    return Vector2(
      lerpDouble(organic.x, schematic.x, _layoutProgress)!,
      lerpDouble(organic.y, schematic.y, _layoutProgress)!,
    );
  }

  void _calculateSchematicLayout(Plant plant) {
    _schematicRootPositions.clear();
    if (plant.rootSystem.isEmpty) return;

    // Build adjacency
    final Map<int, List<int>> children = {};
    for (int i = 0; i < plant.rootSystem.length; i++) {
      final parent = plant.rootSystem[i].parentIndex;
      if (parent != null && parent < plant.rootSystem.length) {
        children.putIfAbsent(parent, () => []).add(i);
      }
    }

    // Subtree leaf counting for spacing
    final Map<int, int> subtreeLeaves = {};
    int countLeaves(int idx) {
      final kids = children[idx] ?? [];
      if (kids.isEmpty) {
        subtreeLeaves[idx] = 1;
        return 1;
      }
      int count = 0;
      for (final k in kids) {
        count += countLeaves(k);
      }
      subtreeLeaves[idx] = count;
      return count;
    }

    countLeaves(0);

    // Layout configuration
    const double hSpacing = 45.0;
    const double vSpacing = 65.0;

    void assignPos(int idx, double xCenter, double y) {
      _schematicRootPositions[idx] = Vector2(xCenter, y);

      final kids = children[idx] ?? [];
      if (kids.isEmpty) return;

      // Center the children under the parent
      double totalWidth = (subtreeLeaves[idx]! - 1) * hSpacing;
      double currentX = xCenter - totalWidth / 2.0;

      for (final k in kids) {
        double kw = (subtreeLeaves[k]! - 1) * hSpacing;
        assignPos(k, currentX + kw / 2.0, y + vSpacing);
        currentX += kw + hSpacing;
      }
    }

    // Start from collar at 0,0
    assignPos(0, 0, 0);
  }

  /// Rebuilds root topology only when the root system grows.
  ///
  /// All three products are derived entirely from immutable [RootNode]s, so a
  /// length check is enough to detect change (growth appends nodes).
  void _ensureRootTopology(List<RootNode> nodes) {
    if (_rootTopologyLength == nodes.length) return;
    _rootTopologyLength = nodes.length;

    // Taproot: follow the most vertical child from the collar.
    final taproot = <int>{};
    int? current = nodes.isEmpty ? null : 0;
    while (current != null && current < nodes.length) {
      taproot.add(current);
      int? bestChild;
      double minXDiff = double.infinity;
      for (int i = 0; i < nodes.length; i++) {
        if (nodes[i].parentIndex == current) {
          final diff = (nodes[i].x - nodes[current].x).abs();
          if (diff < minXDiff) {
            minXDiff = diff;
            bestChild = i;
          }
        }
      }
      current = bestChild;
    }
    _taprootNodeIndices = taproot;

    final childCount = List<int>.filled(nodes.length, 0);
    for (final node in nodes) {
      final parent = node.parentIndex;
      if (parent != null && parent < nodes.length) childCount[parent]++;
    }
    _rootChildCounts = childCount;

    final branches = <int, List<int>>{};
    for (int tip = 0; tip < nodes.length; tip++) {
      if (!nodes[tip].isTip) continue;
      final reversed = <int>[];
      int? currentIndex = tip;
      while (currentIndex != null && currentIndex < nodes.length) {
        reversed.add(currentIndex);
        currentIndex = nodes[currentIndex].parentIndex;
      }
      branches[tip] = reversed.reversed.toList(growable: false);
    }
    _rootBranchIndices = branches;
  }

  void _drawTipAnimations(Canvas canvas) {
    final zoom = game.camera.viewfinder.zoom;
    if (zoom < 0.6) return;
    final zoomLOD = (zoom - 0.6).clamp(0.0, 1.0);

    final isFlowMode = game.ref.read(particleFlowModeProvider);
    final boost = isFlowMode ? 2.5 : 1.0;

    for (final glow in _tipGlows) {
      final alpha = glow.alpha * zoomLOD;
      final progress = glow.life / 2.5;

      // Color based on vitality: Green (healthy) -> Yellow (stress) -> White (active growth)
      final baseColor = Color.lerp(
        const Color(0xFFFACC15), // Yellow
        const Color(0xFF84CC16), // Green
        glow.vitality,
      )!;

      final energyColor = Color.lerp(
        baseColor,
        Colors.white,
        (glow.pulse * 0.5 + 0.5) * 0.5,
      )!;

      // 1. Expanding Metabolic Rings (Multi-layered)
      for (int r = 0; r < 2; r++) {
        final rProgress = (progress + r * 0.3) % 1.0;
        final ringAlpha = (1.0 - rProgress) * 0.2 * alpha;
        final ringRadius = (2.0 + rProgress * 15.0) / zoom;

        canvas.drawCircle(
          glow.position.toOffset(),
          ringRadius,
          Paint()
            ..color = energyColor.withValues(alpha: ringAlpha)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2 / zoom,
        );
      }

      // 2. Active Meristem Core
      final coreRadius = (3.0 + glow.pulse * 2.0 * boost) / zoom;
      canvas.drawCircle(
        glow.position.toOffset(),
        coreRadius,
        Paint()
          ..color = energyColor.withValues(alpha: 0.4 * alpha)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 / zoom),
      );

      // 3. Absorption Sparkles (Random tiny dots)
      if (glow.vitality > 0.5 && glow.pulse > 0.8) {
        final rand = math.Random(glow.hashCode + (glow.life * 10).toInt());
        for (int i = 0; i < 3; i++) {
          final offset = Offset(
            (rand.nextDouble() - 0.5) * 10 / zoom,
            (rand.nextDouble() - 0.5) * 10 / zoom,
          );
          canvas.drawCircle(
            glow.position.toOffset() + offset,
            0.8 / zoom,
            Paint()..color = Colors.white.withValues(alpha: 0.6 * alpha),
          );
        }
      }
    }
  }

  void _spawnShootFlows(double dt) {
    // Xylem flow moving UP to leaves
    if (_random.nextDouble() < 0.1 * dt * 60) {
      final shootPos = SceneCoordinateMapper.mapShootPosition(
        SoilScopeGame.soilColumnWidth,
        game.soilSurfaceY,
      );
      shootPos.x += game.soilLeftX;

      final visualHeight = SceneCoordinateMapper.plantVisualHeight(_plantData!);
      final targetY = game.soilSurfaceY - visualHeight * 0.8;

      game.moleculePool?.spawn(
        position: shootPos,
        type: MoleculeType.water,
        targetPosition: Vector2(
          shootPos.x + (_random.nextDouble() - 0.5) * 40,
          targetY,
        ),
        lifeTime: 4.0,
      );
    }
  }

  void _spawnVapor(Plant plant, double dt) {
    _vaporTimer += dt;
    final transpiration = plant.actualTranspiration;
    if (transpiration < 0.00001) return;

    // Spawn rate based on transpiration
    final interval = 0.1 / (transpiration * 100000).clamp(0.1, 10.0);
    if (_vaporTimer >= interval) {
      _vaporTimer = 0;

      final shootScale =
          0.5 + (plant.totalBiomass / 1000.0).clamp(0.0, 1.5) + _growthBoost;
      final currentHeight = 450.0 * shootScale;

      // Random leaf position
      final t = _random.nextDouble();
      final angle = (t - 0.5) * math.pi;
      final x = math.sin(angle) * 30 * shootScale;
      final y = -currentHeight * (0.3 + _random.nextDouble() * 0.6);

      game.moleculePool?.spawn(
        position: position + Vector2(x, y),
        type: MoleculeType.water,
        velocity: Vector2(
          (_random.nextDouble() - 0.5) * 10,
          -20 - _random.nextDouble() * 30,
        ),
        lifeTime: 1.5,
      );
    }
  }

  void _drawLeaf(
    Canvas canvas,
    Vector2 pos,
    double droop,
    double sway,
    double scale,
    double turgor,
    bool left, {
    int seed = 0,
    bool highlighted = false,
  }) {
    if (scale < 0.01) {
      return;
    }
    canvas.save();
    canvas.translate(pos.x, pos.y);

    final state = game.simulationState;
    final nContent = (state != null && state.profile.layers.isNotEmpty)
        ? (state.profile.layers.first.nitrateContent +
              state.profile.layers.first.ammoniumContent)
        : 30.0;
    final isDeficient = nContent < 15.0;
    final isLowPar = state != null ? (state.solarRadiation < 200.0) : false;

    // Unfolding transition: small leaves are more curled
    final unfoldingFactor = (scale / 0.5).clamp(0.0, 1.0);
    final curlAmount = (1.0 - unfoldingFactor) * 0.4;

    double angleOffset = 0.0;
    if (isDeficient) {
      angleOffset = left ? 0.4 : -0.4;
    } else if (isLowPar) {
      angleOffset = left ? -0.3 : 0.3;
    }

    final baseAngle = (left ? -math.pi / 4 : math.pi / 4);
    final angle =
        baseAngle +
        angleOffset +
        (left ? -droop : droop) +
        sway * (1.3 + math.sin(seed * 0.7)) +
        (math.sin(seed * 1.2 + game.currentTime() * 0.4) * 0.08) +
        (left ? droop : -droop) * 0.5; // Additional leaf drooping
    canvas.rotate(angle);

    // Organic coloring reflecting chlorophyll, vitality and senescence
    final chlorophyllAlpha = (_smoothVitality).clamp(0.2, 1.0);
    final combinedVitality =
        turgor * chlorophyllAlpha * (1.0 - _senescence * 0.8);

    Color leafBase = Color.lerp(
      const Color(0xFF365314),
      const Color(0xFF166534),
      combinedVitality,
    )!;
    Color leafEdge = Color.lerp(
      const Color(0xFF71710a),
      const Color(0xFF4ade80),
      combinedVitality,
    )!;

    // Apply senescence (yellowing/browning)
    if (_senescence > 0.1) {
      leafBase = Color.lerp(leafBase, const Color(0xFF854D0E), _senescence)!;
      leafEdge = Color.lerp(leafEdge, const Color(0xFFEAB308), _senescence)!;
    }

    if (isDeficient) {
      leafBase = Color.lerp(leafBase, Colors.amber.shade900, 0.4)!;
      leafEdge = Color.lerp(leafEdge, Colors.yellow.shade600, 0.6)!;
    }

    _leafBasePaint.color = leafBase;

    // Organic leaf shape - slightly asymmetric
    final leafLen = 52 * scale;
    final leafWidth =
        (20 + 5 * math.sin(seed.toDouble())) * scale * unfoldingFactor;

    final path = Path()..moveTo(0, 0);
    // Upper edge
    path.cubicTo(
      leafLen * 0.2,
      -leafWidth * (0.8 + curlAmount),
      leafLen * 0.7,
      -leafWidth * (1.1 + curlAmount),
      leafLen,
      0,
    );
    // Lower edge
    path.cubicTo(
      leafLen * 0.7,
      leafWidth * (1.1 - curlAmount),
      leafLen * 0.2,
      leafWidth * (0.8 - curlAmount),
      0,
      0,
    );
    path.close();

    canvas.drawPath(path, _leafBasePaint);

    // Gradient for depth and chlorophyll distribution
    final leafGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [leafBase, leafEdge],
    ).createShader(Rect.fromLTWH(0, -leafWidth, leafLen, leafWidth * 2));
    _leafGradientPaint.shader = leafGradient;
    canvas.drawPath(path, _leafGradientPaint);

    // Midrib (Main Vein)
    _veinPaint.strokeWidth = 1.4 * scale;
    canvas.drawLine(Offset.zero, Offset(leafLen * 0.9, 0), _veinPaint);

    // Lateral veins (Secondary)
    if (scale > 0.15) {
      final secondaryVeinPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6 * scale;

      for (int i = 1; i <= 4; i++) {
        final vx = (i / 5.0) * leafLen;
        final vy = (1.0 - (i / 5.0)) * leafWidth * 0.6;
        canvas.drawLine(
          Offset(vx, 0),
          Offset(vx + 4 * scale, -vy),
          secondaryVeinPaint,
        );
        canvas.drawLine(
          Offset(vx, 0),
          Offset(vx + 4 * scale, vy),
          secondaryVeinPaint,
        );
      }
    }

    // Highlights
    _leafHighlightPaint.strokeWidth = 1.0 * scale;
    canvas.drawPath(path, _leafHighlightPaint);

    if (highlighted) {
      final zoom = game.camera.viewfinder.zoom;
      final pulse = 0.5 + 0.5 * math.sin(game.currentTime() * 8);

      _leafPulsePaint
        ..color = Colors.white.withValues(alpha: 0.6 * pulse)
        ..strokeWidth = 2.0 / zoom;

      canvas.drawPath(path, _leafPulsePaint);
    }

    // Stomata (Pores) - subtle visualization
    final stomatalOpening =
        (game.simulationState?.plant.psiLeaf ?? -0.3).abs() < 1.0 ? 1.0 : 0.2;
    if (scale > 0.3 && stomatalOpening > 0.5) {
      final stomataPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.05);
      for (int i = 0; i < 3; i++) {
        final sx = 15 * scale + i * 10 * scale;
        canvas.drawCircle(Offset(sx, 2 * scale), 1.0 * scale, stomataPaint);
        canvas.drawCircle(Offset(sx, -2 * scale), 1.0 * scale, stomataPaint);
      }
    }

    canvas.restore();
  }
}
