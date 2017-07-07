'use strict';

process.env.NODE_ENV = 'production';

// Spawn Process
var yargs = require('yargs');
var path = require('path');
var chalk = require('chalk');
var fs = require('fs-extra');
var webpack = require('webpack');
var checkRequiredFiles = require('../lib/checkRequiredFiles');
var FileSizeReporter = require('../lib/FileSizeReporter');
var printFileSizesAfterBuild = FileSizeReporter.printFileSizesAfterBuild;
var commandOptions = require('../config/options');
var pgk = require('../package.json');
var commandName = Object.keys(pgk.bin)[0];

function showUsage() {
    var command = require('yargs')
        .usage('Usage: ' + commandName + ' build <options>')
        // .command('count', 'Count the lines in a file')
        .example(commandName + ' start -e dev', 'Start the server using the dev configuration');

    commandOptions.forEach(function (option) {
        command = command.option(option.name, option.value);
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
}

if (yargs.argv.h || yargs.argv.e === undefined || (typeof yargs.argv.e === 'boolean') || (typeof yargs.argv.c === 'boolean')) {
    showUsage();
}
global.logger = require('../lib/logger');
require('../lib/getGlobalConfig')();

var paths = global.paths;
var heroCliConfig = global.defaultCliConfig;
var homePageConfig = global.homePageConfigs;
var buildFolder = heroCliConfig.outDir;
var config;
var webpackConfigPath;

if (yargs.argv.c === undefined) {
    global.logger.debug('├── Using default built-in webpack configuration: ');
    global.logger.debug('│    └── ' + chalk.yellow(path.join(__dirname, '../config/webpack.config.prod')));
    config = require('../config/webpack.config.prod');
} else {
    webpackConfigPath = path.join(paths.appIndexJs, '../../', yargs.argv.c);
    global.logger.info('├── Using custom webpack configuration: ');
    global.logger.info('│     └── ' + chalk.yellow(webpackConfigPath));
    config = require(webpackConfigPath);
}
// Warn and crash if required files are missing

if (!checkRequiredFiles([paths.appHtml, paths.appIndexJs])) {
    process.exit(1);
}

// Print out errors
function printErrors(summary, errors) {
    console.log(chalk.red(summary));
    console.log();
    errors.forEach(err => {
        console.log(err.message || err);
        console.log();
    });
}

function showHomepageExample(homepage, isGithub) {
    console.log('The project was built assuming it is hosted at ' + homepage + '.');
    console.log('To override this, specify the ' + chalk.green('homepage') + ' in your '  + chalk.cyan(heroCliConfig.heroCliConfig) + '.');
    if (!isGithub) {
        console.log('For example, add this to build it for GitHub Pages:');
        console.log();
        console.log('  ' + chalk.green('"homepage"') + chalk.cyan(': ') + chalk.green('"http://myname.github.io/myapp"') + chalk.cyan(','));
        console.log();
        console.log('or add this to build it for custom path');
    } else {
        console.log('For example, add this to build it for custom path');
    }
    console.log();
    console.log('  ' + chalk.green('"homepage"') + chalk.cyan(': ') + chalk.green('"/mkt/myapp"') + chalk.cyan(','));
    console.log();
    console.log('The ' + chalk.cyan(paths.appBuild) + ' folder is ready to be deployed.');
    console.log();
}
function showServeBuild() {
    console.log('Add the following script in your ' + chalk.cyan('package.json') + '.');
    console.log();
    console.log('    ' + chalk.dim('// ...'));
    console.log('    ' + chalk.yellow('"scripts"') + ': {');
    console.log('      ' + chalk.dim('// ...'));
    console.log('      ' + chalk.yellow('"serve"') + ': ' + chalk.yellow('"hero serve",'));
    console.log('    }');
    console.log();
    console.log('And then you can serve it with a static server using command:');
    console.log();
    console.log('  ' + chalk.cyan('npm run serve'));
    console.log();
}
// Create the production build and print the deployment instructions.
function build() {
    console.log(chalk.cyan('Creating an optimized production build...'));
    console.log();
    webpack(config).run((err, stats) => {
        if (err) {
            printErrors('Failed to compile.', [err]);
            process.exit(1);
        }

        if (stats.compilation.errors.length) {
            printErrors('Failed to compile.', stats.compilation.errors);
            process.exit(1);
        }

        if (process.env.ESLINT_WARNING_MAX &&
            stats.compilation.warnings.length > parseInt(process.env.ESLINT_WARNING_MAX, 10)) {
            printErrors('Failed to compile. When process.env.ESLINT_WARNING_MAX is set, warnings total size should not greater than ' + process.env.ESLINT_WARNING_MAX + ' Otherwise treated as failures.', stats.compilation.warnings);
            process.exit(1);
        }

        console.log(chalk.green('Compiled successfully.'));
        console.log();

        console.log('File sizes after gzip:');
        console.log();
        printFileSizesAfterBuild(stats);
        console.log();

        var original = homePageConfig.original;
        var getServedPath = homePageConfig.getServedPath;
        var isExists = homePageConfig.isExists;

        var isServedAtRoot = (getServedPath === '/');

        if (!isExists || isServedAtRoot) {
            if (!isExists) {
              // no homepage
                showHomepageExample('the server root');
                showServeBuild();
            } else if (isServedAtRoot) {
              // "homepage": "http://mywebsite.com"
                showHomepageExample(chalk.green(original));
                showServeBuild();
            }
            return;
        }
        var isGithubHome = (original && original.indexOf('.github.io/') !== -1);

        if (!isServedAtRoot) {
            if (isGithubHome) {
              // "homepage": "http://user.github.io/project"
                showHomepageExample(chalk.green(original), true);
                console.log('The ' + chalk.cyan(buildFolder) + ' folder is ready to be deployed.');
                console.log('To publish it at ' + chalk.green(original) + ', run:');
              // If script deploy has been added to package.json, skip the instructions
                console.log();
                console.log('  ' + chalk.cyan('npm') +  ' install --save-dev gh-pages');
                console.log();
                console.log('Add the following script in your ' + chalk.cyan(heroCliConfig.heroCliConfig) + '.');
                console.log();
                console.log('    ' + chalk.dim('// ...'));
                console.log('    ' + chalk.yellow('"scripts"') + ': {');
                console.log('      ' + chalk.dim('// ...'));
                console.log('      ' + chalk.yellow('"predeploy"') + ': ' + chalk.yellow('"npm run build",'));
                console.log('      ' + chalk.yellow('"deploy"') + ': ' + chalk.yellow('"gh-pages -d build"'));
                console.log('    }');
                console.log();
                console.log('Then run:');
                console.log();
                console.log('  ' + chalk.cyan('npm') +  ' run deploy');
                console.log();
            } else {
              // "homepage": "http://mywebsite.com/project"
                showHomepageExample(chalk.green(original));
            }
            showServeBuild();
        }
    });
}

function copyPublicFolder() {
    fs.copySync(paths.appPublic, paths.appBuild, {
        dereference: true
    });
}

global.logger.debug('└── Output Folder: ' + chalk.yellow(paths.appBuild));
console.log();
// Remove all content but keep the directory so that
// if you're in it, you don't end up in Trash
fs.emptyDirSync(paths.appBuild);

// Start the webpack build
build();

// Merge with the public folder
if (global.options.isHeroBasic) {
    copyPublicFolder();
}
