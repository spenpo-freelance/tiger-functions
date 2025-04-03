const MicrosoftGraph = require("@microsoft/microsoft-graph-client");
const { ClientSecretCredential } = require("@azure/identity");
const { ActivityError } = require('../shared/errors');

const credential = new ClientSecretCredential(
    process.env.TENANT_ID,
    process.env.CLIENT_ID,
    process.env.CLIENT_SECRET
);

const client = MicrosoftGraph.Client.initWithMiddleware({
    authProvider: {
        getAccessToken: async () => {
            const token = await credential.getToken("https://graph.microsoft.com/.default");
            return token.token;
        }
    }
});

module.exports = async function (context, input) {
    try {
        context.log('[create-folder] Starting with input:', JSON.stringify(input));

        // Input validation
        if (!input?.name) {
            throw new ActivityError(
                'INVALID_INPUT',
                'Name is required',
                { providedInput: input }
            );
        }

        // Pre-execution checks (e.g., check if folder already exists)
        try {
            const existingFolder = await client.api(`/users/${process.env.DRIVE_USER_ID}/drive/items/${process.env.TEACHERS_DIR_ITEM_ID}/children`)
                .filter(`name eq '${input.name}'`)
                .get();
            
            if (existingFolder.value.length > 0) {
                throw new ActivityError(
                    'FOLDER_EXISTS',
                    `Folder "${input.name}" already exists`,
                    { folderId: existingFolder.value[0].id }
                );
            }
        } catch (error) {
            if (error instanceof ActivityError) throw error;
            // Handle API errors separately
            throw new ActivityError(
                'FOLDER_CHECK_FAILED',
                'Failed to check for existing folder',
                { originalError: error.message }
            );
        }

        // Main execution
        const folder = await client.api(`/users/${process.env.DRIVE_USER_ID}/drive/items/${process.env.TEACHERS_DIR_ITEM_ID}/children`)
            .post({
                name: input.name,
                folder: {}
            });

        context.log('[create-folder] Folder created successfully:', folder.id);
        return folder;

    } catch (error) {
        // Log the error with context
        context.log.error('[create-folder] Failed:', {
            error: error instanceof ActivityError ? error : {
                code: 'UNEXPECTED_ERROR',
                message: error.message,
                stack: error.stack
            },
            input: input,
            timestamp: new Date().toISOString()
        });

        // Always throw a well-structured error
        if (error instanceof ActivityError) {
            throw error;
        }
        throw new ActivityError(
            'UNEXPECTED_ERROR',
            'An unexpected error occurred while creating the folder',
            { originalError: error.message }
        );
    }
};
