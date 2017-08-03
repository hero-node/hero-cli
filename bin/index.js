#!/usr/bin/env node

'use strict';

var spawn = require('cross-spawn');
var script = process.argv[2];
var args = process.argv.slice(3);
var yargs = require('yargs');
var result = null;

function showUsage() {
    // var argv = yargs
    //   .usage('Usage: $0 <command> [options]')
    //   .usage(['init [project-directory]'], 'Initialize workspace, copy project and other basic configuration')
    //   // .command(['start [options]'], 'Initialize workspace, copy project and other basic configuration')
    //   // .command(['build [options]'], 'Initialize workspace, copy project and other basic configuration')
    //   .example('$0 init my-hero-app')
    //   .demandOption([])
    //   // .epilog('copyright 2017')
    //   .argv;

    console.log();
    console.log('Usage: ' + yargs.argv.$0 + ' <command>');
    console.log();
    console.log('where <command> is one of:');
    console.log('    init, start, build');
    console.log();
    console.log(yargs.argv.$0 + ' <cmd> -h\tquick help on <cmd>');
    console.log(yargs.argv.$0 + ' init\tInitialize workspace, copy project and other basic configuration');
    console.log(yargs.argv.$0 + ' platform\tBuild native package.');
    console.log(yargs.argv.$0 + ' start\tStart the http server');
    console.log(yargs.argv.$0 + ' build\tCreate a build package');
    console.log(yargs.argv.$0 + ' publish\tpublish build to IPFS');
    console.log();
    console.log('See: https://github.com/hero-mobile/hero-cli');
    console.log();
}
switch (script) {
    case 'build':
    case 'init':
    case 'platform':
    case 'serve':
    case 'start':
    case 'publish':
        result = spawn.sync('node', [require.resolve('../scripts/' + script)].concat(args), { stdio: 'inherit' });

        if (result.signal) {
            if (result.signal === 'SIGKILL') {
                console.log('The build failed because the process exited too early. ' +
                    'This probably means the system ran out of memory or someone called ' +
                    '`kill -9` on the process.');
            } else if (result.signal === 'SIGTERM') {
                console.log('The build failed because the process exited too early. ' +
                    'Someone might have called `kill` or `killall`, or the system could ' +
                    'be shutting down.');
            }
            process.exit(1);
        }
        process.exit(result.status);
        break;
    default:
        showUsage();
        break;
}
