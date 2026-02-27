#!/usr/bin/env python3
"""Generate data.js from validation results JSON files.

Supports both UID and KEY validation result structures.
Aggregates all validation results from the results/ directory into
a single data.js file for the web viewer.
"""

import json
from pathlib import Path

def get_validation_types(validation_data):
    """
    Determine which validation types are present in the data.
    
    Args:
        validation_data: The validation result dictionary for a table
        
    Returns:
        List of validation types present (e.g., ['uid'], ['key'], ['uid', 'key'])
    """
    types = []
    if validation_data.get('uid_validation'):
        types.append('uid')
    if validation_data.get('key_validation'):
        types.append('key')
    return types


def generate_data_js():
    """Generate data.js containing all validation results."""
    results_dir = Path(__file__).parent.parent / 'results'
    
    if not results_dir.exists():
        print(f"Results directory not found: {results_dir}")
        return
    
    data = {}
    table_dirs = sorted([d for d in results_dir.iterdir() if d.is_dir()])
    
    validation_type_counts = {'uid': 0, 'key': 0, 'both': 0}
    
    for table_dir in table_dirs:
        result_file = table_dir / 'validation_results.json'
        if result_file.exists():
            try:
                with open(result_file, 'r') as f:
                    table_data = json.load(f)
                
                data[table_dir.name] = table_data
                
                # Track validation types
                validation_types = get_validation_types(table_data)
                if len(validation_types) == 2:
                    validation_type_counts['both'] += 1
                elif 'uid' in validation_types:
                    validation_type_counts['uid'] += 1
                elif 'key' in validation_types:
                    validation_type_counts['key'] += 1
                
                types_str = ' + '.join(validation_types).upper() if validation_types else 'NONE'
                print(f"✓ {table_dir.name:<40} [{types_str}]")
                
            except Exception as e:
                print(f"✗ Error loading {table_dir.name}: {e}")
    
    # Write data.js
    output_file = Path(__file__).parent / 'data.js'
    with open(output_file, 'w') as f:
        f.write('// Auto-generated validation data\n')
        f.write('// This file contains validation results for both UID and KEY columns\n')
        f.write('window.VALIDATION_DATA = ')
        json.dump(data, f)
        f.write(';\n')
    
    # Print summary
    print(f"\n{'='*70}")
    print(f"✓ Generated data.js with {len(data)} tables")
    print(f"\nValidation Type Summary:")
    print(f"  UID only:        {validation_type_counts['uid']} tables")
    print(f"  KEY only:        {validation_type_counts['key']} tables")
    print(f"  UID + KEY:       {validation_type_counts['both']} tables")
    print(f"  Total:           {len(data)} tables")
    print(f"\nOutput: {output_file}")
    print(f"{'='*70}")

if __name__ == '__main__':
    generate_data_js()
