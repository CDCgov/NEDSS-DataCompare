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
     */
    hasTableColumnDifferences(tableName) {
        const uidColumns = this.dataManager.getUidColumnsForTable(tableName);

        for (const uidColumn of uidColumns) {
            const uidValues = this.dataManager.getUidValuesForColumn(tableName, uidColumn);

            for (const item of uidValues) {
                if (this.hasColumnDifferences(item.comparison)) {
                    return true;
                }
            }
        }
        return false;
    }

    /**
     * Check if a table has record count mismatches
     */
    hasTableRecordMismatch(tableName) {
        const uidColumns = this.dataManager.getUidColumnsForTable(tableName);

        for (const uidColumn of uidColumns) {
            const uidValues = this.dataManager.getUidValuesForColumn(tableName, uidColumn);

            for (const item of uidValues) {
                if (!item.comparison.record_counts_match) {
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
    filterByType(tables, filterType) {
        if (filterType === 'all') return tables;

        if (filterType === 'column-diff') {
            return tables.filter(tableName => this.hasTableColumnDifferences(tableName));
        }

        if (filterType === 'record-mismatch') {
            return tables.filter(tableName => this.hasTableRecordMismatch(tableName));
        }

        return tables;
    }

    /**
     * Apply combined search and filter
     */
    applyFilters(tables, searchTerm, filterType) {
        let filtered = this.filterBySearchTerm(tables, searchTerm);
        filtered = this.filterByType(filtered, filterType);
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
