'use strict';

var extend = require('extend');
var webpack = require('webpack');
var webConfig = require('./webpack.config.common');
var CaseSensitivePathsPlugin = require('case-sensitive-paths-webpack-plugin');
var WatchMissingNodeModulesPlugin = require('hero-dev-tools/WatchMissingNodeModulesPlugin');
var getDynamicEntries = require('./getDynamicEntries');
var paths = require('./paths');
var publicPath = '/';

webConfig.output = {
  // Next line is not used in dev but WebpackDevServer crashes without it:
    path: paths.appBuild,
  // Add /* filename */ comments to generated require()s in the output.
    pathinfo: true,
  // This does not produce a real file. It's just the virtual path that is
  // served by WebpackDevServer in development. This is the JS bundle
  // containing code from all our entry points, and the Webpack runtime.
    filename: 'static/js/[name].[hash:8].js',
    chunkFilename: 'static/js/[name].[chunkhash:8].chunk.js',
  // This is the URL that app is served from. We use "/" in development.
    publicPath: publicPath
};

webConfig.module.loaders = webConfig.module.loaders.concat([{
    exclude: [
        /\.html$/,
// We have to write /\.(js|jsx)(\?.*)?$/ rather than just /\.(js|jsx)$/
// because you might change the hot reloading server from the custom one
// to Webpack's built-in webpack-dev-server/client?/, which would not
// get properly excluded by /\.(js|jsx)$/ because of the query string.
// Webpack 2 fixes this, but for now we include this hack.
// https://github.com/facebookincubator/create-react-app/issues/1713
        /\.(js|jsx)(\?.*)?$/,
        /\.css$/,
        /\.json$/,
        /\.svg$/
    ],
    loader: 'url',
    query: {
        limit: 10000,
        name: 'static/media/[name].[hash:8].[ext]'
    }
}, {
    test: /\.(js|jsx)$/,
    include: paths.appSrc,
    loader: 'babel',
    query: {
        babelrc: false,
        presets: [require.resolve('babel-preset-react-app')],
        // This is a feature of `babel-loader` for webpack (not Babel itself).
        // It enables caching results in ./node_modules/.cache/babel-loader/
        // directory for faster rebuilds.
        cacheDirectory: true
    }
}]);

var dynamicEntries = getDynamicEntries(true);

webConfig.entry = dynamicEntries.entry;
webConfig.plugins = webConfig.plugins.concat(dynamicEntries.plugin);

var config = extend(true, {}, webConfig, {

    bail: true,
    devtool: 'cheap-module-source-map',
    plugins: webConfig.plugins.concat([
        new webpack.HotModuleReplacementPlugin(),
        new CaseSensitivePathsPlugin(),
        new WatchMissingNodeModulesPlugin(paths.appNodeModules)
    ])
});

module.exports = config;
