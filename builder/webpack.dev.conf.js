const merge = require('webpack-merge')
const webpack = require('webpack')
const path = require('path')
const FriendlyErrorsPlugin = require('friendly-errors-webpack-plugin')

const { getUserConfig, resolve } = require('./utils')
const baseConfig = require('./webpack.base.conf')
const { dev } = getUserConfig()

const publicPath = dev.publicPath

const client = path.resolve(__dirname, './dev-client')
Object.keys(baseConfig.entry).forEach((name) => {
    baseConfig.entry[name] = [client].concat(baseConfig.entry[name])
})

module.exports = merge(baseConfig, {
    output: {
        publicPath
    },
    module: {
        rules: [
            {
                test: /\.(js)$/,
                loader: 'eslint-loader',
                enforce: 'pre',
                include: [resolve('src'), resolve('test')]
            }
        ]
    },
    devtool: '#cheap-module-source-map',
    plugins: [
        new webpack.NoEmitOnErrorsPlugin(),
        new webpack.HotModuleReplacementPlugin(),
        new FriendlyErrorsPlugin(),
        new webpack.DefinePlugin({
            'process.env': JSON.stringify(Object.assign({
                HOME_PAGE: publicPath
            }, dev.env))
        })
    ]
})
