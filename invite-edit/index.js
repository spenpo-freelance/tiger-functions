const MicrosoftGraph = require("@microsoft/microsoft-graph-client");
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
        const driveItem = await client.api(`/me/drive/root/children/${name}`).get();
        
        const invite = await client.api(`/me/drive/root/children/${name}/invite`).post({
            recipients: [{
                email: "test@test.com"
            }],
            roles: ["write"]
        });

        context.res = {
            status: 200,
            body: invite
        };
    } catch (error) {
        context.error(error);
        context.res = {
            status: 500,
            body: "Error inviting user"
        };
    }
}