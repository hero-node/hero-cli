'use strict';

var chalk = require('chalk');

if (!process.env.ANDROID_HOME) {
    console.log('Environment vairable ' + chalk.cyan('ANDROID_HOME') + ' doesn\'t exists! You can creating environmental variables like this:');
    console.log();
    console.log(chalk.cyan('export ANDROID_HOME=/my/user/path/android-sdk-linux'));
    process.exit(1);
}

var fs = require('fs');
var path = require('path');
var yargs = require('yargs');
var shell = require('shelljs');
var pgk = require('../package.json');
var commandName = Object.keys(pgk.bin)[0];
var paths = require('../config/paths');
var getBuildToosVersion = require('../lib/getAndroidVersions');
var checkRequiredFiles = require('../lib/checkRequiredFiles');

var ANDROID = 'android';
var IOS = 'ios';

global.argv = yargs.argv;

function showUsage() {

    console.log();
    console.log('Please specify the platform: android or ios.');
    console.log(chalk.cyan('    ' + commandName + ' platform build ') + chalk.green('<name>'));
    console.log();
    console.log('For example:');
    console.log(chalk.cyan('    ' + commandName + ' platform build android'));
    console.log();

    process.exit(1);
}
if (global.argv.h ||
    global.argv._[0] !== 'build') {
    showUsage();
}
if (global.argv._[1] !== IOS && global.argv._[1] !== ANDROID) {
    showUsage();
}

// Warn and crash if required files are missing
if (!checkRequiredFiles([paths.heroCliConfig])) {
    console.log();
    console.log('Please make sure you\'re under the root folder of the hero application.');
    console.log();
    process.exit(1);
}

var appType = global.argv._[1];
var isWindows = process.platform.indexOf('win') === 0;
var encoding = 'UTF-8';

function handleAndroidFiles() {
    var buildVersion = getBuildToosVersion();

    var gradleTemplate = path.join(__dirname, '../config/build.gradle');
    var content = fs.readFileSync(gradleTemplate, {
        encoding: encoding
    });

    content = content.replace('__compileSdkVersion', buildVersion.compileSdkVersion)
      .replace('__buildToolsVersion', buildVersion.buildToolsVersion)
      .replace('__supportAnnotationVersion', buildVersion.supportLibVersion);

    var gradleFile = path.join(paths.appSrc, '../platforms/', appType, '/app/build.gradle');

    fs.writeFileSync(gradleFile, content, {
        encoding: encoding
    });
}
function handleIOSFiles() {
}
function generateApp() {
    if (appType === IOS) {
        handleIOSFiles();
    } else {
        handleAndroidFiles();
    }

    var command = './gradlew';

    if (isWindows) {
        command += '.bat';
    }
    command += ' assembleDebug';

    shell.exec(command, {
        cwd: path.join(paths.appSrc, '../platforms/', appType),
        env: {
            ANDROID_HOME: process.env.ANDROID_HOME
        }
    });

}

generateApp();
