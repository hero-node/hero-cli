const webpack = require('webpack')
const ParallelUglifyPlugin = require('webpack-parallel-uglify-plugin')
const merge = require('webpack-merge')
const AppCachePlugin = require('appcache-webpack-plugin')
const CopyWebpackPlugin = require('copy-webpack-plugin')
const CompressionWebpackPlugin = require('compression-webpack-plugin')

const baseConfig = require('./webpack.base.conf')
const { resolve, getUserConfig } = require('./utils')
const { build } = getUserConfig()
const publicPath = build.publicPath

module.exports = merge(baseConfig, {
  output: {
    filename: 'js/[name].[chunkhash:8].js',
    chunkFilename: 'js/[name].[chunkhash:8].js'
  },
  devtool: '#source-map',
  plugins: [
    new webpack.DefinePlugin({
      'process.env': JSON.stringify(Object.assign({
        HOME_PAGE: publicPath
      }, build.env))
    }),
    new ParallelUglifyPlugin({
      cacheDir: 'node_modules/.cache/uglify',
      sourceMap: build.sourceMap,
      uglifyJS: {
        output: {
          comments: false
        },
        compress: {
          warnings: false
        }
      }
    }),
    new CompressionWebpackPlugin({
      asset: '[path].gz[query]',
      algorithm: 'gzip',
      test: new RegExp(
        '\\.(js)$'
      ),
      threshold: 10240,
      minRatio: 0.8
    }),
    new AppCachePlugin({
      output: 'app.appcache',
      exclude: build.appCacheExclude
    }),
    new CopyWebpackPlugin([
      {
        from: resolve('public'),
        to: resolve('dist'),
        ignore: ['.*']
      }
    ])
  ]
})
