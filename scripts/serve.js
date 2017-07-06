'use strict';

var yargs = require('yargs');
var detect = require('detect-port');
var chalk = require('chalk');
var http = require('http');
var express = require('express');
var getGlobalConfig = require('../lib/getGlobalConfig');
var clearConsole = require('../lib/clearConsole');
var setProxy = require('../lib/setProxy');
var pgk = require('../package.json');

var commandName = Object.keys(pgk.bin)[0];
var app = express();
var isInteractive = process.stdout.isTTY;

var proxyTips = '\n';

global.logger = require('../lib/logger');
getGlobalConfig(true);
var paths = global.paths;
var listenPort = global.options.p;
var heroCliConfig = global.defaultCliConfig;
var DEFAULT_PORT = (listenPort && /^\d+$/.test(listenPort)) ? listenPort : heroCliConfig.buildServePort;
var homePageConfig = global.homePageConfigs;

function showUsage() {
    var command = yargs
  .usage('Usage: ' + commandName + ' serve [options]')
  // .command('count', 'Count the lines in a file')
  .example(commandName + ' serve -p ' + heroCliConfig.buildServePort, 'Serve the application after build.');

    command.option('p', {
        describe: 'Port to listen on (defaults to ' + heroCliConfig.buildServePort + ')'
    });

    var argv = command.nargs('e', 1)
  .help('h')
  .epilog('copyright 2017')
  .argv;

    var fs = require('fs');
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

if (yargs.argv.h) {
    showUsage();
}

function run(port) {
    var portStr = (port === 80 ? '' : ':' + port);

    var proxyConfig = global.heroCliConfig.proxy;

    if (proxyConfig) {
        Object.keys(proxyConfig).forEach(function (url) {
            setProxy(app, proxyConfig[url], url);
            proxyTips += ('   ' + chalk.cyan(url) + ' will proxy to ' + chalk.cyan(proxyConfig[url]) + '\n');
        });
    }
    app.use(homePageConfig.publicURL, express.static(paths.appBuild));

    http.createServer(app).listen(port, function () {
        console.log();
        console.log(chalk.green('   The app is running at:'));
        console.log();
        console.log(chalk.green('   http://localhost' + portStr + (homePageConfig.getServedPath === '.' ? '/' : homePageConfig.getServedPath) + 'index.html'));
        console.log(proxyTips);
        console.log();
    });
}

detect(DEFAULT_PORT).then(port => {
    if (port === DEFAULT_PORT) {
        // console.log('A: port = ' + port);
        run(port);
        return;
    }
    var existingProcess,
        question;
    var getProcessForPort = require('../lib/getProcessForPort');

    existingProcess = getProcessForPort(DEFAULT_PORT);
    if (isInteractive) {
        clearConsole();
        existingProcess = getProcessForPort(DEFAULT_PORT);
        question = chalk.yellow('Something is already running on port ' + DEFAULT_PORT + '.' + ((existingProcess)
            ? ' Probably:\n  ' + existingProcess
            : '')) + '\n\nWould you like to run the app on another port instead?';

        require('../lib/prompt')(question, true).then(shouldChangePort => {
            if (shouldChangePort) {
                // console.log('B: port = ' + port);
                run(port);
            }
        });
    } else {
        console.log(chalk.red('Something is already running on port ' + DEFAULT_PORT + '.'));
    }
});
