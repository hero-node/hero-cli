'use strict'

let path = require('path')
let yargs = require('yargs')
let chalk = require('chalk')
let HtmlWebpackPlugin = require('html-webpack-plugin')
let ensureSlash = require('../lib/ensureSlash')
let getEntries = require('../lib/getEntries')
let webpackHotDevClientKey = 'web-hot-reload'
let appIndexKey = 'appIndex'
let getComponentsData = require('../lib/getComponentsData').getComponentsData
let hasVerbose = yargs.argv.verbose
let firstError = true
let isRelativePath = global.homePageConfigs.isRelativePath

function getEntryAndPlugins(isDevelopmentEnv) {
  global.entryTemplates = []
  let inlineSourceRegex = global.defaultCliConfig.inlineSourceRegex
  let isStandAlone = global.options.isStandAlone
  let isInlineSource = global.options.isInlineSource
  let isHeroBasic = global.options.isHeroBasic
  let paths = global.paths
  let buildEntries = {}

  // We ship a few polyfills by default:
  let indexOptions, buildPlugins = []

  if (isHeroBasic) {
    // buildEntries[webComponentsKey] = require.resolve('../lib/webcomponents-lite');
    buildEntries[appIndexKey] = paths.appIndexJs

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
    }

    if (isInlineSource) {
      indexOptions.inlineSource = inlineSourceRegex
    }
    // Generates an `index.html` file with the <script> injected.
    buildPlugins.push(new HtmlWebpackPlugin(indexOptions))
  }
  // console.log('getEntryAndPlugins----------------');
  if (isDevelopmentEnv) {
    buildEntries[webpackHotDevClientKey] = require.resolve('../lib/webpackHotDevClient')
  }
  let entries
  let validEntries
  let allGeneratedHTMLNames = {}
  let total = 0

  if (isStandAlone) {
    validEntries = getEntries(path.join(paths.appSrc)).filter(name => {
      return /\.js$/.test(name)
    }).map((name) => {
      return {
        name: name,
        entryConfig: getComponentsData(name)
      }
    }).filter(data => {
      return !!data.entryConfig
    })

    entries = validEntries.map((data, index) => {
      let entryConfig = data.entryConfig

      if (!entryConfig) {
        return
      }

      let name = data.name

      if (entryConfig.path) {
        entryConfig.filename = entryConfig.path
      }

      if (entryConfig.filename && entryConfig.filename.indexOf('/') === 0) {
        entryConfig.filename = entryConfig.filename.slice(1)
      }
      let filePath = name.replace(ensureSlash(path.join(paths.appSrc), true), '')
      let attriName = index + '-' + (name.match(/(.*)\/(.*)\.js$/)[2])

      let fileNamePath = filePath.match(/(.*)\.js$/)[1]

      let customTemplateUrl

      if (entryConfig.template) {
        customTemplateUrl = path.join(name, '../', entryConfig.template)
        global.entryTemplates.push(customTemplateUrl)
        entryConfig.template = '!!ejs!' + customTemplateUrl
      }
      if (isInlineSource) {
        entryConfig.inlineSource = inlineSourceRegex
      }
      let validPosition = (entryConfig.inject === 'head' || entryConfig.inject === 'body' || entryConfig.inject === false)

      let options = Object.assign({
        title: '',
        inject: customTemplateUrl ? (validPosition ? entryConfig.inject : 'head') : false,
        // webconfig html file loader using Polymer HTML
        template: '!!ejs!' + path.join(__dirname, 'entryTemplate.html'),
        filename: fileNamePath + '.html',
        // basePath = '../../' -->
        // entry = './static/js/abc.js'
        // basePath.length -2 + entry --> '../.' + './static/js/abc.js'
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
      }, entryConfig)

      let startWithSlash, pathPartLen
      let basePath = ''

      options.filename = options.filename.trim()
      startWithSlash = options.filename.indexOf('/') === 0

      pathPartLen = options.filename.split('\/').length
      if (startWithSlash) {
        pathPartLen--
      }
      pathPartLen--
      while (pathPartLen) {
        basePath += '../'
        pathPartLen--
      }

      options.basePath = isRelativePath ? basePath.substring(0, basePath.length - 2) : ''

      // console.log(options);

      let hasDuplicatedPath = allGeneratedHTMLNames[options.filename]
      let shortName = name.replace(paths.appSrc, 'src')

      if (hasDuplicatedPath) {
        total++
      }

      // if (!hasDuplicatedPath) {
      allGeneratedHTMLNames[options.filename] = shortName
      // }

      let logMethod = hasDuplicatedPath ? 'warn' : 'debug'

      if (hasVerbose) {
        if (index === 0) {
          global.logger[logMethod]('├── Generate HTML: ')
        }
      } else {
        if (hasDuplicatedPath && firstError) {
          global.logger[logMethod](' ├── Generate HTML: ')
          firstError = false
        }
      }

      let color = hasDuplicatedPath ? 'red' : 'yellow'
      let prefix = '├── '
      let isLastOne = index === (validEntries.length - 1)

      if (isLastOne) {
        prefix = '└── '
      }
      let warnDebugCharGap = (hasDuplicatedPath ? ' ' : '')

      global.logger[logMethod](warnDebugCharGap + '│   ' + prefix + chalk[color](options.filename) + (hasDuplicatedPath ? chalk.red('(Name conflict with file generated by ') + '"' + chalk.cyan(hasDuplicatedPath) + '"' : ''))
      global.logger[logMethod](warnDebugCharGap + '│   ' + (isLastOne ? ' ' : '│') + '   ' + (customTemplateUrl ? '├──' : '└──') + ' JS Entry: ' + shortName)
      if (customTemplateUrl) {
        global.logger[logMethod](warnDebugCharGap + '│   ' + (isLastOne ? '' : '│') + '   └── HTML Template: ' + customTemplateUrl.replace(paths.appSrc, 'src'))
      }
      if (isLastOne) {
        if (!firstError) {
          global.logger.warn(' └── ' + chalk.yellow('Total ' + total + ' Warning' + (total > 1 ? 's.' : '.')))
        }
      }
      return {
        file: name,
        entryName: attriName,
        plugin: new HtmlWebpackPlugin(options)
      }
    }).filter(function(entry) {
      return !!entry
    })

    // console.log('entries-------', entries);
    entries.forEach(entry => {
      buildEntries[entry.entryName] = entry.file
    })

    buildPlugins = buildPlugins.concat(entries.map(entry => {
      return entry.plugin
    }))
  }
  return {
    entry: buildEntries,
    plugin: buildPlugins
  }
}

module.exports = getEntryAndPlugins
