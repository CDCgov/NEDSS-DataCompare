/**
 * Validation Results Reviewer - Main orchestrator class
 * Coordinates data management, state, filtering, rendering, and user interactions
 */

class ValidationResultsReviewer {
    constructor(serverUrl = 'http://localhost:8001') {
        this.serverUrl = serverUrl;
        this.initialized = false;
        
        // Initialize core modules
        this.dataManager = new DataManager(serverUrl);
        this.stateManager = new StateManager();
        this.filterEngine = new FilterEngine(this.dataManager);
        this.uiRenderer = new UIRenderer();
        this.uiController = new UIController(
            this.dataManager,
            this.stateManager,
            this.filterEngine,
            this.uiRenderer
        );
    }

    /**
     * Initialize the application (async)
     */
    async init() {
        try {
            console.log('[App] init() called');
            // Check server health
            console.log('[App] Checking server health...');
            const isHealthy = await this.dataManager.checkHealth();
            console.log('[App] Server health check result:', isHealthy);
            if (!isHealthy) {
                console.error('Server is not responding. Check that the Flask server is running on ' + this.serverUrl);
                this.showError('Cannot connect to server. Is the Flask server running?');
                return;
            }

            console.log('Server is healthy, loading tables...');
            
            // Setup event listeners
            console.log('[App] Setting up event listeners...');
            this.uiController.setupEventListeners();
            console.log('[App] Event listeners set up');
            
            // Load and render tables
            console.log('[App] Rendering tables...');
            await this.render();
            this.initialized = true;
            console.log('Application initialized successfully');
        } catch (error) {
            console.error('Failed to initialize application:', error);
            console.error(error.stack);
            this.showError(`Failed to initialize: ${error.message}`);
        }
    }

    /**
     * Render the initial table list
     */
    async render() {
        try {
            const tables = await this.dataManager.getTableNames();
            console.log(`Loaded ${tables.length} tables`);
            await this.uiController.applyFilters();
        } catch (error) {
            console.error('Failed to render tables:', error);
            this.showError(`Failed to load tables: ${error.message}`);
        }
    }

    /**
     * Show error message to user
     */
    showError(message) {
        const container = document.getElementById('table-list');
        if (container) {
            container.innerHTML = `
                <div style="padding: 20px; background: #fee; color: #c00; border-radius: 4px; margin: 10px;">
                    <strong>Error:</strong> ${message}
                </div>
            `;
        }
    }
}

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    console.log('[Main] DOMContentLoaded fired');
    try {
        const viewer = new ValidationResultsReviewer('http://localhost:8001');
        console.log('[Main] ViewerReviewer created');
        viewer.init().then(() => {
            console.log('[Main] Viewer initialized successfully');
        }).catch(err => {
            console.error('[Main] Error during initialization:', err);
            console.error(err.stack);
        });
    } catch (error) {
        console.error('[Main] EXCEPTION during viewer creation:', error);
        console.error(error.stack);
    }
});
