/**
 * Filter Engine Module - Search and filtering logic
 */

class FilterEngine {
    constructor(dataManager) {
        this.dataManager = dataManager;
    }

    /**
     * Check if a comparison has column differences
     * Handles both new and old data structures
     */
    hasColumnDifferences(comparison) {
        if (!comparison) return false;

        // New structure
        if (comparison.column_differences &&
            Array.isArray(comparison.column_differences) &&
            comparison.column_differences.length > 0) {
            return true;
        }

        // Old structure for backward compatibility
        if (comparison.discrepant_records &&
            Array.isArray(comparison.discrepant_records)) {
            return comparison.discrepant_records.some(record =>
                record.column_differences && record.column_differences.length > 0
            );
        }

        return false;
    }

    /**
     * Check if a table has any column differences
     * Handles both UID and KEY validation types
     */
    async hasTableColumnDifferences(tableName) {
        const columns = await this.dataManager.getUidColumnsForTable(tableName);
        
        if (!columns || !Array.isArray(columns) || columns.length === 0) {
            return false;
        }

        for (const column of columns) {
            const values = await this.dataManager.getUidValuesForColumn(tableName, column);
            
            // Skip if no values returned
            if (!Array.isArray(values) || values.length === 0) {
                continue;
            }

            for (const item of values) {
                if (item && item.comparison && this.hasColumnDifferences(item.comparison)) {
                    return true;
                }
            }
        }
        return false;
    }

    /**
     * Check if a table has record count mismatches
     * Handles both UID and KEY validation types
     */
    async hasTableRecordMismatch(tableName) {
        const columns = await this.dataManager.getUidColumnsForTable(tableName);
        
        if (!columns || !Array.isArray(columns) || columns.length === 0) {
            return false;
        }

        for (const column of columns) {
            const values = await this.dataManager.getUidValuesForColumn(tableName, column);
            
            // Skip if no values returned
            if (!Array.isArray(values) || values.length === 0) {
                continue;
            }

            for (const item of values) {
                if (item && item.comparison && !item.comparison.record_counts_match) {
                    return true;
                }
            }
        }
        return false;
    }

    /**
     * Check if a UID value has any issues
     */
    hasUidValueIssues(comparison) {
        if (!comparison) return false;
        return !comparison.record_counts_match || this.hasColumnDifferences(comparison);
    }

    /**
     * Get status of a UID value for styling
     * Returns: 'match', 'column-diff', 'record-mismatch', or 'null'
     */
    getUidValueStatus(uidValue, comparison) {
        if (uidValue === null) return 'null';
        if (!comparison) return 'unknown';

        const hasColumnDiff = this.hasColumnDifferences(comparison);
        const hasRecordMismatch = !comparison.record_counts_match;

        if (comparison.record_counts_match && !hasColumnDiff) {
            return 'match';
        } else if (hasColumnDiff) {
            return 'column-diff';
        } else if (hasRecordMismatch) {
            return 'record-mismatch';
        }

        return 'unknown';
    }

    /**
     * Filter tables by search term
     */
    filterBySearchTerm(tables, searchTerm) {
        const term = searchTerm.toLowerCase();
        return tables.filter(t => t.toLowerCase().includes(term));
    }

    /**
     * Filter tables by type
     */
    async filterByType(tables, filterType) {
        if (filterType === 'all') return tables;

        if (filterType === 'column-diff') {
            const filtered = [];
            for (const tableName of tables) {
                if (await this.hasTableColumnDifferences(tableName)) {
                    filtered.push(tableName);
                }
            }
            return filtered;
        }

        if (filterType === 'record-mismatch') {
            const filtered = [];
            for (const tableName of tables) {
                if (await this.hasTableRecordMismatch(tableName)) {
                    filtered.push(tableName);
                }
            }
            return filtered;
        }

        return tables;
    }

    /**
     * Apply combined search and filter
     */
    async applyFilters(tables, searchTerm, filterType) {
        let filtered = this.filterBySearchTerm(tables, searchTerm);
        filtered = await this.filterByType(filtered, filterType);
        return filtered;
    }

    /**
     * Get column diff count for a comparison
     */
    getColumnDiffCount(comparison) {
        if (!this.hasColumnDifferences(comparison)) return 0;

        if (comparison.column_differences && Array.isArray(comparison.column_differences)) {
            return comparison.column_differences.length;
        }

        if (comparison.discrepant_records && Array.isArray(comparison.discrepant_records)) {
            return comparison.discrepant_records.filter(r => r.column_differences && r.column_differences.length > 0).length;
        }

        return 0;
    }
}
