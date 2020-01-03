import path from 'path';
import webpack from 'webpack';
import HtmlWebpackPlugin from 'html-webpack-plugin';

const config: webpack.Configuration = {
    stats: "minimal",

    entry: './src/index',

    devServer: {
        historyApiFallback: true
    },

    output: {
        path: path.join(__dirname, '/dist'),
        filename: 'bundle.js'
    },

    resolve: {
        extensions: ['.ts', '.tsx', '.js']
    },

    module: {
        rules: [
            {
                test: /\.(ts|js)x?$/,
                exclude: /node_modules/,
                use: {
                    loader: 'babel-loader',
                    options: {
                        presets: [
                            // [
                            //     '@babel/preset-env',
                            //     {
                            //         targets: {
                            //             browsers: [
                            //                 'last 2 versions'
                            //             ]
                            //         },
                            //         modules: false // Needed for tree shaking to work.
                            //     }
                            // ],
                            '@babel/preset-env',
                            '@babel/preset-react',
                            '@babel/typescript',
                        ],
                        plugins: [
                            '@babel/plugin-proposal-object-rest-spread',
                            '@babel/plugin-proposal-class-properties',
                        ]
                    }
                }
            },

            {
                test: /\.css$/,
                use: ['style-loader', 'css-loader']
            }
        ]
    },

    plugins: [
        new HtmlWebpackPlugin({template: './src/index.html'})
    ]
};

// noinspection JSUnusedGlobalSymbols
export default config;
