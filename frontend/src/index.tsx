import ReactDOM from 'react-dom';
import * as React from "react";
import {CssBaseline} from "@material-ui/core";
import {ThemeProvider} from '@material-ui/styles';
import theme from "./theme";
import {Page} from "./todomvc/Page";
import {Router} from "@reach/router";

ReactDOM.render(
    <ThemeProvider theme={theme}>
        <CssBaseline/>
        <Router>
            <Page path="/*"/>
        </Router>
    </ThemeProvider>,
    document.getElementById('root')
);
