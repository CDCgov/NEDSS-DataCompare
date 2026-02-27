/**
 * KEY Validation Renderer Module - Handles rendering KEY validation details
 */

class KeyValidationRenderer {
    constructor(dataManager) {
        this.dataManager = dataManager;
    }

    /**
     * Render KEY column details for a specific table and column
     */
    renderKeyColumnDetails(tableName, keyColumn) {
        const mappingUids = this.dataManager.getMappingUidsForKeyColumn(tableName, keyColumn);
        const metadata = this.dataManager.getKeyColumnMetadata(tableName, keyColumn);

        let html = `<div class="key-column-details">`;
        html += `<div class="key-header">`;
        html += `<h3>${keyColumn}</h3>`;
        html += `<div class="mapping-metadata">`;
        html += `<span class="mapping-table">${metadata.mapping_table}</span>`;
        html += `<span class="mapping-uid">${metadata.mapping_uid_column}</span>`;
        html += `</div>`;
        html += `</div>`;

        html += `<div class="mapping-uids-summary">`;
        html += `<p>Total Mapping UIDs: <strong>${mappingUids.length}</strong></p>`;
        html += `</div>`;

        html += `<div class="mapping-uid-list">`;
        mappingUids.forEach(mappingUid => {
            const recordData = this.dataManager.getKeyMappingData(tableName, keyColumn, mappingUid);
            if (recordData) {
                html += this.renderMappingUidRow(mappingUid, recordData);
            }
        });
        html += `</div>`;

        html += `</div>`;
        return html;
    }

    /**
     * Render a single mapping UID row
     */
    renderMappingUidRow(mappingUid, recordData) {
        const rdbModernKeyValue = recordData.rdb_modern_key_value;
        const rdbKeyValue = recordData.rdb_key_value;
        const hasRecordCountMismatch = recordData.comparison.rdb_count !== recordData.comparison.rdb_modern_count;
        const hasColumnDifferences = recordData.comparison.has_differences;

        const statusClass = hasRecordCountMismatch ? 'mismatch' : (hasColumnDifferences ? 'differences' : 'match');

        let html = `<div class="mapping-uid-row ${statusClass}">`;
        html += `<div class="mapping-uid-header">`;
        html += `<span class="mapping-uid-label">${mappingUid}</span>`;
        html += `<span class="key-values">`;
        html += `<span class="rdb-modern-key">RDB_MODERN: ${rdbModernKeyValue}</span>`;
        html += `<span class="rdb-key">RDB: ${rdbKeyValue}</span>`;
        html += `</span>`;
        html += `<span class="status-indicator" title="${this.getStatusTitle(recordData.comparison)}">`;
        html += statusClass.toUpperCase();
        html += `</span>`;
        html += `</div>`;

        html += `<div class="comparison-summary">`;
        html += `<p>RDB Records: ${recordData.comparison.rdb_count} | RDB_MODERN Records: ${recordData.comparison.rdb_modern_count}</p>`;
        if (hasColumnDifferences) {
            html += `<p class="differences-count">Column Differences: ${recordData.comparison.column_differences.length}</p>`;
        }
        html += `</div>`;

        html += `</div>`;
        return html;
    }

    /**
     * Get status title for comparison
     */
    getStatusTitle(comparison) {
        if (comparison.rdb_count !== comparison.rdb_modern_count) {
            return `Record count mismatch: RDB has ${comparison.rdb_count}, RDB_MODERN has ${comparison.rdb_modern_count}`;
        }
        if (comparison.has_differences) {
            return `${comparison.column_differences.length} column differences found`;
        }
        return 'No differences found';
    }

    /**
     * Render detailed comparison for a specific mapping UID
     */
    renderMappingUidComparison(tableName, keyColumn, mappingUid) {
        const recordData = this.dataManager.getKeyMappingData(tableName, keyColumn, mappingUid);
        if (!recordData) return '<p>No data found</p>';

        let html = `<div class="mapping-uid-comparison">`;
        html += `<div class="comparison-header">`;
        html += `<h4>Mapping UID: ${mappingUid}</h4>`;
        html += `<div class="key-values-detail">`;
        html += `<p>RDB_MODERN ${keyColumn}: ${recordData.rdb_modern_key_value}</p>`;
        html += `<p>RDB ${keyColumn}: ${recordData.rdb_key_value}</p>`;
        html += `</div>`;
        html += `</div>`;

        // Records summary
        html += `<div class="records-section">`;
        html += `<h5>Record Count</h5>`;
        html += `<table class="record-count-table">`;
        html += `<tr><td>RDB</td><td>${recordData.comparison.rdb_count}</td></tr>`;
        html += `<tr><td>RDB_MODERN</td><td>${recordData.comparison.rdb_modern_count}</td></tr>`;
        html += `</table>`;
        html += `</div>`;

        // Column differences
        if (recordData.comparison.column_differences && recordData.comparison.column_differences.length > 0) {
            html += `<div class="differences-section">`;
            html += `<h5>Column Differences</h5>`;
            html += `<table class="differences-table">`;
            html += `<thead><tr><th>Column</th><th>RDB Value</th><th>RDB_MODERN Value</th></tr></thead>`;
            html += `<tbody>`;
            recordData.comparison.column_differences.forEach(diff => {
                html += `<tr>`;
                html += `<td>${diff.column}</td>`;
                html += `<td><pre>${JSON.stringify(diff.rdb_value, null, 2)}</pre></td>`;
                html += `<td><pre>${JSON.stringify(diff.rdb_modern_value, null, 2)}</pre></td>`;
                html += `</tr>`;
            });
            html += `</tbody>`;
            html += `</table>`;
            html += `</div>`;
        }

        html += `</div>`;
        return html;
    }
}
