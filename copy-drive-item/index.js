const { ClientSecretCredential } = require("@azure/identity");
const { ActivityError } = require('../shared/errors');

const credential = new ClientSecretCredential(
    process.env.TENANT_ID,
    process.env.CLIENT_ID,
    process.env.CLIENT_SECRET
);

module.exports = async function (context, input) {
    try {
        context.log('[copy-drive-item] Starting with input:', JSON.stringify(input));

        // Input validation
        if (!input?.name || !input?.parentReference?.id) {
            throw new ActivityError(
                'INVALID_INPUT',
                'Name and parentReference.id are required',
                { providedInput: input }
            );
        }

        // If driveId is not provided, use the default drive
        const parentReference = {
            id: input.parentReference.id,
            ...(input.parentReference.driveId && { driveId: input.parentReference.driveId })
        };

        // Make the copy request
        context.log('[copy-drive-item] Making copy request...');
        
        // Use fetch directly to get access to the raw response
        const fetch = require('isomorphic-fetch');
        const token = await credential.getToken("https://graph.microsoft.com/.default");
        
        const response = await fetch(
            `https://graph.microsoft.com/v1.0/users/${process.env.DRIVE_USER_ID}/drive/items/${process.env.GRADEBOOK_TEMPLATE_ITEM_ID}/copy`,
            {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${token.token}`,
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    parentReference,
                    name: input.name
                })
            }
        );

        context.log('[copy-drive-item] Response status:', response.status);
        context.log('[copy-drive-item] Response headers:', JSON.stringify(Object.fromEntries(response.headers.entries())));

        if (response.status !== 202) {
            throw new ActivityError(
                'COPY_INITIATION_FAILED',
                'Copy operation did not return 202 Accepted',
                { 
                    status: response.status,
                    statusText: response.statusText
                }
            );
        }

        const locationHeader = response.headers.get('location');
        if (!locationHeader) {
            throw new ActivityError(
                'COPY_INITIATION_FAILED',
                'No Location header received from copy operation',
                { 
                    status: response.status,
                    headers: Object.fromEntries(response.headers.entries())
                }
            );
        }

        context.log('[copy-drive-item] Copy operation initiated:', locationHeader);
        return {
            monitoringUrl: locationHeader,
            status: 'inProgress'
        };

    } catch (error) {
        context.log.error('[copy-drive-item] Failed:', {
            error: error instanceof ActivityError ? error : {
                code: 'UNEXPECTED_ERROR',
                message: error.message,
                stack: error.stack
            },
            input: input,
            timestamp: new Date().toISOString()
        });

        if (error instanceof ActivityError) throw error;
        throw new ActivityError(
            'UNEXPECTED_ERROR',
            'An unexpected error occurred while copying drive item',
            { originalError: error.message }
        );
    }
};
