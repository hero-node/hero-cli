'use strict'

let path = require('path')
let fs = require('fs')
let heroConfig = require('./hero-config.json')
// Make sure any symlinks in the project folder are resolved:
// https://github.com/facebookincubator/create-react-app/issues/637
let appDirectory = fs.realpathSync(process.cwd())

function resolveApp(relativePath) {
  return path.resolve(appDirectory, relativePath)
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

let nodePaths = (process.env.NODE_PATH || '')
  .split(process.platform === 'win32' ? ';' : ':')
  .filter(Boolean)
  .filter(folder => !path.isAbsolute(folder))
  .map(resolveApp)

// config after eject: we're in ./config/
module.exports = {
  appBuild: resolveApp(heroConfig.outDir),
  appPublic: resolveApp('public'),
  appHtml: resolveApp('src/index.html'),
  appIndexJs: resolveApp('src/index.js'),
  appPackageJson: resolveApp('package.json'),
  appSrc: resolveApp('src'),
  yarnLockFile: resolveApp('yarn.lock'),
  testsSetup: resolveApp('src/setupTests.js'),
  appNodeModules: resolveApp('node_modules'),
  nodePaths: nodePaths,
  heroCliConfig: resolveApp(heroConfig.heroCliConfig)
}

// @remove-on-eject-begin
function resolveOwn(relativePath) {
  return path.resolve(__dirname, '..', relativePath)
}

// config before eject: we're in ./node_modules/react-scripts/config/
module.exports = {
  appPath: resolveApp('.'),
  appBuild: resolveApp(heroConfig.outDir),
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
  // These properties only exist before ejecting:
  ownPath: resolveOwn('.'),
  ownNodeModules: resolveOwn('node_modules') // This is empty on npm 3
}

let ownPackageJson = require('../package.json')
let reactScriptsPath = resolveApp(`node_modules/${ownPackageJson.name}`)
let reactScriptsLinked = fs.existsSync(reactScriptsPath) && fs.lstatSync(reactScriptsPath).isSymbolicLink()

// config before publish: we're in ./packages/react-scripts/config/
if (!reactScriptsLinked && __dirname.indexOf(path.join('packages', 'react-scripts', 'config')) !== -1) {
  module.exports = {
    appPath: resolveApp('.'),
    appBuild: resolveOwn('../../' + heroConfig.outDir),
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
    // These properties only exist before ejecting:
    ownPath: resolveOwn('.'),
    ownNodeModules: resolveOwn('node_modules')
  }
}
// @remove-on-eject-end
