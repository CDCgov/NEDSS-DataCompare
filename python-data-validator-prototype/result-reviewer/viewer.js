/**
 * Validation Results Reviewer - Main orchestrator class
 * Coordinates data management, state, filtering, rendering, and user interactions
 */

class ValidationResultsReviewer {
    constructor(data) {
        // Initialize core modules
        this.dataManager = new DataManager(data);
        this.stateManager = new StateManager();
        this.filterEngine = new FilterEngine(this.dataManager);
        this.uiRenderer = new UIRenderer();
        this.uiController = new UIController(
            this.dataManager,
            this.stateManager,
            this.filterEngine,
            this.uiRenderer
        );

        console.log(`Found ${this.dataManager.getTableNames().length} tables`);
        this.init();
    }

    /**
     * Initialize the application
     */
    init() {
        this.uiController.setupEventListeners();
        this.render();
    }

    /**
     * Render the initial table list
     */
    render() {
        const tables = this.dataManager.getTableNames();
        this.uiController.applyFilters();
    }
}

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    new ValidationResultsReviewer(window.VALIDATION_DATA || {});
});
