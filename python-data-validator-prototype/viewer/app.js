/**
 * Results Viewer Frontend
 *
 * - Loads tables from /api/tables
 * - Applies search and filter controls
 * - Lets user drill into UID- and KEY-based comparisons
 */

function computeTableFlags(data) {
    const result = {
        hasColumnDifferences: false,
        hasRecordCountDifferences: false,
        isKeyOnly: false,
        isUidOnly: false,
    };

    if (!data) {
        return result;
    }

    const uidVal = data.uid_validation;
    const keyVal = data.key_validation;

    let hasUid = false;
    let hasKey = false;

    if (uidVal && !uidVal.error) {
        hasUid = true;
        const byCol = uidVal.results_by_uid_column || {};
        Object.values(byCol).forEach(colData => {
            const uidValues = (colData && colData.uid_values) || [];
            uidValues.forEach(item => {
                const cmp = item && item.comparison;
                if (!cmp) return;
                if (cmp.has_differences) {
                    result.hasColumnDifferences = true;
                }
                if (Array.isArray(cmp.column_differences) && cmp.column_differences.length > 0) {
                    result.hasColumnDifferences = true;
                }
                if (cmp.record_counts_match === false) {
                    result.hasRecordCountDifferences = true;
                }
            });
        });
    }

    if (keyVal && !keyVal.error) {
        hasKey = true;
        const byCol = keyVal.results_by_key_column || {};
        Object.values(byCol).forEach(colData => {
            const records = (colData && colData.records_by_mapping_uid) || {};
            Object.values(records).forEach(entry => {
                const cmp = entry && entry.comparison;
                if (!cmp) return;
                if (cmp.has_differences) {
                    result.hasColumnDifferences = true;
                }
                if (Array.isArray(cmp.column_differences) && cmp.column_differences.length > 0) {
                    result.hasColumnDifferences = true;
                }
                if (cmp.record_counts_match === false) {
                    result.hasRecordCountDifferences = true;
                }
            });
        });
    }

    result.isUidOnly = hasUid && !hasKey;
    result.isKeyOnly = hasKey && !hasUid;

    return result;
}

async function loadTables() {
    const loadingEl = document.getElementById('loading');
    const errorEl = document.getElementById('error');
    const listEl = document.getElementById('tableList');
    const searchInput = document.getElementById('tableSearch');
    const filterSelect = document.getElementById('tableFilter');

    try {
        const response = await fetch('/api/tables');
        if (!response.ok) throw new Error(`HTTP ${response.status}`);

        const data = await response.json();
        const tableNames = (data.tables || []).map(t => t.name);

        if (tableNames.length === 0) {
            loadingEl.textContent = 'No tables found';
            return;
        }

        loadingEl.textContent = 'Loading table details...';

        const metaPromises = tableNames.map(async (name) => {
            try {
                const respTable = await fetch(`/api/table/${encodeURIComponent(name)}`);
                if (!respTable.ok) {
                    throw new Error(`HTTP ${respTable.status}`);
                }
                const tableData = await respTable.json();
                const flags = computeTableFlags(tableData);
                return { name, ...flags };
            } catch (e) {
                console.error('Failed to load table details for', name, e);
                return {
                    name,
                    hasColumnDifferences: false,
                    hasRecordCountDifferences: false,
                    isKeyOnly: false,
                    isUidOnly: false,
                };
            }
        });

        const tableMeta = await Promise.all(metaPromises);
        tableMeta.sort((a, b) => a.name.localeCompare(b.name));
        window._allTables = tableMeta;

        function renderTableList(searchText, filterValue) {
            const term = (searchText || '').toLowerCase();
            const filter = filterValue || '';
            listEl.innerHTML = '';

            const itemsToShow = window._allTables.filter(meta => {
                if (term && !meta.name.toLowerCase().includes(term)) {
                    return false;
                }

                if (!filter) return true;

                switch (filter) {
                    case 'hasColumnDifferences':
                        return !!meta.hasColumnDifferences;
                    case 'hasRecordCountDifferences':
                        return !!meta.hasRecordCountDifferences;
                    case 'isKeyBased':
                        return !!meta.isKeyOnly;
                    case 'isUidBased':
                        return !!meta.isUidOnly;
                    default:
                        return true;
                }
            });

            itemsToShow.forEach(meta => {
                const tableName = meta.name;
                const li = document.createElement('li');

                const button = document.createElement('button');
                button.type = 'button';

                const baseClasses = 'table-button btn btn-sm w-100 text-start d-flex justify-content-between align-items-center';
                let stateClasses = 'btn-outline-primary';

                if (meta.hasColumnDifferences) {
                    stateClasses = 'btn-outline-danger table-button-col-diff';
                } else if (meta.hasRecordCountDifferences && !meta.hasColumnDifferences) {
                    stateClasses = 'btn-outline-warning table-button-rec-mismatch';
                }

                button.className = `${baseClasses} ${stateClasses}`;
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

        const initialSearch = searchInput ? searchInput.value : '';
        const initialFilter = filterSelect ? filterSelect.value : '';
        renderTableList(initialSearch, initialFilter);

        if (searchInput) {
            searchInput.addEventListener('input', () => {
                renderTableList(searchInput.value, filterSelect ? filterSelect.value : '');
            });
        }

        if (filterSelect) {
            filterSelect.addEventListener('change', () => {
                renderTableList(searchInput ? searchInput.value : '', filterSelect.value);
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
            const cmp = item.comparison;

            if (!cmp) {
                btn.className = 'tree-column-button btn btn-sm btn-secondary disabled uid-value-no-data';
                btn.disabled = true;
            } else {
                const hasColumnDiffs = Array.isArray(cmp.column_differences) && cmp.column_differences.length > 0;
                const hasRecordCountMismatch = cmp.record_counts_match === false;

                let colorClasses;
                if (hasColumnDiffs) {
                    colorClasses = 'btn-outline-danger uid-value-diff';
                } else if (hasRecordCountMismatch) {
                    colorClasses = 'btn-outline-warning uid-value-rec-mismatch';
                } else {
                    colorClasses = 'btn-outline-success uid-value-ok';
                }

                btn.className = 'tree-column-button btn btn-sm ' + colorClasses;
            }

            btn.textContent = String(item.uid_value);

            const detailsEl = document.createElement('div');
            detailsEl.className = 'uid-comparison-details';
            detailsEl.style.display = 'none';

            if (cmp) {
                btn.addEventListener('click', () => {
                    onUidValueClicked(tableName, columnName, item, detailsEl);
                });
            }

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
            const cmp = entry.comparison;

            if (!cmp) {
                btn.className = 'tree-column-button btn btn-sm btn-secondary disabled uid-value-no-data';
                btn.disabled = true;
            } else {
                const hasColumnDiffs = Array.isArray(cmp.column_differences) && cmp.column_differences.length > 0;
                const hasRecordCountMismatch = cmp.record_counts_match === false;

                let colorClasses;
                if (hasColumnDiffs) {
                    colorClasses = 'btn-outline-danger uid-value-diff';
                } else if (hasRecordCountMismatch) {
                    colorClasses = 'btn-outline-warning uid-value-rec-mismatch';
                } else {
                    colorClasses = 'btn-outline-success uid-value-ok';
                }

                btn.className = 'tree-column-button btn btn-sm ' + colorClasses;
            }

            btn.textContent = `${mappingColName}: ${entry.mapping_uid}`;

            const detailsEl = document.createElement('div');
            detailsEl.className = 'uid-comparison-details';
            detailsEl.style.display = 'none';

            if (cmp) {
                btn.addEventListener('click', () => {
                    onKeyMappingUidClicked(tableName, columnName, mappingTableName, mappingColName, entry, detailsEl);
                });
            }

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
        idType: 'UID',
    });
}

function onKeyMappingUidClicked(tableName, columnName, mappingTableName, mappingColName, entry, detailsEl) {
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
        mappingTableName,
    });
}

function renderComparisonDetails(comparison, detailsEl, context) {
    if (!comparison) {
        detailsEl.style.display = 'block';
        detailsEl.textContent = 'No comparison details.';
        return;
    }

    detailsEl.innerHTML = '';
    const diffs = Array.isArray(comparison.column_differences) ? comparison.column_differences : [];
    const hasColumnDiffs = diffs.length > 0;
    const hasRecordCountMismatch = comparison.record_counts_match === false;

    const summary = document.createElement('div');
    summary.className = 'tree-value-text small mb-2';

    const rdbCount = typeof comparison.rdb_count === 'number' ? comparison.rdb_count : 0;
    const modernCount = typeof comparison.rdb_modern_count === 'number' ? comparison.rdb_modern_count : 0;
    const countsMatch = !!comparison.record_counts_match;
    const hasDiffs = !!comparison.has_differences;

    const lines = [];

    if (context && context.idType === 'KEY' && context.mappingTableName && context.mappingColumn && context.mappingUid !== undefined) {
        lines.push(`<div><strong>Mapping table:</strong> ${context.mappingTableName}</div>`);
        lines.push(`<div><strong>Mapping UID column:</strong> ${context.mappingColumn}</div>`);
        lines.push(`<div><strong>Mapping UID value:</strong> ${context.mappingUid}</div>`);
    }

    lines.push(`<div><strong>RDB records:</strong> ${rdbCount}</div>`);
    lines.push(`<div><strong>RDB_MODERN records:</strong> ${modernCount}</div>`);

    const countsBadgeClass = countsMatch
        ? 'badge bg-success-subtle text-success-emphasis border border-success-subtle'
        : 'badge bg-danger-subtle text-danger-emphasis border border-danger-subtle';
    const diffsBadgeClass = hasDiffs
        ? 'badge bg-danger-subtle text-danger-emphasis border border-danger-subtle'
        : 'badge bg-success-subtle text-success-emphasis border border-success-subtle';

    lines.push(
        `<div class="mt-1">` +
            `<span class="me-2"><strong>Record counts match:</strong> <span class="${countsBadgeClass}">${countsMatch ? 'Yes' : 'No'}</span></span>` +
            `<span><strong>Column differences:</strong> <span class="${diffsBadgeClass}">${hasDiffs ? 'Yes' : 'No'}</span></span>` +
        `</div>`
    );

    summary.innerHTML = lines.join('');
    detailsEl.appendChild(summary);

    if (!hasColumnDiffs) {
        const msg = document.createElement('div');
        msg.className = 'tree-value-text small mt-1';

        const idLabel = context && context.idType === 'KEY' ? 'mapping UID' : 'UID';

        if (hasRecordCountMismatch) {
            if (rdbCount === 0 && modernCount > 0) {
                msg.textContent = `Record count mismatch only: RDB has 0 records, RDB_MODERN has ${modernCount}. Only RDB_MODERN has records for this ${idLabel}.`;
            } else if (modernCount === 0 && rdbCount > 0) {
                msg.textContent = `Record count mismatch only: RDB has ${rdbCount} record(s), RDB_MODERN has 0. Only RDB has records for this ${idLabel}.`;
            } else {
                msg.textContent = `Record count mismatch only: RDB has ${rdbCount} record(s), RDB_MODERN has ${modernCount}.`;
            }
        } else {
            msg.textContent = `No column differences; record counts match for this ${idLabel}.`;
        }

        detailsEl.appendChild(msg);
    } else {
        const wrapper = document.createElement('div');
        wrapper.className = 'uid-comparison-wrapper table-responsive mt-1';

        const table = document.createElement('table');
        table.className = 'uid-comparison-table table table-sm table-bordered table-striped align-middle mb-2';

        const thead = document.createElement('thead');
        thead.innerHTML = '<tr><th>Record Index</th><th>Column</th><th>RDB Value</th><th>RDB_MODERN</th></tr>';
        table.appendChild(thead);

        const tbody = document.createElement('tbody');

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

        table.appendChild(tbody);
        wrapper.appendChild(table);
        detailsEl.appendChild(wrapper);
    }

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

                const originalText = copyBtn.textContent;
                const originalClass = copyBtn.className;
                copyBtn.textContent = 'Copied!';
                copyBtn.className = 'sql-copy-button btn btn-success btn-sm mt-1';
                copyBtn.disabled = true;

                setTimeout(() => {
                    copyBtn.textContent = originalText;
                    copyBtn.className = originalClass;
                    copyBtn.disabled = false;
                }, 1200);
            } catch (e) {
                console.error('Failed to copy SQL', e);
                const originalText = copyBtn.textContent;
                copyBtn.textContent = 'Copy failed';
                copyBtn.classList.remove('btn-outline-secondary', 'btn-success');
                copyBtn.classList.add('btn-danger');
                setTimeout(() => {
                    copyBtn.textContent = originalText;
                    copyBtn.classList.remove('btn-danger');
                    copyBtn.classList.add('btn-outline-secondary');
                }, 1500);
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
    const hasColumnDiffs = diffs.length > 0;
    const hasRecordCountMismatch = comparison.record_counts_match === false;
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
    if (hasColumnDiffs && !cols.length) {
        return '';
    }

    const selectList = hasColumnDiffs ? cols.map(c => `[${c}]`).join(', ') : '*';

    const whereRdb = idCol ? `[${idCol}] = ${formatSqlValue(idValueRdb)}` : null;
    const whereModern = idCol ? `[${idCol}] = ${formatSqlValue(idValueModern)}` : null;

    const lines = [];

    if (hasRecordCountMismatch && !hasColumnDiffs) {
        const rdbCount = typeof comparison.rdb_count === 'number' ? comparison.rdb_count : 0;
        const modernCount = typeof comparison.rdb_modern_count === 'number' ? comparison.rdb_modern_count : 0;

        if (rdbCount > 0 && modernCount === 0) {
            lines.push('-- RDB (records present; RDB_MODERN has none)');
            lines.push(`SELECT ${selectList}`);
            lines.push(`FROM [RDB].[dbo].[${tableName}]`);
            if (whereRdb) {
                lines.push(`WHERE ${whereRdb};`);
            }
            lines.push('');
        } else if (modernCount > 0 && rdbCount === 0) {
            lines.push('-- RDB_MODERN (records present; RDB has none)');
            lines.push(`SELECT ${selectList}`);
            lines.push(`FROM [RDB_MODERN].[dbo].[${tableName}]`);
            if (whereModern) {
                lines.push(`WHERE ${whereModern};`);
            }
            lines.push('');
        } else {
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
        }
    } else {
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
    }

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

// Initialize
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', loadTables);
} else {
    loadTables();
}
