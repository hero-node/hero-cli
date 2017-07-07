'use strict';

var path = require('path');
var fs = require('fs');
var chalk = require('chalk');
var HtmlWebpackPlugin = require('html-webpack-plugin');
var ensureSlash = require('../lib/ensureSlash');
var getEntries = require('../lib/getEntries');
var webpackHotDevClientKey = 'web-hot-reload';
var appIndexKey = 'appIndex';
var getComponentsData = require('../lib/getComponentsData').getComponentsData;
var defaultTemplateContent = fs.readFileSync(path.join(__dirname, 'entryTemplate.html'), 'UTF-8');

function getEntryAndPlugins(isDevelopmentEnv) {
    global.entryTemplates = [];
    var inlineSourceRegex = global.defaultCliConfig.inlineSourceRegex;
    var isStandAlone = global.options.isStandAlone;
    var isInlineSource = global.options.isInlineSource;
    var isHeroBasic = global.options.isHeroBasic;
    var paths = global.paths;
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
    var validEntries;
    var allGeneratedHTMLNames = {};

    if (isStandAlone) {
        validEntries = getEntries(path.join(paths.appSrc)).filter(name => {
            return /\.js$/.test(name);
        }).map((name) => {
            return {
                name: name,
                entryConfig: getComponentsData(name)
            };
        }).filter(data => {
            return !!data.entryConfig;
        });

        entries = validEntries.map((data, index) => {
            var entryConfig = data.entryConfig;

            if (!entryConfig) {
                return;
            }
            if (index === 0) {
                global.logger.debug('├── Generate HTML: ');
            }
            var name = data.name;

            if (entryConfig.path) {
                entryConfig.filename = entryConfig.path;
            }
            var startWithSlash, pathPartLen;
            var basePath = '';

            if (entryConfig.filename) {
                entryConfig.filename = entryConfig.filename.trim();
                startWithSlash = entryConfig.filename.indexOf('/') === 0;

                pathPartLen = entryConfig.filename.split('\/').length;
                if (startWithSlash) {
                    pathPartLen--;
                }
                pathPartLen--;
                while (pathPartLen) {
                    basePath += '../';
                    pathPartLen--;
                }
            }
            if (entryConfig.filename && entryConfig.filename.indexOf('/') === 0) {
                entryConfig.filename = entryConfig.filename.slice(1);
            }
            var filePath = name.replace(ensureSlash(path.join(paths.appSrc), true), '');
            var attriName = index + '-' + (name.match(/(.*)\/(.*)\.js$/)[2]);

            var fileNamePath = filePath.match(/(.*)\.js$/)[1];

            var customTemplateUrl;

            if (entryConfig.template) {
                customTemplateUrl = path.join(name, '../', entryConfig.template);
                global.entryTemplates.push(customTemplateUrl);
                // entryConfig.template = '!!html!' + customTemplateUrl;
                entryConfig.templateContent = fs.readFileSync(customTemplateUrl, 'UTF-8');
                delete entryConfig.template;
            }
            if (isInlineSource) {
                entryConfig.inlineSource = inlineSourceRegex;
            }
            var templateContent = basePath ? defaultTemplateContent.replace('<base href="/">', '<base href="' + basePath + '">') : defaultTemplateContent;

            var options = Object.assign({
                inject: 'head',
          // webconfig html file loader using Polymer HTML
                templateContent: templateContent,
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
                // In Native App, No JS `appIndexKey`, so Need Add Reload in Every Page
                chunks: isDevelopmentEnv ? [webpackHotDevClientKey, attriName] : [attriName]
            }, entryConfig);

            var hasDuplicatedPath = allGeneratedHTMLNames[options.filename];

            if (!hasDuplicatedPath) {
                allGeneratedHTMLNames[options.filename] = true;
            }

            var color = hasDuplicatedPath ? 'red' : 'yellow';
            var logMethod = hasDuplicatedPath ? 'warn' : 'debug';
            var prefix = '├── ';
            var isLastOne = index === (validEntries.length - 1);

            if (isLastOne) {
                prefix = '└── ';
            }
            global.logger[logMethod]((hasDuplicatedPath ? ' ' : '') + '│   ' + prefix + chalk[color](options.filename) + (hasDuplicatedPath ? chalk.red('(HTML Path Conflict!)') : ''));
            global.logger[logMethod]((hasDuplicatedPath ? ' ' : '') + '│   ' + (isLastOne ? ' ' : '│') + '   ' + (customTemplateUrl ? '├──' : '└──') + ' JS Entry: ' + name.replace(paths.appSrc, 'src'));
            if (customTemplateUrl) {
                global.logger.debug('│   ' + (isLastOne ? '' : '│') + '   └── HTML Template: ' + customTemplateUrl.replace(paths.appSrc, 'src'));
            }
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
