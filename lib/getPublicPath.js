'use strict';

var paths = require('../config/paths');
var heroCliConfig = require('../config/hero-config.json');
var heroCustomConfig = require(paths.heroCliConfig);

var publicPath = heroCustomConfig[heroCliConfig.homePageKey];

if (typeof publicPath !== 'string') {
    publicPath = '/';
}

function getPublicPath() {
    return publicPath;
}

module.exports = getPublicPath;
