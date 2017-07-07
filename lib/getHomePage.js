'use strict';

var url = require('url');
var ensureSlash = require('./ensureSlash');

function getHomePage(heroCustomConfig, defaultCliConfig) {

    var original = heroCustomConfig[defaultCliConfig.homePageKey];

    var isExists = (typeof original === 'string');

    if (!isExists || original.trim() === '' || original.trim() === '.' || original.trim() === './') {
        return  {
            original: original,
            getServedPath: './',
            publicURL: '',
            isExists: isExists
        };
    }

    var homepage = isExists ? ensureSlash(url.parse(original).pathname, true) : '/';

    homepage = homepage.indexOf('/') === 0 ? homepage : '/' + homepage;

    return  {
        original: original,
        getServedPath: homepage,
        publicURL: homepage.slice(0, -1),
        isExists: isExists
    };
}
module.exports = getHomePage;
