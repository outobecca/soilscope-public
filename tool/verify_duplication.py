import os
import re

files = [
    'lib/presentation/widgets/game/components/horizon_color_bands_component.dart',
    'lib/presentation/widgets/game/components/soil_texture_pattern_component.dart',
    'lib/presentation/widgets/game/components/capillary_rise_component.dart',
    'lib/presentation/widgets/game/components/clay_node_component.dart',
    'lib/presentation/widgets/game/components/hex_grid_component.dart',
    'lib/presentation/widgets/game/components/horizon_details_component.dart',
    'lib/presentation/widgets/game/components/mesh_network_component.dart',
    'lib/presentation/widgets/game/components/molecule_particle_component.dart',
    'lib/presentation/widgets/game/components/mollier_diagram_component.dart',
    'lib/presentation/widgets/game/components/mycorrhiza_network_component.dart',
    'lib/presentation/widgets/game/components/nutrient_node_component.dart',
    'lib/presentation/widgets/game/components/par_chart_component.dart',
    'lib/presentation/widgets/game/components/ph_gradient_component.dart',
    'lib/presentation/widgets/game/components/photosynthesis_indicator_component.dart',
    'lib/presentation/widgets/game/components/sensor_node_component.dart',
    'lib/presentation/widgets/game/components/soil_evaporation_component.dart',
    'lib/presentation/widgets/game/components/soil_layer_component.dart',
    'lib/presentation/widgets/game/components/soil_texture_label_component.dart',
    'lib/presentation/widgets/game/components/soil_texture_triangle_component.dart',
    'lib/presentation/widgets/game/components/teaching_key_component.dart',
    'lib/presentation/widgets/game/components/visual_key_component.dart',
    'lib/presentation/widgets/game/components/water_flow_paths_component.dart',
    'lib/presentation/widgets/game/components/wetting_front_component.dart',
    'lib/presentation/widgets/game/components/animated_earthworm_component.dart'
]

root = '/home/pecca/mfckt-gh/soilscope/'

for f in files:
    path = os.path.join(root, f)
    if not os.path.exists(path):
        print(f"File not found: {f}")
        continue
    with open(path, 'r') as file:
        content = file.read()
        
        # Check for duplicated blocks at the end
        # We look for the last '}' and see if the code before it matches some code earlier
        last_brace_idx = content.rfind('}')
        if last_brace_idx != -1:
            # Try to find if the last 100 characters are repeated
            tail = content[last_brace_idx-100:last_brace_idx+1]
            if content.count(tail) > 1:
                print(f"Potential duplication in {f}")
            
            # Also check if there is content AFTER the last logical closing brace
            # This is harder to determine without a parser, but often it's another class or method
            # that looks like it was appended.
        
        # Check for misplaced import
        lines = content.split('\n')
        for i, line in enumerate(lines):
            if "import 'tooltip_utils.dart';" in line and i > 20:
                print(f"Misplaced import in {f} at line {i+1}")
