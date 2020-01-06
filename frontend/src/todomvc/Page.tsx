import React, {useEffect, useRef, useState} from "react";
import {Typography} from "@material-ui/core";
import {Form} from "./component/Form";
import {ItemsList} from "./component/ItemsList";
import {RouteComponentProps} from '@reach/router';
import * as Api from "./Api";
import {Item} from "../generated/lib/models";

const useItems = () => {
    const componentIsMounted = useRef(true);
    const [items, setItems] = useState([] as Item[]);
    useEffect(() => {
        Api.getItems().then(items => {
            if (componentIsMounted.current) {
                setItems(items);
            }
        });
        return () => {
            componentIsMounted.current = false;
        };
    }, []);
    const onSave = (name: string) => {
        Api.saveItem(name, false).then(() => Api.getItems().then(items => setItems(items)));
    };
    const onDelete = (id: string) => {
        Api.deleteItem(id).then(() => Api.getItems().then(items => setItems(items)));
    };
    const onCheck = (id: string, checked: boolean) => {
        items.filter(item => item.id == id).forEach(item => {
            Api.saveItem(item.name, checked, item.id).then(() => Api.getItems().then(items => setItems(items)));
        });
    };
    return [items, onSave, onDelete, onCheck] as const;
};

export const Page: React.FunctionComponent<RouteComponentProps> = () => {
    const [items, onSave, onDelete, onCheck] = useItems();
    return (
        <div className="App">
            <Typography component="h1" variant="h2">Todos</Typography>
            <Form onSave={onSave}/>
            <ItemsList items={items} onDelete={onDelete} onCheck={onCheck}/>
        </div>
    );
};
