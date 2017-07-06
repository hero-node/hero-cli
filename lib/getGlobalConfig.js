'use strict';

var yargs = require('yargs');
var paths = require('../config/paths');
var getEnvironments = require('../config/env');
var getHomePage = require('./getHomePage');

var log4js = require('log4js');
var logger = log4js.getLogger();

if (yargs.argv.verbose) {
    logger.setLevel('DEBUG');
} else {
    logger.setLevel('WARN');
}

function getGlobalConfig(isServeStatic) {
    global.paths = paths;
    global.argv = yargs.argv;
    // delete require.cache[paths.heroCliConfig];
    global.heroCliConfig = require(paths.heroCliConfig);
    global.defaultCliConfig = require('../config/hero-config.json');
    var options = {
        isStandAlone: global.argv.s,
        isHeroBasic: global.argv.b,
        isInlineSource: global.argv.i,
        noHashName: global.argv.n,
        noSourceMap: global.argv.m,
        hasAppCache: global.argv.f,
        webpackConfig: global.argv.c,
        env: global.argv.e,
        port: global.argv.p
    };

    if (!options.isStandAlone && !options.isHeroBasic) {
      // equals build all, same as default
        options.isStandAlone = true;
        options.isHeroBasic = true;
    }

    global.options = options;

    global.homePageConfigs = getHomePage(global.heroCliConfig, global.defaultCliConfig);


    if (!isServeStatic) {
        global.clientEnvironmentConfig = getEnvironments(global.options.env, global.heroCliConfig, global.homePageConfigs);
    }

}

module.exports = getGlobalConfig;
