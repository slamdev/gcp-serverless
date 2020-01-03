import React, {useState} from "react";
import {Typography} from "@material-ui/core";
import {Form} from "./component/Form";
import {ItemsList} from "./component/ItemsList";
import Item from "./Item";
import {RouteComponentProps} from '@reach/router';

const useItems = () => {
    const [items, setItems] = useState([] as Array<Item>);
    const onSave = (name: string) => {
        setItems([...items, {name: name, completed: false, id: name}]);
    };
    const onDelete = (id: string) => {
        const newItems = items.filter((item) => item.id !== id);
        setItems(newItems);
    };
    const onCheck = (id: string, checked: boolean) => {
        const newItems = items.map((item) => {
            if (item.id == id) {
                item.completed = checked;
            }
            return item;
        });
        setItems(newItems);
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
