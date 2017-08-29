'use strict'

let runInDefault = (global.options.webpackConfig === undefined)
let extend = require('extend')
let webpack = require('webpack')
let AppCachePlugin = require('appcache-webpack-plugin')
let CaseSensitivePathsPlugin = require('case-sensitive-paths-webpack-plugin')
let WatchMissingNodeModulesPlugin = runInDefault ? require('../lib/WatchMissingNodeModulesPlugin') : require('hero-cli/lib/WatchMissingNodeModulesPlugin')
let getDynamicEntries = runInDefault ? require('./getDynamicEntries') : require('hero-cli/config/getDynamicEntries')

// Webpack Start: Need to Clean the Cache
delete require.cache[require.resolve('./webpack.config.common')]
let webConfig = require('./webpack.config.common')

let options = global.options
let paths = global.paths
let heroCliConfig = global.defaultCliConfig
let homePageConfig = global.homePageConfigs

webConfig.output = {
  // Next line is not used in dev but WebpackDevServer crashes without it:
  path: paths.appBuild,
  // Add /* filename */ comments to generated require()s in the output.
  pathinfo: true,
  // This does not produce a real file. It's just the virtual path that is
  // served by WebpackDevServer in development. This is the JS bundle
  // containing code from all our entry points, and the Webpack runtime.
  filename: options.noHashName ? 'static/js/[name].js' : 'static/js/[name].js',
  chunkFilename: options.noHashName ? 'static/js/[name].chunk.js' : 'static/js/[name].chunk.js',
  // filename: 'static/js/[name].js',
  // chunkFilename: 'static/js/[name.chunk.js',
  // chunkFilename: 'static/js/[name].chunk.js',
  // This is the URL that app is served from. We use "/" in development.
  publicPath: homePageConfig.getServedPath
}

let dynamicEntries = getDynamicEntries(true)

webConfig.entry = dynamicEntries.entry
webConfig.plugins = webConfig.plugins.concat(dynamicEntries.plugin)

// Keep the Plugin at the last
if (options.hasAppCache) {
  webConfig.plugins.push(new AppCachePlugin({
    output: (typeof options.hasAppCache === 'boolean') ? heroCliConfig.defaultAppCacheName : options.hasAppCache
  }))
}

let config = extend(true, {}, webConfig, {

  devtool: options.noSourceMap ? '' : 'cheap-module-source-map',
  plugins: webConfig.plugins.concat([
    new webpack.HotModuleReplacementPlugin(),
    new CaseSensitivePathsPlugin(),
    new WatchMissingNodeModulesPlugin(paths.appNodeModules)
  ])
})

module.exports = config
