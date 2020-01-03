import React from "react";
import {Checkbox, IconButton, List, ListItem, ListItemSecondaryAction, ListItemText} from "@material-ui/core";
import DeleteIcon from "@material-ui/icons/Delete";
import Item from "../Item";

interface Props {
    onDelete: (id: string) => void
    onCheck: (id: string, checked: boolean) => void
    items: Array<Item>
}

export const ItemsList: React.FunctionComponent<Props> = (props) => (
    <List>
        {props.items.map((item: Item) => (
            <ListItem key={item.id} dense button>
                <Checkbox tabIndex={-1} disableRipple checked={item.completed} onChange={(_, checked) => props.onCheck(item.id, checked)}/>
                <ListItemText primary={item.name}/>
                <ListItemSecondaryAction>
                    <IconButton aria-label="Delete" onClick={() => props.onDelete(item.id)}>
                        <DeleteIcon/>
                    </IconButton>
                </ListItemSecondaryAction>
            </ListItem>
        ))}
    </List>
);
