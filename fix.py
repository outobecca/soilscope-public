with open('lib/presentation/widgets/game/components/particle_system_component.dart', 'r') as f:
    content = f.read()

content = content.replace("    if (inXylem)\n      baseOpacity = 1.0; // Fully opaque when traveling up the plant stem", "    if (inXylem) {\n      baseOpacity = 1.0;\n    } // Fully opaque when traveling up the plant stem")

with open('lib/presentation/widgets/game/components/particle_system_component.dart', 'w') as f:
    f.write(content)
