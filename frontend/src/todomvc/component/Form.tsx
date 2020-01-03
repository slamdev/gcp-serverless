import React, {useState} from "react";
import {TextField} from "@material-ui/core";

interface Props {
    onSave: (value: string) => void
}

export const Form: React.FunctionComponent<Props> = (props) => {
    const [value, setValue] = useState('');
    const onSubmit = (event: React.SyntheticEvent) => {
        event.preventDefault();
        props.onSave(value);
        setValue('');
    };
    const onChange = (event: React.ChangeEvent<HTMLInputElement>) => {
        setValue(event.target.value);
    };
    return (
        <form onSubmit={onSubmit}>
            <TextField value={value} onChange={onChange} variant="outlined" placeholder="Add todo" margin="normal"/>
        </form>
    );
};
