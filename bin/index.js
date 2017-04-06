#!/usr/bin/env node

'use strict';

var spawn = require('cross-spawn');
var script = process.argv[2];
var args = process.argv.slice(3);
var yargs = require('yargs');
var fs = require('fs');
var result = null;

function showUsage() {
    var argv = yargs
      .usage('Usage: $0 <command> [options]')
      .command(['init [project-directory]'], 'Initialize workspace, copy project and other basic configuration')
      .example('$0 init my-hero-app')
      .demandOption(['init'])
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

    console.log('See: https://github.com/dianrong/Hero');
}
switch (script) {
    case 'build':
    case 'init':
    case 'start':
    case 'test':
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
