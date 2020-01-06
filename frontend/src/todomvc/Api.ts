import {TodoMVC} from "../generated/lib/todoMVC";
import {ServiceClientCredentials} from "@azure/ms-rest-js/lib/credentials/serviceClientCredentials";
import {WebResource} from "@azure/ms-rest-js/lib/webResource";
import {SaveItemRequest} from "../generated/lib/models";

const env = 'dev';

export async function getItems() {
    try {
        const response = await api.getItems(env);
        return response.items;
    } catch (e) {
        console.error(e.message);
        return [];
    }
}

export async function deleteItem(id: string) {
    try {
        await api.deleteItem(env, id);
    } catch (e) {
        console.error(e.message);
    }
}

export async function saveItem(name: string, completed: boolean, id?: string) {
    if (!id) {
        id = 'generated';
    }
    const request: SaveItemRequest = {name, completed};
    try {
        await api.saveItem(env, request, id);
    } catch (e) {
        console.error(e.message);
    }
}

async function fetchToken() {
    return 'asdZXC';
}

class TokenCredentials implements ServiceClientCredentials {
    tokenAccessor: Promise<string>;

    constructor(tokenAccessor: Promise<string>) {
        if (!tokenAccessor) {
            throw new Error("tokenAccessor cannot be null or undefined.");
        }
        this.tokenAccessor = tokenAccessor;
    }

    signRequest(webResource: WebResource) {
        return this.tokenAccessor.then(token => {
            webResource.headers.set("authorization", `"Bearer" ${token}`);
            return Promise.resolve(webResource);
        });
    }
}

// @ts-ignore
const api = new TodoMVC(new TokenCredentials(fetchToken()));
