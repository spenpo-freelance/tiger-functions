const MicrosoftGraph = require("@microsoft/microsoft-graph-client");
const { ClientSecretCredential } = require("@azure/identity");
const { DefaultAzureCredential } = require("@azure/identity");

const credential = new DefaultAzureCredential();

const client = MicrosoftGraph.Client.initWithMiddleware({
    authProvider: credential,
});

module.exports = async function (context, req) {
    context.log("JavaScript HTTP trigger function processed a request.");
    console.log(req.body);

    const { name } = req.body;
    
    if (!name) {
        context.res = {
            status: 400,
            body: "Please pass a name on the query string or in the request body"
        };
        return;
    }

    try {
        const folder = await client.api("/me/drive/root/children").post({
            name: name,
            folder: {}
        });

        context.res = {
            status: 200,
            body: folder
        };
    } catch (error) {
        context.error(error);
        context.res = {
            status: 500,
            body: "Error creating folder"
        };
    }
};

