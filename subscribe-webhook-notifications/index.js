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
        context.log('[subscribe-webhook] Starting with input:', JSON.stringify(input));

        // Input validation
        if (!input?.folderId || !input?.userId) {
            throw new ActivityError(
                'INVALID_INPUT',
                'Both folderId and userId are required',
                { providedInput: input }
            );
        }

        context.log('[subscribe-webhook] Validating input values:', {
            folderId: input.folderId,
            userId: input.userId,
            userIdType: typeof input.userId
        });

        const subscription = await client.api("/subscriptions").post({
            changeType: "updated",
            notificationUrl: `${process.env.FUNCTION_APP_BASE_URL}/api/update-class-webhook`,
            resource: "/drive/root",
            clientState: String(input.userId),
            latestSupportedTlsVersion: "v1_2",
            expirationDateTime: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
            notificationContentType: "application/json"
        });

        context.log('[subscribe-webhook] Subscription created successfully:', subscription.id);
        return subscription;

    } catch (error) {
        context.log.error('[subscribe-webhook] Failed:', {
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
            'An unexpected error occurred while creating subscription',
            { originalError: error.message }
        );
    }
};
