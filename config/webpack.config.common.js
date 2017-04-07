'use strict';

var autoprefixer = require('autoprefixer');
var webpack = require('webpack');
var ProgressBarPlugin = require('progress-bar-webpack-plugin');

var InterpolateHtmlPlugin = require('hero-dev-tools/InterpolateHtmlPlugin');
var paths = require('./paths');
var envName = process.argv[2];
var getClientEnvironment = require('./env');
var env = getClientEnvironment(envName);

var path = require('path');

var webConfig = {

    resolve: {
    // This allows you to set a fallback for where Webpack should look for modules.
    // We read `NODE_PATH` environment variable in `paths.js` and pass paths here.
    // We use `fallback` instead of `root` because we want `node_modules` to "win"
    // if there any conflicts. This matches Node resolution mechanism.
    // https://github.com/facebookincubator/create-react-app/issues/253
        fallback: paths.nodePaths,
        extensions: ['.js', '.json', '.jsx', '']
    },
    resolveLoader: {
        root: paths.ownNodeModules,
        moduleTemplates: ['*-loader']
    },
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
            {
                test: /\.json$/,
                loader: 'json'
            },
            {
                test: /\.svg$/,
                loader: 'file',
                query: {
                    name: 'static/media/[name].[hash:8].[ext]'
                }
            }
        ]
    },
  // Point ESLint to our predefined config.
    eslint: {
        // e.g. to enable no-console and no-debugger only in production.
        configFile: path.join(__dirname, '../eslintrc'),
        useEslintrc: false
    },
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
        new ProgressBarPlugin(),
        new InterpolateHtmlPlugin(env.raw),
        new webpack.DefinePlugin(env.stringified),
        new webpack.optimize.OccurrenceOrderPlugin(),
        new webpack.optimize.DedupePlugin()
    ],
  // Some libraries import Node modules but don't use them in the browser.
  // Tell Webpack to provide empty mocks for them so importing them works.
    node: {
        fs: 'empty',
        net: 'empty',
        tls: 'empty'
    }
};

module.exports = webConfig;
