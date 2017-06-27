'use strict';

var url = require('url');
var ensureSlash = require('./ensureSlash');

function getHomePage(heroCustomConfig, defaultCliConfig) {

    var original = heroCustomConfig[defaultCliConfig.homePageKey];

    var isExists = (typeof original === 'string');

    if (isExists) {
        original = original.trim();
        if (original === '') {
            original = '/';
        } else if (original === '.') {
            return  {
                original: original,
                getServedPath: '.',
                publicURL: '',
                isExists: isExists
            };
        }
    } else {
        original = '/';
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
