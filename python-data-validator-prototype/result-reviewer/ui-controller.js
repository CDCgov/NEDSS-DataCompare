/**
 * UI Controller Module - Event handling and interaction logic
 */

class UIController {
    constructor(dataManager, stateManager, filterEngine, uiRenderer, validationTabs = null, keyValidationRenderer = null) {
        this.dataManager = dataManager;
        this.stateManager = stateManager;
        this.filterEngine = filterEngine;
        this.uiRenderer = uiRenderer;
        this.validationTabs = validationTabs;
        this.keyValidationRenderer = keyValidationRenderer;
        this.currentSearchTerm = '';
        this.currentFilterType = 'all';
    }

    /**
     * Setup all event listeners
     */
    setupEventListeners() {
        this.setupSearchInput();
        this.setupFilterDropdown();
        this.setupDelegatedListeners();
    }

    /**
     * Setup search input listener
     */
    setupSearchInput() {
        const searchInput = document.getElementById('searchInput');
        if (searchInput) {
            searchInput.addEventListener('input', (e) => this.onSearchInput(e.target.value));
        }
    }

    /**
     * Setup filter dropdown
     */
    setupFilterDropdown() {
        const searchInput = document.getElementById('searchInput');
        if (!searchInput) return;

        const container = searchInput.parentElement;
        if (container.querySelector('#filterSelect')) return; // Already exists

        const filterSelect = document.createElement('select');
        filterSelect.id = 'filterSelect';
        filterSelect.className = 'px-3 py-2 text-sm border border-gray-300 rounded-md focus:outline-none bg-white';

        const options = [
            { value: 'all', text: 'All Tables' },
            { value: 'column-diff', text: 'Has Column Differences' },
            { value: 'record-mismatch', text: 'Record Count Mismatch' }
        ];

        options.forEach(opt => {
            const option = document.createElement('option');
            option.value = opt.value;
            option.textContent = opt.text;
            filterSelect.appendChild(option);
        });

        filterSelect.addEventListener('change', (e) => this.onFilterChanged(e.target.value));
        container.appendChild(filterSelect);
        this.currentFilterType = 'all';
    }

    /**
     * Setup delegated event listeners for dynamic content
     */
    setupDelegatedListeners() {
        const tableList = document.getElementById('table-list');
        if (!tableList) {
            console.error('[UI] table-list element not found!');
            return;
        }
        
        console.log('[UI] Setting up delegated listeners on table-list');

        // Table button clicks
        tableList.addEventListener('click', (e) => {
            const tableBtn = e.target.closest('[data-table-btn]');
            if (tableBtn) {
                const tableName = tableBtn.getAttribute('data-table-btn');
                this.onTableClicked(tableName);
            }

            // UID column button clicks
            const uidColBtn = e.target.closest('[data-uid-col-btn]');
            if (uidColBtn) {
                const key = uidColBtn.getAttribute('data-uid-col-btn');
                const [tableName, uidColumn] = key.split(':');
                this.onUidColumnClicked(tableName, uidColumn);
            }

            // UID value button clicks
            const uidValBtn = e.target.closest('[data-uid-val-btn]');
            if (uidValBtn) {
                const key = uidValBtn.getAttribute('data-uid-val-btn');
                const parts = key.split(':');
                const tableName = parts[0];
                const uidColumn = parts[1];
                const uidValue = parts.slice(2).join(':'); // Handle values with colons - already normalized to string
                this.onUidValueClicked(tableName, uidColumn, uidValue);
            }

            // Copy UID buttons
            const copyUidBtn = e.target.closest('[data-copy-uid]');
            if (copyUidBtn) {
                e.stopPropagation();
                const displayValue = copyUidBtn.previousElementSibling?.textContent?.replace(/.*• /, '');
                if (displayValue) {
                    Utilities.copyToClipboard(displayValue, copyUidBtn);
                }
            }

            // Column differences button clicks
            const colDiffBtn = e.target.closest('[data-col-diff-btn]');
            if (colDiffBtn) {
                const key = colDiffBtn.getAttribute('data-col-diff-btn');
                const parts = key.split(':');
                const tableName = parts[0];
                const uidColumn = parts[1];
                const uidValue = parts.slice(2).join(':');
                this.onColumnDifferencesClicked(tableName, uidColumn, uidValue);
            }

            // Copy SQL buttons
            const copySqlBtn = e.target.closest('[data-copy-sql]');
            if (copySqlBtn) {
                e.stopPropagation();
                const sqlCode = copySqlBtn.previousElementSibling?.textContent;
                if (sqlCode) {
                    Utilities.copyToClipboard(sqlCode, copySqlBtn);
                }
            }

            // KEY column button clicks
            const keyColBtn = e.target.closest('[data-key-col-btn]');
            if (keyColBtn) {
                const key = keyColBtn.getAttribute('data-key-col-btn');
                const [tableName, keyColumn] = key.split(':');
                this.onKeyColumnClicked(tableName, keyColumn);
            }

            // KEY value button clicks
            const keyValBtn = e.target.closest('[data-key-val-btn]');
            if (keyValBtn) {
                const key = keyValBtn.getAttribute('data-key-val-btn');
                const parts = key.split(':');
                const tableName = parts[0];
                const keyColumn = parts[1];
                const mappingUid = parts.slice(2).join(':');
                this.onKeyValueClicked(tableName, keyColumn, mappingUid);
            }

            // Copy KEY UID buttons
            const copyKeyUidBtn = e.target.closest('[data-copy-key-uid]');
            if (copyKeyUidBtn) {
                e.stopPropagation();
                const displayValue = copyKeyUidBtn.previousElementSibling?.textContent?.replace(/.*◆ /, '');
                if (displayValue) {
                    Utilities.copyToClipboard(displayValue, copyKeyUidBtn);
                }
            }
        });
    }

    /**
     * Handle search input
     */
    onSearchInput(searchTerm) {
        this.currentSearchTerm = searchTerm;
        this.applyFilters();
    }

    /**
     * Handle filter change
     */
    onFilterChanged(filterType) {
        this.currentFilterType = filterType;
        this.applyFilters();
    }

    /**
     * Apply combined search and filter (async)
     */
    async applyFilters() {
        try {
            const allTables = await this.dataManager.getTableNames();
            const filtered = await this.filterEngine.applyFilters(allTables, this.currentSearchTerm, this.currentFilterType);
            await this.uiRenderer.renderTableList(filtered, this.dataManager, this.filterEngine, this.stateManager);
        } catch (error) {
            console.error('Failed to apply filters:', error);
        }
    }

    /**
     * Handle table click (async)
     */
    async onTableClicked(tableName) {
        console.log(`[UI] Table clicked: ${tableName}`);
        console.log(`[UI] Is expanded? ${this.stateManager.isTableExpanded(tableName)}`);
        
        if (this.stateManager.isTableExpanded(tableName)) {
            console.log(`[UI] Collapsing table...`);
            this.stateManager.collapseTable(tableName);
            this.hideUidColumns(tableName);
        } else {
            console.log(`[UI] Expanding table...`);
            this.stateManager.expandTable(tableName);
            console.log(`[UI] Calling showUidColumns...`);
            await this.showUidColumns(tableName);
        }
    }

    /**
     * Show UID columns for a table (async)
     */
    async showUidColumns(tableName) {
        try {
            console.log(`[UI] showUidColumns called for: ${tableName}`);
            const container = this.stateManager.getUidContainer(tableName);
            console.log(`[UI] Container found: ${container ? 'YES' : 'NO'}`);
            if (!container) {
                console.error(`[UI] ERROR: No container found for table ${tableName}`);
                return;
            }

            console.log(`[UI] Rendering UID columns...`);
            await this.uiRenderer.renderUidColumns(tableName, this.dataManager, this.stateManager);
            console.log(`[UI] UID columns rendered`);
        } catch (error) {
            console.error('Failed to show UID columns:', error);
        }
    }

    /**
     * Hide UID columns for a table
     */
    hideUidColumns(tableName) {
        const container = this.stateManager.getUidContainer(tableName);
        if (container) {
            container.innerHTML = '';
            container.classList.add('hidden');
        }
        this.stateManager.collapseTable(tableName);
    }

    /**
     * Handle UID column click (async)
     */
    async onUidColumnClicked(tableName, uidColumn) {
        try {
            if (this.stateManager.isUidColumnExpanded(tableName, uidColumn)) {
                this.stateManager.collapseUidColumn(tableName, uidColumn);
                this.hideUidValues(tableName, uidColumn);
            } else {
                this.stateManager.expandUidColumn(tableName, uidColumn);
                await this.showUidValues(tableName, uidColumn);
            }
        } catch (error) {
            console.error('Failed to handle UID column click:', error);
        }
    }

    /**
     * Show UID values for a column (async)
     */
    async showUidValues(tableName, uidColumn) {
        try {
            const container = this.stateManager.getUidValueContainer(tableName, uidColumn);
            if (!container) return;

            await this.uiRenderer.renderUidValues(tableName, uidColumn, this.dataManager, this.filterEngine, this.stateManager);
        } catch (error) {
            console.error('Failed to show UID values:', error);
        }
    }

    /**
     * Hide UID values for a column
     */
    hideUidValues(tableName, uidColumn) {
        const container = this.stateManager.getUidValueContainer(tableName, uidColumn);
        if (container) {
            container.innerHTML = '';
            container.classList.add('hidden');
        }
    }

    /**
     * Handle UID value click (async)
     */
    async onUidValueClicked(tableName, uidColumn, uidValue) {
        try {
            if (uidValue === 'null') return; // Can't expand null values

            if (this.stateManager.isUidValueExpanded(tableName, uidColumn, uidValue)) {
                this.stateManager.collapseUidValue(tableName, uidColumn, uidValue);
                this.hideComparisonDetails(tableName, uidColumn, uidValue);
            } else {
                this.stateManager.expandUidValue(tableName, uidColumn, uidValue);
                await this.showComparisonDetails(tableName, uidColumn, uidValue);
            }
        } catch (error) {
            console.error('Failed to handle UID value click:', error);
        }
    }

    /**
     * Show comparison details (async)
     */
    async showComparisonDetails(tableName, uidColumn, uidValue) {
        try {
            const comparison = await this.dataManager.getComparisonData(tableName, uidColumn, uidValue);
            if (!comparison) {
                console.warn(`No comparison data found for ${tableName}:${uidColumn}:${uidValue}`);
                return;
            }

            const container = this.stateManager.getComparisonContainer(tableName, uidColumn, uidValue);
            if (!container) {
                console.warn(`No container found for ${tableName}:${uidColumn}:${uidValue}`, this.stateManager.comparisonContainers);
                return;
            }

            // Create details content
            const details = document.createElement('div');
            details.className = 'mt-2 ml-12 bg-gray-50 border-l-4 border-gray-300 rounded-sm p-3 space-y-2';

            // RDB Count
            const rdbRow = document.createElement('div');
            rdbRow.className = 'flex justify-between text-xs pb-1 border-b border-gray-200';
            rdbRow.innerHTML = `<span class="font-semibold text-gray-700">RDB Count:</span> <span class="font-mono text-gray-600">${comparison.rdb_count}</span>`;
            details.appendChild(rdbRow);

            // RDB Modern Count
            const modernRow = document.createElement('div');
            modernRow.className = 'flex justify-between text-xs pb-1 border-b border-gray-200';
            modernRow.innerHTML = `<span class="font-semibold text-gray-700">RDB Modern Count:</span> <span class="font-mono text-gray-600">${comparison.rdb_modern_count}</span>`;
            details.appendChild(modernRow);

            // Match status
            const matchRow = document.createElement('div');
            matchRow.className = 'flex justify-between text-xs pb-1 border-b border-gray-200';
            matchRow.innerHTML = `<span class="font-semibold text-gray-700">Record Counts Match:</span> <span class="text-gray-600 font-mono">${comparison.record_counts_match}</span>`;
            details.appendChild(matchRow);

            // Has Differences
            const diffRow = document.createElement('div');
            diffRow.className = 'flex justify-between text-xs pb-1 border-b border-gray-200';
            diffRow.innerHTML = `<span class="font-semibold text-gray-700">Has Differences:</span> <span class="text-gray-600 font-mono">${comparison.has_differences}</span>`;
            details.appendChild(diffRow);

            // Column Differences
            const hasColDiff = this.filterEngine.hasColumnDifferences(comparison);
            const columnDiffCount = this.filterEngine.getColumnDiffCount(comparison);
            const columnDiffRow = document.createElement('div');
            columnDiffRow.className = 'flex items-center justify-between text-xs pt-2';

            const columnDiffBtn = document.createElement('button');
            columnDiffBtn.className = 'px-2 py-1 bg-red-100 border border-red-400 rounded-sm text-xs font-semibold text-red-800 hover:bg-red-200 active:bg-red-300 transition-colors';
            columnDiffBtn.textContent = columnDiffCount;
            columnDiffBtn.setAttribute('data-col-diff-btn', `${tableName}:${uidColumn}:${uidValue}`);

            if (!hasColDiff) {
                columnDiffBtn.style.opacity = '0.6';
            }

            columnDiffRow.innerHTML = `<span class="font-semibold text-gray-700">Records with Column Differences:</span>`;
            columnDiffRow.appendChild(columnDiffBtn);
            details.appendChild(columnDiffRow);

            // Create container for column differences
            const columnDiffContainer = document.createElement('div');
            columnDiffContainer.className = 'hidden';
            columnDiffContainer.setAttribute('data-col-diff-container', `${tableName}:${uidColumn}:${uidValue}`);

            details.appendChild(columnDiffContainer);
            this.stateManager.setColumnDiffContainer(tableName, uidColumn, uidValue, columnDiffContainer);

            container.appendChild(details);
            container.classList.remove('hidden');
        } catch (error) {
            console.error('Failed to show comparison details:', error);
        }
    }

    /**
     * Hide comparison details
     */
    hideComparisonDetails(tableName, uidColumn, uidValue) {
        const container = this.stateManager.getComparisonContainer(tableName, uidColumn, uidValue);
        if (container) {
            container.innerHTML = '';
            container.classList.add('hidden');
        }
    }

    /**
     * Handle column differences click
     */
    onColumnDifferencesClicked(tableName, uidColumn, uidValue) {
        if (this.stateManager.isColumnDiffExpanded(tableName, uidColumn, uidValue)) {
            this.hideColumnDifferences(tableName, uidColumn, uidValue);
        } else {
            this.showColumnDifferences(tableName, uidColumn, uidValue).catch(error => {
                console.error('[UI] Error showing column differences:', error);
            });
        }
    }

    /**
     * Show column differences
     */
    async showColumnDifferences(tableName, uidColumn, uidValue) {
        try {
            console.log(`[UI] showColumnDifferences called for: ${tableName}.${uidColumn}.${uidValue}`);
            const comparison = await this.dataManager.getComparisonData(tableName, uidColumn, uidValue);
            if (!comparison) {
                console.log(`[UI] No comparison data found`);
                return;
            }

            const key = Utilities.createContainerKey(tableName, uidColumn, uidValue);
            const container = this.stateManager.getColumnDiffContainer(tableName, uidColumn, uidValue);
            if (!container) {
                console.error(`[UI] No container found for column diff`);
                return;
            }

            const columnDifferencesData = this.uiRenderer.getColumnDifferences(comparison);

            if (!columnDifferencesData || columnDifferencesData.length === 0) {
                container.innerHTML = '<div class="p-2 text-xs text-gray-600">No column differences found</div>';
                container.classList.remove('hidden');
                return;
            }

            container.innerHTML = '';

            // Column differences list
            const columnDiffList = document.createElement('div');
            columnDiffList.className = 'mt-3 ml-14 space-y-3';

            for (const record of columnDifferencesData) {
                const recordDiv = document.createElement('div');
                recordDiv.className = 'bg-white border border-red-200 rounded-sm p-3 text-xs';

                const indexDiv = document.createElement('div');
                indexDiv.className = 'font-semibold text-red-800 mb-2 pb-2 border-b border-red-200';
                indexDiv.textContent = `Record #${record.record_index}`;
                recordDiv.appendChild(indexDiv);

                const columnsDiv = document.createElement('div');
                columnsDiv.className = 'space-y-2';

                for (const diff of record.column_differences) {
                    const diffDiv = document.createElement('div');
                    diffDiv.className = 'bg-gray-50 border-l-3 border-red-400 p-2 font-mono text-xs';

                    const columnName = document.createElement('div');
                    columnName.className = 'font-semibold text-gray-800';
                    columnName.textContent = diff.column;
                    diffDiv.appendChild(columnName);

                    const rdbValueSpan = document.createElement('div');
                    rdbValueSpan.className = 'text-gray-700 mt-1';
                    const rdbVal = Utilities.formatDisplayValue(diff.rdb_value);
                    rdbValueSpan.textContent = `RDB: ${rdbVal}`;
                    diffDiv.appendChild(rdbValueSpan);

                    const rdbModernValueSpan = document.createElement('div');
                    rdbModernValueSpan.className = 'text-gray-700 mt-1';
                    const modernVal = Utilities.formatDisplayValue(diff.rdb_modern_value);
                    rdbModernValueSpan.textContent = `RDB_MODERN: ${modernVal}`;
                    diffDiv.appendChild(rdbModernValueSpan);

                    columnsDiv.appendChild(diffDiv);
                }

                recordDiv.appendChild(columnsDiv);
                columnDiffList.appendChild(recordDiv);
            }

            container.appendChild(columnDiffList);

            // Generate and render SQL snippet
            const diffColumns = new Set();
            for (const record of columnDifferencesData) {
                for (const diff of record.column_differences) {
                    diffColumns.add(diff.column);
                }
            }

            const sqlSnippet = Utilities.generateSqlQuery(tableName, uidColumn, uidValue, diffColumns);

            const sqlSection = document.createElement('div');
            sqlSection.className = 'mt-3 ml-14 bg-blue-50 border border-blue-200 rounded-sm p-3';

            const sqlTitle = document.createElement('div');
            sqlTitle.className = 'font-semibold text-blue-800 text-xs mb-2';
            sqlTitle.textContent = 'SQL Query for Differing Columns:';
            sqlSection.appendChild(sqlTitle);

            const sqlContainer = document.createElement('div');
            sqlContainer.className = 'flex gap-2 items-start';

            const sqlCode = document.createElement('pre');
            sqlCode.className = 'flex-1 bg-white border border-blue-300 rounded-sm p-2 text-xs font-mono text-gray-700 overflow-x-auto';
            sqlCode.textContent = sqlSnippet;
            sqlContainer.appendChild(sqlCode);

            const sqlCopyBtn = document.createElement('button');
            sqlCopyBtn.className = 'px-2 py-2 bg-blue-100 border border-blue-400 rounded-sm text-xs hover:bg-blue-200 active:bg-blue-300 transition-colors whitespace-nowrap';
            sqlCopyBtn.textContent = '📋';
            sqlCopyBtn.title = 'Copy SQL query';
            sqlCopyBtn.setAttribute('data-copy-sql', `${tableName}:${uidColumn}:${uidValue}`);

            sqlContainer.appendChild(sqlCopyBtn);
            sqlSection.appendChild(sqlContainer);
            container.appendChild(sqlSection);

            container.classList.remove('hidden');
            this.stateManager.expandColumnDiff(tableName, uidColumn, uidValue);
        } catch (error) {
            console.error(`[UI] Exception in showColumnDifferences:`, error);
            console.error(error.stack);
        }
    }

    /**
     * Hide column differences
     */
    hideColumnDifferences(tableName, uidColumn, uidValue) {
        const container = this.stateManager.getColumnDiffContainer(tableName, uidColumn, uidValue);
        if (container) {
            container.innerHTML = '';
            container.classList.add('hidden');
        }
    }

    /**
     * Handle KEY column click (async) - Toggle expansion
     */
    async onKeyColumnClicked(tableName, keyColumn) {
        try {
            if (this.stateManager.isKeyColumnExpanded(tableName, keyColumn)) {
                this.stateManager.collapseKeyColumn(tableName, keyColumn);
                this.hideKeyValues(tableName, keyColumn);
            } else {
                this.stateManager.expandKeyColumn(tableName, keyColumn);
                await this.showKeyValues(tableName, keyColumn);
            }
        } catch (error) {
            console.error('Failed to handle KEY column click:', error);
        }
    }

    /**
     * Show KEY values for a column (async)
     */
    async showKeyValues(tableName, keyColumn) {
        try {
            const container = this.stateManager.getKeyValueContainer(tableName, keyColumn);
            if (!container) {
                console.warn(`No container found for KEY values: ${tableName}:${keyColumn}`);
                return;
            }

            container.innerHTML = '';
            container.classList.remove('hidden');

            await this.uiRenderer.renderKeyValues(tableName, keyColumn, container, this.dataManager, this.stateManager);
        } catch (error) {
            console.error('Failed to show KEY values:', error);
        }
    }

    /**
     * Hide KEY values for a column
     */
    hideKeyValues(tableName, keyColumn) {
        const container = this.stateManager.getKeyValueContainer(tableName, keyColumn);
        if (container) {
            container.innerHTML = '';
            container.classList.add('hidden');
        }
    }

    /**
     * Handle KEY value click (async) - Toggle comparison details
     */
    async onKeyValueClicked(tableName, keyColumn, mappingUid) {
        try {
            if (mappingUid === 'null') return; // Can't expand null values

            if (this.stateManager.isKeyValueExpanded(tableName, keyColumn, mappingUid)) {
                this.stateManager.collapseKeyValue(tableName, keyColumn, mappingUid);
                this.hideKeyComparisonDetails(tableName, keyColumn, mappingUid);
            } else {
                this.stateManager.expandKeyValue(tableName, keyColumn, mappingUid);
                await this.showKeyComparisonDetails(tableName, keyColumn, mappingUid);
            }
        } catch (error) {
            console.error('Failed to handle KEY value click:', error);
        }
    }

    /**
     * Show KEY comparison details (async)
     */
    async showKeyComparisonDetails(tableName, keyColumn, mappingUid) {
        try {
            // Fetch the KEY column data
            const keyValues = await this.dataManager.getKeyValuesForColumn(tableName, keyColumn);
            if (!keyValues) {
                console.warn(`No KEY values found for ${tableName}:${keyColumn}`);
                return;
            }

            // Find the specific mapping UID record
            const keyRecord = keyValues.find(record => record.mapping_uid === mappingUid);
            if (!keyRecord) {
                console.warn(`Mapping UID not found: ${mappingUid}`);
                return;
            }

            const comparison = keyRecord.comparison;
            if (!comparison) {
                console.warn(`No comparison data for mapping UID: ${mappingUid}`);
                return;
            }

            const container = this.stateManager.getKeyComparisonContainer(tableName, keyColumn, mappingUid);
            if (!container) {
                console.warn(`No container found for KEY comparison: ${tableName}:${keyColumn}:${mappingUid}`);
                return;
            }

            // Create details content (similar to UID but adapted for KEY)
            const details = document.createElement('div');
            details.className = 'mt-2 ml-12 bg-blue-50 border-l-4 border-blue-300 rounded-sm p-3 space-y-2';

            // RDB Count
            const rdbRow = document.createElement('div');
            rdbRow.className = 'flex justify-between text-xs pb-1 border-b border-blue-200';
            rdbRow.innerHTML = `<span class="font-semibold text-blue-700">RDB Count:</span> <span class="font-mono text-blue-600">${comparison.rdb_count}</span>`;
            details.appendChild(rdbRow);

            // RDB Modern Count
            const modernRow = document.createElement('div');
            modernRow.className = 'flex justify-between text-xs pb-1 border-b border-blue-200';
            modernRow.innerHTML = `<span class="font-semibold text-blue-700">RDB Modern Count:</span> <span class="font-mono text-blue-600">${comparison.rdb_modern_count}</span>`;
            details.appendChild(modernRow);

            // Match status
            const matchRow = document.createElement('div');
            matchRow.className = 'flex justify-between text-xs pb-1 border-b border-blue-200';
            matchRow.innerHTML = `<span class="font-semibold text-blue-700">Record Counts Match:</span> <span class="text-blue-600 font-mono">${comparison.record_counts_match}</span>`;
            details.appendChild(matchRow);

            // Has Differences
            const diffRow = document.createElement('div');
            diffRow.className = 'flex justify-between text-xs pb-1 border-b border-blue-200';
            diffRow.innerHTML = `<span class="font-semibold text-blue-700">Has Differences:</span> <span class="text-blue-600 font-mono">${comparison.has_differences}</span>`;
            details.appendChild(diffRow);

            // Column Differences
            const hasColDiff = this.filterEngine.hasColumnDifferences(comparison);
            const columnDiffCount = this.filterEngine.getColumnDiffCount(comparison);
            const columnDiffRow = document.createElement('div');
            columnDiffRow.className = 'flex items-center justify-between text-xs pt-2';

            const columnDiffBtn = document.createElement('button');
            columnDiffBtn.className = 'px-2 py-1 bg-blue-100 border border-blue-400 rounded-sm text-xs font-semibold text-blue-800 hover:bg-blue-200 active:bg-blue-300 transition-colors';
            columnDiffBtn.textContent = columnDiffCount;
            columnDiffBtn.setAttribute('data-col-diff-key-btn', `${tableName}:${keyColumn}:${mappingUid}`);

            if (!hasColDiff) {
                columnDiffBtn.style.opacity = '0.6';
            }

            columnDiffRow.innerHTML = `<span class="font-semibold text-blue-700">Records with Column Differences:</span>`;
            columnDiffRow.appendChild(columnDiffBtn);
            details.appendChild(columnDiffRow);

            // Create container for column differences
            const columnDiffContainer = document.createElement('div');
            columnDiffContainer.className = 'hidden';
            columnDiffContainer.setAttribute('data-col-diff-key-container', `${tableName}:${keyColumn}:${mappingUid}`);

            details.appendChild(columnDiffContainer);
            container.appendChild(details);
            container.classList.remove('hidden');
        } catch (error) {
            console.error('Failed to show KEY comparison details:', error);
        }
    }

    /**
     * Hide KEY comparison details
     */
    hideKeyComparisonDetails(tableName, keyColumn, mappingUid) {
        const container = this.stateManager.getKeyComparisonContainer(tableName, keyColumn, mappingUid);
        if (container) {
            container.innerHTML = '';
            container.classList.add('hidden');
        }
    }
}
