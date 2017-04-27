'use strict';

var extend = require('extend');
var webpack = require('webpack');

var notGenerateSourceMap = global.argv.m;

delete require.cache[require.resolve('./webpack.config.common')];
var webConfig = require('./webpack.config.common');
var CaseSensitivePathsPlugin = require('case-sensitive-paths-webpack-plugin');
var getDynamicEntries = require('./getDynamicEntries');
var WatchMissingNodeModulesPlugin = require('../lib/WatchMissingNodeModulesPlugin');
var paths = require('./paths');
var heroCliConfig = require('./hero-config.json');
var getClientEnvironment = require('./env');
var env = getClientEnvironment().raw;

var publicPath = env[heroCliConfig.homePageKey];

if (typeof publicPath !== 'string') {
    publicPath = '/';
}
webConfig.output = {
  // Next line is not used in dev but WebpackDevServer crashes without it:
    path: paths.appBuild,
  // Add /* filename */ comments to generated require()s in the output.
    pathinfo: true,
  // This does not produce a real file. It's just the virtual path that is
  // served by WebpackDevServer in development. This is the JS bundle
  // containing code from all our entry points, and the Webpack runtime.
    filename: 'static/js/[name].js',
    // chunkFilename: 'static/js/[name.chunk.js',
    chunkFilename: 'static/js/[name].chunk.js',
  // This is the URL that app is served from. We use "/" in development.
    publicPath: publicPath
};

var dynamicEntries = getDynamicEntries(true);

webConfig.entry = dynamicEntries.entry;
webConfig.plugins = webConfig.plugins.concat(dynamicEntries.plugin);

var config = extend(true, {}, webConfig, {

    devtool: notGenerateSourceMap ? '' : 'cheap-module-source-map',
    plugins: webConfig.plugins.concat([
        new webpack.HotModuleReplacementPlugin(),
        new CaseSensitivePathsPlugin(),
        new WatchMissingNodeModulesPlugin(paths.appNodeModules)
    ])
});

module.exports = config;
