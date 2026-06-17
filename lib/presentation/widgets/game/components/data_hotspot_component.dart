import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide PointerMoveEvent;
import '../soil_scope_game.dart';
import '../../../../domain/models/biophysical_state.dart';
import '../../../providers/ui_state_provider.dart';
import 'riverpod_lifecycle_mixin.dart';

enum HotspotType {
  nutrient,
  sensor,
  cec,
}

/// A diegetic (in-world) interactive data component.
/// Displays a small, pulsing icon representing a data source.
/// Tapping or hovering triggers a high-fidelity information panel in the UI.
class DataHotspotComponent extends CircleComponent
    with HasGameReference<SoilScopeGame>, TapCallbacks, HoverCallbacks, RiverpodLifecycleMixin {
  final String layerId;
  final String label;
  final Color color;
  final HotspotType type;

  bool _isPinned = false;

  // Cached painters for performance
  late final TextPainter _labelTp;

  DataHotspotComponent({
    required this.layerId,
    required this.label,
    required this.color,
    required this.type,
    required Vector2 position,
  }) : super(
          position: position,
          radius: 24.0,
          anchor: Anchor.center,
          priority: 200,
          paint: Paint()..color = Colors.transparent, // Base circle is transparent
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _labelTp = TextPainter(
      textDirection: TextDirection.ltr,
    );
  }

  @override
  void onTapUp(TapUpEvent event) {
    _isPinned = !_isPinned;
    _showHotspotInfo(pinned: _isPinned);
    event.handled = true;
  }

  @override
  void onHoverEnter() {
    final currentInfo = game.ref.read(uIStateProvider);
    if (currentInfo == null || !currentInfo.isPinned) {
      _showHotspotInfo(pinned: false);
    }
  }

  @override
  void onHoverExit() {
    if (!_isPinned) {
      game.ref.read(uIStateProvider.notifier).setHoverInfo(null);
    }
  }

  void _showHotspotInfo({bool pinned = false}) {
    final state = game.simulationState;
    if (state == null) return;
    
    final info = _getHotspotInfo(state);
    
    // Determine element symbol for CPK indicator
    String? elementSymbol;
    if (['N', 'NH4+', 'NH₄⁺', 'NO3-', 'NO₃⁻'].contains(label)) elementSymbol = 'N';
    if (label == 'P') elementSymbol = 'P';
    if (label == 'K') elementSymbol = 'K';
    if (label == 'Ca') elementSymbol = 'Ca';
    if (label == 'Mg') elementSymbol = 'Mg';

    game.ref.read(uIStateProvider.notifier).setHoverInfo(
      HoverInfo(
        title: info['title'] as String,
        description: info['description'] as String,
        stats: info['stats'] as Map<String, String>,
        isPinned: pinned,
        accentColor: color,
        elementSymbol: elementSymbol,
        screenPosition: game.worldToScreen(absolutePosition).toOffset(),
      ),
    );
  }

  Map<String, dynamic> _getHotspotInfo(BiophysicalState state) {
    final l = game.l10n;
    String value = "--";
    String unit = "";
    
    try {
      final layer = state.profile.layers.firstWhere((l) => l.id == layerId);
      switch (label) {
        case 'CEC':
          value = layer.cec.toStringAsFixed(1);
          unit = "cmol(+)/kg";
          break;
        case 'N' || 'NH4+' || 'NH₄⁺': 
          value = layer.ammoniumContent.toStringAsFixed(1);
          unit = "mg/kg (Mineral)";
          break;
        case 'NO3-' || 'NO₃⁻': 
          value = layer.nitrateContent.toStringAsFixed(1);
          unit = "mg/kg (Mineral)";
          break;
        case 'P': 
          value = layer.phosphateContent.toStringAsFixed(1);
          unit = "mg/kg (Mineral)";
          break;
        case 'K': 
          value = layer.potassiumContent.toStringAsFixed(1);
          unit = "mg/kg (Mineral)";
          break;
        case 'T': 
          value = (layer.temperature - 273.15).toStringAsFixed(1);
          unit = "° Celsius";
          break;
        case 'W': 
          value = (layer.waterContent * 100).toStringAsFixed(1);
          unit = "% Water Content";
          break;
        case 'pH': 
          value = layer.ph.toStringAsFixed(2);
          unit = "Potential Hydrogen";
          break;
        case 'O2': 
          value = layer.oxygenContent.toStringAsFixed(2);
          unit = "mol/m³ Dissolved";
          break;
        case 'POM-N': 
          value = layer.particulateOrganicMatter.toStringAsFixed(1);
          unit = "mg/kg (Particulate)";
          break;
        case 'Mic-N': 
          value = layer.microbialBiomass.toStringAsFixed(1);
          unit = "mg/kg (Microbial)";
          break;
        case 'MAOM-N': 
          value = layer.maomNitrogen.toStringAsFixed(1);
          unit = "mg/kg (Associated)";
          break;
        case 'Urease':
          value = layer.nitrificationRate.toStringAsFixed(3); // Placeholder proxy
          unit = "μmol/min/g";
          break;
        case 'Cellulase':
          value = (layer.particulateOrganicMatter * 0.05).toStringAsFixed(2);
          unit = "μmol/min/g";
          break;
        case 'Phosphatase':
          value = (layer.phosphateContent * 0.1).toStringAsFixed(2);
          unit = "μmol/min/g";
          break;
        case 'Protease':
          value = (layer.organicNitrogen * 0.08).toStringAsFixed(2);
          unit = "μmol/min/g";
          break;
      }
    } catch (_) {}

    String typeLabel = "SENSOR";
    if (type == HotspotType.nutrient) typeLabel = l.nutrient;
    if (type == HotspotType.cec) typeLabel = "CEC (Clay)";

    return {
      'title': "$typeLabel - $label",
      'description': type == HotspotType.cec 
          ? "Cation Exchange Capacity: The ability of soil to hold and release nutrients like K+, Ca2+, and Mg2+."
          : "${l.nutrient} ${type == HotspotType.nutrient ? l.nutrient.toLowerCase() : l.measurement}",
      'stats': {
        "Value": value,
        "Unit": unit,
      },
    };
  }

  @override
  void render(Canvas canvas) {
    // Note: CircleComponent.render handles its own circle if not transparent.
    // We override to draw our organic speck.
    final double zoom = game.camera.viewfinder.zoom;
    final center = Offset(radius, radius); // In local coordinates

    _renderCollapsed(canvas, center, zoom);
  }

  void triggerPulse() {
    // Quick visual feedback pulse
    add(
      ScaleEffect.to(
        Vector2.all(1.4),
        EffectController(duration: 0.15, reverseDuration: 0.2, curve: Curves.easeOut),
      ),
    );
    add(
      OpacityEffect.to(
        1.0,
        EffectController(duration: 0.1, reverseDuration: 0.4),
      ),
    );
  }

  double _getNormalizedValue(BiophysicalState state) {
    try {
      final layer = state.profile.layers.firstWhere((l) => l.id == layerId);
      switch (label) {
        case 'T': return ((layer.temperature - 273.15) / 40.0).clamp(0.0, 1.0);
        case 'W': return (layer.waterContent / (layer.porosity > 0 ? layer.porosity : 0.5)).clamp(0.0, 1.0);
        case 'pH': return ((layer.ph - 3.0) / 7.0).clamp(0.0, 1.0);
        case 'O2': return (layer.oxygenContent / 1.0).clamp(0.0, 1.0);
        case 'CEC': return (layer.cec / 50.0).clamp(0.0, 1.0);
        case 'NO3-' || 'NO₃⁻': return (layer.nitrateContent / 50.0).clamp(0.0, 1.0);
        case 'NH4+' || 'NH₄⁺': return (layer.ammoniumContent / 30.0).clamp(0.0, 1.0);
        case 'P': return (layer.phosphateContent / 20.0).clamp(0.0, 1.0);
        case 'K': return (layer.potassiumContent / 200.0).clamp(0.0, 1.0);
        case 'MAOM-N': return (layer.maomNitrogen / 100.0).clamp(0.0, 1.0);
        case 'SOM': return (layer.organicMatterContent / 0.1).clamp(0.0, 1.0);
        default: return 0.5;
      }
    } catch (_) {
      return 0.0;
    }
  }

  void _renderCollapsed(Canvas canvas, Offset center, double zoom) {
    final state = game.simulationState;
    final time = game.currentTime();
    final currentOpacity = opacity;
    
    // Slow, breathing pulse for organic feel
    final pulse = 0.95 + 0.05 * math.sin(time * 2.0);
    final drawRadius = (zoom > 1.5 ? 10.0 : 6.0) * pulse;

    if ((type == HotspotType.sensor || type == HotspotType.cec || label == 'NO3-' || label == 'NH4+' || label == 'NO₃⁻' || label == 'NH₄⁺') && state != null) {
      // 1. OLD CIRCULAR METER STYLE (Task: Restore classic meter feel for all sensors/metrics)
      final value = _getNormalizedValue(state);
      
      // Background Ring
      canvas.drawCircle(
        center, 
        drawRadius * 1.4, 
        Paint()..color = Colors.black.withValues(alpha: 0.4 * currentOpacity)
      );
      
      final meterPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 / zoom
        ..strokeCap = StrokeCap.round;

      // Inactive Arc
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: drawRadius * 1.1),
        -math.pi / 2,
        2 * math.pi,
        false,
        meterPaint..color = Colors.white.withValues(alpha: 0.1 * currentOpacity),
      );

      // Active Progress Arc
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: drawRadius * 1.1),
        -math.pi / 2,
        2 * math.pi * value,
        false,
        meterPaint..color = color.withValues(alpha: 0.8 * currentOpacity),
      );

      // Central Indicator (Small dot)
      canvas.drawCircle(
        center, 
        drawRadius * 0.3, 
        Paint()..color = Colors.white.withValues(alpha: 0.9 * currentOpacity)
      );
      
      // Label indicator (Needle)
      final needleAngle = -math.pi / 2 + 2 * math.pi * value;
      canvas.drawLine(
        center,
        center + Offset(math.cos(needleAngle) * drawRadius * 0.8, math.sin(needleAngle) * drawRadius * 0.8),
        Paint()..color = Colors.white.withValues(alpha: 1.0 * currentOpacity)..strokeWidth = 1.0 / zoom,
      );

    } else if (type == HotspotType.cec) {
      // 2. Crystal/Mineral structure for CEC
      final paint = Paint()
        ..color = color.withValues(alpha: 0.6 * pulse * currentOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 / zoom;
      
      canvas.drawCircle(center, drawRadius * 0.6, paint);
      for (int i = 0; i < 4; i++) {
        final angle = i * math.pi / 2 + time * 0.5;
        canvas.drawCircle(
          center + Offset(math.cos(angle) * drawRadius, math.sin(angle) * drawRadius), 
          drawRadius * 0.3, 
          paint
        );
      }
    } else {
      // 3. Organic "Soil Speck" - Irregular shape with contrast core
      final speckPaint = Paint()
        ..color = color.withValues(alpha: 0.5 * pulse * currentOpacity)
        ..style = PaintingStyle.fill;
      
      // Draw a tiny contrast core for visibility
      canvas.drawCircle(center, drawRadius * 0.2, Paint()..color = Colors.white.withValues(alpha: 0.4 * currentOpacity));

      for (int i = 0; i < 3; i++) {
        final off = Offset(
          math.cos(i * 2 + time * 1.2) * 4,
          math.sin(i * 2 + time * 1.2) * 4,
        );
        canvas.drawCircle(center + off, drawRadius * (0.6 - i * 0.1), speckPaint);
      }
    }

    // 1. Core Glow (Complying with max 0.15 opacity rule)
    canvas.drawCircle(
      center,
      drawRadius * 0.8,
      Paint()
        ..color = color.withValues(alpha: 0.15 * currentOpacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4 / zoom),
    );

    // 2. Solid Shaded Core (for non-sensors or as secondary indicator)
    if (type != HotspotType.sensor) {
      final coreRadius = drawRadius * 0.4;
      // Base shadow
      canvas.drawCircle(center + const Offset(1.0, 1.0), coreRadius, Paint()..color = Colors.black.withValues(alpha: 0.3 * currentOpacity));
      // Main Body
      canvas.drawCircle(center, coreRadius, Paint()..color = color.withValues(alpha: 0.9 * currentOpacity));
      // Contrast Ring
      canvas.drawCircle(center, coreRadius, Paint()..color = Colors.white.withValues(alpha: 0.4 * currentOpacity)..style = PaintingStyle.stroke..strokeWidth = 0.8);
      // Shading highlight
      canvas.drawCircle(
        center - Offset(coreRadius * 0.3, coreRadius * 0.3),
        coreRadius * 0.4,
        Paint()..color = Colors.white.withValues(alpha: 0.5 * currentOpacity),
      );
    }

    // 3. Label Text (Only visible at high zoom levels to reduce clutter)
    if (zoom > 1.8) {
      _labelTp.text = TextSpan(
        text: label,
        style: TextStyle(
          color: color.withValues(alpha: 0.8 * currentOpacity),
          fontSize: 9,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
          shadows: [Shadow(color: Colors.black.withValues(alpha: 0.5 * currentOpacity), blurRadius: 2)],
        ),
      );
      _labelTp.layout();
      _labelTp.paint(canvas, center + Offset(-_labelTp.width / 2, drawRadius + (type == HotspotType.sensor ? 8 : 4)));
    }
  }
}
