class ValidationResultsReviewer {
    constructor(data) {
        this.allTables = Object.keys(data).sort();
        this.validationData = data;
        this.expandedTables = new Set();
        this.expandedUidColumns = new Set();  // Track expanded UID columns
        this.expandedUidValues = new Set();   // Track expanded UID values
        this.expandedDiscrepancies = new Set();  // Track expanded discrepancy lists
        this.uidContainers = {};
        this.uidValueContainers = {};  // Track UID value containers
        this.comparisonContainers = {};  // Track comparison detail containers
        this.discrepancyContainers = {};  // Track discrepancy list containers
        
        console.log(`Found ${this.allTables.length} tables`);
        this.init();
    }
    
    init() {
        this.setupEventListeners();
        this.render();
    }
    
    setupEventListeners() {
        const searchInput = document.getElementById('searchInput');
        searchInput.addEventListener('input', (e) => this.onSearchText(e.target.value));
        
        // Add filter dropdown if not already present
        const container = searchInput.parentElement;
        if (!container.querySelector('#filterSelect')) {
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
            searchInput.parentElement.appendChild(filterSelect);
            this.currentFilter = 'all';
        }
    }
    
    onSearchText(searchTerm) {
        const term = searchTerm.toLowerCase();
        const filtered = this.allTables.filter(t => t.toLowerCase().includes(term));
        this.applyFilters(filtered);
    }
    
    onFilterChanged(filterValue) {
        this.currentFilter = filterValue;
        const searchInput = document.getElementById('searchInput');
        const term = searchInput.value.toLowerCase();
        const filtered = this.allTables.filter(t => t.toLowerCase().includes(term));
        this.applyFilters(filtered);
    }
    
    applyFilters(tables) {
        let filteredTables = tables;
        
        if (this.currentFilter === 'column-diff') {
            filteredTables = tables.filter(tableName => this.hasTableColumnDifferences(tableName));
        } else if (this.currentFilter === 'record-mismatch') {
            filteredTables = tables.filter(tableName => this.hasTableRecordMismatch(tableName));
        }
        
        this.updateTableList(filteredTables);
    }
    
    hasTableColumnDifferences(tableName) {
        const data = this.validationData[tableName] || {};
        const resultsByUidColumn = data.results_by_uid_column || {};
        
        for (const uidColumn in resultsByUidColumn) {
            const columnData = resultsByUidColumn[uidColumn];
            const uidValues = columnData.uid_values || [];
            
            for (const item of uidValues) {
                if (this.hasColumnDifferences(item.comparison)) {
                    return true;
                }
            }
        }
        return false;
    }
    
    hasTableRecordMismatch(tableName) {
        const data = this.validationData[tableName] || {};
        const resultsByUidColumn = data.results_by_uid_column || {};
        
        for (const uidColumn in resultsByUidColumn) {
            const columnData = resultsByUidColumn[uidColumn];
            const uidValues = columnData.uid_values || [];
            
            for (const item of uidValues) {
                if (!item.comparison.record_counts_match) {
                    return true;
                }
            }
        }
        return false;
    }
    
    updateTableList(tables) {
        const listContainer = document.getElementById('tableList');
        listContainer.innerHTML = '';
        this.uidContainers = {};
        
        for (const tableName of tables) {
            // Create table row container
            const tableRow = document.createElement('div');
            tableRow.className = 'flex flex-col';
            tableRow.dataset.table = tableName;
            
            // Create table button
            const tableBtn = document.createElement('button');
            tableBtn.className = 'px-4 py-3 bg-gray-100 border border-gray-300 rounded-md text-sm text-left hover:bg-gray-200 active:bg-gray-300 transition-colors flex items-center gap-2';
            tableBtn.addEventListener('click', () => this.onTableClicked(tableName));
            
            // Table name span
            const tableNameSpan = document.createElement('span');
            tableNameSpan.className = 'flex-1';
            tableNameSpan.textContent = tableName;
            tableBtn.appendChild(tableNameSpan);
            
            // Column differences indicator
            if (this.hasTableColumnDifferences(tableName)) {
                const colDiffBadge = document.createElement('div');
                colDiffBadge.className = 'px-2 py-1 bg-red-100 border border-red-300 rounded-sm text-xs font-semibold text-red-700 whitespace-nowrap';
                colDiffBadge.textContent = 'Col Diff';
                tableBtn.appendChild(colDiffBadge);
            }
            
            // Record count mismatch indicator
            if (this.hasTableRecordMismatch(tableName)) {
                const recordMismatchBadge = document.createElement('div');
                recordMismatchBadge.className = 'px-2 py-1 bg-yellow-100 border border-yellow-300 rounded-sm text-xs font-semibold text-yellow-700 whitespace-nowrap';
                recordMismatchBadge.textContent = 'Rec Mismatch';
                tableBtn.appendChild(recordMismatchBadge);
            }
            
            tableRow.appendChild(tableBtn);
            
            // Create UID columns container
            const uidContainer = document.createElement('div');
            uidContainer.className = 'hidden flex flex-col gap-0.5 mt-1 ml-5';
            uidContainer.dataset.table = tableName;
            
            tableRow.appendChild(uidContainer);
            this.uidContainers[tableName] = uidContainer;
            
            listContainer.appendChild(tableRow);
        }
    }
    
    onTableClicked(tableName) {
        if (this.expandedTables.has(tableName)) {
            this.expandedTables.delete(tableName);
            this.hideUidColumns(tableName);
        } else {
            this.expandedTables.add(tableName);
            this.showUidColumns(tableName);
        }
    }
    
    showUidColumns(tableName) {
        const container = this.uidContainers[tableName];
        if (!container) return;
        
        const data = this.validationData[tableName] || {};
        const uidColumns = data.uid_columns || [];
        
        container.innerHTML = '';
        
        for (const uidCol of uidColumns) {
            // Create UID column row
            const uidRow = document.createElement('div');
            uidRow.className = 'flex flex-col';
            uidRow.dataset.table = tableName;
            uidRow.dataset.column = uidCol;
            
            // Create UID column button
            const uidBtn = document.createElement('button');
            uidBtn.className = 'px-3 py-2 bg-gray-50 border border-gray-200 rounded-md text-xs text-gray-600 text-left hover:bg-gray-100 active:bg-gray-200 transition-colors';
            uidBtn.textContent = `→ ${uidCol}`;
            uidBtn.addEventListener('click', () => this.onUidColumnClicked(tableName, uidCol));
            
            uidRow.appendChild(uidBtn);
            
            // Create container for UID values
            const uidValueContainer = document.createElement('div');
            uidValueContainer.className = 'hidden flex flex-col gap-0.5 mt-1 ml-5';
            uidValueContainer.dataset.table = tableName;
            uidValueContainer.dataset.column = uidCol;
            
            uidRow.appendChild(uidValueContainer);
            const key = `${tableName}:${uidCol}`;
            this.uidValueContainers[key] = uidValueContainer;
            
            container.appendChild(uidRow);
        }
        
        container.classList.remove('hidden');
    }
    
    hideUidColumns(tableName) {
        const container = this.uidContainers[tableName];
        if (container) {
            container.innerHTML = '';
            container.classList.add('hidden');
        }
        // Clear expanded UID columns for this table
        const toDelete = Array.from(this.expandedUidColumns).filter(key => key.startsWith(tableName + ':'));
        toDelete.forEach(key => this.expandedUidColumns.delete(key));
    }
    
    onUidColumnClicked(tableName, uidColumn) {
        const key = `${tableName}:${uidColumn}`;
        if (this.expandedUidColumns.has(key)) {
            this.expandedUidColumns.delete(key);
            this.hideUidValues(tableName, uidColumn);
        } else {
            this.expandedUidColumns.add(key);
            this.showUidValues(tableName, uidColumn);
        }
    }
    
    showUidValues(tableName, uidColumn) {
        const key = `${tableName}:${uidColumn}`;
        const container = this.uidValueContainers[key];
        if (!container) return;
        
        const data = this.validationData[tableName] || {};
        const resultsByUidColumn = data.results_by_uid_column || {};
        const columnData = resultsByUidColumn[uidColumn] || {};
        const uidValues = columnData.uid_values || [];
        
        container.innerHTML = '';
        
        for (const item of uidValues) {
            const uidValue = item.uid_value;
            const displayValue = uidValue === null ? '(null)' : uidValue;
            const comparison = item.comparison;
            
            // Create UID value row
            const valueRow = document.createElement('div');
            valueRow.className = 'flex flex-col';
            
            // Create container for value and copy button
            const valueContainer = document.createElement('div');
            valueContainer.className = 'flex items-center gap-1';
            
            // Create UID value button
            const valueBtn = document.createElement('button');
            valueBtn.className = 'flex-1 px-3 py-2 bg-white border border-gray-100 rounded-sm text-xs text-gray-700 text-left hover:bg-gray-50 active:bg-gray-100 transition-colors font-mono';
            valueBtn.textContent = `    • ${displayValue}`;
            
            // Add match status styling
            if (uidValue !== null && comparison) {
                const hasColumnDifferences = this.hasColumnDifferences(comparison);
                const hasRecordCountMismatch = !comparison.record_counts_match;
                if (comparison.record_counts_match && !hasColumnDifferences) {
                    valueBtn.className = 'flex-1 px-3 py-2 bg-green-100 border border-green-400 rounded-sm text-xs text-green-800 text-left hover:bg-green-200 active:bg-green-300 transition-colors font-mono';
                } else if (hasColumnDifferences) {
                    valueBtn.className = 'flex-1 px-3 py-2 bg-red-100 border border-red-400 rounded-sm text-xs text-red-800 text-left hover:bg-red-200 active:bg-red-300 transition-colors font-mono';
                } else if (hasRecordCountMismatch) {
                    valueBtn.className = 'flex-1 px-3 py-2 bg-yellow-100 border border-yellow-400 rounded-sm text-xs text-yellow-800 text-left hover:bg-yellow-200 active:bg-yellow-300 transition-colors font-mono';
                }
            }
            
            // Only make it clickable if UID value is not null
            if (uidValue !== null) {
                valueBtn.addEventListener('click', () => this.onUidValueClicked(tableName, uidColumn, uidValue));
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
                copyBtn.addEventListener('click', (e) => {
                    e.stopPropagation();
                    this.copyToClipboard(displayValue, copyBtn);
                });
                valueContainer.appendChild(copyBtn);
            }
            
            valueRow.appendChild(valueContainer);
            
            // Create container for comparison details
            const comparisonContainer = document.createElement('div');
            comparisonContainer.className = 'hidden';
            
            valueRow.appendChild(comparisonContainer);
            const comparisonKey = `${tableName}:${uidColumn}:${uidValue}`;
            this.comparisonContainers[comparisonKey] = comparisonContainer;
            
            // Store comparison data on the row for later use
            valueRow.dataset.comparison = JSON.stringify(item.comparison);
            
            container.appendChild(valueRow);
        }
        
        container.classList.remove('hidden');
    }
    
    hideUidValues(tableName, uidColumn) {
        const key = `${tableName}:${uidColumn}`;
        const container = this.uidValueContainers[key];
        if (container) {
            container.innerHTML = '';
            container.classList.add('hidden');
        }
        // Clear expanded UID values for this column
        const toDelete = Array.from(this.expandedUidValues).filter(k => k.startsWith(tableName + ':' + uidColumn + ':'));
        toDelete.forEach(k => this.expandedUidValues.delete(k));
    }
    
    hasColumnDifferences(comparison) {
        // Check new structure
        if (comparison && comparison.column_differences && 
            Array.isArray(comparison.column_differences) &&
            comparison.column_differences.length > 0) {
            return true;
        }
        
        // Check old structure for backward compatibility
        if (comparison && comparison.discrepant_records && 
            Array.isArray(comparison.discrepant_records)) {
            return comparison.discrepant_records.some(record => 
                record.column_differences && record.column_differences.length > 0
            );
        }
        
        return false;
    }
    
    onUidValueClicked(tableName, uidColumn, uidValue) {
        const key = `${tableName}:${uidColumn}:${uidValue}`;
        if (this.expandedUidValues.has(key)) {
            this.expandedUidValues.delete(key);
            this.hideComparisonDetails(key);
        } else {
            this.expandedUidValues.add(key);
            this.showComparisonDetails(tableName, uidColumn, uidValue);
        }
    }
    
    showComparisonDetails(tableName, uidColumn, uidValue) {
        const key = `${tableName}:${uidColumn}:${uidValue}`;
        const container = this.comparisonContainers[key];
        if (!container) return;
        
        const data = this.validationData[tableName] || {};
        const resultsByUidColumn = data.results_by_uid_column || {};
        const columnData = resultsByUidColumn[uidColumn] || {};
        const uidValues = columnData.uid_values || [];
        
        // Find the comparison data for this UID value
        const item = uidValues.find(v => v.uid_value === uidValue);
        if (!item) return;
        
        const comparison = item.comparison;
        
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
        const countsMatch = comparison.record_counts_match;
        matchRow.innerHTML = `<span class="font-semibold text-gray-700">Record Counts Match:</span> <span class="text-gray-600 font-mono">${countsMatch}</span>`;
        details.appendChild(matchRow);
        
        // Has Differences
        const diffRow = document.createElement('div');
        diffRow.className = 'flex justify-between text-xs pb-1 border-b border-gray-200';
        const diffStatus = comparison.has_differences;
        diffRow.innerHTML = `<span class="font-semibold text-gray-700">Has Differences:</span> <span class="text-gray-600 font-mono">${diffStatus}</span>`;
        details.appendChild(diffRow);
        
        // Column Differences Count
        const hasColDiff = this.hasColumnDifferences(comparison);
        const columnDiffRow = document.createElement('div');
        columnDiffRow.className = 'flex items-center justify-between text-xs pt-2';
        const columnDiffBtn = document.createElement('button');
        columnDiffBtn.className = 'px-2 py-1 bg-red-100 border border-red-400 rounded-sm text-xs font-semibold text-red-800 hover:bg-red-200 active:bg-red-300 transition-colors';
        
        const columnDiffCount = hasColDiff ? (comparison.column_differences?.length || 
            comparison.discrepant_records?.filter(r => r.column_differences && r.column_differences.length > 0).length || 0) : 0;
        columnDiffBtn.textContent = columnDiffCount;
        
        if (hasColDiff) {
            columnDiffBtn.addEventListener('click', () => this.onColumnDifferencesClicked(tableName, uidColumn, uidValue));
        } else {
            columnDiffBtn.style.opacity = '0.6';
        }
        
        columnDiffRow.innerHTML = `<span class="font-semibold text-gray-700">Records with Column Differences:</span>`;
        columnDiffRow.appendChild(columnDiffBtn);
        details.appendChild(columnDiffRow);
        
        // Create container for column differences
        const columnDiffContainer = document.createElement('div');
        columnDiffContainer.className = 'hidden';
        this.columnDiffContainers = this.columnDiffContainers || {};
        this.columnDiffContainers[key] = columnDiffContainer;
        
        details.appendChild(columnDiffContainer);
        
        container.appendChild(details);
        container.classList.remove('hidden');
    }
    
    hideComparisonDetails(key) {
        const container = this.comparisonContainers[key];
        if (container) {
            container.innerHTML = '';
            container.classList.add('hidden');
        }
    }
    
    onColumnDifferencesClicked(tableName, uidColumn, uidValue) {
        const key = `${tableName}:${uidColumn}:${uidValue}`;
        this.columnDiffContainers = this.columnDiffContainers || {};
        const isExpanded = this.columnDiffContainers[key] && !this.columnDiffContainers[key].classList.contains('hidden');
        
        if (isExpanded) {
            this.hideColumnDifferences(key);
        } else {
            this.showColumnDifferences(tableName, uidColumn, uidValue);
        }
    }
    
    showColumnDifferences(tableName, uidColumn, uidValue) {
        const key = `${tableName}:${uidColumn}:${uidValue}`;
        this.columnDiffContainers = this.columnDiffContainers || {};
        const container = this.columnDiffContainers[key];
        if (!container) return;
        
        const data = this.validationData[tableName] || {};
        const resultsByUidColumn = data.results_by_uid_column || {};
        const columnData = resultsByUidColumn[uidColumn] || {};
        const uidValues = columnData.uid_values || [];
        
        // Find the comparison data for this UID value
        const item = uidValues.find(v => v.uid_value === uidValue);
        if (!item) return;
        
        const comparison = item.comparison;
        
        // Determine which data structure to use
        let columnDifferencesData = [];
        if (comparison.column_differences && Array.isArray(comparison.column_differences)) {
            // New structure
            columnDifferencesData = comparison.column_differences;
        } else if (comparison.discrepant_records && Array.isArray(comparison.discrepant_records)) {
            // Old structure - filter records with column_differences
            columnDifferencesData = comparison.discrepant_records.filter(r => r.column_differences && r.column_differences.length > 0);
        }
        
        if (!columnDifferencesData || columnDifferencesData.length === 0) return;
        
        container.innerHTML = '';
        
        // Column differences list
        const columnDiffList = document.createElement('div');
        columnDiffList.className = 'mt-3 ml-14 space-y-3';
        
        if (columnDifferencesData.length === 0) {
            columnDiffList.innerHTML = '<div class="p-2 text-xs text-gray-600">No column differences found</div>';
        } else {
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
                    const rdbVal = diff.rdb_value === null ? '(null)' : String(diff.rdb_value).substring(0, 50);
                    rdbValueSpan.textContent = `RDB: ${rdbVal}`;
                    diffDiv.appendChild(rdbValueSpan);
                    
                    const rdbModernValueSpan = document.createElement('div');
                    rdbModernValueSpan.className = 'text-gray-700 mt-1';
                    const modernVal = diff.rdb_modern_value === null ? '(null)' : String(diff.rdb_modern_value).substring(0, 50);
                    rdbModernValueSpan.textContent = `RDB_MODERN: ${modernVal}`;
                    diffDiv.appendChild(rdbModernValueSpan);
                    
                    columnsDiv.appendChild(diffDiv);
                }
                
                recordDiv.appendChild(columnsDiv);
                columnDiffList.appendChild(recordDiv);
            }
        }
        
        container.appendChild(columnDiffList);
        
        // Generate SQL snippet (after column differences)
        const diffColumns = new Set();
        for (const record of columnDifferencesData) {
            for (const diff of record.column_differences) {
                diffColumns.add(diff.column);
            }
        }
        
        // Include UID column first, then all differing columns
        const columnList = `[${uidColumn}], ${Array.from(diffColumns).sort().map(col => `[${col}]`).join(', ')}`;
        const uidValueForSQL = typeof uidValue === 'string' ? `'${uidValue.replace(/'/g, "''")}'` : uidValue;
        
        const sqlSnippet = `-- RDB\nSELECT ${columnList} FROM [RDB].[dbo].[${tableName}] WHERE [${uidColumn}] = ${uidValueForSQL}\n\n-- RDB_MODERN\nSELECT ${columnList} FROM [RDB_MODERN].[dbo].[${tableName}] WHERE [${uidColumn}] = ${uidValueForSQL}`;
        
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
        sqlCopyBtn.addEventListener('click', (e) => {
            e.stopPropagation();
            this.copyToClipboard(sqlSnippet, sqlCopyBtn);
        });
        sqlContainer.appendChild(sqlCopyBtn);
        
        sqlSection.appendChild(sqlContainer);
        container.appendChild(sqlSection);
        
        container.classList.remove('hidden');
    }
    
    hideColumnDifferences(key) {
        this.columnDiffContainers = this.columnDiffContainers || {};
        const container = this.columnDiffContainers[key];
        if (container) {
            container.innerHTML = '';
            container.classList.add('hidden');
        }
    }
    
    copyToClipboard(text, button) {
        navigator.clipboard.writeText(text).then(() => {
            // Show feedback
            const originalText = button.textContent;
            button.textContent = '✓';
            button.style.backgroundColor = '#dcfce7';
            button.style.borderColor = '#4ade80';
            button.style.color = '#166534';
            
            // Revert after 2 seconds
            setTimeout(() => {
                button.textContent = originalText;
                button.style.backgroundColor = '';
                button.style.borderColor = '';
                button.style.color = '';
            }, 2000);
        }).catch(() => {
            // Fallback for older browsers
            const textarea = document.createElement('textarea');
            textarea.value = text;
            document.body.appendChild(textarea);
            textarea.select();
            document.execCommand('copy');
            document.body.removeChild(textarea);
            
            // Show feedback
            const originalText = button.textContent;
            button.textContent = '✓';
            button.style.backgroundColor = '#dcfce7';
            setTimeout(() => {
                button.textContent = originalText;
                button.style.backgroundColor = '';
            }, 2000);
        });
    }
    
    render() {
        this.updateTableList(this.allTables);
    }
}

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    new ValidationResultsReviewer(window.VALIDATION_DATA || {});
});
