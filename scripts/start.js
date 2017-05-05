'use strict';
// Spawn Process
process.env.NODE_ENV = 'development';

var yargs = require('yargs');
var chalk = require('chalk');
var _ = require('lodash');
var webpack = require('webpack');
var WebpackDevServer = require('webpack-dev-server');
var detect = require('detect-port');
var clearConsole = require('../lib/clearConsole');
var checkRequiredFiles = require('../lib/checkRequiredFiles');
var formatWebpackMessages = require('../lib/formatWebpackMessages');
var pgk = require('../package.json');
var paths = require('../config/paths');
var heroCliConfig = require('../config/hero-config.json');
var chokidar = require('chokidar');
var updateEntryFile = require('../lib/updateWebpackEntry');
var commandName = Object.keys(pgk.bin)[0];

function showUsage() {
    var argv = yargs
        .usage('Usage: ' + commandName + ' start <options>')
        // .command('count', 'Count the lines in a file')
        .example(commandName + ' start -e dev', 'Start the server using the dev configuration')
        .option('e', {
            demandOption: true,
            // default: '/etc/passwd',
            describe: 'Environment name of the configuration when start the server\n ' +
                      'Available value refer to \n\n' +
                      '<you-project-path>/' + heroCliConfig.heroCliConfig + '\n\nor you can add attribute environment names to attribute [' + heroCliConfig.environmentKey + '] in that file',
            type: 'string'
        })
        .nargs('e', 1)
        .help('h')
        .epilog('copyright 2017')
        .detectLocale(false)
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

if (yargs.argv.h || yargs.argv.e === undefined || typeof yargs.argv.e === 'boolean') {
    showUsage();
}
global.argv = yargs.argv;

var options = {
    isStandAlone: global.argv.s,
    isHeroBasic: global.argv.b,
    isInlineSource: global.argv.i,
    noHashName: global.argv.n,
    noSourceMap: global.argv.m,
    hasAppCache: global.argv.f,
    env: global.argv.f
};

if (!options.isStandAlone && !options.isHeroBasic) {
  // equals build all, same as default
    options.isStandAlone = true;
    options.isHeroBasic = true;
}

global.options = options;

var availablePort;
var cli = 'npm';
var isInteractive = process.stdout.isTTY;
// Initialize watcher.
var isFirstWatch = true;
var devServer = null;
// Tools like Cloud9 rely on this.
var DEFAULT_PORT = parseInt(process.env.PORT, 10) || heroCliConfig.devServerPort;
var compiler;

var expectedType = /\.js$/;
// Something to use when events are received.
var needUpdateEntry = false;

function restart() {
  // console.log('restart....');
// devServer.middleware.invalidate();
    devServer.close();
// eslint-disable-next-line
  run(availablePort);
}
function _checkRebuild(path, isDelete) {

    if (!expectedType.test(path)) {
        // Only Handler JS File
        return;
    }
    if (path === paths.appIndexJs) {
        // Ignore the src/index.js, using webpck default rebuild
        return;
    }
    if (!isFirstWatch) {
        // console.log('check.....=' + path);
        try {
            needUpdateEntry = updateEntryFile(compiler, path, isDelete);
        } catch (e) {
                // e && console.log(e);
            needUpdateEntry = false;
        }
        if (needUpdateEntry) {
            restart();
        }
    }
}
var checkRebuild = _.throttle(_checkRebuild, 1000, { 'trailing': true });

var watcher;

var fileAddWatchListener = function (path) {
    if (expectedType.test(path)) {
        // console.log('File ADD: ' + path);
        watcher.add(path);
        checkRebuild(path);
    }
};

var fileChangeWatchListener = function (path) {
    // console.log('File Change: ' + path);
    checkRebuild(path);
};

var fileRemoveWatchListener = function (path) {
  // Using Webpack Re-Build
    // console.log('File REMOVE: ' + path);
    watcher.unwatch(path);
    checkRebuild(path, true);
};

var addDirListener = function (path) {
  // console.log('Dir ADD: ' + path);
    watcher.add(path);
};

var unlinkDirListener = function (path) {
  // console.log('Dir REMOVE: ' + path);
    watcher.unwatch(path);
};

function watchSources() {
    watcher = chokidar.watch(paths.appSrc, {
        ignored: /[\/\\]\./,
        persistent: true
    });

    watcher.on('add', fileAddWatchListener)
          .on('change', fileChangeWatchListener)
          .on('unlink', fileRemoveWatchListener);

    // More possible events.
    watcher.on('addDir', addDirListener)
      .on('unlinkDir', unlinkDirListener);

}

// Warn and crash if required files are missing
if (!checkRequiredFiles([paths.appHtml, paths.appIndexJs])) {
    process.exit(1);
}


function setupCompiler(config, host, port, protocol) {
    // "Compiler" is a low-level interface to Webpack.
    // It lets us listen to some events and provide our own custom messages.
    // console.log(config, host, port, protocol);
    compiler = webpack(config, function (err) {
        if (err) {
            console.log(err);
        }
    });

    // "invalid" event fires when you have changed a file, and Webpack is
    // recompiling a bundle. WebpackDevServer takes care to pause serving the
    // bundle, so if you refresh, it'll wait instead of serving the old one.
    // "invalid" is short for "bundle invalidated", it doesn't imply any errors.
    compiler.plugin('invalid', function () {
        if (isInteractive) {
            clearConsole();
        }
        console.log('Compiling...');
    });

    // "done" event fires when Webpack has finished recompiling the bundle.
    // Whether or not you have warnings or errors, you will get this event.
    compiler.plugin('done', function (stats) {
        if (!watcher) { watchSources(); }
        if (isFirstWatch) {
            isFirstWatch = false;
        }
        if (isInteractive) {
            clearConsole();
        }
        // We have switched off the default Webpack output in WebpackDevServer
        // options so we are going to "massage" the warnings and errors and present
        // them in a readable focused way.
        var messages = formatWebpackMessages(stats.toJson({}, true));

        var isSuccessful = !messages.errors.length && !messages.warnings.length;
        var showInstructions = true;

        if (isSuccessful) {
            console.log(chalk.green('Compiled successfully!'));
        }

        // If errors exist, only show errors.
        if (messages.errors.length) {
            console.log(chalk.red('Failed to compile.'));
            console.log();
            messages.errors.forEach(message => {
                console.log(message);
                console.log();
            });

            // Teach some ESLint tricks.
            console.log('You may use special comments to disable some warnings.');
            console.log('Use ' + chalk.yellow('// eslint-disable-next-line') + ' to ignore the next line.');
            console.log('Use ' + chalk.yellow('/* eslint-disable */') + ' to ignore all warnings in a file.');

            return;
        }

    // Show warnings if no errors were found.
        if (messages.warnings.length) {
            console.log(chalk.yellow('Compiled with warnings.'));
            console.log();
            messages.warnings.forEach(message => {
                console.log(message);
                console.log();
            });
        }
        // Teach some ESLint tricks.
        console.log('You may use special comments to disable some warnings.');
        console.log('Use ' + chalk.yellow('// eslint-disable-next-line') + ' to ignore the next line.');
        console.log('Use ' + chalk.yellow('/* eslint-disable */') + ' to ignore all warnings in a file.');

        if (showInstructions) {
            console.log();
            console.log('The app is running at:');
            console.log();
            console.log('  ' + chalk.cyan(protocol + '://' + host + ':' + port + '/'));
            console.log();
            console.log('Note that the development build is not optimized.');
            console.log('To create a production build, use ' + chalk.cyan(cli + ' run build') + '.');
            console.log();
            console.log('To start the mock server, use ' + chalk.cyan(cli + ' run mock') + '.');
            console.log();
        }
    });
    // console.log(JSON.stringify(compiler));
}

function runDevServer(config, host, port, protocol) {

    devServer = new WebpackDevServer(compiler, {
    // Enable gzip compression of generated files.
        compress: true,
    // Silence WebpackDevServer's own logs since they're generally not useful.
    // It will still show compile warnings and errors with this setting.
        clientLogLevel: 'none',
        contentBase: paths.appPublic,
    // Enable hot reloading server. It will provide /sockjs-node/ endpoint
    // for the WebpackDevServer client so it can learn when the files were
    // updated. The WebpackDevServer client is included as an entry point
    // in the Webpack development configuration. Note that only changes
    // to CSS are currently hot reloaded. JS changes will refresh the browser.
        hot: true,
        setup: function (app) {
            var proxy;
            var proxyConfig = require(paths.heroCliConfig).proxy;

            if (proxyConfig) {
                proxy = require('express-http-proxy');

                Object.keys(proxyConfig).forEach(function (url) {
                    app.use(url, proxy(proxyConfig[url], {
                        forwardPath: function (req) {
                            return url + require('url').parse(req.url).path;
                        }
                    }));
                });
            }
        },
    // It is important to tell WebpackDevServer to use the same "root" path
    // as we specified in the config. In development, we always serve from /.
        publicPath: config.output.publicPath,
    // WebpackDevServer is noisy by default so we emit custom message instead
    // by listening to the compiler events with `compiler.plugin` calls above.
        quiet: true,
        watchOptions: {
            ignored: /node_modules/
        },
    // Enable HTTPS if the HTTPS environment variable is set to 'true'
        https: protocol === 'https',
        host: host
    });

    devServer.use(devServer.middleware);
  // Launch WebpackDevServer.
    devServer.listen(port, err => {
        if (err) {
            return console.log(err);
        }

        if (isInteractive) {
            clearConsole();
        }
        console.log(chalk.cyan('Starting the development server...'));
        console.log();

    });
}

function run(port) {
    var config, protocol, host;

    try {
        delete require.cache[require.resolve('../config/webpack.config.dev')];
        config = require('../config/webpack.config.dev');

        protocol = process.env.HTTPS === 'true' ? 'https' : 'http';
        host = process.env.HOST || 'localhost';

        availablePort = port;
        setupCompiler(config, host, port, protocol);
        runDevServer(config, host, port, protocol);
    } catch (e) {
        console.log(e);
    }
}

// We attempt to use the default port but if it is busy, we offer the user to
// run on a different port. `detect()` Promise resolves to the next free port.
detect(DEFAULT_PORT).then(port => {
    if (port === DEFAULT_PORT) {
        // console.log('A: port = ' + port);
        run(port);
        return;
    }
    var existingProcess, question;
    var getProcessForPort = require('../lib/getProcessForPort');

    existingProcess = getProcessForPort(DEFAULT_PORT);
    if (isInteractive) {
        clearConsole();
        existingProcess = getProcessForPort(DEFAULT_PORT);
        question = chalk.yellow('Something is already running on port ' + DEFAULT_PORT + '.' +
        ((existingProcess) ? ' Probably:\n  ' + existingProcess : '')) +
        '\n\nWould you like to run the app on another port instead?';

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
