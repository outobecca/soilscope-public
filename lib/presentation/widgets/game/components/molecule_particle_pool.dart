import 'package:flame/components.dart';
import 'molecule_particle_component.dart';
import 'molecule_renderer.dart';

/// A performance-optimized pool for MoleculeParticleComponents.
/// Prevents GC pressure and over-exposure by limiting the absolute maximum particle count.
class MoleculeParticlePool extends Component {
  final int maxParticles;
  final List<MoleculeParticleComponent> _pool = [];
  final List<MoleculeParticleComponent> _active = [];

  MoleculeParticlePool({this.maxParticles = 120});

  @override
  Future<void> onLoad() async {
    for (int i = 0; i < maxParticles; i++) {
      final p = MoleculeParticleComponent(
        position: Vector2.zero(),
        type: MoleculeType.co2,
      );
      // We don't add them yet, they will be added when spawned
      _pool.add(p);
    }
  }

  /// Spawns or reuses a particle from the pool.
  MoleculeParticleComponent? spawn({
    required Vector2 position,
    required MoleculeType type,
    MoleculeType? transformTarget,
    Vector2? targetPosition,
    List<Vector2>? path,
    int? seed,
    Vector2? velocity,
    double? lifeTime,
    double? opacity,
    bool? isInteractionEnabled,
  }) {
    if (_pool.isEmpty) return null;

    final p = _pool.removeLast();
    p.reset(
      position: position,
      type: type,
      transformTarget: transformTarget,
      targetPosition: targetPosition,
      path: path,
      seed: seed,
      velocity: velocity,
      lifeTime: lifeTime,
      opacity: opacity,
      isInteractionEnabled: isInteractionEnabled,
    );
    
    _active.add(p);
    add(p);
    return p;
  }

  int get activeCount => _active.length;

  @override
  void update(double dt) {
    super.update(dt);
    
    // Check for removed components to return them to the pool
    _active.removeWhere((p) {
      if (!p.isMounted && !p.isRemoving) {
        _pool.add(p);
        return true;
      }
      return false;
    });
  }
}
