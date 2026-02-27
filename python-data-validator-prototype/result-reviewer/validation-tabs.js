/**
 * Validation Tabs Module - Manages switching between UID and KEY validation views
 */

class ValidationTabs {
    constructor(dataManager, uiRenderer) {
        this.dataManager = dataManager;
        this.uiRenderer = uiRenderer;
        this.currentValidationType = 'uid'; // Default to UID
        this.currentTable = null;
    }

    /**
     * Set current table and update tabs
     */
    setTable(tableName) {
        this.currentTable = tableName;
        this.currentValidationType = 'uid'; // Reset to UID when switching tables
        this.renderTabs();
    }

    /**
     * Render validation type tabs for current table
     */
    renderTabs() {
        if (!this.currentTable) return;

        const validationTypes = this.dataManager.getValidationTypes(this.currentTable);
        const tabContainer = document.getElementById('validation-tabs');
        
        if (!tabContainer) return;

        // Clear existing tabs
        tabContainer.innerHTML = '';

        validationTypes.forEach(type => {
            const button = document.createElement('button');
            button.className = `tab-button ${type === this.currentValidationType ? 'active' : ''}`;
            button.textContent = type.toUpperCase() + ' Validation';
            button.dataset.type = type;
            
            button.addEventListener('click', () => {
                this.switchValidationType(type);
            });
            
            tabContainer.appendChild(button);
        });

        // Show appropriate content
        this.updateContent();
    }

    /**
     * Switch to a different validation type
     */
    switchValidationType(type) {
        this.currentValidationType = type;
        this.renderTabs();
    }

    /**
     * Get current validation type
     */
    getCurrentValidationType() {
        return this.currentValidationType;
    }

    /**
     * Check if specific validation type is available
     */
    isValidationTypeAvailable(type) {
        if (!this.currentTable) return false;
        return this.dataManager.hasValidationType(this.currentTable, type);
    }

    /**
     * Update content based on current validation type
     */
    updateContent() {
        const contentContainer = document.getElementById('validation-content');
        if (!contentContainer) return;

        if (this.currentValidationType === 'uid') {
            this.renderUidContent();
        } else if (this.currentValidationType === 'key') {
            this.renderKeyContent();
        }
    }

    /**
     * Render UID validation content
     */
    renderUidContent() {
        const contentContainer = document.getElementById('validation-content');
        if (!contentContainer || !this.currentTable) return;

        const uidColumns = this.dataManager.getUidColumnsForTable(this.currentTable);
        
        let html = '<div class="uid-validation">';
        html += '<h3>UID Columns Found: ' + uidColumns.length + '</h3>';
        
        if (uidColumns.length === 0) {
            html += '<p>No UID columns found for this table.</p>';
        } else {
            html += '<ul>';
            uidColumns.forEach(col => {
                html += `<li><strong>${col}</strong></li>`;
            });
            html += '</ul>';
        }
        
        html += '</div>';
        contentContainer.innerHTML = html;
    }

    /**
     * Render KEY validation content
     */
    renderKeyContent() {
        const contentContainer = document.getElementById('validation-content');
        if (!contentContainer || !this.currentTable) return;

        const keyColumns = this.dataManager.getKeyColumnsForTable(this.currentTable);
        
        let html = '<div class="key-validation">';
        html += '<h3>KEY Columns Found: ' + keyColumns.length + '</h3>';
        
        if (keyColumns.length === 0) {
            html += '<p>No KEY columns found for this table.</p>';
        } else {
            html += '<div class="key-columns-list">';
            keyColumns.forEach(keyColumn => {
                const metadata = this.dataManager.getKeyColumnMetadata(this.currentTable, keyColumn);
                html += `<div class="key-column-group">`;
                html += `<h4>${keyColumn}</h4>`;
                html += `<div class="mapping-info">`;
                html += `<p><strong>Mapping Table:</strong> ${metadata.mapping_table}</p>`;
                html += `<p><strong>Mapping UID Column:</strong> ${metadata.mapping_uid_column}</p>`;
                html += `</div>`;
                html += `</div>`;
            });
            html += '</div>';
        }
        
        html += '</div>';
        contentContainer.innerHTML = html;
    }
}
