'use strict';

var extend = require('extend');
var webpack = require('webpack');
var webConfig = require('./webpack.config.common');
var ManifestPlugin = require('webpack-manifest-plugin');
var getDynamicEntries = require('./getDynamicEntries');
var paths = require('./paths');
var heroCliConfig = require('./hero-config.json');
var getClientEnvironment = require('./env');
var env = getClientEnvironment().raw;

var publicPath = env[heroCliConfig.homePageKey];

if (typeof publicPath !== 'string') {
    publicPath = '/';
}
var notGenerateSourceMap = global.argv.m;

var dynamicEntries = getDynamicEntries(false);

webConfig.output = {
  // The build folder.
    path: paths.appBuild,
  // Generated JS file names (with nested folders).
  // There will be one main bundle, and one file per asynchronous chunk.
  // We don't currently advertise code splitting but Webpack supports it.
    filename: 'static/js/[name].js',
    chunkFilename: 'static/js/[name].chunk.js',
  // We inferred the "public path" (such as / or /my-project) from homepage.
    publicPath: publicPath
};

webConfig.entry = dynamicEntries.entry;
webConfig.plugins = webConfig.plugins.concat(dynamicEntries.plugin);

var config = extend(true, {}, webConfig, {

    devtool: notGenerateSourceMap ? '' : 'source-map',
    plugins: webConfig.plugins.concat([
        new webpack.optimize.UglifyJsPlugin({
            compress: {
                'screw_ie8': true, // React doesn't support IE8
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
