'use strict';

var paths = require('./paths');
var checkRequiredFiles = require('../lib/checkRequiredFiles');

// Warn and crash if required files are missing
if (!checkRequiredFiles([paths.heroCliConfig, paths.appIndexJs])) {
    process.exit(1);
}

function getClientEnvironment(env) {
    var heroFileConfig = require(paths.heroCliConfig);

    if (!heroFileConfig.environments) {
      
    }
  // Stringify all values so we can feed into Webpack DefinePlugin
    var stringified = {
        'process.env': Object
      .keys(raw)
      .reduce((env, key) => {
          env[key] = JSON.stringify(raw[key]);
          return env;
      }, {})
    };

    return { raw, stringified };
}

module.exports = getClientEnvironment;
