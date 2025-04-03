const df = require('durable-functions');

module.exports = async function (context, req) {
    const client = df.getClient(context);
    const { function_name, data } = req.body;
    
    if (!function_name) {
        return {
            status: 400,
            body: "Function name is required in the request body"
        };
    }

    const instanceId = await client.startNew(function_name, undefined, data);

    context.log(`Started orchestration with ID = '${instanceId}'.`);

    return client.createCheckStatusResponse(context.bindingData.req, instanceId);
};
