'use strict';
var chalk = require('chalk');
var yargs = require('yargs');
var paths = require('../config/paths');
var getEnvironments = require('../config/env');
var getHomePage = require('./getHomePage');

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


    global.logger.debug('Current build settings:');
    if (options.isInlineSource) {
        global.logger.debug('├── ' + chalk.yellow('Inline JavaScript/CSS into HTML'));
    } else {
        global.logger.debug('├── ' + chalk.yellow('Keep JavaScript/CSS Independent, Do not inline into HTML'));
    }
    if (options.noHashName) {
        global.logger.debug('├── ' + chalk.yellow('Rename JavaScript/CSS file with hashcode.'));
    } else {
        global.logger.debug('├── ' + chalk.yellow('Keep the original JavaScript/CSS filename, Do not rename it with hashcode.'));
    }

    if (options.noSourceMap) {
        global.logger.debug('├── ' + chalk.yellow('No Sourcemap File Generated.'));
    } else {
        global.logger.debug('├── ' + chalk.yellow('Generate Sourcemap File'));
    }

    if (options.hasAppCache) {
        global.logger.debug('├── ' + chalk.yellow('Generate AppCache File: ' + (options.hasAppCache === true ? global.defaultCliConfig.defaultAppCacheName : options.hasAppCache)));
    } else {
        global.logger.debug('├── ' + chalk.yellow('No AppCache File Generated.'));
    }

    if (!options.isStandAlone && !options.isHeroBasic) {
      // equals build all, same as default
        options.isStandAlone = true;
        options.isHeroBasic = true;
    } else if (options.isStandAlone !== options.isHeroBasic) {
        if (options.isStandAlone) {
            global.logger.debug('├── ' + chalk.yellow('Building without hero-js libararies.'));
        }
        if (options.isHeroBasic) {
            global.logger.debug('├── ' + chalk.yellow('Building with hero-js libararies only.'));
        }
    }

    global.options = options;

    global.homePageConfigs = getHomePage(global.heroCliConfig, global.defaultCliConfig);


    if (!isServeStatic) {
        global.clientEnvironmentConfig = getEnvironments(global.options.env, global.heroCliConfig, global.homePageConfigs);
    }

}

module.exports = getGlobalConfig;
