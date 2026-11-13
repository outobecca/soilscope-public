import os
import re

files = [
    'test/domain/logic_lab/evaluator_test.dart',
    'test/domain/solvers/aggregation_solver_test.dart',
    'test/domain/solvers/energy_solver_test.dart',
    'test/domain/solvers/gas_solver_test.dart',
    'test/domain/solvers/scoring_solver_benchmark_test.dart'
]

for file in files:
    with open(file, 'r') as f:
        content = f.read()

    # BiophysicalState(..., plant: const Plant(...), ...)
    content = re.sub(
        r'plant: (const Plant\([^)]+\)),', 
        r'plants: [\1],', 
        content,
        flags=re.MULTILINE
    )
    
    # In evaluators: plant: const Plant(
    # it can be multi-line
    content = re.sub(r'plant:\s*const Plant\(', r'plants: [const Plant(', content)
    # We'll just replace `plant: ` with `plants: ` and manually fix the brackets for the multiline ones.
    
    # For `plant: plant`
    content = re.sub(r'plant: plant', r'plants: [plant]', content)
    
    # For `plant: plantWithLai`
    content = re.sub(r'plant: plantWithLai', r'plants: [plantWithLai]', content)

    with open(file, 'w') as f:
        f.write(content)

