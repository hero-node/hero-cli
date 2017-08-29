'use strict'

let chalk = require('chalk')
let execSync = require('child_process').execSync
let execOptions = {
  encoding: 'utf8',
  stdio: [
    'pipe', // stdin (default)
    'pipe', // stdout (default)
    'ignore' // stderr
  ]
}

// function isProcessAHeroApp(processCommand) {
//     return /^node .*hero-cli\/scripts\/start\.js.*$/m.test(processCommand);
// }

function getProcessIdOnPort(port) {
  return execSync('lsof -i:' + port + ' -P -t -sTCP:LISTEN', execOptions).trim()
}

function getProcessCommand(processId) {
  let command = execSync('ps -o command -p ' + processId + ' | sed -n 2p', execOptions)

  // console.log(command);
  // if (isProcessAHeroApp(command)) {
  //     return 'scripts command from package.json ' + '\n';
  // } else {
  //     return command;
  // }
  return command
}

function getDirectoryOfProcessById(processId) {
  return execSync('lsof -p ' + processId + ' | awk \'$4=="cwd" {print $9}\'', execOptions).trim()
}

function getProcessForPort(port) {
  let processId, directory, command

  try {
    processId = getProcessIdOnPort(port)
    directory = getDirectoryOfProcessById(processId)
    command = getProcessCommand(processId, directory)

    return chalk.cyan(command) + chalk.blue('  in ') + chalk.cyan(directory)
  } catch (e) {
    return null
  }
}

module.exports = getProcessForPort
