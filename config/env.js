'use strict';

var paths = require('./paths');
var path = require('path');
var checkRequiredFiles = require('../lib/checkRequiredFiles');
var chalk = require('chalk');
var config = require('./hero-config.json');

// Warn and crash if required files are missing
if (!checkRequiredFiles([paths.heroCliConfig])) {
    process.exit(1);
}

function getClientEnvironment(env) {
    var heroFileConfig = require(paths.heroCliConfig);
    var environments = heroFileConfig[config.environmentKey];

    if (environments && Object.keys(environments) === 1) {
        if (!env) {
            env = Object.keys(environments)[0];
        }
    }
    if (env) {
        if (!environments || !environments[env]) {
            console.log(chalk.red('Unknown Environment "' + env + '".'));
            console.log('You may need to update ' + paths.heroCliConfig);
            console.log(chalk.red('  Add attribute "' + env + '" under key "' + config.environmentKey + '" in : ') + chalk.cyan(paths.heroCliConfig) + ' and set the value to the config file path');
            process.exit(1);
        }
    }
    // console.log('env=' + env);
    var configPath = path.resolve(paths.heroCliConfig, '../', heroFileConfig[config.environmentKey][env]);

    var raw = require(configPath);

    raw.NODE_ENV = process.env.NODE_ENV || 'development';
  // Stringify all values so we can feed into Webpack DefinePlugin
    var stringified = {
        'process.env': JSON.stringify(raw)
    };

    return { raw, stringified };
}

module.exports = getClientEnvironment;
