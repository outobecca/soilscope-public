import 'dart:math' as math;
import 'package:oxygen/oxygen.dart';
import '../../core/biophysics_utils.dart';
import '../../core/simulation_constants.dart';

enum ParticleType {
  ammonium,
  nitrate,
  labileCarbon,
  water,
  stableCarbon,
  organicNitrogen,
  carbon,
  phosphorus,
  organicPhosphorus,
}

class ParticleSnapshot {
  final int id;
  final double x;
  final double y;
  final double vx;
  final double vy;
  final int type;
  final double state;

  const ParticleSnapshot(
    this.id,
    this.x,
    this.y,
    this.vx,
    this.vy,
    this.type,
    this.state,
  );
}

/// A simple, lightweight representation of a molecule for high-performance isolate calculations.
class Particle {
  final int id;
  ParticleType type; // Changed to non-final to allow transformation
  double x;
  double y;
  double vx;
  double vy;
  double life; // 0.0 to 1.0
  final int seed;
  bool isImmobilized;
  double state; // Used for morphing and visual cues (0.0 to 1.0)
  
  // Bezier trajectory parameters (used when state >= 10.0)
  double x0 = 0;
  double y0 = 0;
  double t = 0;

  Particle({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    this.vx = 0,
    this.vy = 0,
    this.life = 1.0,
    this.seed = 0,
    this.isImmobilized = false,
    this.state = 0.0,
  });

  List<double> toData() => [
    id.toDouble(),
    type.index.toDouble(),
    x,
    y,
    vx,
    vy,
    life,
    seed.toDouble(),
    isImmobilized ? 1.0 : 0.0,
    state,
    x0,
    y0,
    t,
  ];

  static Particle fromData(List<double> data) {
    final p = Particle(
      id: data[0].toInt(),
      type: ParticleType.values[data[1].toInt()],
      x: data[2],
      y: data[3],
      vx: data[4],
      vy: data[5],
      life: data[6],
      seed: data[7].toInt(),
      isImmobilized: data[8] > 0.5,
      state: data.length > 9 ? data[9] : 0.0,
    );
    if (data.length > 12) {
      p.x0 = data[10];
      p.y0 = data[11];
      p.t = data[12];
    }
    return p;
  }
}


class ParticleDataComponent extends Component<Particle> {
  late Particle data;

  @override
  void init([Particle? data]) {
    if (data != null) {
      this.data = data;
    }
  }

  @override
  void reset() {
    // No-op
  }
}

class ParticleEcsSystem extends System {
  late Query _query;
  
  @override
  void init() {
    _query = createQuery([Has<ParticleDataComponent>()]);
  }

  @override
  void execute(double delta) {
    final context = world!.retrieve<Map<String, dynamic>>('context')!;
    final double dt = context['dt'];
    final double minX = context['minX'];
    final double maxX = context['maxX'];
    final double worldHeight = context['worldHeight'];
    final double surfaceY = context['surfaceY'];
    final double temperatureK = context['temperatureK'];
    final List<({double x, double y, int type})> hotspots = context['hotspots'];
    final double friction = context['friction'];
    final bool isAnaerobic = context['isAnaerobic'];
    final double waterFlux = context['waterFlux'];
    final double cnRatio = context['cnRatio'] ?? 10.0;
    final List<double>? visibleRect = context['visibleRect'];

    final random = math.Random();

    final double q10Factor = BiophysicsUtils.q10Factor(temperatureK);

    final center = (minX + maxX) / 2;
    final List<({double x, double y, double q})> attractors = [
      (x: center - 400, y: surfaceY + 150, q: -1.0),
      (x: center + 350, y: surfaceY + 250, q: -1.0),
      (x: center, y: surfaceY + 400, q: -1.5),
      (x: center - 600, y: surfaceY + 500, q: -1.0),
      (x: center + 700, y: surfaceY + 650, q: -2.0),
    ];

    for (final entity in _query.entities) {
      final p = entity.get<ParticleDataComponent>()!.data;

      if (visibleRect != null && visibleRect.length == 4) {
        final left = visibleRect[0];
        final top = visibleRect[1];
        final right = visibleRect[2];
        final bottom = visibleRect[3];
        if (p.x < left || p.x > right || p.y < top || p.y > bottom) {
          continue; // Cull off screen
        }
      }

      if (cnRatio > 25.0 && (p.type == ParticleType.ammonium || p.type == ParticleType.nitrate)) {
        p.isImmobilized = true;
      }

      final damp = (p.isImmobilized ? 0.05 : 1.0) / (friction > 0 ? friction : 1.0);

      p.x += p.vx * dt * damp;
      p.y += p.vy * dt * damp;

      double typeJitter = 1.0;
      final bool isLabileC = p.type == ParticleType.labileCarbon || p.type == ParticleType.carbon;
      final bool isStableC = p.type == ParticleType.stableCarbon;

      if (isLabileC) {
        typeJitter = 2.8 * p.life; // Increased from 2.2
      } else if (isStableC) {
        typeJitter = 0.45; // Increased from 0.35
      }

      final jitterStrength = 15.0 * q10Factor * typeJitter; // Reduced from 22.0
      final bx = (random.nextDouble() * 2 - 1) * jitterStrength * (p.isImmobilized ? 0.2 : 1.0);
      final by = (random.nextDouble() * 2 - 1) * jitterStrength * (p.isImmobilized ? 0.2 : 1.0);
      p.x += bx * dt;
      p.y += by * dt;

      if (p.type == ParticleType.ammonium && p.state > 0 && p.state < 1.0) {
        p.state += dt * 0.8; // Faster morphing (from 0.5)
        if (p.state >= 1.0) {
          p.type = ParticleType.nitrate;
          p.state = 0.0;
          // Nitrification burst
          p.vx += (random.nextDouble() - 0.5) * 20.0; // Reduced from 40
          p.vy -= 5.0; // Reduced from 10
        }
      }

      if (isAnaerobic && p.type == ParticleType.nitrate) {
        if (random.nextDouble() < 0.015) { 
          p.vy -= 20.0 * dt; // Reduced from 40.0
          p.life -= 0.1 * dt; // Reduced from 0.15
        }
      }

      // Organism Chemotaxis (Hotspot Interaction via Cost-Benefit)
      ({double x, double y, int type})? bestHotspot;
      double maxAccessibility = -1.0;

      for (final h in hotspots) {
        final dx = h.x - p.x;
        final dy = h.y - p.y;
        final dist = math.sqrt(dx * dx + dy * dy).clamp(1.0, 1000.0);
        
        double bioValue = 0.0;
        
        if (h.type == 1 && (p.type == ParticleType.labileCarbon || p.type == ParticleType.carbon)) {
          // Microbes seeking Carbon based on C/N mass growth potential
          const cnTarget = SimulationConstants.microbialCnTarget;
          bioValue = 35.0 / (1.0 + (cnRatio - cnTarget).abs() * 0.5); // Reduced from 45
        } else if (h.type == 2 && (p.type == ParticleType.nitrate || p.type == ParticleType.ammonium)) {
          bioValue = 300.0; // Reduced from 500
        } else if (h.type == 2 && (p.type == ParticleType.phosphorus || p.type == ParticleType.water)) {
          // Roots seeking Nutrients & Water - Restore as absolute centers of physiological gravity
          bioValue = 50.0; // Reduced from 75.0
        } else if (h.type == 3 && p.type == ParticleType.labileCarbon) {
          // Fungi seeking Plant Sugars (Labile C)
          bioValue = 30.0; // Reduced from 50.0
        }

        if (bioValue > 0) {
          final energyCost = dist * 0.35; // Increased cost from 0.25 to reduce attraction range
          // Condition: Energia < Energiapotentiaali
          if (energyCost < bioValue) {
            final accessibility = bioValue / (dist + 15.0); // Increased smoothing from 10.0
            if (accessibility > maxAccessibility) {
              maxAccessibility = accessibility;
              bestHotspot = h;
            }
          }
        }
      }

      if (bestHotspot != null) {
        final dx = bestHotspot.x - p.x;
        final dy = bestHotspot.y - p.y;
        final dist = math.sqrt(dx * dx + dy * dy).clamp(1.0, 1000.0);
        
        if (bestHotspot.type == 2 && (p.type == ParticleType.nitrate || p.type == ParticleType.ammonium)) {
           // Special pathfinding: Beeline to the root
           final targetVx = (dx / dist) * 80.0; // Reduced from 120
           final targetVy = (dy / dist) * 80.0; // Reduced from 120
           p.vx += (targetVx - p.vx) * 3.0 * dt; // Smoother lerp from 5.0
           p.vy += (targetVy - p.vy) * 3.0 * dt;
        } else {
           final diffCoeff = (0.5 + waterFlux * 2.0).clamp(0.1, 5.0); // Reduced from 0.6 / 3.0 / 8.0
           final force = (maxAccessibility * diffCoeff * 15.0) / dist; // Reduced from 20.0
           p.vx += (dx / dist) * force * dt;
           p.vy += (dy / dist) * force * dt;
        }

        // Interaction effects (Mining/Consumption)
        if (dist < 30.0) { // Reduced interaction radius from 35.0
          if (bestHotspot.type == 1) {
            if (!isAnaerobic && p.type == ParticleType.ammonium && p.state == 0.0 && random.nextDouble() < 0.05) { // Reduced from 0.08
              p.state = 0.01;
              p.vx += (random.nextDouble() - 0.5) * 10; // Reduced from 20
            }
            if (isLabileC) {
              p.life -= 0.12 * q10Factor * dt; // Reduced from 0.18
            }
          }
          if (bestHotspot.type == 2) {
            if (p.type == ParticleType.nitrate || p.type == ParticleType.ammonium || p.type == ParticleType.phosphorus) {
              if (p.type == ParticleType.nitrate || p.type == ParticleType.ammonium) {
                 if (p.state < 10) {
                    p.state = 10.0; // Marker for "inside root"
                    p.x0 = p.x;
                    p.y0 = p.y;
                    p.t = 0.0;
                 }
              } else {
                 p.life -= 0.4 * dt; // Reduced from 0.5
              }
            }
          }
          if (bestHotspot.type == 3) {
            if (isStableC) {
              // Michaelis-Menten enzymatic mining (Aerobic)
              double vMax = 0.3; // Reduced from 0.4
              if (isAnaerobic) vMax *= 0.2; 
              const double kM = 0.5;
              final double mmRate = vMax / (kM + 1.0);
              if (random.nextDouble() < mmRate * q10Factor * dt * 8.0) { // Reduced from 12.0
                p.type = ParticleType.labileCarbon;
                p.isImmobilized = false;
                p.life = 1.0;
                p.vx += (random.nextDouble() - 0.5) * 15; // Reduced from 30
              }
            }
            if (p.type == ParticleType.organicNitrogen) {
              double vMax = 0.4; // Reduced from 0.5
              if (isAnaerobic) vMax *= 0.3;
              const double kM = 0.6;
              final double mmRate = vMax / (kM + 1.0);
              if (random.nextDouble() < mmRate * q10Factor * dt * 8.0) { // Reduced from 12.0
                p.type = ParticleType.ammonium;
                p.life = 1.0;
                p.vx += (random.nextDouble() - 0.5) * 12; // Reduced from 25
              }
            }
            if (p.type == ParticleType.organicPhosphorus) {
              double vMax = 0.5; // Reduced from 0.7
              if (isAnaerobic) vMax *= 0.4;
              const double kM = 0.4;
              final double mmRate = vMax / (kM + 1.0);
              if (random.nextDouble() < mmRate * q10Factor * dt * 10.0) { // Reduced from 15.0
                p.type = ParticleType.phosphorus;
                p.life = 1.0;
              }
            }
          }
          if (bestHotspot.type == 1) {
            if (p.type == ParticleType.organicNitrogen) {
              double vMax = 0.35; // Reduced from 0.45
              if (isAnaerobic) vMax *= 0.3;
              const double kM = 0.5;
              final double mmRate = vMax / (kM + 1.0);
              if (random.nextDouble() < mmRate * q10Factor * dt * 8.0) { // Reduced from 10.0
                p.type = ParticleType.ammonium;
                p.life = 1.0;
              }
            }
          }
        }
      }

      if (p.state >= 10.0 && (p.type == ParticleType.nitrate || p.type == ParticleType.ammonium)) {
        // Quadratic Bezier Suction: P(t) = (1-t)²P0 + 2(1-t)tP1 + t²P2
        // P0 = Entry point (x0, y0)
        // P2 = Vertical destination point (x0, y0 - 150)
        // P1 = Control point biased towards surface (x0, y0 - 50)
        
        p.t += dt * 0.8; // Reduced Suction speed from 1.2
        if (p.t > 1.0) p.t = 1.0;

        final double t = p.t;
        final double invT = 1.0 - t;
        
        // Destination is straight up, but with some organic variance
        final double destX = p.x0 + math.sin(p.seed.toDouble() + t * 5) * 8.0; // Reduced variance
        final double destY = p.y0 - 180.0; // Reduced height from 200
        
        // Control point
        final double cpX = p.x0;
        final double cpY = p.y0 - 40.0; // Reduced from 50

        p.x = invT * invT * p.x0 + 2 * invT * t * cpX + t * t * destX;
        p.y = invT * invT * p.y0 + 2 * invT * t * cpY + t * t * destY;

        p.isImmobilized = false;
        
        // If we reached the end of the suction curve, either die or continue linear rise
        if (p.t >= 1.0) {
           p.life -= 1.5 * dt; // Reduced from 2.0
        }
      }

      if (!p.isImmobilized) {
        double q1 = 0.0;
        if (p.type == ParticleType.ammonium) q1 = 1.0;
        if (p.type == ParticleType.nitrate) q1 = -1.0;

        if (q1 != 0) {
          for (final a in attractors) {
            final dx = a.x - p.x;
            final dy = a.y - p.y;
            final r2 = (dx * dx + dy * dy).clamp(100.0, 100000.0);
            final force = SimulationConstants.attractorForceScale * (q1 * a.q) / r2;
            final r = math.sqrt(r2);
            p.vx += (dx / r) * force * dt;
            p.vy += (dy / r) * force * dt;

            if (force < -5.0 && r < 15.0 && p.type == ParticleType.ammonium && random.nextDouble() < 0.08) { // Reduced from 20.0 / 0.1
              p.isImmobilized = true;
              p.vx *= 0.1;
              p.vy *= 0.1;
            }
          }
        }

        if (p.type == ParticleType.ammonium) {
          p.vy += 1.8 * dt; // Reduced from 2.5
        } else if (p.type == ParticleType.nitrate) {
          p.vy += (4.0 + waterFlux * 60.0) * dt; // Reduced from 6.0 / 80.0
          p.vx += (random.nextDouble() - 0.5) * 10.0 * dt; // Reduced from 15.0
        } else if (p.type == ParticleType.water) {
          // Water moves with flux and gravity
          p.vy += (3.5 + waterFlux * 70.0) * dt; // Reduced from 5.0 / 100.0
          p.vx += (random.nextDouble() - 0.5) * 20.0 * dt; // Reduced from 35.0
        } else if (isLabileC) {
          p.vy += 1.2 * dt; // Reduced from 2.0
        } else if (isStableC) {
          p.vy += 0.2 * dt; // Reduced from 0.3
        }
      } else {
        if (random.nextDouble() < 0.006) { // Reduced from 0.008
          p.isImmobilized = false;
        }
      }

      p.life -= 0.06 * dt; // Reduced from 0.08 (calmer lifecycle)

      if (p.x < minX + 6.0) {
        p.x = minX + 6.0;
        p.vx *= -1;
      }
      if (p.x > maxX - 6.0) {
        p.x = maxX - 6.0;
        p.vx *= -1;
      }
      if (p.y < surfaceY) {
        // Atmospheric dynamics for particles that leak above ground (e.g. escaping gases)
        final windDrift = context['windDrift'] ?? 10.0;
        final noiseMagnitude = context['windNoise'] ?? 15.0;

        final noiseX = (random.nextDouble() - 0.5) * noiseMagnitude;
        final noiseY = (random.nextDouble() - 0.5) * noiseMagnitude;

        p.vx += (windDrift + noiseX) * dt;
        p.vy += noiseY * dt;

        // Frame-rate independent velocity drag (damping) toward a floaty terminal velocity
        final dragFactor = math.exp(-0.8 * dt);
        p.vx *= dragFactor;
        p.vy *= dragFactor;

        // Un-targeted atmospheric particles should generally rise slightly faster to clear screen
        p.vy -= 15.0 * dt;

        // Rapidly decrease life in atmosphere to prevent accumulation in invisible space
        p.life -= 0.5 * dt;
      } else {
         if (p.y < surfaceY + 4.0) {
           p.y = surfaceY + 4.0;
           p.vy *= -1;
         }
      }

      if (p.y > worldHeight - 6.0) {
        p.y = worldHeight - 6.0;
        p.vy = 0;
      }
    }
  }
}

class ParticlePhysicsSolver {
  static void updateParticles(
    List<Particle> particles,
    double dt,
    double time,
    double minX,
    double maxX,
    double worldHeight,
    double surfaceY, {
    double temperatureK = 293.15,
    List<({double x, double y, int type})> hotspots = const [],
    double friction = 1.0,
    bool isAnaerobic = false,
    double waterFlux = 0.0,
    double cnRatio = 10.0,
    List<double>? visibleRect,
    double windDrift = 10.0,
    double windNoise = 15.0,
  }) {
    final world = World();
    world.registerComponent<ParticleDataComponent, Particle>(() => ParticleDataComponent());
    world.registerSystem(ParticleEcsSystem());
    world.init();

    world.store('context', {
      'dt': dt,
      'time': time,
      'minX': minX,
      'maxX': maxX,
      'worldHeight': worldHeight,
      'surfaceY': surfaceY,
      'temperatureK': temperatureK,
      'hotspots': hotspots,
      'friction': friction,
      'isAnaerobic': isAnaerobic,
      'waterFlux': waterFlux,
      'cnRatio': cnRatio,
      'visibleRect': visibleRect,
      'windDrift': windDrift,
      'windNoise': windNoise,
    });

    for (final p in particles) {
      world.createEntity().add<ParticleDataComponent, Particle>(p);
    }

    world.execute(dt);
  }
}

