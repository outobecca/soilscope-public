import 'package:flame/components.dart';
import '../soil_scope_game.dart';
import 'process_magnifier_component.dart';
import '../../../providers/simulation_session_provider.dart';

/// Manages a group of process magnifiers at the viewport level.
class MagnifierGroupComponent extends PositionComponent
    with HasGameReference<SoilScopeGame> {
  
  MagnifierGroupComponent() : super(
    priority: 300,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _initMagnifiers();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Overwrite the size that Flame sets to keep children positions valid
    this.size = size;
    position = Vector2.zero();
  }

  void _initMagnifiers() {
    // All magnifiers are stacked at the same viewport position (Top Center)
    add(ProcessMagnifierComponent(type: MagnifierType.leaf, position: size / 2));
    add(ProcessMagnifierComponent(type: MagnifierType.stem, position: size / 2));
    add(ProcessMagnifierComponent(type: MagnifierType.root, position: size / 2));
    add(ProcessMagnifierComponent(type: MagnifierType.rhizosphere, position: size / 2));
    add(ProcessMagnifierComponent(type: MagnifierType.microbe, position: size / 2));
    add(ProcessMagnifierComponent(type: MagnifierType.soilStructure, position: size / 2));
    add(ProcessMagnifierComponent(type: MagnifierType.apicalMeristem, position: size / 2));
  }

  @override
  void update(double dt) {
    _updateMagnifiers(dt);
  }

  /// The game freezes world updates while an inspection card is pinned. The
  /// microscope lives in the viewport and must keep fading in above it, so
  /// the game calls this explicitly during that paused phase.
  ///
  /// A parent's [update] does not recurse into its children in Flame, so this
  /// must drive the child update tree explicitly. Otherwise the microscope
  /// coordinator gets updated while each magnifier's opacity stays at zero.
  void updateForInspectionPause(double dt) {
    _updateMagnifierVisibility();
    super.update(dt);
    for (final child in children) {
      child.updateTree(dt);
    }
  }

  void _updateMagnifiers(double dt) {
    super.update(dt);
    _updateMagnifierVisibility();
  }

  void _updateMagnifierVisibility() {
    final session = game.ref.read(simulationSessionProvider);
    
    final selectedType = session.selectedInspectorType;
    final isMicroscope = session.isMicroscopeEnabled;

    for (final child in children.query<ProcessMagnifierComponent>()) {
      // Only visible if microscope is on AND this type is selected
      child.isVisible = isMicroscope && child.type.name == selectedType;
    }
  }

  /// Returns all active magnifiers.
  List<ProcessMagnifierComponent> get magnifiers => children.query<ProcessMagnifierComponent>().toList();

  /// Finds a magnifier of a specific type.
  ProcessMagnifierComponent? getMagnifier(MagnifierType type) {
    return children.query<ProcessMagnifierComponent>().where((m) => m.type == type).firstOrNull;
  }

  void setVisible(bool visible) {
    // This is now handled by _updateMagnifierVisibility and state.isMicroscopeEnabled
  }
}
