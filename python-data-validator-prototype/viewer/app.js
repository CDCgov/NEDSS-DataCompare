/**
 * Main App - Fetch and display tables
 */

async function loadTables() {
    const loadingEl = document.getElementById('loading');
    const errorEl = document.getElementById('error');
    const listEl = document.getElementById('tableList');
    const searchInput = document.getElementById('tableSearch');
    
    try {
        const response = await fetch('/api/tables');
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        
        const data = await response.json();
        const tables = (data.tables || []).map(t => t.name);
        
        if (tables.length === 0) {
            loadingEl.textContent = 'No tables found';
            return;
        }
        
        // Store tables globally for filtering
        window._allTables = tables.slice().sort();

        function renderTableList(filterText) {
            const term = (filterText || '').toLowerCase();
            listEl.innerHTML = '';

            const namesToShow = window._allTables.filter(name =>
                !term || name.toLowerCase().includes(term)
            );

            namesToShow.forEach(tableName => {
                const li = document.createElement('li');

                const button = document.createElement('button');
                button.type = 'button';
                button.className = 'table-button btn btn-outline-primary btn-sm w-100 text-start d-flex justify-content-between align-items-center';
                button.textContent = tableName;

                const details = document.createElement('div');
                details.className = 'table-details';
                details.style.display = 'none';

                button.addEventListener('click', () => {
                    onTableClicked(tableName, details);
                });

                li.appendChild(button);
                li.appendChild(details);
                listEl.appendChild(li);
            });
        }

        renderTableList('');

        if (searchInput) {
            searchInput.addEventListener('input', () => {
                renderTableList(searchInput.value);
            });
        }
        
        loadingEl.style.display = 'none';
        listEl.style.display = 'block';
        
    } catch (error) {
        loadingEl.style.display = 'none';
        errorEl.textContent = `Error loading tables: ${error.message}`;
        errorEl.style.display = 'block';
        console.error('Failed to load tables:', error);
    }
}

async function onTableClicked(tableName, detailsEl) {
    // Toggle visibility: if already visible, hide and stop
    if (detailsEl.style.display === 'block') {
        detailsEl.style.display = 'none';
        detailsEl.innerHTML = '';
        return;
    }

    detailsEl.textContent = 'Loading columns...';
    detailsEl.style.display = 'block';

    try {
        const resp = await fetch(`/api/table/${encodeURIComponent(tableName)}?structure_only=true`);
        if (!resp.ok) throw new Error(`HTTP ${resp.status}`);

        const data = await resp.json();
        const uidVal = data.uid_validation;
        const keyVal = data.key_validation;

        const hasUid = uidVal && !uidVal.error && Array.isArray(uidVal.uid_columns) && uidVal.uid_columns.length;
        const hasKey = keyVal && !keyVal.error && Array.isArray(keyVal.key_columns) && keyVal.key_columns.length;

        if (!hasUid && !hasKey) {
            detailsEl.textContent = 'No UID or KEY columns.';
            return;
        }

        detailsEl.innerHTML = '';
        const list = document.createElement('ul');
        list.className = 'tree-list';

        if (hasUid) {
            uidVal.uid_columns.forEach(colName => {
                const li = document.createElement('li');

                const btn = document.createElement('button');
                btn.type = 'button';
                btn.className = 'tree-column-button btn btn-link btn-sm p-0';
                btn.textContent = colName;

                const valuesEl = document.createElement('ul');
                valuesEl.className = 'tree-list';
                valuesEl.style.display = 'none';

                btn.addEventListener('click', () => {
                    onUidColumnClicked(tableName, colName, valuesEl);
                });

                li.appendChild(btn);
                li.appendChild(valuesEl);
                list.appendChild(li);
            });
        }

        if (hasKey) {
            keyVal.key_columns.forEach(colName => {
                const li = document.createElement('li');

                const btn = document.createElement('button');
                btn.type = 'button';
                btn.className = 'tree-column-button btn btn-link btn-sm p-0';
                btn.textContent = colName;

                const valuesEl = document.createElement('ul');
                valuesEl.className = 'tree-list';
                valuesEl.style.display = 'none';

                btn.addEventListener('click', () => {
                    onKeyColumnClicked(tableName, colName, valuesEl);
                });

                li.appendChild(btn);
                li.appendChild(valuesEl);
                list.appendChild(li);
            });
        }

        detailsEl.appendChild(list);
    } catch (err) {
        console.error('Failed to load table structure', tableName, err);
        detailsEl.textContent = `Error loading columns: ${err.message}`;
    }
}

async function onUidColumnClicked(tableName, columnName, valuesEl) {
    // Toggle off if already visible
    if (valuesEl.style.display === 'block') {
        valuesEl.style.display = 'none';
        valuesEl.innerHTML = '';
        return;
    }

    valuesEl.innerHTML = '';
    const loadingItem = document.createElement('li');
    loadingItem.className = 'tree-value-text';
    loadingItem.textContent = 'Loading UID values...';
    valuesEl.appendChild(loadingItem);
    valuesEl.style.display = 'block';

    try {
        const resp = await fetch(`/api/table/${encodeURIComponent(tableName)}`);
        if (!resp.ok) throw new Error(`HTTP ${resp.status}`);

        const data = await resp.json();
        const uidVal = data.uid_validation;
        const colData = uidVal && uidVal.results_by_uid_column && uidVal.results_by_uid_column[columnName];

        if (!colData || !Array.isArray(colData.uid_values) || !colData.uid_values.length) {
            valuesEl.innerHTML = '';
            const li = document.createElement('li');
            li.className = 'tree-value-text';
            li.textContent = 'No UID values found.';
            valuesEl.appendChild(li);
            return;
        }

        valuesEl.innerHTML = '';
        colData.uid_values.forEach(item => {
            const li = document.createElement('li');

            const btn = document.createElement('button');
            btn.type = 'button';
            const hasDiff = item.comparison && item.comparison.has_differences;
            btn.className = 'tree-column-button btn btn-sm ' + (hasDiff ? 'btn-outline-danger uid-value-diff' : 'btn-outline-success uid-value-ok');
            btn.textContent = String(item.uid_value);

            const detailsEl = document.createElement('div');
            detailsEl.className = 'uid-comparison-details';
            detailsEl.style.display = 'none';

            btn.addEventListener('click', () => {
                onUidValueClicked(tableName, columnName, item, detailsEl);
            });

            li.appendChild(btn);
            li.appendChild(detailsEl);
            valuesEl.appendChild(li);
        });
    } catch (err) {
        console.error('Failed to load UID values', tableName, columnName, err);
        valuesEl.innerHTML = '';
        const li = document.createElement('li');
        li.className = 'tree-value-text';
        li.textContent = `Error loading UID values: ${err.message}`;
        valuesEl.appendChild(li);
    }
}

async function onKeyColumnClicked(tableName, columnName, valuesEl) {
    // Toggle off if already visible
    if (valuesEl.style.display === 'block') {
        valuesEl.style.display = 'none';
        valuesEl.innerHTML = '';
        return;
    }

    valuesEl.innerHTML = '';
    const loadingItem = document.createElement('li');
    loadingItem.className = 'tree-value-text';
    loadingItem.textContent = 'Loading mapping UIDs...';
    valuesEl.appendChild(loadingItem);
    valuesEl.style.display = 'block';

    try {
        const resp = await fetch(`/api/table/${encodeURIComponent(tableName)}`);
        if (!resp.ok) throw new Error(`HTTP ${resp.status}`);

        const data = await resp.json();
        const keyVal = data.key_validation;
        const colData = keyVal && keyVal.results_by_key_column && keyVal.results_by_key_column[columnName];

        if (!colData || !colData.records_by_mapping_uid) {
            valuesEl.innerHTML = '';
            const li = document.createElement('li');
            li.className = 'tree-value-text';
            li.textContent = 'No mapping UIDs found.';
            valuesEl.appendChild(li);
            return;
        }

        const mappingColName = colData.mapping_uid_column || 'mapping_uid';
        const mappingTableName = colData.mapping_table;
        const entries = Object.values(colData.records_by_mapping_uid);

        if (!entries.length) {
            valuesEl.innerHTML = '';
            const li = document.createElement('li');
            li.className = 'tree-value-text';
            li.textContent = 'No mapping UIDs found.';
            valuesEl.appendChild(li);
            return;
        }

        // Sort by mapping_uid numeric if possible
        entries.sort((a, b) => {
            const av = Number(a.mapping_uid);
            const bv = Number(b.mapping_uid);
            if (!isNaN(av) && !isNaN(bv)) return av - bv;
            return String(a.mapping_uid).localeCompare(String(b.mapping_uid));
        });

        valuesEl.innerHTML = '';
        entries.forEach(entry => {
            const li = document.createElement('li');

            const btn = document.createElement('button');
            btn.type = 'button';
            const hasDiff = entry.comparison && entry.comparison.has_differences;
            btn.className = 'tree-column-button btn btn-sm ' + (hasDiff ? 'btn-outline-danger uid-value-diff' : 'btn-outline-success uid-value-ok');
            btn.textContent = `${mappingColName}: ${entry.mapping_uid}`;

            const detailsEl = document.createElement('div');
            detailsEl.className = 'uid-comparison-details';
            detailsEl.style.display = 'none';

            btn.addEventListener('click', () => {
                onKeyMappingUidClicked(tableName, columnName, mappingTableName, mappingColName, entry, detailsEl);
            });

            li.appendChild(btn);
            li.appendChild(detailsEl);
            valuesEl.appendChild(li);
        });
    } catch (err) {
        console.error('Failed to load mapping UIDs', tableName, columnName, err);
        valuesEl.innerHTML = '';
        const li = document.createElement('li');
        li.className = 'tree-value-text';
        li.textContent = `Error loading mapping UIDs: ${err.message}`;
        valuesEl.appendChild(li);
    }
}

function onUidValueClicked(tableName, columnName, uidItem, detailsEl) {
    // Toggle off
    if (detailsEl.style.display === 'block') {
        detailsEl.style.display = 'none';
        detailsEl.innerHTML = '';
        return;
    }

    const comparison = uidItem.comparison;
    renderComparisonDetails(comparison, detailsEl, {
        tableName,
        idColumnName: columnName,
        idValueRdb: uidItem.uid_value,
        idValueModern: uidItem.uid_value,
        idType: 'UID'
    });
}

function onKeyMappingUidClicked(tableName, columnName, mappingTableName, mappingColName, entry, detailsEl) {
    // Toggle off
    if (detailsEl.style.display === 'block') {
        detailsEl.style.display = 'none';
        detailsEl.innerHTML = '';
        return;
    }

    const comparison = entry.comparison;
    renderComparisonDetails(comparison, detailsEl, {
        tableName,
        idColumnName: columnName,
        idValueRdb: entry.rdb_key_value,
        idValueModern: entry.rdb_modern_key_value,
        idType: 'KEY',
        mappingUid: entry.mapping_uid,
        mappingColumn: mappingColName,
        mappingTableName
    });
}

function renderComparisonDetails(comparison, detailsEl, context) {
    if (!comparison) {
        detailsEl.style.display = 'block';
        detailsEl.textContent = 'No comparison details.';
        return;
    }

    detailsEl.innerHTML = '';

    const table = document.createElement('table');
    table.className = 'uid-comparison-table';

    const thead = document.createElement('thead');
    thead.innerHTML = '<tr><th>Record Index</th><th>Column</th><th>RDB Value</th><th>RDB_MODERN</th></tr>';
    table.appendChild(thead);

    const tbody = document.createElement('tbody');

    const diffs = Array.isArray(comparison.column_differences) ? comparison.column_differences : [];

    if (!diffs.length) {
        const tr = document.createElement('tr');
        const td = document.createElement('td');
        td.colSpan = 4;
        td.textContent = 'No column differences.';
        tr.appendChild(td);
        tbody.appendChild(tr);
    } else {
        diffs.forEach(recDiff => {
            const recordIndex = recDiff.record_index;
            const cols = Array.isArray(recDiff.column_differences) ? recDiff.column_differences : [];
            cols.forEach(colDiff => {
                const tr = document.createElement('tr');

                const tdIdx = document.createElement('td');
                tdIdx.textContent = String(recordIndex);

                const tdCol = document.createElement('td');
                tdCol.textContent = colDiff.column;

                const tdRdb = document.createElement('td');
                tdRdb.textContent = colDiff.rdb_value === null ? '⟂ null' : String(colDiff.rdb_value);

                const tdModern = document.createElement('td');
                tdModern.textContent = colDiff.rdb_modern_value === null ? '⟂ null' : String(colDiff.rdb_modern_value);

                tr.appendChild(tdIdx);
                tr.appendChild(tdCol);
                tr.appendChild(tdRdb);
                tr.appendChild(tdModern);
                tbody.appendChild(tr);
            });
        });
    }

    table.appendChild(tbody);

    const summary = document.createElement('div');
    summary.className = 'tree-value-text small mb-2';

    if (context && context.idType === 'KEY' && context.mappingTableName && context.mappingColumn && context.mappingUid !== undefined) {
        summary.textContent = `mapping_table=${context.mappingTableName}, mapping_uid_column=${context.mappingColumn}, mapping_uid=${context.mappingUid} | rdb_count=${comparison.rdb_count}, modern_count=${comparison.rdb_modern_count}, counts_match=${comparison.record_counts_match ? 'yes' : 'no'}, has_differences=${comparison.has_differences ? 'yes' : 'no'}`;
    } else {
        summary.textContent = `rdb_count=${comparison.rdb_count}, modern_count=${comparison.rdb_modern_count}, counts_match=${comparison.record_counts_match ? 'yes' : 'no'}, has_differences=${comparison.has_differences ? 'yes' : 'no'}`;
    }

    detailsEl.appendChild(summary);
    detailsEl.appendChild(table);

    const sql = buildSqlForComparison(comparison, context);
    if (sql) {
        const label = document.createElement('div');
        label.className = 'tree-value-text small mt-2 fw-semibold';
        label.textContent = 'SQL (RDB and RDB_MODERN):';

        const textarea = document.createElement('textarea');
        textarea.readOnly = true;
        textarea.className = 'form-control form-control-sm font-monospace mt-1';
        textarea.style.width = '100%';
        textarea.rows = Math.min(10, sql.split('\n').length + 1);
        textarea.value = sql;
        
        const copyBtn = document.createElement('button');
        copyBtn.type = 'button';
        copyBtn.className = 'sql-copy-button btn btn-outline-secondary btn-sm mt-1';
        copyBtn.textContent = 'Copy SQL';
        copyBtn.addEventListener('click', async () => {
            try {
                if (navigator.clipboard && navigator.clipboard.writeText) {
                    await navigator.clipboard.writeText(textarea.value);
                } else {
                    textarea.select();
                    document.execCommand('copy');
                    textarea.blur();
                }
            } catch (e) {
                console.error('Failed to copy SQL', e);
            }
        });

        detailsEl.appendChild(label);
        detailsEl.appendChild(textarea);
        detailsEl.appendChild(copyBtn);
    }

    detailsEl.style.display = 'block';
}

function buildSqlForComparison(comparison, context) {
    if (!comparison || !context || !context.tableName || !context.idColumnName) {
        return '';
    }

    const tableName = context.tableName;
    const idCol = context.idColumnName;
    const idValueRdb = context.idValueRdb;
    const idValueModern = context.idValueModern;

    const colSet = new Set();
    const diffs = Array.isArray(comparison.column_differences) ? comparison.column_differences : [];
    diffs.forEach(recDiff => {
        const cols = Array.isArray(recDiff.column_differences) ? recDiff.column_differences : [];
        cols.forEach(colDiff => {
            if (colDiff.column) {
                colSet.add(colDiff.column);
            }
        });
    });

    if (idCol) {
        colSet.add(idCol);
    }

    const cols = Array.from(colSet);
    if (!cols.length) {
        return '';
    }

    const selectList = cols.map(c => `[${c}]`).join(', ');

    const whereRdb = idCol ? `[${idCol}] = ${formatSqlValue(idValueRdb)}` : null;
    const whereModern = idCol ? `[${idCol}] = ${formatSqlValue(idValueModern)}` : null;

    const lines = [];
    lines.push('-- RDB');
    lines.push(`SELECT ${selectList}`);
    lines.push(`FROM [RDB].[dbo].[${tableName}]`);
    if (whereRdb) {
        lines.push(`WHERE ${whereRdb};`);
    }
    lines.push('');
    lines.push('-- RDB_MODERN');
    lines.push(`SELECT ${selectList}`);
    lines.push(`FROM [RDB_MODERN].[dbo].[${tableName}]`);
    if (whereModern) {
        lines.push(`WHERE ${whereModern};`);
    }
    lines.push('');

    // For KEY-based tables, also include queries against the mapping table
    if (context.idType === 'KEY' && context.mappingTableName && context.mappingColumn && context.mappingUid !== undefined) {
        const mapTable = context.mappingTableName;
        const mapCol = context.mappingColumn;
        const whereMap = `[${mapCol}] = ${formatSqlValue(context.mappingUid)}`;

        lines.push('-- Mapping table RDB');
        lines.push('SELECT *');
        lines.push(`FROM [RDB].[dbo].[${mapTable}]`);
        lines.push(`WHERE ${whereMap};`);
        lines.push('');

        lines.push('-- Mapping table RDB_MODERN');
        lines.push('SELECT *');
        lines.push(`FROM [RDB_MODERN].[dbo].[${mapTable}]`);
        lines.push(`WHERE ${whereMap};`);
        lines.push('');
    }

    return lines.join('\n');
}

function formatSqlValue(value) {
    if (value === null || value === undefined) {
        return 'NULL';
    }

    if (typeof value === 'number') {
        return String(value);
    }

    const num = Number(value);
    if (!Number.isNaN(num) && String(num) === String(value)) {
        return String(value);
    }

    const s = String(value).replace(/'/g, "''");
    return `'${s}'`;
}

// Load tables when page loads
document.addEventListener('DOMContentLoaded', loadTables);
