'use strict'

let runInDefault = (global.options.webpackConfig === undefined)
let pathConfigPrefix = runInDefault ? '.' : 'hero-cli/config'
let extend = require('extend')
let webpack = require('webpack')
let AppCachePlugin = require('appcache-webpack-plugin')
let webConfig = require('./webpack.config.common')
let ManifestPlugin = require('webpack-manifest-plugin')
let getDynamicEntries = require(pathConfigPrefix + '/getDynamicEntries')

let options = global.options
let paths = global.paths
let heroCliConfig = global.defaultCliConfig
let homePageConfig = global.homePageConfigs

let dynamicEntries = getDynamicEntries(false)

webConfig.output = {
  // The build folder.
  path: paths.appBuild,
  // Generated JS file names (with nested folders).
  // There will be one main bundle, and one file per asynchronous chunk.
  // We don't currently advertise code splitting but Webpack supports it.
  // filename: 'static/js/[name].js',
  // chunkFilename: 'static/js/[name].chunk.js',
  filename: options.noHashName ? 'static/js/[name].js' : 'static/js/[name].[chunkhash:8].js',
  chunkFilename: options.noHashName ? 'static/js/[name].chunk.js' : 'static/js/[name].[chunkhash:8].chunk.js',
  // We inferred the "public path" (such as / or /my-project) from homepage.
  publicPath: homePageConfig.getServedPath
}

webConfig.entry = dynamicEntries.entry
webConfig.plugins = webConfig.plugins.concat(dynamicEntries.plugin)

// Keep the Plugin at the last
if (options.hasAppCache) {
  webConfig.plugins.push(new AppCachePlugin({
    output: (typeof options.hasAppCache === 'boolean') ? heroCliConfig.defaultAppCacheName : options.hasAppCache
  }))
}

let config = extend(true, {}, webConfig, {

  devtool: options.noSourceMap ? '' : 'source-map',
  plugins: webConfig.plugins.concat([
    new webpack.optimize.OccurrenceOrderPlugin(),
    new webpack.optimize.DedupePlugin(),
    new webpack.optimize.UglifyJsPlugin({
      compress: {
        'screw_ie8': true,
        warnings: false
      },
      mangle: {
        'screw_ie8': true
      },
      output: {
        comments: false,
        'screw_ie8': true
      }
    }),
    // Generate a manifest file which contains a mapping of all asset filenames
    // to their corresponding output file so that tools can pick it up without
    // having to parse `index.html`.
    new ManifestPlugin({
      fileName: 'asset-manifest.json'
    })
  ])
})

module.exports = config
