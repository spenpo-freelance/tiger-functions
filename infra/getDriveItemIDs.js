// getDriveItemIds.js

import { Client } from "@microsoft/microsoft-graph-client";
import { ClientSecretCredential } from "@azure/identity";
import "isomorphic-fetch"; // Required for Graph client

const [
    , , // skip node and script path
    tenantId,
    clientId,
    clientSecret,
    userId,
    path
] = process.argv;

const credential = new ClientSecretCredential(tenantId, clientId, clientSecret);

const client = Client.initWithMiddleware({
  authProvider: {
    getAccessToken: async () =>
      (await credential.getToken("https://graph.microsoft.com/.default")).token,
  },
});

(async () => {
    try {
        const item = await client
        .api(`/users/${userId}/drive/root:${path}`)
        .get();
        console.log(item.id);
    } catch (error) {
        console.error(`❌ ${path} → ${error.message}`);
    }
})();
