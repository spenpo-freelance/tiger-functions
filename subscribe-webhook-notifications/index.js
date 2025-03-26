const { ClientSecretCredential } = require("@azure/identity");
const { DefaultAzureCredential } = require("@azure/identity");

const credential = new DefaultAzureCredential();

const client = MicrosoftGraph.Client.initWithMiddleware({
    authProvider: credential,
    scopes: ["https://graph.microsoft.com/.default"],
});

module.exports = async function (context, req) {
    context.log("JavaScript HTTP trigger function processed a request.");

    const { name } = req.body;

    if (!name) {
        context.res = {
            status: 400,
            body: "Please pass a name on the query string or in the request body"
        };
        return;
    }

    try {
        const subscription = await client.api("/subscriptions").post({
            changeType: "created",
            notificationUrl: "https://tiger-functions.azurewebsites.net/api/webhook-notifications",
            resource: `/me/drive/root/children/${name}`,
            clientState: "test",
            latestSupportedTlsVersion: "v1_2"
        });

        context.res = {
            status: 200,
            body: subscription
        };
    } catch (error) {
        context.error(error);
        context.res = {
            status: 500,
            body: "Error subscribing to webhook notifications"
        };
    }
}