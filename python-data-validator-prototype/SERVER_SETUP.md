# Validation Results Server Setup

The validation results viewer now uses a Flask server to dynamically serve data instead of a static data.js file. This provides better performance and flexibility.

## Installation

Install Flask and CORS support:

```bash
pip install -r result-reviewer/server-requirements.txt
```

Or install directly:

```bash
pip install flask==2.3.3 flask-cors==4.0.0
```

## Running the Server

Start the Flask server:

```bash
cd python-data-validator-prototype
python3 result-reviewer/server.py
```

The server will start on `http://localhost:5000` and display available endpoints:

```
Starting validation results server...
Results directory: /path/to/results
Serving on http://localhost:5000

Endpoints:
  GET /api/health             - Health check
  GET /api/tables             - List all tables
  GET /api/table/<name>       - Get table validation data
  GET /api/table/<name>/columns  - Get table columns
  GET /api/table/<name>/column/<col>  - Get column values
  GET /api/table/<name>/column/<col>/values - Paginated values
```

## Using the Web Viewer

Open `result-reviewer/index.html` in your browser. The viewer will:
1. Detect the running Flask server
2. Load the list of tables dynamically
3. Fetch validation data on demand as you interact with the UI

### Features

- **Search**: Filter tables by name in real-time
- **Dynamic Loading**: Only loads data when needed (click to expand)
- **Caching**: Client-side caching to avoid re-fetching data
- **Server Health Check**: Automatically detects if the server is running

## Server API Reference

### GET /api/health
Health check endpoint.

Response:
```json
{
    "status": "ok",
    "results_dir": "/path/to/results",
    "exists": true
}
```

### GET /api/tables
List all tables with validation data.

Response:
```json
{
    "tables": [
        {"name": "TABLE_NAME1", "path": "/path/to/results/TABLE_NAME1"},
        {"name": "TABLE_NAME2", "path": "/path/to/results/TABLE_NAME2"}
    ],
    "count": 85
}
```

### GET /api/table/<table_name>
Get validation data for a specific table.

Query Parameters:
- `structure_only=true` - Return only column structure (no records)
- `include_records=false` - Remove all record details

Response:
```json
{
    "table_name": "TABLE_NAME",
    "uid_validation": {...},
    "key_validation": {...}
}
```

### GET /api/table/<table_name>/columns
Get column information for a table.

Response:
```json
{
    "table_name": "TABLE_NAME",
    "uid_columns": ["COLUMN1", "COLUMN2"],
    "key_columns": ["KEY_COL1"]
}
```

### GET /api/table/<table_name>/column/<column_name>
Get validation values for a specific column.

Response (UID validation):
```json
{
    "table_name": "TABLE_NAME",
    "column_name": "COLUMN_NAME",
    "validation_type": "uid",
    "uid_values": [...]
}
```

Response (KEY validation):
```json
{
    "table_name": "TABLE_NAME",
    "column_name": "KEY_COL",
    "validation_type": "key",
    "mapping_table": "MAPPING_TABLE",
    "mapping_uid_column": "MAPPING_UID_COL",
    "records_by_mapping_uid": {...}
}
```

## Troubleshooting

### Connection refused
Ensure the Flask server is running on localhost:5000. Start it with:
```bash
python3 result-reviewer/server.py
```

### Port already in use
If port 5000 is already in use, modify the server.py file to use a different port and update viewer.js accordingly.

### CORS errors
The server includes Flask-CORS to handle cross-origin requests. If you still see CORS errors, ensure flask-cors is installed correctly.

### No tables showing
Check that:
1. The results directory exists at `../results/`
2. Results subdirectories contain `validation_results.json` files
3. The server logs show tables being found
