'use strict';

var extend = require('extend');
var webpack = require('webpack');
var webConfig = require('./webpack.config.common');
var ManifestPlugin = require('webpack-manifest-plugin');
var getDynamicEntries = require('./getDynamicEntries');
var paths = require('./paths');

var publicPath = paths.servedPath;
var dynamicEntries = getDynamicEntries(false);

var envName = process.argv[2];
var getClientEnvironment = require('./env');
var env = getClientEnvironment(envName);

// Assert this just to be safe.
// Development builds of React are slow and not intended for production.
if (env.raw.NODE_ENV !== 'production') {
    throw new Error('Production builds must have NODE_ENV=production.');
}

webConfig.output = {
  // The build folder.
    path: paths.appBuild,
  // Generated JS file names (with nested folders).
  // There will be one main bundle, and one file per asynchronous chunk.
  // We don't currently advertise code splitting but Webpack supports it.
    filename: 'static/js/[name].[chunkhash:8].js',
    chunkFilename: 'static/js/[name].[chunkhash:8].chunk.js',
  // We inferred the "public path" (such as / or /my-project) from homepage.
    publicPath: publicPath
};

webConfig.module.loaders = webConfig.module.loaders.concat([{
    exclude: [
        /\.html$/,
        /\.(js|jsx)$/,
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
        presets: [require.resolve('babel-preset-react-app')]
    }
}]);

webConfig.entry = dynamicEntries.entry;
webConfig.plugins = webConfig.plugins.concat(dynamicEntries.plugin);

var config = extend(true, {}, webConfig, {

    devtool: 'source-map',
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
