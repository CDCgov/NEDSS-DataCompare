#!/usr/bin/env python3
"""Generate data.js from validation results JSON files."""

import json
from pathlib import Path

def generate_data_js():
    """Generate data.js containing all validation results."""
    results_dir = Path(__file__).parent.parent / 'results'
    
    if not results_dir.exists():
        print(f"Results directory not found: {results_dir}")
        return
    
    data = {}
    table_dirs = sorted([d for d in results_dir.iterdir() if d.is_dir()])
    
    for table_dir in table_dirs:
        result_file = table_dir / 'validation_results.json'
        if result_file.exists():
            try:
                with open(result_file, 'r') as f:
                    data[table_dir.name] = json.load(f)
                print(f"✓ Loaded {table_dir.name}")
            except Exception as e:
                print(f"✗ Error loading {table_dir.name}: {e}")
    
    # Write data.js
    output_file = Path(__file__).parent / 'data.js'
    with open(output_file, 'w') as f:
        f.write('// Auto-generated validation data\n')
        f.write('window.VALIDATION_DATA = ')
        json.dump(data, f)
        f.write(';\n')
    
    print(f"\n✓ Generated data.js with {len(data)} tables")
    print(f"  Output: {output_file}")

if __name__ == '__main__':
    generate_data_js()
