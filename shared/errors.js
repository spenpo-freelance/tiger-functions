class ActivityError extends Error {
    constructor(code, message, details = null) {
        super(message);
        this.name = 'ActivityError';  // Add name for better error identification
        this.code = code;
        this.details = details;
    }
}

class OrchestrationError extends Error {
    constructor(code, message, details = null) {
        super(message);
        this.name = 'OrchestrationError';
        this.code = code;
        this.details = details;
    }
}

module.exports = {
    ActivityError,
    OrchestrationError
}; 