'use strict';

var entryFolder = require('./hero-config.json').entryFolder;
var path = require('path');
var paths = require('./paths');
var HtmlWebpackPlugin = require('html-webpack-plugin');
var ensureSlash = require('hero-dev-tools/ensureSlash');
var getEntries = require('hero-dev-tools/getEntries');
var webpackHotDevClientKey = 'webpackHotDevClient';
var appIndexKey = 'appIndex';

var buildEntries = {
    // We ship a few polyfills by default:
    polyfills: require.resolve('./polyfills')
};
// Finally, this is your app's code:

buildEntries[appIndexKey] = paths.appIndexJs;

function getEntryAndPlugins(isDevelopmentEnv) {

    if (isDevelopmentEnv) {
        buildEntries[webpackHotDevClientKey] = require.resolve('hero-dev-tools/webpackHotDevClient');
    }

    var entries = getEntries(path.join(paths.appSrc, entryFolder)).filter(name => {
        return /\.js$/.test(name);
    }).map((name, index) => {
        var filePath = name.replace(ensureSlash(path.join(paths.appSrc, entryFolder), true), '');
        var attriName = index + '-' + (name.match(/(.*)\/(.*)\.js$/)[2]);
        var fileNamePath = filePath.match(/(.*)\.js$/)[1];

        return {
            file: name,
            entryName: attriName,
            plugin: new HtmlWebpackPlugin({
                inject: true,
                template: paths.appHtml,
                filename: fileNamePath + '.html',
                minify: {
                    removeComments: true,
              // collapseWhitespace: true,
              // removeRedundantAttributes: true,
                    useShortDoctype: true
              // removeEmptyAttributes: true,
              // removeStyleLinkTypeAttributes: true,
              // keepClosingSlash: true,
              // minifyJS: true,
              // minifyCSS: true,
              // minifyURLs: true
                },
                chunks: isDevelopmentEnv ? [attriName, webpackHotDevClientKey] : [attriName]
            })
        };
    });

    entries.forEach(entry => {
        buildEntries[entry.entryName] = entry.file;
    });

    var indexPlugin = [
    // Generates an `index.html` file with the <script> injected.
        new HtmlWebpackPlugin({
            inject: true,
            template: paths.appHtml,
            minify: {
                removeComments: true,
                // collapseWhitespace: true,
                // removeRedundantAttributes: true,
                useShortDoctype: true
                // removeEmptyAttributes: true,
                // removeStyleLinkTypeAttributes: true,
                // keepClosingSlash: true,
                // minifyJS: true,
                // minifyCSS: true,
                // minifyURLs: true
            },
            chunks: isDevelopmentEnv ? [appIndexKey, webpackHotDevClientKey] : [appIndexKey]
        })
    ];
    var buildPlugins = entries.map(entry => {
        return entry.plugin;
    }).concat(indexPlugin);

    return {
        entry: buildEntries,
        plugin: buildPlugins
    };
}


module.exports = getEntryAndPlugins;
