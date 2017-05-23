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
var getAndroidVersion = require('../lib/getAndroidVersions');
var checkRequiredFiles = require('../lib/checkRequiredFiles');
var getEntries = require('../lib/getEntries');

var ANDROID = 'android';
var IOS = 'ios';

global.argv = yargs.argv;

function showUsage() {

    var command = yargs
      .usage('Usage: ' + commandName + ' platform build <android | ios>')
      // .command('count', 'Count the lines in a file')
      .example(commandName + ' platform build android -e dev', 'Build android app using dev configurations');

    command.option('e', {
        demandOption: true,
        // default: '/etc/passwd',
        describe: 'Environment name of the configuration when build the native app',
        type: 'string'
    });
    var argv = command.nargs('e', 1)
          .help('h')
          .epilog('copyright 2017')
          .argv;

    var s = fs.createReadStream(argv.file);

    var lines = 0;

    s.on('data', function (buf) {
        lines += buf.toString().match(/\n/g).length;
    });

    s.on('end', function () {
        console.log(lines);
    });

    process.exit(1);

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
if (global.argv.h || global.argv.e === undefined || typeof global.argv.e === 'boolean') {
    showUsage();
}

var appConfigs = global.argv._[1].split(':');

if (appConfigs[0] !== IOS  && appConfigs[0] !== ANDROID) {
    showUsage();
}

var customHeroCliConfig = require(paths.heroCliConfig);

if (!customHeroCliConfig[appConfigs[0]] ||
    !customHeroCliConfig[appConfigs[0]][global.argv.e] ||
    !customHeroCliConfig[appConfigs[0]][global.argv.e].host) {
    console.log('Please specify the ' + chalk.cyan('host') + ' attribute of environment ' + chalk.cyan(global.argv.e) + ' in the ' + chalk.cyan(appConfigs[0]) + ' configuration of file ' + chalk.cyan(paths.heroCliConfig));
    console.log();
    console.log('For example:');
    console.log();
    console.log('    ' + chalk.dim('// ...'));
    console.log('    ' + chalk.yellow('"' + appConfigs[0] + '"') + ': {');
    console.log('      ' + chalk.dim('// ...'));
    console.log('      ' + chalk.yellow('"' + global.argv.e + '"') + ': {');
    console.log('        ' + chalk.dim('// ...'));
    console.log('        ' + chalk.yellow('"host"') + ': ' + chalk.yellow('"http://10.0.2.2:3000/mkt/pages/start.html",'));
    console.log('      }');
    console.log('    }');
    console.log();
    process.exit(1);
}

console.log(customHeroCliConfig.android[global.argv.e]);
// Warn and crash if required files are missing

if (!checkRequiredFiles([paths.heroCliConfig])) {
    console.log();
    console.log('Please make sure you\'re under the root folder of the hero application.');
    console.log();
    process.exit(1);
}

var appType = appConfigs[0];
var isWindows = process.platform.indexOf('win') === 0;
var encoding = 'UTF-8';

function handleAndroidFiles() {
    // Dealing with file platforms/android/app/build.gradle
    var buildVersion = getAndroidVersion(appConfigs);
    var gradleTemplate = path.join(__dirname, '../config/build.gradle');
    var content = fs.readFileSync(gradleTemplate, {
        encoding: encoding
    });

    content = content.replace(/__compileSdkVersion/g, buildVersion.compileSdkVersion)
      .replace(/__buildToolsVersion/g, buildVersion.buildToolsVersion)
      .replace(/__supportAnnotationVersion/g, buildVersion.supportLibVersion);

    var gradleFile = path.join(paths.appSrc, '../platforms/', appType, '/app/build.gradle');

    fs.writeFileSync(gradleFile, content, {
        encoding: encoding
    });

    var javaPath = 'app/src/main/java/hero/hero_sample/HeroSampleApplication.java';
    var javaHomePageTemplatePath = path.join(__dirname, '../config/HeroSampleApplication.java');

    content = fs.readFileSync(javaHomePageTemplatePath, {
        encoding: encoding
    });

    content = content.replace(/__HOME_ADDRESS/g, customHeroCliConfig.android[global.argv.e].host);

    var javaHomePagePath = path.join(paths.appSrc, '../platforms/', appType, javaPath);

    fs.writeFileSync(javaHomePagePath, content, {
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
    }, function (error) {
        if (!error) {
            console.log('Built the following apk(s): ');
            console.log();
            if (appConfigs[0] === ANDROID) {
                getEntries(path.join(paths.appSrc, '../platforms/', appType, 'app/build/outputs/apk')).forEach(function (filename) {
                    console.log('	' + chalk.cyan(filename));
                });
            }
            console.log();
        }
    });

}

generateApp();
