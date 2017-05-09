'use strict';

var url = require('url');
var ensureSlash = require('./ensureSlash');
var paths = require('../config/paths');
var heroCliConfig = require('../config/hero-config.json');
var heroCustomConfig = require(paths.heroCliConfig);

var original = heroCustomConfig[heroCliConfig.homePageKey];

var isExists = (typeof original === 'string');

if (isExists) {
    original = original.trim();
    if (original === '') {
        original = '/';
    }
} else {
    original = '/';
}
var homepage = isExists ? ensureSlash(url.parse(original).pathname, true) : '/';

homepage = homepage.indexOf('/') === 0 ? homepage : '/' + homepage;

module.exports = {
    original: original,
    getServedPath: homepage,
    publicURL: homepage.slice(0, -1),
    isExists: isExists
};
