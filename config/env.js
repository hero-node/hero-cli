'use strict';

var path = require('path');
var checkRequiredFiles = require('../lib/checkRequiredFiles');
var chalk = require('chalk');
var HERO_APP = /^HERO_APP_/i;

function getClientEnvironment(env, heroFileConfig, homePageConfig) {
    var paths = global.paths;

    if (!checkRequiredFiles([global.paths.heroCliConfig])) {
        process.exit(1);
    }
    var config = global.defaultCliConfig;
    var environments = heroFileConfig[config.environmentKey];

    if (!environments || !environments[env]) {
        console.log(chalk.red('Unknown Environment "' + env + '".'));
        console.log('You have to add attribute ' + chalk.cyan(env) + ' under key ' + chalk.cyan(config.environmentKey) + ' in file ' + chalk.cyan(paths.heroCliConfig));
        console.log();
        console.log('For example:');
        console.log();
        console.log('    ' + chalk.dim('// ...'));
        console.log('    ' + chalk.yellow('"environments"') + ': {');
        console.log('      ' + chalk.dim('// ...'));
        console.log('      ' + chalk.yellow('"' + env + '"') + ': ' + chalk.yellow('"src/environments/environment-' + env + '.js"'));
        console.log('    }');
        console.log();
        process.exit(1);
    } else {
        global.logger.debug('├── Using Envrionment Config: ' + chalk.yellow(environments[env]));
    }

    var configPath = path.resolve(paths.heroCliConfig, '../', heroFileConfig[config.environmentKey][env]);

    // delete require.cache[configPath];
    var heroCustomConfig = require(configPath);

    var raw = Object
      .keys(process.env)
      .filter(key => HERO_APP.test(key))
      .reduce((rawConfig, key) => {
          rawConfig[key] = process.env[key];
          return rawConfig;
      }, heroCustomConfig);

    raw.NODE_ENV = process.env.NODE_ENV || 'development';
    // `publicUrl` is just like `publicPath`, but we will provide it to our app
    // as %PUBLIC_URL% in `index.html` and `process.env.PUBLIC_URL` in JavaScript.
    // Omit trailing slash as %PUBLIC_URL%/xyz looks better than %PUBLIC_URL%xyz.
    raw.HOME_PAGE = homePageConfig.publicURL;

  // Stringify all values so we can feed into Webpack DefinePlugin
    var stringified = {
        'process.env': JSON.stringify(raw)
    };

    return { raw, stringified, configPath };
}

module.exports = getClientEnvironment;
