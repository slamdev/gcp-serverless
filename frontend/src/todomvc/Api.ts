import {TodoMVC} from "../generated/lib/todoMVC";
import {TokenCredentials} from "@azure/ms-rest-js";

export const getItems = () => {
    const creds = new TokenCredentials('asdZXC');
    const api = new TodoMVC(creds);
    return api.getItems('dev');
};
