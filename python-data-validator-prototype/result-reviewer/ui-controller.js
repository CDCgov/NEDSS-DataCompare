/**
 * UI Controller Module - Event handling and interaction logic
 */

class UIController {
    constructor(dataManager, stateManager, filterEngine, uiRenderer) {
        this.dataManager = dataManager;
        this.stateManager = stateManager;
        this.filterEngine = filterEngine;
        this.uiRenderer = uiRenderer;
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
        const tableList = document.getElementById('tableList');
        if (!tableList) return;

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
     * Apply combined search and filter
     */
    applyFilters() {
        const allTables = this.dataManager.getTableNames();
        const filtered = this.filterEngine.applyFilters(allTables, this.currentSearchTerm, this.currentFilterType);
        this.uiRenderer.renderTableList(filtered, this.dataManager, this.filterEngine, this.stateManager);
    }

    /**
     * Handle table click
     */
    onTableClicked(tableName) {
        if (this.stateManager.isTableExpanded(tableName)) {
            this.stateManager.collapseTable(tableName);
            this.hideUidColumns(tableName);
        } else {
            this.stateManager.expandTable(tableName);
            this.showUidColumns(tableName);
        }
    }

    /**
     * Show UID columns for a table
     */
    showUidColumns(tableName) {
        const container = this.stateManager.getUidContainer(tableName);
        if (!container) return;

        this.uiRenderer.renderUidColumns(tableName, this.dataManager, this.stateManager);
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
     * Handle UID column click
     */
    onUidColumnClicked(tableName, uidColumn) {
        if (this.stateManager.isUidColumnExpanded(tableName, uidColumn)) {
            this.stateManager.collapseUidColumn(tableName, uidColumn);
            this.hideUidValues(tableName, uidColumn);
        } else {
            this.stateManager.expandUidColumn(tableName, uidColumn);
            this.showUidValues(tableName, uidColumn);
        }
    }

    /**
     * Show UID values for a column
     */
    showUidValues(tableName, uidColumn) {
        const container = this.stateManager.getUidValueContainer(tableName, uidColumn);
        if (!container) return;

        this.uiRenderer.renderUidValues(tableName, uidColumn, this.dataManager, this.filterEngine, this.stateManager);
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
     * Handle UID value click
     */
    onUidValueClicked(tableName, uidColumn, uidValue) {
        if (uidValue === 'null') return; // Can't expand null values

        if (this.stateManager.isUidValueExpanded(tableName, uidColumn, uidValue)) {
            this.stateManager.collapseUidValue(tableName, uidColumn, uidValue);
            this.hideComparisonDetails(tableName, uidColumn, uidValue);
        } else {
            this.stateManager.expandUidValue(tableName, uidColumn, uidValue);
            this.showComparisonDetails(tableName, uidColumn, uidValue);
        }
    }

    /**
     * Show comparison details
     */
    showComparisonDetails(tableName, uidColumn, uidValue) {
        const comparison = this.dataManager.getComparisonData(tableName, uidColumn, uidValue);
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
            this.showColumnDifferences(tableName, uidColumn, uidValue);
        }
    }

    /**
     * Show column differences
     */
    showColumnDifferences(tableName, uidColumn, uidValue) {
        const comparison = this.dataManager.getComparisonData(tableName, uidColumn, uidValue);
        if (!comparison) return;

        const key = Utilities.createContainerKey(tableName, uidColumn, uidValue);
        const container = this.stateManager.getColumnDiffContainer(tableName, uidColumn, uidValue);
        if (!container) return;

        const columnDifferencesData = this.dataManager.getColumnDifferences(comparison);

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
}
