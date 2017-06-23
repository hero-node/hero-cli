var runInDefault = (global.options.webpackConfig === undefined);
var pathPrefix = runInDefault ? '..' : 'hero-cli';
var path = require('path');
var autoprefixer = require('autoprefixer');
var webpack = require('webpack');
var ExtractTextPlugin = require('extract-text-webpack-plugin');
var ProgressBarPlugin = require('progress-bar-webpack-plugin');
var HtmlWebpackInlineSourcePlugin = require('html-webpack-inline-source-plugin');
var InterpolateHtmlPlugin = require(pathPrefix + '/lib/InterpolateHtmlPlugin');
var paths = global.paths;
var options = global.options;
// Note: defined here because it will be used more than once.
var cssFilename = 'static/css/[name].[contenthash:8].css';

console.log(global.homePageConfigs);
var shouldUseRelativeAssetPaths = global.homePageConfigs.getServedPath === './';
// ExtractTextPlugin expects the build output to be flat.
// (See https://github.com/webpack-contrib/extract-text-webpack-plugin/issues/27)
// However, our output is structured with css, js and media folders.
// To have this structure working with relative paths, we have to use custom options.
var extractTextPluginOptions = shouldUseRelativeAssetPaths
  // Making sure that the publicPath goes back to to build folder.
  ? { publicPath: Array(cssFilename.split('/').length).join('../') }
  : undefined;

var plugins = [
    new ProgressBarPlugin(),
    // Note: this won't work without ExtractTextPlugin.extract(..) in `loaders`.
    new ExtractTextPlugin(cssFilename),
    new InterpolateHtmlPlugin(global.clientEnvironmentConfig.raw),
    new webpack.DefinePlugin(global.clientEnvironmentConfig.stringified)
];

if (options.isInlineSource) {
    plugins.push(new HtmlWebpackInlineSourcePlugin());
}

var webConfig = {

    resolve: {
    // This allows you to set a fallback for where Webpack should look for modules.
    // We read `NODE_PATH` environment variable in `paths.js` and pass paths here.
    // We use `fallback` instead of `root` because we want `node_modules` to "win"
    // if there any conflicts. This matches Node resolution mechanism.
    // https://github.com/facebookincubator/create-react-app/issues/253
        fallback: paths.nodePaths,
        extensions: ['.js', '.json', '']
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
                test: /\.js$/,
                loader: 'eslint',
                include: paths.appSrc
            }
        ],
        loaders: [
            {
                exclude: [
                    /\.html$/,
                    /\.css$/,
                    /\.less$/,
                    /\.scss$/,
                    /\.js$/,
                    /\.json$/,
                    /\.svg$/
                ],
                loader: 'file',
                query: {
                    // limit: 10000,
                    name: 'static/media/[name].[hash:8].[ext]'
                }
            },
            // {
            //   test: /\.css$/,
            //   loader: 'style!css?importLoaders=1!postcss'
            // },
            {
                test: /\.less$/,
                loader: ExtractTextPlugin.extract(
                // 'style',
                'css?importLoaders=1!postcss!less',
                extractTextPluginOptions
              )
            },
            {
                test: /\.css$/,
                loader: ExtractTextPlugin.extract(
                  // 'style',
                  'css?importLoaders=1!postcss',
                  extractTextPluginOptions
                )
            },
            {
                test: /\.scss$/,
                loader: ExtractTextPlugin.extract(
                  // 'style',
                  'css?importLoaders=1!postcss!sass',
                  extractTextPluginOptions
                )
            },
            {
                test: /\.html$/, // handles html files. <link rel="import" href="path.html"> and import 'path.html';
                loader: 'babel?babelrc=false!wc'
//                loader: 'babel?babelrc=false,presets[]=es2015,presets[]=stage-2,plugins[]=transform-decorators-legacy,plugins[]=transform-class-properties,plugins[]=transform-object-rest-spread!wc'
                // if you are using es6 inside html use
                // loader: 'babel-loader!wc-loader'
                // similarly you can use coffee, typescript etc. pipe wc result through the respective loader.
            },
            {
                test: /\.js$/,
                include: paths.appSrc,
                loader: 'babel',
                query: {
                    babelrc: false,
                    presets: [
                        require.resolve('babel-preset-es2015'),
                        require.resolve('babel-preset-stage-2')
                    ],
                    plugins: [
                        require.resolve('babel-plugin-transform-class-properties'),
                        require.resolve('babel-plugin-transform-object-rest-spread'),
                        require.resolve('babel-plugin-transform-decorators-legacy')
                    ],
                // This is a feature of `babel-loader` for webpack (not Babel itself).
                // It enables caching results in ./node_modules/.cache/babel-loader/
                // directory for faster rebuilds.
                    cacheDirectory: true
                }
            },
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
        configFile: runInDefault ? path.join(__dirname, '../eslintrc') : path.join(__dirname, '.eslintrc'),
        useEslintrc: false
    },
    plugins: plugins,
  // Some libraries import Node modules but don't use them in the browser.
  // Tell Webpack to provide empty mocks for them so importing them works.
    node: {
        fs: 'empty',
        net: 'empty',
        tls: 'empty'
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
    }
};

module.exports = webConfig;
