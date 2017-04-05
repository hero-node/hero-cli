// @remove-on-eject-begin
/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */
// @remove-on-eject-end
'use strict';
var entryFolder = 'src/entry';
var autoprefixer = require('autoprefixer');
var webpack = require('webpack');
var ProgressBarPlugin = require('progress-bar-webpack-plugin');
var HtmlWebpackPlugin = require('html-webpack-plugin');
var CaseSensitivePathsPlugin = require('case-sensitive-paths-webpack-plugin');
var InterpolateHtmlPlugin = require('hero-dev-tools/InterpolateHtmlPlugin');
var WatchMissingNodeModulesPlugin = require('hero-dev-tools/WatchMissingNodeModulesPlugin');
var envName = process.argv[2];
var getClientEnvironment = require('./env');
var paths = require('./paths');
var path = require('path');

var getEntries = require('../lib/getEntries');

var entries = getEntries(path.join(process.cwd(),entryFolder)).filter(name => {
  return /\.js$/.test(name);
}).map((name, index) => {
  var attriName = index +'-'+ (name.match(/(.*)\/(.*)\.js$/)[2]);
  return {
    file: name,
    entryName: attriName,
    plugin: new HtmlWebpackPlugin({
        inject: true,
        template: paths.appHtml,
        filename: attriName+'.html',
        minify: {
            removeComments: true,
            // collapseWhitespace: true,
            // removeRedundantAttributes: true,
            useShortDoctype: true,
            // removeEmptyAttributes: true,
            // removeStyleLinkTypeAttributes: true,
            // keepClosingSlash: true,
            // minifyJS: true,
            // minifyCSS: true,
            // minifyURLs: true
        },
        chunks: [attriName]
    })
  }
});

var buildEntries = {
    webpackHotDevClient: require.resolve('hero-dev-tools/webpackHotDevClient'),
// We ship a few polyfills by default:
    polyfills:  require.resolve('./polyfills'),
// Finally, this is your app's code:
    appIndex:   paths.appIndexJs
};
entries.forEach(entry => {
  buildEntries[entry.entryName] = entry.file
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
              useShortDoctype: true,
              // removeEmptyAttributes: true,
              // removeStyleLinkTypeAttributes: true,
              // keepClosingSlash: true,
              // minifyJS: true,
              // minifyCSS: true,
              // minifyURLs: true
          },
          chunks: ['appIndex']
      })
]
var buildPlugins = entries.map(entry => {
  console.log(entry.plugin);
  return entry.plugin;
}).concat(indexPlugin);

console.log('buildEntries', buildEntries);

// @remove-on-eject-end

// Webpack uses `publicPath` to determine where the app is being served from.
// In development, we always serve from the root. This makes config easier.
var publicPath = '/';
// `publicUrl` is just like `publicPath`, but we will provide it to our app
// as %PUBLIC_URL% in `index.html` and `process.env.PUBLIC_URL` in JavaScript.
// Omit trailing slash as %PUBLIC_PATH%/xyz looks better than %PUBLIC_PATH%xyz.
var publicUrl = '';
// Get environment variables to inject into our app.
var env = getClientEnvironment(envName);

// This is the development configuration.
// It is focused on developer experience and fast rebuilds.
// The production configuration is different and lives in a separate file.
var webConfig = {
  // You may want 'eval' instead if you prefer to see the compiled output in DevTools.
  // See the discussion in https://github.com/facebookincubator/create-react-app/issues/343.
    devtool: 'cheap-module-source-map',
  // These are the "entry points" to our application.
  // This means they will be the "root" imports that are included in JS bundle.
  // The first two entry points enable "hot" CSS and auto-refreshes for JS.
    output: {
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
    },
    resolve: {
    // This allows you to set a fallback for where Webpack should look for modules.
    // We read `NODE_PATH` environment variable in `paths.js` and pass paths here.
    // We use `fallback` instead of `root` because we want `node_modules` to "win"
    // if there any conflicts. This matches Node resolution mechanism.
    // https://github.com/facebookincubator/create-react-app/issues/253
        fallback: paths.nodePaths,
    // These are the reasonable defaults supported by the Node ecosystem.
    // We also include JSX as a common component filename extension to support
    // some tools, although we do not recommend using it, see:
    // https://github.com/facebookincubator/create-react-app/issues/290
        extensions: ['.js', '.json', '.jsx', ''],
        alias: {
      // Support React Native Web
      // https://www.smashingmagazine.com/2016/08/a-glimpse-into-the-future-with-react-native-for-web/
            'react-native': 'react-native-web'
        }
    },
  // @remove-on-eject-begin
  // Resolve loaders (webpack plugins for CSS, images, transpilation) from the
  // directory of `react-scripts` itself rather than the project directory.
    resolveLoader: {
        root: paths.ownNodeModules,
        moduleTemplates: ['*-loader']
    },
  // @remove-on-eject-end
    module: {
    // First, run the linter.
    // It's important to do this before Babel processes the JS.
        preLoaders: [
            {
                test: /\.(js|jsx)$/,
                loader: 'eslint',
                include: paths.appSrc
            }
        ],
        loaders: [
      // ** ADDING/UPDATING LOADERS **
      // The "url" loader handles all assets unless explicitly excluded.
      // The `exclude` list *must* be updated with every change to loader extensions.
      // When adding a new loader, you must add its `test`
      // as a new entry in the `exclude` list for "url" loader.

      // "url" loader embeds assets smaller than specified size as data URLs to avoid requests.
      // Otherwise, it acts like the "file" loader.
            {
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
            },
      // Process JS with Babel.
            {
                test: /\.(js|jsx)$/,
                include: paths.appSrc,
                loader: 'babel',
                query: {
          // @remove-on-eject-begin
                    babelrc: false,
                    presets: [require.resolve('babel-preset-react-app')],
          // @remove-on-eject-end
          // This is a feature of `babel-loader` for webpack (not Babel itself).
          // It enables caching results in ./node_modules/.cache/babel-loader/
          // directory for faster rebuilds.
                    cacheDirectory: true
                }
            },
      // "postcss" loader applies autoprefixer to our CSS.
      // "css" loader resolves paths in CSS and adds assets as dependencies.
      // "style" loader turns CSS into JS modules that inject <style> tags.
      // In production, we use a plugin to extract that CSS to a file, but
      // in development "style" loader enables hot editing of CSS.
            {
                test: /\.css$/,
                loader: 'style!css?importLoaders=1!postcss'
            },
      // JSON is not enabled by default in Webpack but both Node and Browserify
      // allow it implicitly so we also enable it.
            {
                test: /\.json$/,
                loader: 'json'
            },
      // "file" loader for svg
            {
                test: /\.svg$/,
                loader: 'file',
                query: {
                    name: 'static/media/[name].[hash:8].[ext]'
                }
            }
      // ** STOP ** Are you adding a new loader?
      // Remember to add the new extension(s) to the "url" loader exclusion list.
        ]
    },
  // @remove-on-eject-begin
  // Point ESLint to our predefined config.
    eslint: {
        configFile: path.join(__dirname, '../eslintrc'),
        useEslintrc: false
    },
  // @remove-on-eject-end
  // We use PostCSS for autoprefixing only.
    postcss: function () {
        return [
            autoprefixer({
                browsers: [
                    '>1%',
                    'last 4 versions',
                    'Firefox ESR',
                    'not ie < 9' // React doesn't support IE8 anyway
                ]
            })
        ];
    },
    plugins: [
    // Makes some environment variables available in index.html.
    // The public URL is available as %PUBLIC_URL% in index.html, e.g.:
    // <link rel="shortcut icon" href="%PUBLIC_URL%/favicon.ico">
    // In development, this will be an empty string.
        new ProgressBarPlugin(),
        new InterpolateHtmlPlugin(env.raw),
    // Makes some environment variables available to the JS code, for example:
    // if (process.env.NODE_ENV === 'development') { ... }. See `./env.js`.
        new webpack.DefinePlugin(env.stringified),
    // This is necessary to emit hot updates (currently CSS only):
        new webpack.HotModuleReplacementPlugin(),
    // Watcher doesn't work well if you mistype casing in a path so we use
    // a plugin that prints an error when you attempt to do this.
    // See https://github.com/facebookincubator/create-react-app/issues/240
        new CaseSensitivePathsPlugin(),
    // If you require a missing module and then `npm install` it, you still have
    // to restart the development server for Webpack to discover it. This plugin
    // makes the discovery automatic so you don't have to restart.
    // See https://github.com/facebookincubator/create-react-app/issues/186
        new WatchMissingNodeModulesPlugin(paths.appNodeModules)
    ],
  // Some libraries import Node modules but don't use them in the browser.
  // Tell Webpack to provide empty mocks for them so importing them works.
    node: {
        fs: 'empty',
        net: 'empty',
        tls: 'empty'
    }
};
webConfig.entry = buildEntries;
webConfig.plugins = webConfig.plugins.concat(buildPlugins);
console.log(webConfig);
module.exports = webConfig;
