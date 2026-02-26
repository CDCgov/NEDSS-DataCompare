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
    }
    
    onSearchText(searchTerm) {
        const term = searchTerm.toLowerCase();
        const filtered = this.allTables.filter(t => t.toLowerCase().includes(term));
        this.updateTableList(filtered);
    }
    
    updateTableList(tables) {
        const listContainer = document.getElementById('tableList');
        listContainer.innerHTML = '';
        this.uidContainers = {};
        
        for (const tableName of tables) {
            // Create table row container
            const tableRow = document.createElement('div');
            tableRow.className = 'table-row';
            tableRow.dataset.table = tableName;
            
            // Create table button
            const tableBtn = document.createElement('button');
            tableBtn.className = 'table-button';
            tableBtn.textContent = tableName;
            tableBtn.addEventListener('click', () => this.onTableClicked(tableName));
            
            tableRow.appendChild(tableBtn);
            
            // Create UID columns container
            const uidContainer = document.createElement('div');
            uidContainer.className = 'uid-container';
            uidContainer.style.display = 'none';
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
            uidRow.className = 'uid-column-row';
            uidRow.dataset.table = tableName;
            uidRow.dataset.column = uidCol;
            
            // Create UID column button
            const uidBtn = document.createElement('button');
            uidBtn.className = 'uid-button';
            uidBtn.textContent = `→ ${uidCol}`;
            uidBtn.addEventListener('click', () => this.onUidColumnClicked(tableName, uidCol));
            
            uidRow.appendChild(uidBtn);
            
            // Create container for UID values
            const uidValueContainer = document.createElement('div');
            uidValueContainer.className = 'uid-value-container';
            uidValueContainer.style.display = 'none';
            uidValueContainer.dataset.table = tableName;
            uidValueContainer.dataset.column = uidCol;
            
            uidRow.appendChild(uidValueContainer);
            const key = `${tableName}:${uidCol}`;
            this.uidValueContainers[key] = uidValueContainer;
            
            container.appendChild(uidRow);
        }
        
        container.style.display = 'block';
    }
    
    hideUidColumns(tableName) {
        const container = this.uidContainers[tableName];
        if (container) {
            container.innerHTML = '';
            container.style.display = 'none';
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
            valueRow.className = 'uid-value-row';
            
            // Create UID value button
            const valueBtn = document.createElement('button');
            valueBtn.className = 'uid-value-button';
            valueBtn.textContent = `    • ${displayValue}`;
            
            // Add match status styling
            if (uidValue !== null && comparison) {
                if (comparison.match) {
                    valueBtn.classList.add('match-true-bg');
                } else {
                    valueBtn.classList.add('match-false-bg');
                }
            }
            
            // Only make it clickable if UID value is not null
            if (uidValue !== null) {
                valueBtn.style.cursor = 'pointer';
                valueBtn.addEventListener('click', () => this.onUidValueClicked(tableName, uidColumn, uidValue));
            } else {
                valueBtn.style.cursor = 'default';
                valueBtn.style.opacity = '0.7';
            }
            
            valueRow.appendChild(valueBtn);
            
            // Create container for comparison details
            const comparisonContainer = document.createElement('div');
            comparisonContainer.className = 'comparison-container';
            comparisonContainer.style.display = 'none';
            
            valueRow.appendChild(comparisonContainer);
            const comparisonKey = `${tableName}:${uidColumn}:${uidValue}`;
            this.comparisonContainers[comparisonKey] = comparisonContainer;
            
            // Store comparison data on the row for later use
            valueRow.dataset.comparison = JSON.stringify(item.comparison);
            
            container.appendChild(valueRow);
        }
        
        container.style.display = 'block';
    }
    
    hideUidValues(tableName, uidColumn) {
        const key = `${tableName}:${uidColumn}`;
        const container = this.uidValueContainers[key];
        if (container) {
            container.innerHTML = '';
            container.style.display = 'none';
        }
        // Clear expanded UID values for this column
        const toDelete = Array.from(this.expandedUidValues).filter(k => k.startsWith(tableName + ':' + uidColumn + ':'));
        toDelete.forEach(k => this.expandedUidValues.delete(k));
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
        details.className = 'comparison-details';
        
        // RDB Count
        const rdbRow = document.createElement('div');
        rdbRow.className = 'detail-row';
        rdbRow.innerHTML = `<span class="detail-label">RDB Count:</span> <span class="detail-value">${comparison.rdb_count}</span>`;
        details.appendChild(rdbRow);
        
        // RDB Modern Count
        const modernRow = document.createElement('div');
        modernRow.className = 'detail-row';
        modernRow.innerHTML = `<span class="detail-label">RDB Modern Count:</span> <span class="detail-value">${comparison.rdb_modern_count}</span>`;
        details.appendChild(modernRow);
        
        // Match status
        const matchRow = document.createElement('div');
        matchRow.className = 'detail-row';
        const matchStatus = comparison.match ? '✓ Match' : '✗ No Match';
        const matchClass = comparison.match ? 'match-true' : 'match-false';
        matchRow.innerHTML = `<span class="detail-label">Match:</span> <span class="detail-value ${matchClass}">${matchStatus}</span>`;
        details.appendChild(matchRow);
        
        // Has Differences
        const diffRow = document.createElement('div');
        diffRow.className = 'detail-row';
        const diffStatus = comparison.has_differences ? '✓ Has Differences' : '✗ No Differences';
        diffRow.innerHTML = `<span class="detail-label">Has Differences:</span> <span class="detail-value">${diffStatus}</span>`;
        details.appendChild(diffRow);
        
        // Discrepant Count
        const discrepantRow = document.createElement('div');
        discrepantRow.className = 'detail-row';
        const discrepantCountValue = comparison.discrepant_count;
        const discrepantBtn = document.createElement('button');
        discrepantBtn.className = 'discrepant-count-button';
        discrepantBtn.textContent = discrepantCountValue;
        
        if (discrepantCountValue > 0) {
            discrepantBtn.style.cursor = 'pointer';
            discrepantBtn.addEventListener('click', () => this.onDiscrepancyClicked(tableName, uidColumn, uidValue));
        } else {
            discrepantBtn.style.cursor = 'default';
            discrepantBtn.style.opacity = '0.7';
        }
        
        discrepantRow.innerHTML = `<span class="detail-label">Discrepant Records:</span>`;
        discrepantRow.appendChild(discrepantBtn);
        details.appendChild(discrepantRow);
        
        // Create container for discrepancy details
        const discrepancyContainer = document.createElement('div');
        discrepancyContainer.className = 'discrepancy-container';
        discrepancyContainer.style.display = 'none';
        const discrepancyKey = `${tableName}:${uidColumn}:${uidValue}`;
        this.discrepancyContainers[discrepancyKey] = discrepancyContainer;
        
        details.appendChild(discrepancyContainer);
        
        container.appendChild(details);
        container.style.display = 'block';
    }
    
    hideComparisonDetails(key) {
        const container = this.comparisonContainers[key];
        if (container) {
            container.innerHTML = '';
            container.style.display = 'none';
        }
        // Clear expanded discrepancies for this value
        const toDelete = Array.from(this.expandedDiscrepancies).filter(k => k.startsWith(key + ':'));
        toDelete.forEach(k => this.expandedDiscrepancies.delete(k));
    }
    
    onDiscrepancyClicked(tableName, uidColumn, uidValue) {
        const key = `${tableName}:${uidColumn}:${uidValue}`;
        if (this.expandedDiscrepancies.has(key)) {
            this.expandedDiscrepancies.delete(key);
            this.hideDiscrepancies(key);
        } else {
            this.expandedDiscrepancies.add(key);
            this.showDiscrepancies(tableName, uidColumn, uidValue);
        }
    }
    
    showDiscrepancies(tableName, uidColumn, uidValue) {
        const key = `${tableName}:${uidColumn}:${uidValue}`;
        const container = this.discrepancyContainers[key];
        if (!container) return;
        
        const data = this.validationData[tableName] || {};
        const resultsByUidColumn = data.results_by_uid_column || {};
        const columnData = resultsByUidColumn[uidColumn] || {};
        const uidValues = columnData.uid_values || [];
        
        // Find the comparison data for this UID value
        const item = uidValues.find(v => v.uid_value === uidValue);
        if (!item || !item.comparison.discrepant_records) return;
        
        const discrepantRecords = item.comparison.discrepant_records;
        
        container.innerHTML = '';
        
        const discrepancyList = document.createElement('div');
        discrepancyList.className = 'discrepancy-list';
        
        for (const record of discrepantRecords) {
            const recordDiv = document.createElement('div');
            recordDiv.className = 'discrepant-record';
            
            // Record type
            const typeDiv = document.createElement('div');
            typeDiv.className = 'record-type';
            typeDiv.textContent = `Type: ${record.type}`;
            recordDiv.appendChild(typeDiv);
            
            // Record data
            const data = record.rdb_modern_record || record.rdb_record || {};
            const dataKeys = Object.keys(data).slice(0, 5); // Show first 5 fields
            
            if (dataKeys.length > 0) {
                const fieldsDiv = document.createElement('div');
                fieldsDiv.className = 'record-fields';
                
                for (const key of dataKeys) {
                    const fieldDiv = document.createElement('div');
                    fieldDiv.className = 'record-field';
                    const value = data[key];
                    const displayValue = value === null ? '(null)' : String(value).substring(0, 50);
                    fieldDiv.textContent = `${key}: ${displayValue}`;
                    fieldsDiv.appendChild(fieldDiv);
                }
                
                recordDiv.appendChild(fieldsDiv);
            }
            
            discrepancyList.appendChild(recordDiv);
        }
        
        container.appendChild(discrepancyList);
        container.style.display = 'block';
    }
    
    hideDiscrepancies(key) {
        const container = this.discrepancyContainers[key];
        if (container) {
            container.innerHTML = '';
            container.style.display = 'none';
        }
    }
    
    render() {
        this.updateTableList(this.allTables);
    }
}

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    new ValidationResultsReviewer(window.VALIDATION_DATA || {});
});
