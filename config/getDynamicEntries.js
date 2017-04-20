'use strict';

var entryFolder = require('./hero-config.json').entryFolder;
var path = require('path');
var paths = require('./paths');
var HtmlWebpackPlugin = require('html-webpack-plugin');
var ensureSlash = require('../lib/ensureSlash');
var getEntries = require('../lib/getEntries');
var webpackHotDevClientKey = 'web-hot-reload';
var appIndexKey = 'appIndex';
var webComponentsKey = 'webcomponents-lite';
var polyfillKey = 'polyfills';

var buildEntries = {
};

// We ship a few polyfills by default:
buildEntries[polyfillKey] = require.resolve('./polyfills');
buildEntries[webComponentsKey] = require.resolve('../lib/webcomponents-lite');
buildEntries[appIndexKey] = paths.appIndexJs;

function getEntryAndPlugins(isDevelopmentEnv) {

    if (isDevelopmentEnv) {
        buildEntries[webpackHotDevClientKey] = require.resolve('../lib/webpackHotDevClient');
    }

    var entries = getEntries(path.join(paths.appSrc, entryFolder)).filter(name => {
        return /\.js$/.test(name);
    }).map((name, index) => {
        console.log(name);
        var filePath = name.replace(ensureSlash(path.join(paths.appSrc, entryFolder), true), '');
        var attriName = index + '-' + (name.match(/(.*)\/(.*)\.js$/)[2]);
        var fileNamePath = filePath.match(/(.*)\.js$/)[1];

        return {
            file: name,
            entryName: attriName,
            plugin: new HtmlWebpackPlugin({
                inject: 'head',
                // webconfig html file loader using Polymer HTML
                template: '!!html!' + path.join(__dirname, 'entryTemplate.html'),
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
                chunks: [attriName]
            })
        };
    });

    entries.forEach(entry => {
        buildEntries[entry.entryName] = entry.file;
    });

    var indexPlugin = [
    // Generates an `index.html` file with the <script> injected.
        new HtmlWebpackPlugin({
            inject: 'head',
            // webconfig html file loader using Polymer HTML
            template: '!!html!' + paths.appHtml,
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
            chunks: isDevelopmentEnv ? [webComponentsKey, polyfillKey, appIndexKey, webpackHotDevClientKey] : [webComponentsKey, polyfillKey, appIndexKey]
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
