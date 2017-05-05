'use strict';

var path = require('path');
var paths = require('./paths');
var HtmlWebpackPlugin = require('html-webpack-plugin');
var ensureSlash = require('../lib/ensureSlash');
var getEntries = require('../lib/getEntries');
var webpackHotDevClientKey = 'web-hot-reload';
var appIndexKey = 'appIndex';
var heroConfig = require('./hero-config.json');
// var webComponentsKey = 'webcomponents-lite';
var getComponentsData = require('../lib/getComponentsData');

var isStandAlone = global.options.isStandAlone;
var isInlineSource = global.options.isInlineSource;
var isHeroBasic = global.options.isHeroBasic;

var inlineSourceRegex = heroConfig.inlineSourceRegex;

function getEntryAndPlugins(isDevelopmentEnv) {

    var buildEntries = {};

    // We ship a few polyfills by default:
    var indexOptions, buildPlugins = [];

    if (isHeroBasic) {
        // buildEntries[webComponentsKey] = require.resolve('../lib/webcomponents-lite');
        buildEntries[appIndexKey] = paths.appIndexJs;

        indexOptions = {
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
                  // chunks: isDevelopmentEnv ? [webComponentsKey, appIndexKey, webpackHotDevClientKey] : [webComponentsKey, appIndexKey]
            chunks: isDevelopmentEnv ? [appIndexKey, webpackHotDevClientKey] : [appIndexKey]
        };

        if (isInlineSource) {
            indexOptions.inlineSource = inlineSourceRegex;
        }
        // Generates an `index.html` file with the <script> injected.
        buildPlugins.push(new HtmlWebpackPlugin(indexOptions));
    }
    // console.log('getEntryAndPlugins----------------');
    if (isDevelopmentEnv) {
        buildEntries[webpackHotDevClientKey] = require.resolve('../lib/webpackHotDevClient');
    }
    var entries;

    if (isStandAlone) {

        entries = getEntries(path.join(paths.appSrc)).filter(name => {
            return /\.js$/.test(name);
        }).map((name, index) => {
            var entryConfig = getComponentsData(name);

        // console.log('entryConfig---------', entryConfig);
            if (!entryConfig) {
                return;
            }
            var filePath = name.replace(ensureSlash(path.join(paths.appSrc), true), '');
            var attriName = index + '-' + (name.match(/(.*)\/(.*)\.js$/)[2]);
            var fileNamePath = filePath.match(/(.*)\.js$/)[1];

            if (entryConfig.template) {
          // console.log(name);
          // console.log(entryConfig.template);
                entryConfig.template = '!!html!' + path.join(name.replace('/\.js$/', ''), '../', entryConfig.template);
            }
            if (isInlineSource) {
                entryConfig.inlineSource = inlineSourceRegex;
            }
            var options = Object.assign({
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
            }, entryConfig);

        // console.log(options);
            return {
                file: name,
                entryName: attriName,
                plugin: new HtmlWebpackPlugin(options)
            };
        }).filter(function (entry) {
            return !!entry;
        });

      // console.log('entries-------', entries);
        entries.forEach(entry => {
            buildEntries[entry.entryName] = entry.file;
        });

        buildPlugins = buildPlugins.concat(entries.map(entry => {
            return entry.plugin;
        }));
    }
    return {
        entry: buildEntries,
        plugin: buildPlugins
    };
}

module.exports = getEntryAndPlugins;
