/**
 * State Manager Module - Manages UI expansion state
 */

class StateManager {
    constructor() {
        this.expandedTables = new Set();
        this.expandedUidColumns = new Set();
        this.expandedUidValues = new Set();
        this.expandedKeyColumns = new Set();
        this.expandedKeyValues = new Set();
        this.columnDiffContainers = {};
        this.uidContainers = {};
        this.uidValueContainers = {};
        this.comparisonContainers = {};
    }

    /**
     * Table expansion state management
     */
    expandTable(tableName) {
        this.expandedTables.add(tableName);
    }

    collapseTable(tableName) {
        this.expandedTables.delete(tableName);
        // Clean up related expansions
        const toDelete = Array.from(this.expandedUidColumns).filter(key => key.startsWith(tableName + ':'));
        toDelete.forEach(key => this.expandedUidColumns.delete(key));
    }

    isTableExpanded(tableName) {
        return this.expandedTables.has(tableName);
    }

    /**
     * UID column expansion state management
     */
    expandUidColumn(tableName, uidColumn) {
        const key = Utilities.createContainerKey(tableName, uidColumn);
        this.expandedUidColumns.add(key);
    }

    collapseUidColumn(tableName, uidColumn) {
        const key = Utilities.createContainerKey(tableName, uidColumn);
        this.expandedUidColumns.delete(key);
        // Clean up related expansions
        const toDelete = Array.from(this.expandedUidValues).filter(k => k.startsWith(key + ':'));
        toDelete.forEach(k => this.expandedUidValues.delete(k));
    }

    isUidColumnExpanded(tableName, uidColumn) {
        const key = Utilities.createContainerKey(tableName, uidColumn);
        return this.expandedUidColumns.has(key);
    }

    /**
     * UID value expansion state management
     */
    expandUidValue(tableName, uidColumn, uidValue) {
        const key = Utilities.createContainerKey(tableName, uidColumn, String(uidValue));
        this.expandedUidValues.add(key);
    }

    collapseUidValue(tableName, uidColumn, uidValue) {
        const key = Utilities.createContainerKey(tableName, uidColumn, String(uidValue));
        this.expandedUidValues.delete(key);
    }

    isUidValueExpanded(tableName, uidColumn, uidValue) {
        const key = Utilities.createContainerKey(tableName, uidColumn, String(uidValue));
        return this.expandedUidValues.has(key);
    }

    /**
     * KEY column expansion state management
     */
    expandKeyColumn(tableName, keyColumn) {
        const key = Utilities.createContainerKey(tableName, keyColumn);
        this.expandedKeyColumns.add(key);
    }

    collapseKeyColumn(tableName, keyColumn) {
        const key = Utilities.createContainerKey(tableName, keyColumn);
        this.expandedKeyColumns.delete(key);
        // Clean up related expansions
        const toDelete = Array.from(this.expandedKeyValues).filter(k => k.startsWith(key + ':'));
        toDelete.forEach(k => this.expandedKeyValues.delete(k));
    }

    isKeyColumnExpanded(tableName, keyColumn) {
        const key = Utilities.createContainerKey(tableName, keyColumn);
        return this.expandedKeyColumns.has(key);
    }

    /**
     * KEY value expansion state management
     */
    expandKeyValue(tableName, keyColumn, mappingUid) {
        const key = Utilities.createContainerKey(tableName, keyColumn, String(mappingUid));
        this.expandedKeyValues.add(key);
    }

    collapseKeyValue(tableName, keyColumn, mappingUid) {
        const key = Utilities.createContainerKey(tableName, keyColumn, String(mappingUid));
        this.expandedKeyValues.delete(key);
    }

    isKeyValueExpanded(tableName, keyColumn, mappingUid) {
        const key = Utilities.createContainerKey(tableName, keyColumn, String(mappingUid));
        return this.expandedKeyValues.has(key);
    }

    /**
     * Container reference management
     */
    setUidContainer(tableName, container) {
        this.uidContainers[tableName] = container;
    }

    getUidContainer(tableName) {
        return this.uidContainers[tableName];
    }

    setUidValueContainer(tableName, uidColumn, container) {
        const key = Utilities.createContainerKey(tableName, uidColumn);
        this.uidValueContainers[key] = container;
    }

    getUidValueContainer(tableName, uidColumn) {
        const key = Utilities.createContainerKey(tableName, uidColumn);
        return this.uidValueContainers[key];
    }

    setComparisonContainer(tableName, uidColumn, uidValue, container) {
        const key = Utilities.createContainerKey(tableName, uidColumn, String(uidValue));
        this.comparisonContainers[key] = container;
    }

    getComparisonContainer(tableName, uidColumn, uidValue) {
        const key = Utilities.createContainerKey(tableName, uidColumn, String(uidValue));
        return this.comparisonContainers[key];
    }

    setColumnDiffContainer(tableName, uidColumn, uidValue, container) {
        const key = Utilities.createContainerKey(tableName, uidColumn, String(uidValue));
        this.columnDiffContainers[key] = container;
    }

    getColumnDiffContainer(tableName, uidColumn, uidValue) {
        const key = Utilities.createContainerKey(tableName, uidColumn, String(uidValue));
        return this.columnDiffContainers[key];
    }

    isColumnDiffExpanded(tableName, uidColumn, uidValue) {
        const container = this.getColumnDiffContainer(tableName, uidColumn, uidValue);
        return container && !container.classList.contains('hidden');
    }

    /**
     * KEY column container management
     */
    setKeyValueContainer(tableName, keyColumn, container) {
        const key = Utilities.createContainerKey(tableName, keyColumn);
        this.keyValueContainers = this.keyValueContainers || {};
        this.keyValueContainers[key] = container;
    }

    getKeyValueContainer(tableName, keyColumn) {
        if (!this.keyValueContainers) this.keyValueContainers = {};
        const key = Utilities.createContainerKey(tableName, keyColumn);
        return this.keyValueContainers[key];
    }

    setKeyComparisonContainer(tableName, keyColumn, mappingUid, container) {
        if (!this.keyComparisonContainers) this.keyComparisonContainers = {};
        const key = Utilities.createContainerKey(tableName, keyColumn, String(mappingUid));
        this.keyComparisonContainers[key] = container;
    }

    getKeyComparisonContainer(tableName, keyColumn, mappingUid) {
        if (!this.keyComparisonContainers) this.keyComparisonContainers = {};
        const key = Utilities.createContainerKey(tableName, keyColumn, String(mappingUid));
        return this.keyComparisonContainers[key];
    }

    /**
     * Clear all containers for a table
     */
    clearTableContainers(tableName) {
        delete this.uidContainers[tableName];
        const toDelete = Array.from(Object.keys(this.uidValueContainers)).filter(key => key.startsWith(tableName + ':'));
        toDelete.forEach(key => delete this.uidValueContainers[key]);
    }

    /**
     * Clear comparison containers for a UID column
     * Called when re-rendering to remove orphaned container references
     */
    clearUidColumnComparisonContainers(tableName, uidColumn) {
        const prefix = Utilities.createContainerKey(tableName, uidColumn);
        const toDelete = Array.from(Object.keys(this.comparisonContainers)).filter(key => key.startsWith(prefix + ':'));
        toDelete.forEach(key => delete this.comparisonContainers[key]);
        
        // Also clear column diff containers
        const colDiffToDelete = Array.from(Object.keys(this.columnDiffContainers)).filter(key => key.startsWith(prefix + ':'));
        colDiffToDelete.forEach(key => delete this.columnDiffContainers[key]);
    }
}
