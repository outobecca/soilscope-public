import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../soil_scope_game.dart';
import 'inspection_target_component.dart';
import 'rhizosphere_hotspot_component.dart';
import 'selection_node_component.dart';

/// Routes taps that land on an inspection target above every world overlay.
///
/// Targets live inside the simulation animation layer and are drawn below the
/// technical hotspot overlay. Without this router, a target inside the soil
/// loses its tap to a soil layer, a root or a data hotspot, even though the
/// target ring is what the user is aiming at. The router is deliberately
/// narrow: its hit area is the union of the rendered targets' own hit areas,
/// and it does nothing anywhere else.
class InspectionTargetTapRouter extends Component
    with HasGameReference<SoilScopeGame>, TapCallbacks {
  InspectionTargetTapRouter() : super(priority: 2600);

  @override
  bool containsLocalPoint(Vector2 point) => _nearestTarget(point) != null;

  @override
  void onTapUp(TapUpEvent event) {
    final target = _nearestTarget(event.localPosition);
    if (target == null) return;
    target.activateFromTap();
    event.handled = true;
  }

  /// Resolves overlapping targets by world-space proximity to the pointer.
  /// All targets share one visual layer, so nearest is the least surprising
  /// winner when their generous touch radii overlap.
  InspectionTargetComponent? _nearestTarget(Vector2 worldPoint) {
    InspectionTargetComponent? nearest;
    var nearestDistance = double.infinity;

    for (final target
        in game.world.descendants().whereType<InspectionTargetComponent>()) {
      if (!target.isInteractive) continue;
      final distance = target.distanceToWorldPoint(worldPoint);
      if (distance <= target.hitRadius && distance < nearestDistance) {
        nearest = target;
        nearestDistance = distance;
      }
    }
    return nearest;
  }
}

/// Routes taps on layer icons and rhizosphere hotspots, which are drawn below
/// passive process overlays such as capillary rise.
///
/// This router sits below the technical hotspot overlay (2500) so a data
/// hotspot drawn on top still wins where the two overlap. Above that, it
/// resolves the anchors that are actually visible under the pointer, nearest
/// first.
class CanvasAnchorTapRouter extends Component
    with HasGameReference<SoilScopeGame>, TapCallbacks {
  CanvasAnchorTapRouter() : super(priority: 2400);

  @override
  bool containsLocalPoint(Vector2 point) => _nearestAnchor(point) != null;

  @override
  void onTapUp(TapUpEvent event) {
    final anchor = _nearestAnchor(event.localPosition);
    if (anchor == null) return;
    anchor.activate();
    event.handled = true;
  }

  _TapAnchor? _nearestAnchor(Vector2 worldPoint) {
    _TapAnchor? nearest;

    void consider(Vector2 center, double radius, void Function() activate) {
      final distance = (center - worldPoint).length;
      if (distance > radius) return;
      if (nearest != null && distance >= nearest!.distance) return;
      nearest = _TapAnchor(distance, activate);
    }

    for (final node
        in game.world.descendants().whereType<SelectionNodeComponent>()) {
      consider(
        node.absolutePositionOf(node.size / 2),
        node.hitRadius,
        node.activateFromTap,
      );
    }

    for (final hotspot
        in game.world.descendants().whereType<RhizosphereHotspotComponent>()) {
      consider(
        hotspot.absolutePositionOf(hotspot.size / 2),
        hotspot.hitRadius,
        hotspot.activateFromTap,
      );
    }

    return nearest;
  }
}

class _TapAnchor {
  const _TapAnchor(this.distance, this.activate);

  final double distance;
  final void Function() activate;
}
