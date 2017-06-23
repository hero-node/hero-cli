'use strict';

var runInDefault = (global.options.webpackConfig === undefined);
var pathConfigPrefix = runInDefault ? '.' : 'hero-cli/config';
var extend = require('extend');
var webpack = require('webpack');
var AppCachePlugin = require('appcache-webpack-plugin');
var webConfig = require('./webpack.config.common');
var ManifestPlugin = require('webpack-manifest-plugin');
var getDynamicEntries = require(pathConfigPrefix + '/getDynamicEntries');

var options = global.options;
var paths = global.paths;
var heroCliConfig = global.defaultCliConfig;
var homePageConfig = global.homePageConfigs;

var dynamicEntries = getDynamicEntries(false);

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
};

webConfig.entry = dynamicEntries.entry;
webConfig.plugins = webConfig.plugins.concat(dynamicEntries.plugin);

// Keep the Plugin at the last
if (options.hasAppCache) {
    webConfig.plugins.push(new AppCachePlugin({
        output: (typeof options.hasAppCache === 'boolean') ? heroCliConfig.defaultAppCacheName : options.hasAppCache
    }));
}

var config = extend(true, {}, webConfig, {

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
});

module.exports = config;
