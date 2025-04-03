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

module.exports = async function (context, message) {
    try {
        context.log('[invite-edit] Processing queue message:', JSON.stringify(message));

        // Input validation
        if (!message?.folderId || !message?.email) {
            throw new ActivityError(
                'INVALID_INPUT',
                'Both folderId and email are required',
                { providedMessage: message }
            );
        }

        const invite = await client.api(`/users/${process.env.DRIVE_USER_ID}/drive/items/${message.folderId}/invite`).post({
            recipients: [{
                email: message.email,
            }],
            roles: ["write"],
            requireSignIn: false,
            sendInvitation: true
        });

        context.log('[invite-edit] Invite sent successfully:', JSON.stringify(invite));

    } catch (error) {
        context.log.error('[invite-edit] Failed:', {
            error: error instanceof ActivityError ? error : {
                code: 'UNEXPECTED_ERROR',
                message: error.message,
                stack: error.stack
            },
            message: message,
            timestamp: new Date().toISOString()
        });

        throw error; // Let the Service Bus handle retry policy
    }
};
