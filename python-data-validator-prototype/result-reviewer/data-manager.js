/**
 * Data Manager Module - Abstraction layer for data access
 */

class DataManager {
    constructor(validationData) {
        this.validationData = validationData;
        this.allTables = Object.keys(validationData).sort();
    }

    /**
     * Get all table names
     */
    getTableNames() {
        return this.allTables;
    }

    /**
     * Get table validation data
     */
    getTableData(tableName) {
        return this.validationData[tableName] || {};
    }

    /**
     * Get UID columns for a table
     */
    getUidColumnsForTable(tableName) {
        const data = this.getTableData(tableName);
        return data.uid_columns || [];
    }

    /**
     * Get all UID values for a specific UID column
     */
    getUidValuesForColumn(tableName, uidColumn) {
        const data = this.getTableData(tableName);
        const resultsByUidColumn = data.results_by_uid_column || {};
        const columnData = resultsByUidColumn[uidColumn] || {};
        return columnData.uid_values || [];
    }

    /**
     * Get comparison data for a specific UID value
     */
    getComparisonData(tableName, uidColumn, uidValue) {
        const uidValues = this.getUidValuesForColumn(tableName, uidColumn);
        // Handle type coercion - UID might be stored as number or string
        const item = uidValues.find(v => {
            // Try strict equality first
            if (v.uid_value === uidValue) return true;
            // Then try loose equality to handle string/number mismatch
            if (v.uid_value == uidValue) return true;
            return false;
        });
        return item ? item.comparison : null;
    }

    /**
     * Get column differences from comparison
     * Handles both new and old data structures
     */
    getColumnDifferences(comparison) {
        if (!comparison) return [];

        // New structure
        if (comparison.column_differences && Array.isArray(comparison.column_differences)) {
            return comparison.column_differences;
        }

        // Old structure - flatten records with column_differences
        if (comparison.discrepant_records && Array.isArray(comparison.discrepant_records)) {
            return comparison.discrepant_records.filter(r => r.column_differences && r.column_differences.length > 0);
        }

        return [];
    }
}
