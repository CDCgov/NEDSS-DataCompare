/**
 * DataManager - Fetches validation data from the Flask server
 * Provides a clean interface for accessing table and validation data
 */

class DataManager {
    constructor(baseUrl = 'http://localhost:8001') {
        this.baseUrl = baseUrl;
        this.apiBase = `${baseUrl}/api`;
        this.cache = new Map();
    }

    /**
     * Fetch JSON from the server
     */
    async fetch(endpoint) {
        const response = await fetch(endpoint);
        if (!response.ok) {
            const error = new Error(`HTTP ${response.status}: ${response.statusText}`);
            error.status = response.status;
            throw error;
        }
        return await response.json();
    }

    /**
     * Get list of all tables (async)
     */
    async getTableNames() {
        if (this.cache.has('tables')) {
            return this.cache.get('tables');
        }

        const data = await this.fetch(`${this.apiBase}/tables`);
        const tableNames = data.tables.map(t => t.name).sort();
        this.cache.set('tables', tableNames);
        return tableNames;
    }

    /**
     * Get table data (structure only by default)
     */
    async getTableData(tableName, structureOnly = true) {
        const cacheKey = `table-${tableName}-${structureOnly}`;
        if (this.cache.has(cacheKey)) {
            console.log(`[DataManager] Returning cached data for ${tableName}`);
            return this.cache.get(cacheKey);
        }

        const url = structureOnly
            ? `${this.apiBase}/table/${tableName}?structure_only=true`
            : `${this.apiBase}/table/${tableName}?include_records=true`;

        console.log(`[DataManager] Fetching from URL: ${url}`);
        const data = await this.fetch(url);
        console.log(`[DataManager] Raw API response for ${tableName}:`, data);
        this.cache.set(cacheKey, data);
        return data;
    }

    /**
     * Get UID columns for a table
     * Returns both UID and KEY columns for validation checking
     */
    async getUidColumnsForTable(tableName) {
        console.log(`[DataManager] getUidColumnsForTable called for: ${tableName}`);
        const data = await this.getTableData(tableName);
        console.log(`[DataManager] Table data retrieved:`, data);
        const columns = [];
        
        // Get UID columns (prioritize these as they're primary validation)
        if (data.uid_validation && !('error' in data.uid_validation)) {
            const uid_cols = data.uid_validation.uid_columns || [];
            console.log(`[DataManager] Found UID columns:`, uid_cols);
            columns.push(...uid_cols);
        }
        
        // Get KEY columns as fallback/additional validation
        if (data.key_validation && !('error' in data.key_validation)) {
            const key_cols = data.key_validation.key_columns || [];
            console.log(`[DataManager] Found KEY columns:`, key_cols);
            columns.push(...key_cols);
        }
        
        console.log(`[DataManager] Final columns for ${tableName}:`, columns);
        return columns;
    }

    /**
     * Get UID/validation values for a specific column
     * Handles both UID and KEY validation types from API
     */
    async getUidValuesForColumn(tableName, uidColumn) {
        const cacheKey = `values-${tableName}-${uidColumn}`;
        if (this.cache.has(cacheKey)) {
            return this.cache.get(cacheKey);
        }

        try {
            const data = await this.fetch(`${this.apiBase}/table/${tableName}/column/${uidColumn}`);
            
            let values = [];
            
            if (data.validation_type === 'uid') {
                // UID validation - use uid_values directly
                values = data.uid_values || [];
            } else if (data.validation_type === 'key') {
                // KEY validation - convert records to display format
                const records = data.records_by_mapping_uid || {};
                values = Object.entries(records).map(([mappingUid, recordData]) => ({
                    uid_value: mappingUid,
                    comparison: recordData.comparison
                }));
            } else {
                // Unknown validation type - return empty (graceful fallback)
                values = [];
            }

            this.cache.set(cacheKey, values);
            return values;
        } catch (error) {
            // Column has no validation data - 404 is expected, don't log it
            if (error.status !== 404) {
                console.warn(`Error fetching ${tableName}.${uidColumn}:`, error.message);
            }
            this.cache.set(cacheKey, []);
            return [];
        }
    }

    /**
     * Get columns for a table
     */
    async getTableColumns(tableName) {
        const cacheKey = `columns-${tableName}`;
        if (this.cache.has(cacheKey)) {
            return this.cache.get(cacheKey);
        }

        const data = await this.fetch(`${this.apiBase}/table/${tableName}/columns`);
        this.cache.set(cacheKey, data);
        return data;
    }

    /**
     * Get comparison data for a specific UID value
     */
    async getComparisonData(tableName, uidColumn, uidValue) {
        const uidValues = await this.getUidValuesForColumn(tableName, uidColumn);
        const item = uidValues.find(v => v.uid_value == uidValue);
        return item ? item.comparison : null;
    }

    /**
     * Get KEY columns for a table
     */
    async getKeyColumnsForTable(tableName) {
        const data = await this.getTableData(tableName);
        const keyData = data.key_validation || {};
        return keyData.key_columns || [];
    }

    /**
     * Get mapping information for a KEY column (mapping table, mapping UID column, etc.)
     */
    async getKeyColumnMappingInfo(tableName, keyColumn) {
        const data = await this.getTableData(tableName);
        if (!data.key_validation || 'error' in data.key_validation) {
            return null;
        }

        const resultsByKey = data.key_validation.results_by_key_column || {};
        return resultsByKey[keyColumn] || null;
    }

    /**
     * Get KEY mapping UIDs for a specific key column
     */
    async getKeyValuesForColumn(tableName, keyColumn) {
        const cacheKey = `key-values-${tableName}-${keyColumn}`;
        if (this.cache.has(cacheKey)) {
            return this.cache.get(cacheKey);
        }

        try {
            const data = await this.fetch(`${this.apiBase}/table/${tableName}/column/${keyColumn}`);
            
            let values = [];
            
            // KEY validation endpoint returns records_by_mapping_uid
            if (data.validation_type === 'key' && data.records_by_mapping_uid) {
                values = Object.entries(data.records_by_mapping_uid).map(([mappingUid, recordData]) => ({
                    mapping_uid: mappingUid,
                    comparison: recordData.comparison,
                    rdb_key_value: recordData.rdb_key_value,
                    rdb_modern_key_value: recordData.rdb_modern_key_value
                }));
            }

            this.cache.set(cacheKey, values);
            return values;
        } catch (error) {
            // Column has no validation data - 404 is expected, don't log it
            if (error.status !== 404) {
                console.warn(`Error fetching ${tableName}.${keyColumn}:`, error.message);
            }
            this.cache.set(cacheKey, []);
            return [];
        }
    }

    /**
     * Clear cache for a specific table or all cache
     */
    clearCache(tableName = null) {
        if (tableName) {
            const keys = Array.from(this.cache.keys()).filter(k => k.includes(tableName));
            keys.forEach(k => this.cache.delete(k));
        } else {
            this.cache.clear();
        }
    }

    /**
     * Check server health
     */
    async checkHealth() {
        try {
            const data = await this.fetch(`${this.apiBase}/health`);
            return data.status === 'ok';
        } catch (error) {
            console.error('Server health check failed:', error);
            return false;
        }
    }
}
