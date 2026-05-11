import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide PointerMoveEvent;
import '../soil_scope_game.dart';
import '../../../providers/ui_state_provider.dart';
import 'scene_coordinate_mapper.dart';
import 'animated_microbe_component.dart';
import 'expandable_hotspot_node.dart';
import 'soil_layer_component.dart';
import 'biological_entities_component.dart';
import '../../../../core/cpk_standards.dart';
import '../../../../domain/models/biophysical_state.dart';
import 'cycle_highlight_mixin.dart';

/// The consolidated "Single Source of Truth" for the Nutrient and Symbiosis Network.
/// Visualizes the "Wood Wide Web" and nutrient routing between plants, microbes, and hotspots.
class SoilSymbiosisNetworkComponent extends PositionComponent
    with
        HasGameReference<SoilScopeGame>,
        TapCallbacks,
        HoverCallbacks,
        CycleHighlightMixin {
  @override
  Set<ObservationCycle> get memberOfCycles => {
    ObservationCycle.nitrogen,
    ObservationCycle.phosphorus,
    ObservationCycle.carbon,
  };

  final Paint _glowPaint = Paint();
  final Paint _threadPaint = Paint()..style = PaintingStyle.stroke;
  final Paint _shadowPaint = Paint();
  final Paint _bodyPaint = Paint();
  final Paint _corePaint = Paint();
  final Paint _specularPaint = Paint();
  final Paint _pulseGlowPaint = Paint();

  SoilSymbiosisNetworkComponent() : super(priority: 2000);

  @override
  bool containsLocalPoint(Vector2 point) {
    // SURGICAL HIT-TESTING (Task 4/6):
    // Only capture taps near nodes or edges to prevent blocking empty space.
    final double threshold = 15.0;
    
    // Check nodes (approximate world to local if needed, but here they are world-space offsets)
    // Actually, in this component, we render using absolute world coordinates, 
    // but PositionComponent's containsLocalPoint receives local coordinates.
    // If this component is at (0,0), then local == world.
    
    for (final edge in _edges) {
      // Check proximity to endpoints
      if ((point.toOffset() - edge.a.pos).distance < threshold) return true;
      if ((point.toOffset() - edge.b.pos).distance < threshold) return true;
      
      // Check proximity to the line segment (simplified as straight line for hit-testing)
      final d = _distanceToLineSegment(point.toOffset(), edge.a.pos, edge.b.pos);
      if (d < threshold) return true;
    }
    
    return false;
  }

  double _distanceToLineSegment(Offset p, Offset a, Offset b) {
    final l2 = (a - b).distanceSquared;
    if (l2 == 0.0) return (p - a).distance;
    final t = (((p.dx - a.dx) * (b.dx - a.dx) + (p.dy - a.dy) * (b.dy - a.dy)) / l2).clamp(0.0, 1.0);
    final projection = a + (b - a) * t;
    return (p - projection).distance;
  }

  bool _isPinned = false;
  final List<NetworkEdge> _edges = [];
  double _lastGraphUpdate = 0;

  @override
  void render(Canvas canvas) {
    final activeCycle = game.ref.read(activeCycleProvider);
    final flowMode = game.ref.read(particleFlowModeProvider);
    
    // VISIBILITY LOGIC:
    // Show if a cycle is active, OR if the explicit "Flow Mode" is toggled on.
    double baseOpacity = (activeCycle == ObservationCycle.none) ? 0.0 : cycleOpacity;
    if (flowMode) baseOpacity = math.max(baseOpacity, 0.7);
    
    if (baseOpacity < 0.05) return;

    final double zoom = game.camera.viewfinder.zoom;
    final state = game.simulationState;
    if (state == null) return;

    final time = game.currentTime();

    // 1. Organic Graph Maintenance (Single Source)
    if (time - _lastGraphUpdate > 1.2) {
      _rebuildSymbioticGraph(state);
      _lastGraphUpdate = time;
    }

    final currentOpacity = baseOpacity;

    // 2. High-Fidelity Rendering
    for (final edge in _edges) {
      _drawSymbioticEdge(canvas, edge, time, zoom, currentOpacity);
    }
    
    // 3. Node Highlights (Glowing Hubs)
    if (currentOpacity > 0.1) {
      _drawNodeGlows(canvas, time, zoom, currentOpacity);
    }
  }

  void _drawNodeGlows(Canvas canvas, double time, double zoom, double opacity) {
    final nodes = <NetNode>{};
    for (final edge in _edges) {
      nodes.add(edge.a);
      nodes.add(edge.b);
    }

    final paint = _glowPaint..maskFilter = MaskFilter.blur(BlurStyle.normal, 3.0 / zoom);
    for (final node in nodes) {
      final pulse = 0.8 + 0.2 * math.sin(time * 3.0 + node.pos.dx);
      final color = node.type == 'root_tip' ? Colors.white : const Color(0xFF2DD4BF);
      
      canvas.drawCircle(
        node.pos, 
        (node.type == 'root_tip' ? 8.0 : 4.0) * pulse / zoom, 
        paint..color = color.withValues(alpha: 0.2 * opacity)
      );
    }
  }

  void _rebuildSymbioticGraph(BiophysicalState state) {
    _edges.clear();
    final rootNodes = <NetNode>[];
    final otherNodes = <NetNode>[];
    
    final surfaceY = game.soilSurfaceY;
    final soilHeight = game.soilColumnHeight;
    final worldWidth = SoilScopeGame.soilColumnWidth;
    final soilX = game.soilLeftX;

    // 1. Root Tips (Origin Hubs)
    for (final plant in state.plants) {
      for (final tip in plant.rootSystem.where((n) => n.isTip)) {
        final rawY = SceneCoordinateMapper.mapRootY(tip.z, surfaceY, soilHeight);
        final pos = Offset(
          SceneCoordinateMapper.mapRootX(tip.x, worldWidth, baseX: plant.baseX) + soilX,
          rawY.clamp(surfaceY + 10.0, surfaceY + soilHeight - 10.0).toDouble(),
        );
        rootNodes.add(NetNode(pos, 'root_tip', metadata: {'plantId': plant.id}));
      }
    }

    // 2. Target Nodes (Hotspots and Microbes)
    final hotspots = game.world.children
        .whereType<SoilLayerComponent>()
        .expand((l) => l.children.whereType<ExpandableHotspotNode>());
    for (final h in hotspots) {
      otherNodes.add(NetNode(h.absolutePosition.toOffset(), 'hotspot', metadata: {'layerId': h.layerId}));
    }

    final biologicalEntities = parent?.children.whereType<BiologicalEntitiesComponent>().firstOrNull;
    final microbes = biologicalEntities?.children.whereType<AnimatedMicrobeComponent>() ?? const [];
    for (final m in microbes) {
      otherNodes.add(NetNode(m.absolutePosition.toOffset(), 'microbe'));
    }

    if (rootNodes.isEmpty || otherNodes.isEmpty) return;

    // RHIZOSPHERE CENTRIC EXPANSION:
    // Build the network by connecting root tips to their nearest neighbors, 
    // and then those neighbors to further targets.
    
    final connectedNodes = <NetNode>{...rootNodes};
    final frontier = <NetNode>[...rootNodes];
    final remainingTargets = <NetNode>[...otherNodes];

    // Limit search depth to keep focus on rhizosphere
    int depth = 0;
    while (frontier.isNotEmpty && depth < 2) {
      final nextFrontier = <NetNode>[];
      
      for (final u in frontier) {
        // Find N nearest remaining targets
        remainingTargets.sort((a, b) => (u.pos - a.pos).distanceSquared.compareTo((u.pos - b.pos).distanceSquared));
        
        final maxConnections = (u.type == 'root_tip') ? 2 : 1;
        final potentialTargets = remainingTargets.take(maxConnections).toList();
        
        for (final v in potentialTargets) {
          final dist = (u.pos - v.pos).distance;
          if (dist > 300) continue; // Range limit

          _edges.add(NetworkEdge(u, v));
          nextFrontier.add(v);
          connectedNodes.add(v);
        }
        
        // Remove connected from remaining
        remainingTargets.removeWhere((n) => nextFrontier.contains(n));
      }
      
      frontier.clear();
      frontier.addAll(nextFrontier);
      depth++;
    }

    // Optional: Connect microbes to nearby hotspots if they are both "connected" to the tree
    // to show full rhizosphere integration.
  }

  void _drawSymbioticEdge(
    Canvas canvas,
    NetworkEdge edge,
    double time,
    double zoom,
    double opacity,
  ) {
    final start = edge.a.pos;
    final end = edge.b.pos;

    // Metabolic activity determines thickness and pulse
    final activity = _calculateMetabolism(edge);
    if (activity < 0.1) return;

    final seed = edge.hashCode % 100;
    final baseDrift = 25.0 * math.sin(time * 0.5 + seed);
    final mid = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
    final diff = end - start;
    if (diff.distance < 1.0) return;
    final normal = Offset(-diff.dy, diff.dx) / diff.distance;
    
    final cp = mid + (normal * baseDrift);
    
    // Use cubic for more "thread-like" look
    final c1 = Offset.lerp(start, cp, 0.5)!;
    final c2 = Offset.lerp(cp, end, 0.5)!;

    final paint = _threadPaint;
    final strokeBase = (2.5 + activity * 2.0) / zoom; // Thicker threads

    // DRAW HYPHAL BUNDLE (Multiple strands for "Better Visualized" food web)
    for (int i = 0; i < 3; i++) {
      final threadOffset = normal * (i - 1) * 3.0 / zoom;
      final jitter = 2.0 * math.sin(time * 2.0 + i + seed);
      
      final threadPath = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(
          c1.dx + threadOffset.dx + jitter, c1.dy + threadOffset.dy + jitter,
          c2.dx + threadOffset.dx - jitter, c2.dy + threadOffset.dy - jitter,
          end.dx, end.dy
        );

      // Glow for the whole bundle if i==1
      if (i == 1) {
        canvas.drawPath(
          threadPath,
          paint
            ..color = _getEdgeColor(edge).withValues(alpha: 0.1 * opacity)
            ..strokeWidth = strokeBase * 4.0
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3.0 / zoom),
        );
      }

      // Core thread
      canvas.drawPath(
        threadPath,
        paint
          ..color = (i == 1 ? const Color(0xFFF1F5F9) : const Color(0xFFCBD5E1))
              .withValues(alpha: (0.4 - i * 0.1) * opacity)
          ..strokeWidth = strokeBase * (1.0 - i * 0.2)
          ..maskFilter = null,
      );
    }

    // 3. Bidirectional Flux Particles (The actual "transfer")
    // Use a unified path for particles
    final particlePath = Path()..moveTo(start.dx, start.dy)..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
    _drawFluxPulses(canvas, particlePath, edge, time, zoom, activity, opacity);
  }

  double _calculateMetabolism(NetworkEdge edge) {
    final dist = (edge.a.pos - edge.b.pos).distance;
    double m = (1.0 - (dist / 400)).clamp(0.1, 1.0);

    // Symbiotic bonus: connections to root tips are high-activity
    if (edge.a.type == 'root_tip' || edge.b.type == 'root_tip') {
      m *= 1.5;
    }
    return m;
  }

  Color _getEdgeColor(NetworkEdge edge) {
    if (edge.a.type == 'microbe' || edge.b.type == 'microbe') {
      return const Color(0xFF2DD4BF); // Teal
    }
    if (edge.a.type == 'hotspot' || edge.b.type == 'hotspot') {
      return const Color(0xFFFBBF24); // Amber (Nutrient Transfer)
    }
    return const Color(0xFF94A3B8).withValues(alpha: 0.5); // Soft Slate for structural connections
  }

  void _drawFluxPulses(
    Canvas canvas,
    Path path,
    NetworkEdge edge,
    double time,
    double zoom,
    double activity,
    double opacity,
  ) {
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final m = metrics.first;

    final flowMode = game.ref.read(particleFlowModeProvider);
    final speed = (0.5 + activity * 0.4) * (flowMode ? 2.0 : 1.0);
    final count = (flowMode ? 4 : (2 * activity).toInt().clamp(1, 3));

    for (int i = 0; i < count; i++) {
      final t = (time * speed + (i / count)) % 1.0;

      // Routing Logic:
      // 1. Nutrients (P, N) -> Flow TOWARDS Root Tip
      // 2. Carbon (C) -> Flow AWAY from Root Tip (to Fungi/Microbes)
      final activeCycle = game.ref.read(activeCycleProvider);

      final bool isTargetingRoot = edge.b.type == 'root_tip';
      final progress = isTargetingRoot ? t : (1.0 - t);

      final tangent = m.getTangentForOffset(m.length * progress);
      if (tangent != null) {
        // Color mapping based on active cycle
        Color pColor = Colors.white;
        switch (activeCycle) {
          case ObservationCycle.nitrogen: pColor = CPKStandards.colorN; break;
          case ObservationCycle.carbon: pColor = CPKStandards.colorC; break;
          case ObservationCycle.water: pColor = CPKStandards.colorO; break;
          case ObservationCycle.phosphorus: pColor = CPKStandards.colorP; break;
          default:
            pColor = isTargetingRoot ? CPKStandards.colorP : Colors.amberAccent;
        }
        
        // BOOST: Glow and size if flowMode is active
        final radius = (flowMode ? 3.5 : 2.2) / zoom;
        final glowSize = (flowMode ? 8.0 : 4.0) / zoom;

        final pos = tangent.position;

        // 1. Shadow
        canvas.drawCircle(pos + const Offset(1, 1), radius, _shadowPaint..color = Colors.black.withValues(alpha: 0.1 * opacity));
        
        // 2. Glow (Boosted by flowMode)
        canvas.drawCircle(
          pos, 
          glowSize, 
          (_pulseGlowPaint
            ..color = pColor.withValues(alpha: 0.4 * opacity)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4 / zoom))
        );

        // 3. Main Body
        canvas.drawCircle(
          pos,
          radius,
          (_bodyPaint..color = Colors.white.withValues(alpha: 0.9 * opacity)),
        );
        
        canvas.drawCircle(
          pos,
          radius * 0.7,
          _corePaint..color = pColor.withValues(alpha: 0.8 * opacity),
        );

        // 4. Specular Highlight
        canvas.drawCircle(
          pos - Offset(radius * 0.3, radius * 0.3),
          radius * 0.4,
          (_specularPaint..color = Colors.white.withValues(alpha: 0.9 * opacity)),
        );
      }
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    _isPinned = !_isPinned;
    _showInfo(pinned: _isPinned);
    event.handled = true;
  }

  @override
  void onHoverEnter() {
    _showInfo(pinned: false);
  }

  @override
  void onHoverExit() {
    if (!_isPinned) game.ref.read(uIStateProvider.notifier).setHoverInfo(null);
  }

  void _showInfo({bool pinned = false}) {
    game.ref
        .read(uIStateProvider.notifier)
        .setHoverInfo(
          HoverInfo(
            title: "SYMBIOSIS NETWORK",
            description:
                "The 'Wood Wide Web' connecting roots, mycorrhizal fungi, and nutrient hotspots. This unified architecture orchestrates the bidirectional exchange of Carbon for Phosphorus and Nitrogen.",
            stats: {
              "Integrity": "Consolidated",
              "Flux": "Active",
              "Nodes": "${_edges.length * 2}",
            },
            isPinned: pinned,
          ),
        );
  }
  /// Finds a path through the symbiotic network from [startWorld] to [endWorld].
  /// Uses simple BFS on the existing graph.
  List<Vector2>? findNetworkPath(Vector2 startWorld, Vector2 endWorld) {
    if (_edges.isEmpty) return null;

    // 1. Find nearest nodes
    NetNode? startNode;
    NetNode? endNode;
    double minStartDist = 999999;
    double minEndDist = 999999;

    final allNodes = <NetNode>{};
    for (final edge in _edges) {
      allNodes.add(edge.a);
      allNodes.add(edge.b);
    }

    for (final node in allNodes) {
      final dStart = (startWorld.toOffset() - node.pos).distanceSquared;
      if (dStart < minStartDist) {
        minStartDist = dStart;
        startNode = node;
      }
      final dEnd = (endWorld.toOffset() - node.pos).distanceSquared;
      if (dEnd < minEndDist) {
        minEndDist = dEnd;
        endNode = node;
      }
    }

    if (startNode == null || endNode == null) return null;
    if (startNode == endNode) return [endWorld];

    // 2. BFS Pathfinding
    final Map<NetNode, NetNode?> parentMap = {startNode: null};
    final List<NetNode> queue = [startNode];
    final Set<NetNode> visited = {startNode};

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      if (current == endNode) break;

      for (final edge in _edges) {
        NetNode? neighbor;
        if (edge.a == current) {
          neighbor = edge.b;
        } else if (edge.b == current) {
          neighbor = edge.a;
        }

        if (neighbor != null && !visited.contains(neighbor)) {
          visited.add(neighbor);
          parentMap[neighbor] = current;
          queue.add(neighbor);
        }
      }
    }

    if (!parentMap.containsKey(endNode)) return null;

    // 3. Reconstruct path
    final List<Vector2> path = [endWorld];
    NetNode? curr = endNode;
    while (curr != null) {
      path.insert(0, Vector2(curr.pos.dx, curr.pos.dy));
      curr = parentMap[curr];
    }
    
    // Smooth the start
    path.insert(0, startWorld);
    
    return path;
  }
}

class NetNode {
  final Offset pos;
  final String type;
  final Map<String, dynamic>? metadata;
  NetNode(this.pos, this.type, {this.metadata});
}

class NetworkEdge {
  final NetNode a;
  final NetNode b;
  NetworkEdge(this.a, this.b);
}
