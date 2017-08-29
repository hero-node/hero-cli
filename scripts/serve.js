'use strict'

let yargs = require('yargs')
let detect = require('detect-port')
let chalk = require('chalk')
let http = require('http')
let express = require('express')
let getGlobalConfig = require('../lib/getGlobalConfig')
let clearConsole = require('../lib/clearConsole')
let setProxy = require('../lib/setProxy')
let pgk = require('../package.json')

let commandName = Object.keys(pgk.bin)[0]
let app = express()
let isInteractive = process.stdout.isTTY

let proxyTips = '\n'

global.logger = require('../lib/logger')
getGlobalConfig(true)
let paths = global.paths
let listenPort = global.options.p
let heroCliConfig = global.defaultCliConfig
let DEFAULT_PORT = (listenPort && /^\d+$/.test(listenPort)) ? listenPort : heroCliConfig.buildServePort
let homePageConfig = global.homePageConfigs

function showUsage() {
  let command = yargs
    .usage('Usage: ' + commandName + ' serve [options]')
    // .command('count', 'Count the lines in a file')
    .example(commandName + ' serve -p ' + heroCliConfig.buildServePort, 'Serve the application after build.')

  command.option('p', {
    describe: 'Port to listen on (defaults to ' + heroCliConfig.buildServePort + ')'
  })

  let argv = command.nargs('e', 1)
    .help('h')
    .epilog('copyright 2017')
    .argv

  let fs = require('fs')
  let s = fs.createReadStream(argv.file)

  let lines = 0

  s.on('data', function(buf) {
    lines += buf.toString().match(/\n/g).length
  })

  s.on('end', function() {
    console.log(lines)
  })

  process.exit(1)
}

if (yargs.argv.h) {
  showUsage()
}

function run(port) {
  let portStr = (port === 80 ? '' : ':' + port)

  let proxyConfig = global.heroCliConfig.proxy

  if (proxyConfig) {
    Object.keys(proxyConfig).forEach(function(url) {
      setProxy(app, proxyConfig[url], url)
      proxyTips += ('   ' + chalk.cyan(url) + ' will proxy to ' + chalk.cyan(proxyConfig[url]) + '\n')
    })
  }
  app.use(homePageConfig.publicURL ? homePageConfig.publicURL : '/', express.static(paths.appBuild))

  let serveRootPath = homePageConfig.isRelativePath

  http.createServer(app).listen(port, function() {
    console.log(chalk.green('   The app is running at:'))
    console.log()
    console.log(chalk.green('   http://localhost' + portStr + (serveRootPath ? '/' : homePageConfig.getServedPath) + 'index.html'))
    console.log(proxyTips)
  })
}

detect(DEFAULT_PORT).then(port => {
  if (port === DEFAULT_PORT) {
    // console.log('A: port = ' + port);
    run(port)
    return
  }
  let existingProcess,
    question
  let getProcessForPort = require('../lib/getProcessForPort')

  existingProcess = getProcessForPort(DEFAULT_PORT)
  if (isInteractive) {
    clearConsole()
    existingProcess = getProcessForPort(DEFAULT_PORT)
    question = chalk.yellow('Something is already running on port ' + DEFAULT_PORT + '.' + ((existingProcess)
      ? ' Probably:\n  ' + existingProcess
      : '')) + '\n\nWould you like to run the app on another port instead?'

    require('../lib/prompt')(question, true).then(shouldChangePort => {
      if (shouldChangePort) {
        // console.log('B: port = ' + port);
        run(port)
      } else {
        process.exit(0)
      }
    })
  } else {
    console.log(chalk.red('Something is already running on port ' + DEFAULT_PORT + '.'))
  }
})
