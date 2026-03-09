#!/usr/bin/env python3
"""
Flask server for serving validation results to the web UI.

Provides RESTful endpoints to access validation data without loading
everything into memory at once.
"""

import json
import os
from pathlib import Path
from flask import Flask, jsonify, request, send_from_directory
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# Base directory for results
RESULTS_DIR = Path(__file__).parent.parent / 'results'
STATIC_DIR = Path(__file__).parent  # Current directory for static files


def get_results_directory():
    """Get and validate results directory."""
    if not RESULTS_DIR.exists():
        return None
    return RESULTS_DIR


def load_table_validation(table_name):
    """Load validation results for a specific table."""
    table_dir = RESULTS_DIR / table_name
    result_file = table_dir / 'validation_results.json'
    
    if not result_file.exists():
        return None
    
    try:
        with open(result_file, 'r') as f:
            return json.load(f)
    except Exception as e:
        print(f"Error loading {table_name}: {e}")
        return None


@app.route('/api/health', methods=['GET'])
def health():
    """Health check endpoint."""
    return jsonify({
        'status': 'ok',
        'results_dir': str(RESULTS_DIR),
        'exists': RESULTS_DIR.exists()
    })


@app.route('/api/tables', methods=['GET'])
def get_tables():
    """Get list of all tables with validation data."""
    print("[DEBUG] /api/tables called")
    results_dir = get_results_directory()
    if not results_dir:
        print("[DEBUG] Results directory not found")
        return jsonify({'error': 'Results directory not found'}), 404
    
    print(f"[DEBUG] Results directory: {results_dir}")
    tables = []
    for table_dir in sorted(results_dir.iterdir()):
        if table_dir.is_dir():
            result_file = table_dir / 'validation_results.json'
            if result_file.exists():
                tables.append({
                    'name': table_dir.name,
                    'path': str(table_dir)
                })
    
    print(f"[DEBUG] Found {len(tables)} tables")
    return jsonify({'tables': tables, 'count': len(tables)})


@app.route('/api/table/<table_name>', methods=['GET'])
def get_table_data(table_name):
    """
    Get validation data for a specific table.
    
    Query params:
    - structure_only: If true, returns only column/structure info (no records)
    - include_records: If false, removes all record details
    """
    data = load_table_validation(table_name)
    if not data:
        return jsonify({'error': f'Table {table_name} not found'}), 404
    
    structure_only = request.args.get('structure_only', 'false').lower() == 'true'
    include_records = request.args.get('include_records', 'true').lower() == 'true'
    
    if structure_only:
        # Return only column structure, not record data
        slim = {
            'table_name': data.get('table_name', table_name),
            'uid_validation': None,
            'key_validation': None
        }
        
        if data.get('uid_validation'):
            uid_val = data['uid_validation']
            # Only process if not an error state
            if 'error' not in uid_val:
                slim['uid_validation'] = {
                    'table_name': uid_val.get('table_name'),
                    'uid_columns': uid_val.get('uid_columns', []),
                    'results_by_uid_column': {}
                }
                for uid_col, col_data in uid_val.get('results_by_uid_column', {}).items():
                    slim['uid_validation']['results_by_uid_column'][uid_col] = {
                        'uid_column': col_data.get('uid_column'),
                        'total_uid_values': len(col_data.get('uid_values', []))
                    }
            else:
                slim['uid_validation'] = uid_val  # Include error message
        
        if data.get('key_validation'):
            key_val = data['key_validation']
            # Only process if not an error state
            if 'error' not in key_val:
                slim['key_validation'] = {
                    'table_name': key_val.get('table_name'),
                    'key_columns': key_val.get('key_columns', []),
                    'results_by_key_column': {}
                }
                for key_col, col_data in key_val.get('results_by_key_column', {}).items():
                    slim['key_validation']['results_by_key_column'][key_col] = {
                        'key_column': col_data.get('key_column'),
                        'mapping_table': col_data.get('mapping_table'),
                        'mapping_uid_column': col_data.get('mapping_uid_column'),
                        'total_records': len(col_data.get('records_by_mapping_uid', {}))
                    }
            else:
                slim['key_validation'] = key_val  # Include error message
        
        return jsonify(slim)
    
    if not include_records:
        # Remove all record details but keep structure
        clean = {
            'table_name': data.get('table_name', table_name),
            'uid_validation': None,
            'key_validation': None
        }
        
        if data.get('uid_validation'):
            uid_val = data['uid_validation']
            # Only process if not an error state
            if 'error' not in uid_val:
                clean['uid_validation'] = {
                    'table_name': uid_val.get('table_name'),
                    'uid_columns': uid_val.get('uid_columns', []),
                    'results_by_uid_column': {}
                }
                for uid_col, col_data in uid_val.get('results_by_uid_column', {}).items():
                    clean['uid_validation']['results_by_uid_column'][uid_col] = {
                        'uid_column': col_data.get('uid_column'),
                        'uid_values': []
                    }
            else:
                clean['uid_validation'] = uid_val  # Include error message
        
        if data.get('key_validation'):
            key_val = data['key_validation']
            # Only process if not an error state
            if 'error' not in key_val:
                clean['key_validation'] = {
                    'table_name': key_val.get('table_name'),
                    'key_columns': key_val.get('key_columns', []),
                    'results_by_key_column': {}
                }
                for key_col, col_data in key_val.get('results_by_key_column', {}).items():
                    clean['key_validation']['results_by_key_column'][key_col] = {
                        'key_column': col_data.get('key_column'),
                        'mapping_table': col_data.get('mapping_table'),
                        'mapping_uid_column': col_data.get('mapping_uid_column'),
                        'records_by_mapping_uid': {}
                    }
            else:
                clean['key_validation'] = key_val  # Include error message
        
        return jsonify(clean)
    
    return jsonify(data)


@app.route('/api/table/<table_name>/columns', methods=['GET'])
def get_table_columns(table_name):
    """Get column information for a table (UID or KEY columns)."""
    data = load_table_validation(table_name)
    if not data:
        return jsonify({'error': f'Table {table_name} not found'}), 404
    
    columns = {
        'table_name': table_name,
        'uid_columns': [],
        'key_columns': []
    }
    
    # Only include uid_columns if uid_validation has actual results (not an error)
    if data.get('uid_validation'):
        uid_val = data['uid_validation']
        if 'error' not in uid_val:
            columns['uid_columns'] = uid_val.get('uid_columns', [])
    
    # Only include key_columns if key_validation has actual results (not an error)
    if data.get('key_validation'):
        key_val = data['key_validation']
        if 'error' not in key_val:
            columns['key_columns'] = key_val.get('key_columns', [])
    
    return jsonify(columns)


@app.route('/api/table/<table_name>/column/<column_name>', methods=['GET'])
def get_column_values(table_name, column_name):
    """
    Get validation values for a specific column in a table.
    
    Returns different structure based on whether it's UID or KEY validation.
    Handles error states and empty results gracefully.
    """
    data = load_table_validation(table_name)
    if not data:
        return jsonify({'error': f'Table {table_name} not found'}), 404
    
    # Check UID validation first
    if data.get('uid_validation'):
        uid_val = data['uid_validation']
        
        # Skip if uid_validation contains an error message
        if 'error' in uid_val:
            pass  # Continue to check key_validation
        else:
            results_by_uid = uid_val.get('results_by_uid_column', {})
            if column_name in results_by_uid:
                col_data = results_by_uid[column_name]
                return jsonify({
                    'table_name': table_name,
                    'column_name': column_name,
                    'validation_type': 'uid',
                    'uid_values': col_data.get('uid_values', [])
                })
    
    # Check KEY validation
    if data.get('key_validation'):
        key_val = data['key_validation']
        
        # Skip if key_validation contains an error message
        if 'error' in key_val:
            pass  # No more validation types to check
        else:
            results_by_key = key_val.get('results_by_key_column', {})
            if column_name in results_by_key:
                col_data = results_by_key[column_name]
                return jsonify({
                    'table_name': table_name,
                    'column_name': column_name,
                    'validation_type': 'key',
                    'mapping_table': col_data.get('mapping_table'),
                    'mapping_uid_column': col_data.get('mapping_uid_column'),
                    'records_by_mapping_uid': col_data.get('records_by_mapping_uid', {})
                })
    
    # No validation data found for this column - return empty results (not an error)
    return jsonify({
        'table_name': table_name,
        'column_name': column_name,
        'validation_type': 'unknown',
        'uid_values': [],
        'records_by_mapping_uid': {}
    }), 404


@app.route('/api/table/<table_name>/column/<column_name>/values', methods=['GET'])
def get_column_values_paginated(table_name, column_name):
    """
    Get paginated values for a column.
    
    Query params:
    - offset: Starting position (default 0)
    - limit: Number of items to return (default 100)
    """
    data = load_table_validation(table_name)
    if not data:
        return jsonify({'error': f'Table {table_name} not found'}), 404
    
    offset = int(request.args.get('offset', 0))
    limit = int(request.args.get('limit', 100))
    
    # Check UID validation
    if data.get('uid_validation'):
        uid_val = data['uid_validation']
        # Skip if error state
        if 'error' not in uid_val:
            results_by_uid = uid_val.get('results_by_uid_column', {})
            if column_name in results_by_uid:
                col_data = results_by_uid[column_name]
                uid_values = col_data.get('uid_values', [])
                paginated = uid_values[offset:offset+limit]
                return jsonify({
                    'table_name': table_name,
                    'column_name': column_name,
                    'validation_type': 'uid',
                    'offset': offset,
                    'limit': limit,
                    'total': len(uid_values),
                    'values': paginated
                })
    
    # Check KEY validation
    if data.get('key_validation'):
        key_val = data['key_validation']
        # Skip if error state
        if 'error' not in key_val:
            results_by_key = key_val.get('results_by_key_column', {})
            if column_name in results_by_key:
                col_data = results_by_key[column_name]
                records = col_data.get('records_by_mapping_uid', {})
                record_list = list(records.values())
                paginated = record_list[offset:offset+limit]
                return jsonify({
                    'table_name': table_name,
                    'column_name': column_name,
                    'validation_type': 'key',
                    'offset': offset,
                    'limit': limit,
                    'total': len(record_list),
                    'records': paginated
                })
    
    # Return empty results for columns that don't exist or have errors
    return jsonify({
        'table_name': table_name,
        'column_name': column_name,
        'validation_type': 'unknown',
        'offset': offset,
        'limit': limit,
        'total': 0,
        'values': [],
        'records': []
    }), 404

# Static file routes - MUST be after all API routes
@app.route('/', methods=['GET'])
def index():
    """Serve the index.html file."""
    return send_from_directory(STATIC_DIR, 'index.html')


@app.route('/<path:filename>')
def serve_static(filename):
    """Serve static files (CSS, JS, etc)."""
    return send_from_directory(STATIC_DIR, filename)


if __name__ == '__main__':
    print(f"Starting validation results server...")
    print(f"Results directory: {RESULTS_DIR}")
    print(f"Serving on http://localhost:8001")
    print(f"\nEndpoints:")
    print(f"  GET /api/health             - Health check")
    print(f"  GET /api/tables             - List all tables")
    print(f"  GET /api/table/<name>       - Get table validation data")
    print(f"  GET /api/table/<name>/columns  - Get table columns")
    print(f"  GET /api/table/<name>/column/<col>  - Get column values")
    print(f"  GET /api/table/<name>/column/<col>/values - Paginated values")
    print()
    
    app.run(debug=False, port=8001, use_reloader=False)

