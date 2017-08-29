'use strict'

let chalk = require('chalk')

if (!process.env.ANDROID_HOME) {
  console.log('Environment vairable ' + chalk.cyan('ANDROID_HOME') + ' doesn\'t exists! You can creating environmental variables like this:')
  console.log()
  console.log(chalk.cyan('export ANDROID_HOME=/my/user/path/android-sdk-linux'))
  process.exit(1)
}

let fs = require('fs')
let path = require('path')
let yargs = require('yargs')
let shell = require('shelljs')
let pgk = require('../package.json')
let commandName = Object.keys(pgk.bin)[0]
let paths = require('../config/paths')
let getAndroidVersion = require('../lib/getAndroidVersions')
let checkRequiredFiles = require('../lib/checkRequiredFiles')
let getEntries = require('../lib/getEntries')

let ANDROID = 'android'
let IOS = 'ios'

global.argv = yargs.argv

function showUsage() {
  let command = yargs
    .usage('Usage: ' + commandName + ' platform build <android | ios>')
    // .command('count', 'Count the lines in a file')
    .example(commandName + ' platform build android -e dev', 'Build android app using dev configurations')

  command.option('e', {
    demandOption: true,
    // default: '/etc/passwd',
    describe: 'Environment name of the configuration when build the native app',
    type: 'string'
  })
  let argv = command.nargs('e', 1)
    .help('h')
    .epilog('copyright 2017')
    .argv

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
if (global.argv.h ||
    global.argv._[0] !== 'build') {
  showUsage()
}
if (global.argv.h || global.argv.e === undefined || typeof global.argv.e === 'boolean') {
  showUsage()
}

global.logger = require('../lib/logger')

let appConfigs = global.argv._[1].split(':')

if (appConfigs[0] !== IOS && appConfigs[0] !== ANDROID) {
  showUsage()
}

let customHeroCliConfig = require(paths.heroCliConfig)

if (!customHeroCliConfig[appConfigs[0]] ||
    !customHeroCliConfig[appConfigs[0]][global.argv.e] ||
    !customHeroCliConfig[appConfigs[0]][global.argv.e].host) {
  console.log(chalk.red('Unknown Environment "' + global.argv.e + '".'))
  console.log('Please specify the ' + chalk.cyan('host') + ' attribute of environment ' + chalk.cyan(global.argv.e) + ' in the ' + chalk.cyan(appConfigs[0]) + ' configuration of file ' + chalk.cyan(paths.heroCliConfig))
  console.log()
  console.log('For example:')
  console.log()
  console.log('    ' + chalk.dim('// ...'))
  console.log('    ' + chalk.yellow('"' + appConfigs[0] + '"') + ': {')
  console.log('      ' + chalk.dim('// ...'))
  console.log('      ' + chalk.yellow('"' + global.argv.e + '"') + ': {')
  console.log('        ' + chalk.dim('// ...'))
  console.log('        ' + chalk.yellow('"host"') + ': ' + chalk.yellow('"http://10.0.2.2:3000/mkt/pages/start.html"'))
  console.log('      }')
  console.log('    }')
  console.log()
  process.exit(1)
}

console.log(customHeroCliConfig.android[global.argv.e])
// Warn and crash if required files are missing

if (!checkRequiredFiles([paths.heroCliConfig])) {
  console.log()
  console.log('Please make sure you\'re under the root folder of the hero application.')
  console.log()
  process.exit(1)
}

let appType = appConfigs[0]
let isWindows = process.platform.indexOf('win') === 0
let encoding = 'UTF-8'

function handleAndroidFiles() {
  // Dealing with file platforms/android/app/build.gradle
  let buildVersion = getAndroidVersion(appConfigs)
  let gradleTemplate = path.join(paths.appSrc, '../platforms/', appType, '/template/build.gradle')

  let content = fs.readFileSync(gradleTemplate, {
    encoding: encoding
  })

  content = content.replace(/__compileSdkVersion/g, buildVersion.compileSdkVersion)
    .replace(/__buildToolsVersion/g, buildVersion.buildToolsVersion)
    .replace(/__supportAnnotationVersion/g, buildVersion.supportLibVersion)

  let gradleFile = path.join(paths.appSrc, '../platforms/', appType, '/app/build.gradle')

  fs.writeFileSync(gradleFile, content, {
    encoding: encoding
  })

  let javaPath = 'app/src/main/java/hero/hero_sample/HeroSampleApplication.java'
  let javaHomePageTemplatePath = path.join(paths.appSrc, '../platforms/', appType, '/template/HeroSampleApplication.java')

  content = fs.readFileSync(javaHomePageTemplatePath, {
    encoding: encoding
  })

  content = content.replace(/__HOME_ADDRESS/g, customHeroCliConfig.android[global.argv.e].host)

  let javaHomePagePath = path.join(paths.appSrc, '../platforms/', appType, javaPath)

  fs.writeFileSync(javaHomePagePath, content, {
    encoding: encoding
  })
}
function handleIOSFiles() {
}
function generateApp() {
  if (appType === IOS) {
    handleIOSFiles()
  } else {
    handleAndroidFiles()
  }

  let command = './gradlew'

  if (isWindows) {
    command += '.bat'
  }
  command += ' assembleDebug'

  shell.exec(command, {
    cwd: path.join(paths.appSrc, '../platforms/', appType),
    env: {
      ANDROID_HOME: process.env.ANDROID_HOME
    }
  }, function(error) {
    if (!error) {
      console.log('Built the following apk(s): ')
      console.log()
      if (appConfigs[0] === ANDROID) {
        getEntries(path.join(paths.appSrc, '../platforms/', appType, 'app/build/outputs/apk')).forEach(function(filename) {
          console.log('	' + chalk.cyan(filename))
        })
      }
      console.log()
    }
  })
}

generateApp()
