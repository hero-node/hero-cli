'use strict';

var paths = require('./paths');
var path = require('path');
var checkRequiredFiles = require('../lib/checkRequiredFiles');
var chalk = require('chalk');
var config = require('./hero-config.json');
var homePageConfig = require('../lib/getHomePage');

// Warn and crash if required files are missing
if (!checkRequiredFiles([paths.heroCliConfig])) {
    process.exit(1);
}

function getClientEnvironment() {
    var env = global.envName || global.argv.e;

  // Hero will restart webpack, keep the variable
    global.envName = env;

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
    // `publicUrl` is just like `publicPath`, but we will provide it to our app
    // as %PUBLIC_URL% in `index.html` and `process.env.PUBLIC_URL` in JavaScript.
    // Omit trailing slash as %PUBLIC_URL%/xyz looks better than %PUBLIC_URL%xyz.
    raw.HOME_PAGE = homePageConfig.publicURL;
  // Stringify all values so we can feed into Webpack DefinePlugin
    var stringified = {
        'process.env': JSON.stringify(raw)
    };

    return { raw, stringified };
}

module.exports = getClientEnvironment;
