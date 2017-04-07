'use strict';

var path = require('path');
var fs = require('fs');
var url = require('url');
var heroConfig = require('./hero-config.json');
// Make sure any symlinks in the project folder are resolved:
// https://github.com/facebookincubator/create-react-app/issues/637
var appDirectory = fs.realpathSync(process.cwd());

function resolveApp(relativePath) {
    return path.resolve(appDirectory, relativePath);
}

// We support resolving modules according to `NODE_PATH`.
// This lets you use absolute paths in imports inside large monorepos:
// https://github.com/facebookincubator/create-react-app/issues/253.

// It works similar to `NODE_PATH` in Node itself:
// https://nodejs.org/api/modules.html#modules_loading_from_the_global_folders

// We will export `nodePaths` as an array of absolute paths.
// It will then be used by Webpack configs.
// Jest doesn’t need this because it already handles `NODE_PATH` out of the box.

// Note that unlike in Node, only *relative* paths from `NODE_PATH` are honored.
// Otherwise, we risk importing Node.js core modules into an app instead of Webpack shims.
// https://github.com/facebookincubator/create-react-app/issues/1023#issuecomment-265344421

var nodePaths = (process.env.NODE_PATH || '')
  .split(process.platform === 'win32' ? ';' : ':')
  .filter(Boolean)
  .filter(folder => !path.isAbsolute(folder))
  .map(resolveApp);

var envPublicUrl = process.env.PUBLIC_URL;

var ensureSlash = require('../lib/ensureSlash');

function getPublicUrl(appPackageJson) {
    return envPublicUrl || require(appPackageJson).homepage;
}

// We use `PUBLIC_URL` environment variable or "homepage" field to infer
// "public path" at which the app is served.
// Webpack needs to know it to put the right <script> hrefs into HTML even in
// single-page apps that may serve index.html for nested URLs like /todos/42.
// We can't use a relative path in HTML because we don't want to load something
// like /todos/42/static/js/bundle.7289d.js. We have to know the root.
function getServedPath(appPackageJson) {
    var publicUrl = getPublicUrl(appPackageJson);
    var servedUrl = envPublicUrl || (
    publicUrl ? url.parse(publicUrl).pathname : '/'
  );

    return ensureSlash(servedUrl, true);
}

// config after eject: we're in ./config/
module.exports = {
    appBuild: resolveApp('build'),
    appPublic: resolveApp('public'),
    appHtml: resolveApp('src/index.html'),
    appIndexJs: resolveApp('src/index.js'),
    appPackageJson: resolveApp('package.json'),
    appSrc: resolveApp('src'),
    yarnLockFile: resolveApp('yarn.lock'),
    testsSetup: resolveApp('src/setupTests.js'),
    appNodeModules: resolveApp('node_modules'),
    nodePaths: nodePaths,
    heroCliConfig: resolveApp(heroConfig.heroCliConfig),
    publicUrl: getPublicUrl(resolveApp('package.json')),
    servedPath: getServedPath(resolveApp('package.json'))
};

// @remove-on-eject-begin
function resolveOwn(relativePath) {
    return path.resolve(__dirname, '..', relativePath);
}

// config before eject: we're in ./node_modules/react-scripts/config/
module.exports = {
    appPath: resolveApp('.'),
    appBuild: resolveApp('build'),
    appPublic: resolveApp('public'),
    appHtml: resolveApp('src/index.html'),
    appIndexJs: resolveApp('src/index.js'),
    appPackageJson: resolveApp('package.json'),
    appSrc: resolveApp('src'),
    yarnLockFile: resolveApp('yarn.lock'),
    testsSetup: resolveApp('src/setupTests.js'),
    appNodeModules: resolveApp('node_modules'),
    nodePaths: nodePaths,
    heroCliConfig: resolveApp(heroConfig.heroCliConfig),
    publicUrl: getPublicUrl(resolveApp('package.json')),
    servedPath: getServedPath(resolveApp('package.json')),
  // These properties only exist before ejecting:
    ownPath: resolveOwn('.'),
    ownNodeModules: resolveOwn('node_modules') // This is empty on npm 3
};

var ownPackageJson = require('../package.json');
var reactScriptsPath = resolveApp(`node_modules/${ownPackageJson.name}`);
var reactScriptsLinked = fs.existsSync(reactScriptsPath) && fs.lstatSync(reactScriptsPath).isSymbolicLink();

// config before publish: we're in ./packages/react-scripts/config/
if (!reactScriptsLinked && __dirname.indexOf(path.join('packages', 'react-scripts', 'config')) !== -1) {
    module.exports = {
        appPath: resolveApp('.'),
        appBuild: resolveOwn('../../build'),
        appPublic: resolveOwn('template/public'),
        appHtml: resolveOwn('template/src/index.html'),
        appIndexJs: resolveOwn('template/src/index.js'),
        appPackageJson: resolveOwn('package.json'),
        appSrc: resolveOwn('template/src'),
        yarnLockFile: resolveOwn('template/yarn.lock'),
        testsSetup: resolveOwn('template/src/setupTests.js'),
        appNodeModules: resolveOwn('node_modules'),
        nodePaths: nodePaths,
        heroCliConfig: resolveApp(heroConfig.heroCliConfig),
        publicUrl: getPublicUrl(resolveOwn('package.json')),
        servedPath: getServedPath(resolveOwn('package.json')),
    // These properties only exist before ejecting:
        ownPath: resolveOwn('.'),
        ownNodeModules: resolveOwn('node_modules')
    };
}
// @remove-on-eject-end
