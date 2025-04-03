const fetch = require('isomorphic-fetch');
const { ActivityError } = require('../shared/errors');

module.exports = async function (context, message) {
    try {
        context.log('[monitor-copy-status] Starting with message:', JSON.stringify(message));

        // Input validation
        ['monitoringUrl', 'classId'].forEach(field => {
            if (!message[field]) {
                throw new ActivityError(
                    'INVALID_INPUT',
                    `${field} is required`,
                    { providedMessage: message }
                );
            }
        });

        let retryCount = 0;
        const maxRetries = 30; // 5 minutes with 10-second intervals

        do {
            // Get the status directly from the monitoring URL
            const response = await fetch(message.monitoringUrl);
            if (!response.ok) {
                throw new ActivityError(
                    'STATUS_CHECK_FAILED',
                    `Failed to check status: ${response.status} ${response.statusText}`,
                    { url: message.monitoringUrl }
                );
            }

            const status = await response.json();
            context.log('[monitor-copy-status] Status check:', {
                status: status.status,
                percentageComplete: status.percentageComplete,
                retryCount
            });

            if (status.status === 'completed') {
                const body = {
                    gradebook_id: status.resourceId,
                    class_id: message.classId,
                    folder_id: message.folderId
                }
                context.log('[monitor-copy-status] Copy completed successfully:', status.resourceId);
                context.log('[monitor-copy-status] Updating class...', body);
                const response = await fetch(process.env.TIGER_GRADES_BASE_URL + '/wp-json/tiger-grades/v1/update-class', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify(body)
                });

                if (!response.ok) {
                    let errorDetails = { status: response.status, statusText: response.statusText };
                    try {
                        const errorBody = await response.json();
                        errorDetails.message = errorBody.message;
                    } catch (e) {
                        // If we can't parse the response body as JSON, that's okay
                    }
                    
                    throw new ActivityError(
                        'UPDATE_CLASS_FAILED',
                        `Failed to update class: ${response.status} ${response.statusText}`,
                        errorDetails
                    );
                }
            
                const data = await response.json();
                context.log('[monitor-copy-status] Class updated successfully:', data);
                return;
            }

            retryCount++;
            if (retryCount >= maxRetries) {
                throw new ActivityError(
                    'COPY_TIMEOUT',
                    'Copy operation timed out after 5 minutes',
                    { lastStatus: status }
                );
            }

            // Wait 10 seconds before next check
            await new Promise(resolve => setTimeout(resolve, 10000));
        } while (true);

    } catch (error) {
        context.log.error('[monitor-copy-status] Failed:', {
            error: error instanceof ActivityError ? error : {
                code: 'UNEXPECTED_ERROR',
                message: error.message,
                stack: error.stack
            },
            message: message,
            timestamp: new Date().toISOString()
        });

        if (error instanceof ActivityError) throw error;
        throw new ActivityError(
            'UNEXPECTED_ERROR',
            'An unexpected error occurred while monitoring copy status',
            { originalError: error.message }
        );
    }
}; 