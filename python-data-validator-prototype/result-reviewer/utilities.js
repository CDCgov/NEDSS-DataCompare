/**
 * Utilities Module - Shared helper functions
 */

class Utilities {
    /**
     * Format display value (handle null, truncate large values)
     */
    static formatDisplayValue(value) {
        if (value === null) return '(null)';
        const strVal = String(value);
        return strVal.length > 50 ? strVal.substring(0, 50) : strVal;
    }

    /**
     * Generate unique key for container tracking
     */
    static createContainerKey(...parts) {
        return parts.join(':');
    }

    /**
     * Copy text to clipboard with visual feedback
     */
    static copyToClipboard(text, button) {
        navigator.clipboard.writeText(text).then(() => {
            Utilities.showCopyFeedback(button);
        }).catch(() => {
            // Fallback for older browsers
            const textarea = document.createElement('textarea');
            textarea.value = text;
            document.body.appendChild(textarea);
            textarea.select();
            document.execCommand('copy');
            document.body.removeChild(textarea);
            Utilities.showCopyFeedback(button);
        });
    }

    /**
     * Show visual feedback after copy operation
     */
    static showCopyFeedback(button) {
        const originalText = button.textContent;
        button.textContent = '✓';
        button.style.backgroundColor = '#dcfce7';
        button.style.borderColor = '#4ade80';
        button.style.color = '#166534';

        setTimeout(() => {
            button.textContent = originalText;
            button.style.backgroundColor = '';
            button.style.borderColor = '';
            button.style.color = '';
        }, 2000);
    }

    /**
     * Generate SQL query snippet for differing columns
     */
    static generateSqlQuery(tableName, uidColumn, uidValue, diffColumns) {
        const columnList = `[${uidColumn}], ${Array.from(diffColumns).sort().map(col => `[${col}]`).join(', ')}`;
        const uidValueForSQL = typeof uidValue === 'string' ? `'${uidValue.replace(/'/g, "''")}'` : uidValue;

        return `-- RDB\nSELECT ${columnList} FROM [RDB].[dbo].[${tableName}] WHERE [${uidColumn}] = ${uidValueForSQL}\n\n-- RDB_MODERN\nSELECT ${columnList} FROM [RDB_MODERN].[dbo].[${tableName}] WHERE [${uidColumn}] = ${uidValueForSQL}`;
    }

    /**
     * Create a styled badge element
     */
    static createBadge(text, type = 'default') {
        const badge = document.createElement('div');
        const styles = {
            'col-diff': 'bg-red-100 border border-red-300 text-red-700',
            'record-mismatch': 'bg-yellow-100 border border-yellow-300 text-yellow-700',
            'success': 'bg-green-100 border border-green-400 text-green-800',
            'warning': 'bg-yellow-100 border border-yellow-400 text-yellow-800',
            'error': 'bg-red-100 border border-red-400 text-red-800',
            'default': 'bg-gray-100 border border-gray-300 text-gray-700'
        };

        badge.className = `px-2 py-1 rounded-sm text-xs font-semibold whitespace-nowrap ${styles[type] || styles.default}`;
        badge.textContent = text;
        return badge;
    }
}
