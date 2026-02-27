/**
 * UI Renderer Module - Pure DOM rendering (no event listeners)
 */

class UIRenderer {
    /**
     * Extract column differences from comparison object
     */
    getColumnDifferences(comparison) {
        if (!comparison) return [];
        
        // Use column_differences if present (new structure)
        if (comparison.column_differences && Array.isArray(comparison.column_differences)) {
            return comparison.column_differences;
        }
        
        // Old structure compatibility
        if (comparison.discrepant_records && Array.isArray(comparison.discrepant_records)) {
            return comparison.discrepant_records;
        }
        
        return [];
    }

    /**
     * Render the entire table list (async)
     */
    async renderTableList(tables, dataManager, filterEngine, stateManager) {
        const listContainer = document.getElementById('table-list');
        listContainer.innerHTML = '';
        // Clear all containers from state manager
        stateManager.uidContainers = {};
        stateManager.uidValueContainers = {};
        stateManager.comparisonContainers = {};
        stateManager.columnDiffContainers = {};

        for (const tableName of tables) {
            await this.renderTableRow(tableName, listContainer, dataManager, filterEngine, stateManager);
        }
    }

    /**
     * Render a single table row with button and container
     */
    async renderTableRow(tableName, parentContainer, dataManager, filterEngine, stateManager) {
        // Create table row container
        const tableRow = document.createElement('div');
        tableRow.className = 'flex flex-col';
        tableRow.dataset.table = tableName;

        // Create table button
        const tableBtn = document.createElement('button');
        tableBtn.className = 'px-4 py-3 bg-gray-100 border border-gray-300 rounded-md text-sm text-left hover:bg-gray-200 active:bg-gray-300 transition-colors flex items-center gap-2';
        tableBtn.setAttribute('data-table-btn', tableName);

        // Table name span
        const tableNameSpan = document.createElement('span');
        tableNameSpan.className = 'flex-1';
        tableNameSpan.textContent = tableName;
        tableBtn.appendChild(tableNameSpan);

        // Add badges
        if (await filterEngine.hasTableColumnDifferences(tableName)) {
            tableBtn.appendChild(Utilities.createBadge('Col Diff', 'col-diff'));
        }

        if (await filterEngine.hasTableRecordMismatch(tableName)) {
            tableBtn.appendChild(Utilities.createBadge('Rec Mismatch', 'record-mismatch'));
        }

        tableRow.appendChild(tableBtn);

        // Create UID columns container
        const uidContainer = document.createElement('div');
        uidContainer.className = 'hidden flex flex-col gap-0.5 mt-1 ml-5';
        uidContainer.dataset.table = tableName;

        tableRow.appendChild(uidContainer);
        stateManager.setUidContainer(tableName, uidContainer);

        parentContainer.appendChild(tableRow);
    }

    /**
     * Render UID columns for a table (async)
     */
    async renderUidColumns(tableName, dataManager, stateManager) {
        console.log(`[Renderer] renderUidColumns called for: ${tableName}`);
        const container = stateManager.getUidContainer(tableName);
        console.log(`[Renderer] Container found: ${container ? 'YES' : 'NO'}`);
        if (!container) {
            console.error(`[Renderer] ERROR: Container not found for ${tableName}`);
            return;
        }

        try {
            console.log(`[Renderer] Calling dataManager.getUidColumnsForTable...`);
            const uidColumns = await dataManager.getUidColumnsForTable(tableName);
            console.log(`[Renderer] UID columns for ${tableName}:`, uidColumns);
            
            // Also get KEY columns
            const keyColumns = await dataManager.getKeyColumnsForTable(tableName);
            console.log(`[Renderer] KEY columns for ${tableName}:`, keyColumns);
            
            container.innerHTML = '';

            if ((!uidColumns || uidColumns.length === 0) && (!keyColumns || keyColumns.length === 0)) {
                console.log(`[Renderer] No UID or KEY columns found, skipping render`);
                container.classList.remove('hidden');
                return;
            }

            // Render UID columns
            for (const uidCol of uidColumns) {
                console.log(`[Renderer] Rendering UID column: ${uidCol}`);
                this.renderUidColumnRow(tableName, uidCol, container, stateManager);
            }

            // Render KEY columns
            for (const keyCol of keyColumns) {
                console.log(`[Renderer] Rendering KEY column: ${keyCol}`);
                await this.renderKeyColumnRow(tableName, keyCol, container, dataManager, stateManager);
            }

            console.log(`[Renderer] Removing hidden class from container`);
            container.classList.remove('hidden');
            console.log(`[Renderer] Container class after: ${container.className}`);
        } catch (error) {
            console.error(`[Renderer] EXCEPTION in renderUidColumns for ${tableName}:`, error);
            console.error(error.stack);
        }
    }

    /**
     * Render a single UID column row
     */
    renderUidColumnRow(tableName, uidCol, parentContainer, stateManager) {
        // Create UID column row
        const uidRow = document.createElement('div');
        uidRow.className = 'flex flex-col';
        uidRow.dataset.table = tableName;
        uidRow.dataset.column = uidCol;

        // Create UID column button
        const uidBtn = document.createElement('button');
        uidBtn.className = 'px-3 py-2 bg-gray-50 border border-gray-200 rounded-md text-xs text-gray-600 text-left hover:bg-gray-100 active:bg-gray-200 transition-colors';
        uidBtn.textContent = `→ ${uidCol}`;
        uidBtn.setAttribute('data-uid-col-btn', `${tableName}:${uidCol}`);

        uidRow.appendChild(uidBtn);

        // Create container for UID values
        const uidValueContainer = document.createElement('div');
        uidValueContainer.className = 'hidden flex flex-col gap-0.5 mt-1 ml-5';
        uidValueContainer.dataset.table = tableName;
        uidValueContainer.dataset.column = uidCol;

        uidRow.appendChild(uidValueContainer);
        stateManager.setUidValueContainer(tableName, uidCol, uidValueContainer);

        parentContainer.appendChild(uidRow);
    }

    /**
     * Render a single KEY column row
     */
    async renderKeyColumnRow(tableName, keyCol, parentContainer, dataManager, stateManager) {
        try {
            // Fetch mapping information for this key column
            const keyData = await dataManager.getKeyColumnMappingInfo(tableName, keyCol);
            
            // Create KEY column row
            const keyRow = document.createElement('div');
            keyRow.className = 'flex flex-col';
            keyRow.dataset.table = tableName;
            keyRow.dataset.column = keyCol;
            keyRow.dataset.validationType = 'key';

            // Create KEY column button - styled differently from UID
            const keyBtn = document.createElement('button');
            keyBtn.className = 'px-3 py-2 bg-blue-50 border border-blue-300 rounded-md text-xs text-blue-700 text-left hover:bg-blue-100 active:bg-blue-200 transition-colors font-semibold';
            keyBtn.textContent = `◆ ${keyCol}`;
            keyBtn.setAttribute('data-key-col-btn', `${tableName}:${keyCol}`);

            keyRow.appendChild(keyBtn);

            // Create container for KEY mapping UIDs
            const keyMappingContainer = document.createElement('div');
            keyMappingContainer.className = 'hidden flex flex-col gap-0.5 mt-1 ml-5 bg-blue-50 border border-blue-100 rounded-md p-2';
            keyMappingContainer.dataset.table = tableName;
            keyMappingContainer.dataset.column = keyCol;

            // Add mapping info display
            if (keyData && keyData.mapping_table) {
                const infoDiv = document.createElement('div');
                infoDiv.className = 'text-xs text-blue-700 italic mb-2 pb-2 border-b border-blue-200';
                infoDiv.innerHTML = `
                    <div><strong>Mapping Table:</strong> ${keyData.mapping_table}</div>
                    <div><strong>Mapping UID Column:</strong> ${keyData.mapping_uid_column}</div>
                `;
                keyMappingContainer.appendChild(infoDiv);
            }

            keyRow.appendChild(keyMappingContainer);
            stateManager.setKeyValueContainer(tableName, keyCol, keyMappingContainer);

            parentContainer.appendChild(keyRow);
        } catch (error) {
            console.error(`[Renderer] Error rendering key column ${tableName}:${keyCol}:`, error);
        }
    }

    /**
     * Render KEY mapping UIDs for a column (async)
     */
    async renderKeyValues(tableName, keyColumn, dataManager, stateManager) {
        const container = stateManager.getKeyValueContainer(tableName, keyColumn);
        if (!container) return;

        try {
            const keyValues = await dataManager.getKeyValuesForColumn(tableName, keyColumn);
            const keyData = await dataManager.getKeyColumnMappingInfo(tableName, keyColumn);
            
            // Find the info div (it's already in the container)
            const existingInfo = container.querySelector('[class*="border-b-blue"]');
            if (existingInfo) {
                // Clear everything after the info div
                const children = Array.from(container.children);
                const infoIndex = children.indexOf(existingInfo);
                for (let i = children.length - 1; i > infoIndex; i--) {
                    children[i].remove();
                }
            }

            for (const item of keyValues) {
                this.renderKeyValueRow(tableName, keyColumn, item, container, stateManager, keyData);
            }

            container.classList.remove('hidden');
        } catch (error) {
            console.error(`Failed to render KEY values for ${tableName}:${keyColumn}:`, error);
        }
    }

    /**
     * Render a single KEY mapping UID row
     */
    renderKeyValueRow(tableName, keyColumn, item, parentContainer, stateManager, keyData) {
        const mappingUid = item.mapping_uid;
        const mappingUidKey = String(mappingUid);
        const displayValue = Utilities.formatDisplayValue(mappingUid);
        const comparison = item.comparison;

        // Create KEY value row
        const valueRow = document.createElement('div');
        valueRow.className = 'flex flex-col';

        // Create container for value and copy button
        const valueContainer = document.createElement('div');
        valueContainer.className = 'flex items-center gap-1';

        // Create KEY value button  
        const valueBtn = document.createElement('button');
        valueBtn.className = 'flex-1 px-3 py-2 rounded-sm text-xs text-left hover:bg-blue-100 active:bg-blue-200 transition-colors font-mono bg-white border border-blue-100';
        valueBtn.setAttribute('data-key-val-btn', `${tableName}:${keyColumn}:${mappingUidKey}`);
        valueBtn.textContent = `    ◆ ${displayValue}`;

        // Highlight if has differences
        if (comparison && comparison.has_differences) {
            valueBtn.className = 'flex-1 px-3 py-2 rounded-sm text-xs text-left font-mono bg-red-100 border border-red-400 text-red-800 hover:bg-red-200 active:bg-red-300 transition-colors font-bold';
        }

        valueContainer.appendChild(valueBtn);

        // Create copy button
        const copyBtn = document.createElement('button');
        copyBtn.className = 'px-2 py-2 bg-blue-100 border border-blue-300 rounded-sm text-xs hover:bg-blue-200 active:bg-blue-300 transition-colors';
        copyBtn.textContent = '📋';
        copyBtn.title = 'Copy mapping UID';
        copyBtn.setAttribute('data-copy-key-uid', `${tableName}:${keyColumn}:${mappingUidKey}`);

        valueContainer.appendChild(copyBtn);
        valueRow.appendChild(valueContainer);

        // Create container for KEY value comparison details (includes mapping info and comparison)
        const comparisonContainer = document.createElement('div');
        comparisonContainer.className = 'hidden mt-2 ml-10';
        const containerKey = Utilities.createContainerKey(tableName, keyColumn, mappingUidKey);
        comparisonContainer.setAttribute('data-key-comparison-container', containerKey);

        // Add mapping info to comparison container
        if (keyData && keyData.mapping_table) {
            const mappingInfo = document.createElement('div');
            mappingInfo.className = 'bg-blue-50 border border-blue-200 rounded-sm p-2 mb-2 text-xs text-blue-700';
            mappingInfo.innerHTML = `
                <div class="font-semibold mb-1">Mapping Information:</div>
                <div class="flex justify-between pb-1"><span>Mapping Table:</span> <span class="font-mono">${keyData.mapping_table}</span></div>
                <div class="flex justify-between"><span>Mapping UID Column:</span> <span class="font-mono">${keyData.mapping_uid_column}</span></div>
            `;
            comparisonContainer.appendChild(mappingInfo);
        }

        valueRow.appendChild(comparisonContainer);
        stateManager.setKeyComparisonContainer(tableName, keyColumn, mappingUidKey, comparisonContainer);

        parentContainer.appendChild(valueRow);
    }

    /**
     * Render UID values for a column (async)
     */
    async renderUidValues(tableName, uidColumn, dataManager, filterEngine, stateManager) {
        const container = stateManager.getUidValueContainer(tableName, uidColumn);
        if (!container) return;

        try {
            // Clear old orphaned container references from state before clearing DOM
            stateManager.clearUidColumnComparisonContainers(tableName, uidColumn);

            const uidValues = await dataManager.getUidValuesForColumn(tableName, uidColumn);
            container.innerHTML = '';

            for (const item of uidValues) {
                this.renderUidValueRow(tableName, uidColumn, item, container, dataManager, filterEngine, stateManager);
            }

            container.classList.remove('hidden');
        } catch (error) {
            console.error(`Failed to render UID values for ${tableName}:${uidColumn}:`, error);
        }
    }

    /**
     * Render a single UID value row
     */
    renderUidValueRow(tableName, uidColumn, item, parentContainer, dataManager, filterEngine, stateManager) {
        const uidValue = item.uid_value;
        // Normalize UID value to string for consistent key generation
        const uidValueKey = String(uidValue);
        const displayValue = Utilities.formatDisplayValue(uidValue);
        const comparison = item.comparison;

        // Create UID value row
        const valueRow = document.createElement('div');
        valueRow.className = 'flex flex-col';

        // Create container for value and copy button
        const valueContainer = document.createElement('div');
        valueContainer.className = 'flex items-center gap-1';

        // Create UID value button
        const valueBtn = document.createElement('button');
        valueBtn.className = 'flex-1 px-3 py-2 rounded-sm text-xs text-left hover:bg-gray-50 active:bg-gray-100 transition-colors font-mono';
        valueBtn.setAttribute('data-uid-val-btn', `${tableName}:${uidColumn}:${uidValueKey}`);
        valueBtn.textContent = `    • ${displayValue}`;

        // Apply status-based styling
        const status = filterEngine.getUidValueStatus(uidValue, comparison);
        this.applyUidValueStyling(valueBtn, status);

        // Only make it clickable if UID value is not null
        if (uidValue !== null) {
            valueBtn.style.cursor = 'pointer';
        } else {
            valueBtn.style.opacity = '0.6';
        }

        valueContainer.appendChild(valueBtn);

        // Create copy button
        if (uidValue !== null) {
            const copyBtn = document.createElement('button');
            copyBtn.className = 'px-2 py-2 bg-gray-100 border border-gray-300 rounded-sm text-xs hover:bg-gray-200 active:bg-gray-300 transition-colors';
            copyBtn.textContent = '📋';
            copyBtn.title = 'Copy UID value';
            copyBtn.setAttribute('data-copy-uid', `${tableName}:${uidColumn}:${uidValueKey}`);

            valueContainer.appendChild(copyBtn);
        }

        valueRow.appendChild(valueContainer);

        // Create container for comparison details
        const comparisonContainer = document.createElement('div');
        comparisonContainer.className = 'hidden';
        const containerKey = Utilities.createContainerKey(tableName, uidColumn, uidValueKey);
        comparisonContainer.setAttribute('data-comparison-container', containerKey);

        valueRow.appendChild(comparisonContainer);
        stateManager.setComparisonContainer(tableName, uidColumn, uidValueKey, comparisonContainer);

        parentContainer.appendChild(valueRow);
    }

    /**
     * Apply styling based on UID value status
     */
    applyUidValueStyling(button, status) {
        const baseClass = 'bg-white border border-gray-100';
        const statusClasses = {
            'match': 'bg-green-100 border border-green-400 text-green-800',
            'column-diff': 'bg-red-100 border border-red-400 text-red-800',
            'record-mismatch': 'bg-yellow-100 border border-yellow-400 text-yellow-800',
            'null': 'bg-white border border-gray-100 text-gray-700',
            'unknown': 'bg-white border border-gray-100 text-gray-700'
        };

        button.className = `flex-1 px-3 py-2 rounded-sm text-xs text-left transition-colors font-mono ${statusClasses[status] || baseClass}`;
    }

    /**
     * Render comparison details
     */
    renderComparisonDetails(tableName, uidColumn, uidValue, comparison, filterEngine) {
        const container = document.getElementById('tableList').querySelector(`[data-comparison-detail="${tableName}:${uidColumn}:${uidValue}"]`);
        if (!container) return;

        container.innerHTML = '';

        // Create details table
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

        // Column Differences Count
        const hasColDiff = filterEngine.hasColumnDifferences(comparison);
        const columnDiffCount = filterEngine.getColumnDiffCount(comparison);
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

        details.appendChild(columnDiffContainer);

        container.appendChild(details);
        container.classList.remove('hidden');
    }

    /**
     * Render column differences
     */
    renderColumnDifferences(tableName, uidColumn, uidValue, comparison, dataManager, filterEngine) {
        const key = Utilities.createContainerKey(tableName, uidColumn, uidValue);
        const columnDiffContainer = document.querySelector(`[data-col-diff-container="${key}"]`);
        if (!columnDiffContainer) return;

        const columnDifferencesData = dataManager.getColumnDifferences(comparison);

        if (!columnDifferencesData || columnDifferencesData.length === 0) {
            columnDiffContainer.innerHTML = '<div class="p-2 text-xs text-gray-600">No column differences found</div>';
            return;
        }

        columnDiffContainer.innerHTML = '';

        // Column differences list
        const columnDiffList = document.createElement('div');
        columnDiffList.className = 'mt-3 ml-14 space-y-3';

        for (const record of columnDifferencesData) {
            const recordDiv = document.createElement('div');
            recordDiv.className = 'bg-white border border-red-200 rounded-sm p-3 text-xs';

            // Record index
            const indexDiv = document.createElement('div');
            indexDiv.className = 'font-semibold text-red-800 mb-2 pb-2 border-b border-red-200';
            indexDiv.textContent = `Record #${record.record_index}`;
            recordDiv.appendChild(indexDiv);

            // Column differences
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

        columnDiffContainer.appendChild(columnDiffList);

        // Generate and render SQL snippet
        const diffColumns = new Set();
        for (const record of columnDifferencesData) {
            for (const diff of record.column_differences) {
                diffColumns.add(diff.column);
            }
        }

        const sqlSnippet = Utilities.generateSqlQuery(tableName, uidColumn, uidValue, diffColumns);
        this.renderSqlSnippet(columnDiffContainer, sqlSnippet, `${tableName}:${uidColumn}:${uidValue}`);

        columnDiffContainer.classList.remove('hidden');
    }

    /**
     * Render SQL snippet section
     */
    renderSqlSnippet(parentContainer, sqlSnippet, uniqueKey) {
        // Create SQL snippet section
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
        sqlCopyBtn.setAttribute('data-copy-sql', uniqueKey);

        sqlContainer.appendChild(sqlCopyBtn);

        sqlSection.appendChild(sqlContainer);
        parentContainer.appendChild(sqlSection);
    }

    /**
     * Hide a container
     */
    hideContainer(container) {
        if (container) {
            container.innerHTML = '';
            container.classList.add('hidden');
        }
    }

    /**
     * Show a container
     */
    showContainer(container) {
        if (container) {
            container.classList.remove('hidden');
        }
    }
}
