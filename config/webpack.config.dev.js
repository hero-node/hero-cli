'use strict';

var runInDefault = (global.options.webpackConfig === undefined);
var extend = require('extend');
var webpack = require('webpack');
var AppCachePlugin = require('appcache-webpack-plugin');
var CaseSensitivePathsPlugin = require('case-sensitive-paths-webpack-plugin');
var WatchMissingNodeModulesPlugin = runInDefault ? require('../lib/WatchMissingNodeModulesPlugin') : require('hero-cli/lib/WatchMissingNodeModulesPlugin');
var getDynamicEntries = runInDefault ? require('./getDynamicEntries') : require('hero-cli/config/getDynamicEntries');

delete require.cache[require.resolve('./webpack.config.common')];
var webConfig = require('./webpack.config.common');

var options = global.options;
var paths = global.paths;
var heroCliConfig = global.defaultCliConfig;
var homePageConfig = global.homePageConfigs;

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
};

var dynamicEntries = getDynamicEntries(true);

webConfig.entry = dynamicEntries.entry;
webConfig.plugins = webConfig.plugins.concat(dynamicEntries.plugin);

// Keep the Plugin at the last
if (options.hasAppCache) {
    webConfig.plugins.push(new AppCachePlugin({
        output: (typeof options.hasAppCache === 'boolean') ? heroCliConfig.defaultAppCacheName : options.hasAppCache
    }));
}

var config = extend(true, {}, webConfig, {

    devtool: options.noSourceMap ? '' : 'cheap-module-source-map',
    plugins: webConfig.plugins.concat([
        new webpack.HotModuleReplacementPlugin(),
        new CaseSensitivePathsPlugin(),
        new WatchMissingNodeModulesPlugin(paths.appNodeModules)
    ])
});

module.exports = config;
