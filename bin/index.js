#!/usr/bin/env node
'use strict'
let spawn = require('cross-spawn')
let script = process.argv[2]
let args = process.argv.slice(3)
let yargs = require('yargs')
let result = null

function showUsage() {
  console.log()
  console.log('Usage: ' + yargs.argv.$0 + ' <command>')
  console.log()
  console.log('where <command> is one of:')
  console.log('    init, start, build')
  console.log()
  console.log(yargs.argv.$0 + ' <cmd> -h\tquick help on <cmd>')
  console.log(yargs.argv.$0 + ' init \t Initialize workspace, copy project and other basic configuration')
  console.log(yargs.argv.$0 + ' platform \t Build native package.')
  console.log(yargs.argv.$0 + ' dev \t Start the http server')
  console.log(yargs.argv.$0 + ' build \t Create a build package')
  console.log(yargs.argv.$0 + ' publish \t publish build to IPFS')
  console.log()
  console.log('See: https://github.com/hero-mobile/hero-cli')
  console.log()
}

switch (script) {
  case 'dev':
    require('../builder/dev-server')()
    break
  case 'build':
    require('../builder/build')()
    break
  case 'init':
  case 'platform':
  case 'serve':
  case 'start':
  case 'publish':
    result = spawn.sync('node', [require.resolve('../scripts/' + script)].concat(args), { stdio: 'inherit' })

    if (result.signal) {
      if (result.signal === 'SIGKILL') {
        console.log('The build failed because the process exited too early. ' +
          'This probably means the system ran out of memory or someone called ' +
          '`kill -9` on the process.')
      } else if (result.signal === 'SIGTERM') {
        console.log('The build failed because the process exited too early. ' +
          'Someone might have called `kill` or `killall`, or the system could ' +
          'be shutting down.')
      }
      process.exit(1)
    }
    process.exit(result.status)

  default:
    showUsage()
    break
}
