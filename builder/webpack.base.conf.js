const path = require('path')
const webpack = require('webpack')
const merge = require('webpack-merge')
const HtmlWebpackPlugin = require('html-webpack-plugin')
const HappyPack = require('happypack')
const os = require('os')

const { getEntries, renameByRouter, getUserConfig, resolve } = require('./utils')
const userConfig = getUserConfig()
const entry = renameByRouter(getEntries('src/pages'), userConfig.router)

const config = {
    context: path.resolve(__dirname, '../'),
    entry,
    output: {
        path: resolve('dist'),
        filename: '[name].js'
    },
    resolve: {
        extensions: ['.js', '.vue', '.json'],
        alias: {
            '@': resolve('src')
        }
    },
    module: {
        rules: [
            {
                test: /\.js$/,
                loader: 'HappyPack/loader?id=js',
                include: [resolve('src'), resolve('test')]
            },
            {
                test: /\.(png|jpe?g|gif|svg)(\?.*)?$/,
                loader: 'file-loader',
                options: {
                    name: 'img/[name].[hash:7].[ext]'
                }
            },
        ]
    },
    plugins: [
        new HappyPack({
            id: 'js',
            threadPool: HappyPack.ThreadPool({ size: os.cpus().length }),
            loaders: [{
                path: 'babel-loader',
                query: {
                    cacheDirectory: 'node_modules/.cache/babel'
                }
            }]
        }),
        new webpack.optimize.CommonsChunkPlugin({
            name: 'commons',
            minChunks: 3
        }),
        new webpack.optimize.CommonsChunkPlugin({
            name: 'vendor',
            minChunks(module) {
                return (module.context && module.context.indexOf('node_modules') !== -1)
            }
        }),
        new webpack.optimize.CommonsChunkPlugin({
            name: 'manifest',
            chunks: ['vendor', 'commons']
        })
    ]
}

module.exports = merge(config, {
    plugins: Object.keys(config.entry).map((file) => {
        const chunks = ['manifest', 'vendor', 'commons', file]
        return new HtmlWebpackPlugin({
            chunks,
            filename: file + '.html',
            template: resolve('index.html'),
            inject: true,
            NODE_ENV: process.env.NODE_ENV,
            minify: {
                removeComments: true,
                collapseWhitespace: true,
                removeAttributeQuotes: true
            },
            chunksSortMode: (a, b) => chunks.indexOf(a.names[0]) - chunks.indexOf(b.names[0])
        })
    })
})
