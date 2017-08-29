'use strict'

let yargs = require('yargs')
let log4js = require('log4js')
let logger = log4js.getLogger()

if (yargs.argv.verbose) {
  logger.setLevel('DEBUG')
} else {
  logger.setLevel('INFO')
}

// logger.trace('Entering cheese testing');
// logger.debug('Got cheese.');
// logger.info('Cheese is Gouda.');
// logger.warn('Cheese is quite smelly.');
// logger.error('Cheese is too ripe!');
// logger.fatal('Cheese was breeding ground for listeria.');

module.exports = logger
