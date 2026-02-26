# Setup Instructions

## Prerequisites

### Install Microsoft ODBC Driver for macOS

The ODBC driver is required to connect to SQL Server via pyodbc.

**Option 1: Using Homebrew (Recommended)**

Add Microsoft's Homebrew tap and install:

```bash
brew tap microsoft/mssql-release https://github.com/Microsoft/homebrew-mssql-release
brew install mssql-tools
```

**Option 2: Using Official Microsoft Installer**

Download and install from Microsoft's official source:

```bash
# Install using the official Microsoft script
/bin/bash -c "$(curl https://aka.ms/getodbc/mac)"
```

**Option 3: Verify Installation**

After installation, verify the driver is installed:

```bash
odbcinst -j
```

You should see output showing ODBC driver installations. Look for "ODBC Driver 18 for SQL Server" or "ODBC Driver 17 for SQL Server".

### Verify Python Installation

Ensure Python 3.8 or higher is installed:

```bash
python --version
```

## Installation Steps

### 1. Install Python Dependencies

```bash
python -m pip install -r requirements.txt
```

This installs:
- **pyodbc** — SQL Server ODBC driver for Python
- **sqlalchemy** — ORM and SQL query builder

### 2. Verify Installation

```bash
python -c "import pyodbc; print('pyodbc installed successfully')"
python -c "import sqlalchemy; print('sqlalchemy installed successfully')"
```
## Running The Validator

Validate all tables:
```bash
python main.py
```

Provide target list of tables:
```bash
python main.py --target-tables <my_tables_list.txt>
```

## Running The Results Viewer

### 1. Generate Data File

Navigate to the result-reviewer directory and generate the data.js file from validation results:

```bash
cd result-reviewer
python generate_data.py
```

This will load all 297 tables from the `results/` directory and generate a `data.js` file containing all validation data.

### 2. Open viewer.js

Drag `result-viewer/viewer.js` to your browser and enjoy.

### Features

- **Search/Filter**: Type in the search bar to filter tables by name (case-insensitive)
- **Expandable Rows**: Click any table name to expand and view its UID columns
- **All Data Loaded**: Validation results are fully loaded in `data.js` for fast, offline access
## Troubleshooting

### ODBC Driver Not Found

If you get "ODBC Driver 18 for SQL Server not found", verify installation:

```bash
odbcinst -j
```

### Connection Timeout

Ensure your SQL Server is accessible and firewall allows the connection (default port 1433).

### Authentication Errors

Verify username, password, and server name. Test with SQL Server Management Studio first if available.
