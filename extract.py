import sys

def process_file():
    with open('lib/presentation/widgets/game/components/particle_system_component.dart', 'r') as f:
        content = f.read()

    new_methods = """
  bool _isPartOfActiveCycle(ParticleType type, ObservationCycle activeCycle) {
    switch (activeCycle) {
      case ObservationCycle.nitrogen:
        return type == ParticleType.nitrate ||
            type == ParticleType.ammonium ||
            type == ParticleType.organicNitrogen;
      case ObservationCycle.carbon:
        return type == ParticleType.carbon ||
            type == ParticleType.labileCarbon ||
            type == ParticleType.stableCarbon;
      case ObservationCycle.water:
        return type == ParticleType.water;
      case ObservationCycle.phosphorus:
        return type == ParticleType.phosphorus ||
            type == ParticleType.organicPhosphorus;
      case ObservationCycle.none:
        return true;
    }
  }

  bool _isElementHighlighted(ParticleType type, ObservationCycle activeCycle,
      bool isPartOfActiveCycle, String? highlightedSymbol) {
    if (activeCycle != ObservationCycle.none && isPartOfActiveCycle) {
      return true;
    } else if (highlightedSymbol != null && highlightedSymbol.isNotEmpty) {
      final s = highlightedSymbol.toUpperCase();
      if (s == 'N' || s == 'NITROGEN') {
        return type == ParticleType.nitrate ||
            type == ParticleType.ammonium ||
            type == ParticleType.organicNitrogen;
      } else if (s == 'NH4' || s == 'NH4+' || s == 'NH₄⁺' || s == 'AMMONIUM') {
        return type == ParticleType.ammonium;
      } else if (s == 'NO3' || s == 'NO3-' || s == 'NO₃⁻' || s == 'NITRATE') {
        return type == ParticleType.nitrate;
      } else if (s == 'C' || s == 'CARBON') {
        return type == ParticleType.carbon ||
            type == ParticleType.labileCarbon ||
            type == ParticleType.stableCarbon;
      } else if (s == 'H' || s == 'HYDROGEN') {
        return type == ParticleType.water;
      } else if (s == 'O' || s == 'OXYGEN') {
        return type == ParticleType.water ||
            type == ParticleType.nitrate ||
            type == ParticleType.phosphorus ||
            type == ParticleType.organicPhosphorus;
      } else if (s == 'P' || s == 'PHOSPHORUS' || s == 'PO4') {
        return type == ParticleType.phosphorus ||
            type == ParticleType.organicPhosphorus;
      }
    }
    return false;
  }

  double _calculateBaseOpacity(bool isImmobilized, double life, bool inXylem, bool flowMode) {
    double baseOpacity =
        (isImmobilized ? 0.35 : 0.55) * (life > 0 ? life : 1.0).clamp(0.0, 1.0);
    if (inXylem) baseOpacity = 1.0; // Fully opaque when traveling up the plant stem

    // BOOST: Flow Mode increases overall particle presence
    if (flowMode) {
      baseOpacity = math.min(1.0, baseOpacity * 1.5);
    }
    return baseOpacity;
  }

  void _drawHighlight(
      Canvas canvas,
      Offset pos,
      ObservationCycle activeCycle,
      String? highlightedSymbol,
      bool isPinned,
      bool isHovered,
      bool isElementHighlighted) {
    String symbol = 'N';
    if (activeCycle == ObservationCycle.carbon) {
      symbol = 'C';
    } else if (activeCycle == ObservationCycle.water) {
      symbol = 'H';
    } else if (activeCycle == ObservationCycle.phosphorus) {
      symbol = 'P';
    } else if (highlightedSymbol != null) {
      symbol = highlightedSymbol;
    }

    final highlightColor = isElementHighlighted
        ? (CPKStandards.getColor(symbol).withValues(alpha: 0.8))
        : (isPinned ? Colors.white : Colors.white70);

    final double pulse = isElementHighlighted
        ? (0.8 + 0.4 * math.sin(game.currentTime() * 8))
        : 1.0;

    // Constrain highlight size to prevent massive blobs at low zoom
    final double baseHighlightRadius = isElementHighlighted ? 10.0 : 8.0;
    final double scaledRadius =
        (baseHighlightRadius / renderZoom).clamp(baseHighlightRadius, 25.0);

    canvas.drawCircle(
      pos,
      scaledRadius * pulse,
      Paint()
        ..color = highlightColor.withValues(alpha: 0.3 * pulse)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (isElementHighlighted ? 2.0 : 1.2) / renderZoom,
    );
  }

  void _drawSimplifiedParticle(Canvas canvas, Offset pos, int pTypeIdx,
      bool isImmobilized, double baseOpacity) {
    final Paint basePaint =
        _getSimplifiedPaint(pTypeIdx, isImmobilized, baseOpacity);
    // Add contrast ring for dark molecules (N, C) at low zoom to ensure visibility
    final isDark = pTypeIdx == ParticleType.carbon.index ||
        pTypeIdx == ParticleType.nitrate.index ||
        pTypeIdx == ParticleType.ammonium.index;

    if (isDark) {
      canvas.drawCircle(
          pos,
          (isImmobilized ? 4.5 : 4.0),
          Paint()..color = Colors.white.withValues(alpha: 0.15));
    }
    canvas.drawCircle(
      pos,
      isImmobilized ? 3.5 : 3.0,
      basePaint,
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final state = game.simulationState;
    if (state == null) return;

    final bool isPaused = !state.isRunning;

    if (_particleData.isEmpty) return;
    final activeCycle = game.ref.read(activeCycleProvider);
    final visibleRect = game.camera.visibleWorldRect.inflate(50.0);
    final flowMode = game.ref.read(particleFlowModeProvider);
    final session = game.ref.read(simulationSessionProvider);
    final highlightedSymbol = session.selectedElementSymbol;

    canvas.save();
    try {
      for (int i = 0; i < _particleData.length; i += 10) {
        final pId = _particleData[i].toInt();
        final px = _particleData[i + 1];
        final py = _particleData[i + 2];

        if (px < visibleRect.left ||
            px > visibleRect.right ||
            py < visibleRect.top ||
            py > visibleRect.bottom) {
          continue; // Cull rendering
        }

        final pvx = _particleData[i + 3];
        final pvy = _particleData[i + 4];
        final pTypeIdx = _particleData[i + 5].toInt();
        final pState = _particleData[i + 6];

        final isImmobilized = pState < 0;
        double stateValue = pState.abs();

        bool inXylem = stateValue >= 100.0;
        double life = stateValue % 1.0;
        double morphProgress = (stateValue / 10.0).floorToDouble() / 10.0;
        if (inXylem) {
          morphProgress = 0.0;
        }

        if (stateValue == 0) continue;
        if (life == 0 && stateValue < 1.0) continue;

        final pos = Offset(px, py);
        double baseOpacity = _calculateBaseOpacity(isImmobilized, life, inXylem, flowMode);

        final isPinned = pId == _pinnedParticleId;
        final isHovered = pId == _hoveredParticleId;

        final type = ParticleType.values[pTypeIdx];

        // Cycle Membership Check
        bool isPartOfActiveCycle = _isPartOfActiveCycle(type, activeCycle);

        if (activeCycle != ObservationCycle.none && !isPartOfActiveCycle) {
          baseOpacity *= 0.15; // High-contrast dimming
        }

        // Element Highlighting Logic (for manual selection or specific cycle focus)
        bool isElementHighlighted = _isElementHighlighted(
            type, activeCycle, isPartOfActiveCycle, highlightedSymbol);

        if (isPinned || isHovered || isElementHighlighted) {
          _drawHighlight(canvas, pos, activeCycle, highlightedSymbol, isPinned,
              isHovered, isElementHighlighted);
        }

        // LOD Optimization: Draw simple dots at very low zoom
        if (renderZoom < 0.6 && !isPaused && !isPinned && !isHovered) {
          _drawSimplifiedParticle(
              canvas, pos, pTypeIdx, isImmobilized, baseOpacity);
          continue;
        }

        if (pTypeIdx == ParticleType.ammonium.index) {
          _drawAmmonium(
            canvas,
            pos,
            px + py,
            opacity: baseOpacity,
            isLocked: isImmobilized,
            morphProgress: morphProgress,
            isPaused: isPaused,
            zoom: renderZoom,
          );
        } else if (pTypeIdx == ParticleType.nitrate.index) {
          _drawNitrate(
            canvas,
            pos,
            px - py,
            opacity: baseOpacity,
            isLocked: isImmobilized,
            isPaused: isPaused,
            zoom: renderZoom,
          );
        } else if (pTypeIdx == ParticleType.labileCarbon.index ||
            pTypeIdx == ParticleType.carbon.index) {
          _drawLabileCarbon(canvas, pos, px + py,
              opacity: baseOpacity, zoom: renderZoom);
        } else if (pTypeIdx == ParticleType.stableCarbon.index) {
          canvas.drawCircle(
            pos,
            3.2,
            _stableCarbonPaint
              ..color =
                  _stableCarbonPaint.color.withValues(alpha: baseOpacity * 0.7),
          );
        } else if (pTypeIdx == ParticleType.water.index) {
          _drawWater(canvas, pos, px - py, opacity: baseOpacity, zoom: renderZoom);
        } else if (pTypeIdx == ParticleType.organicNitrogen.index) {
          _drawOrganicNitrogen(canvas, pos, px + py,
              opacity: baseOpacity, zoom: renderZoom);
        } else if (pTypeIdx == ParticleType.phosphorus.index) {
          _drawPhosphorus(
            canvas,
            pos,
            opacity: baseOpacity,
            isLocked: isImmobilized,
            zoom: renderZoom,
          );
        } else if (pTypeIdx == ParticleType.organicPhosphorus.index) {
          canvas.drawCircle(
            pos,
            2.5,
            _pPaint..color = _pPaint.color.withValues(alpha: baseOpacity),
          );
          canvas.drawCircle(
            pos + const Offset(2, 2),
            1.8,
            _cPaint..color = _cPaint.color.withValues(alpha: baseOpacity * 0.7),
          );
        }

        // Draw movement trails for non-immobilized particles
        if (!isImmobilized && !isPaused && renderZoom > 1.2) {
          _drawParticleTrail(canvas, px, py, pvx, pvy, pTypeIdx, renderZoom);
        }
      }
    } catch (e) {
      // Robustness
    }
    canvas.restore();
  }"""

    import re
    # We replace the entire @override void render(...) block with new_methods
    # We find the bounds using regular expressions

    start_str = "  @override\n  void render(Canvas canvas) {"
    end_str = "  @override\n  void onPointerMove(PointerMoveEvent event) {"

    start_idx = content.find(start_str)
    end_idx = content.find(end_str)

    if start_idx != -1 and end_idx != -1:
        new_content = content[:start_idx] + new_methods + "\n\n" + content[end_idx:]
        with open('lib/presentation/widgets/game/components/particle_system_component.dart', 'w') as f:
            f.write(new_content)
        print("Success")
    else:
        print("Failed to find bounds")

process_file()
