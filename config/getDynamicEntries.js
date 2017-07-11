'use strict';

var path = require('path');
var yargs = require('yargs');
var chalk = require('chalk');
var HtmlWebpackPlugin = require('html-webpack-plugin');
var ensureSlash = require('../lib/ensureSlash');
var getEntries = require('../lib/getEntries');
var webpackHotDevClientKey = 'web-hot-reload';
var appIndexKey = 'appIndex';
var getComponentsData = require('../lib/getComponentsData').getComponentsData;
var hasVerbose = yargs.argv.verbose;
var firstError = true;
var isRelativePath = global.homePageConfigs.isRelativePath;

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
    var total = 0;

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
                entryConfig.template = '!!ejs!' + customTemplateUrl;
            }
            if (isInlineSource) {
                entryConfig.inlineSource = inlineSourceRegex;
            }
            var validPosition = (entryConfig.inject === 'head' || entryConfig.inject === 'body' || entryConfig.inject === false);

            var options = Object.assign({
                title: '',
                inject: customTemplateUrl ? (validPosition ? entryConfig.inject : 'head') : false,
          // webconfig html file loader using Polymer HTML
                template: '!!ejs!' + path.join(__dirname, 'entryTemplate.html'),
                filename: fileNamePath + '.html',
          // basePath = '../../' -->
          // entry = './static/js/abc.js'
          // basePath.length -2 + entry --> '../.' + './static/js/abc.js'
                basePath: isRelativePath ? basePath.substring(0, basePath.length - 2) : '',
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
            var shortName = name.replace(paths.appSrc, 'src');

            if (hasDuplicatedPath) {
                total++;
            }

            // if (!hasDuplicatedPath) {
            allGeneratedHTMLNames[options.filename] = shortName;
            // }

            var logMethod = hasDuplicatedPath ? 'warn' : 'debug';

            if (hasVerbose) {
                if (index === 0) {
                    global.logger[logMethod]('├── Generate HTML: ');
                }
            } else {
                if (hasDuplicatedPath && firstError) {
                    global.logger[logMethod](' ├── Generate HTML: ');
                    firstError = false;
                }
            }

            var color = hasDuplicatedPath ? 'red' : 'yellow';
            var prefix = '├── ';
            var isLastOne = index === (validEntries.length - 1);

            if (isLastOne) {
                prefix = '└── ';
            }
            var warnDebugCharGap = (hasDuplicatedPath ? ' ' : '');

            global.logger[logMethod](warnDebugCharGap + '│   ' + prefix + chalk[color](options.filename) + (hasDuplicatedPath ? chalk.red('(Name conflict with file generated by ') + '"' + chalk.cyan(hasDuplicatedPath) + '"' : ''));
            global.logger[logMethod](warnDebugCharGap + '│   ' + (isLastOne ? ' ' : '│') + '   ' + (customTemplateUrl ? '├──' : '└──') + ' JS Entry: ' + shortName);
            if (customTemplateUrl) {
                global.logger[logMethod](warnDebugCharGap + '│   ' + (isLastOne ? '' : '│') + '   └── HTML Template: ' + customTemplateUrl.replace(paths.appSrc, 'src'));
            }
            if (isLastOne) {
                if (!firstError) {
                    global.logger.warn(' └── ' + chalk.yellow('Total ' + total + ' Warning' + (total > 1 ? 's.' : '.')));
                }
            }
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
