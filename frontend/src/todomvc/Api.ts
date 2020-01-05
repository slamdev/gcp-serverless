import {TodoMVC} from "../generated/lib/todoMVC";
import {ServiceClientCredentials} from "@azure/ms-rest-js/lib/credentials/serviceClientCredentials";
import {WebResource} from "@azure/ms-rest-js/lib/webResource";
import {Item, ItemsListResponse, SaveItemRequest} from "../generated/lib/models";
import {RestError} from "@azure/ms-rest-js";

const env = 'dev';

export const getItems = (): Promise<Item[]> => api.getItems(env)
    .then((r: ItemsListResponse) => Promise.resolve(r.items))
    .catch((e: RestError) => {
        console.error(e.message);
        return Promise.resolve([]);
    });

export const deleteItem = (id: string): Promise<void> => api.deleteItem(env, id)
    .catch((e: RestError) => {
        console.error(e.message);
        return Promise.resolve();
    }) as Promise<void>;

export const saveItem = (item: Item): Promise<void> => {
    const request: SaveItemRequest = {name: item.name, completed: item.completed};
    return api.saveItem(env, request, item.id)
        .catch((e: RestError) => {
            console.error(e.message);
            return Promise.resolve();
        }) as Promise<void>;
};

const fetchToken = () => new Promise<string>(resolve => resolve('asdZXC'));

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
