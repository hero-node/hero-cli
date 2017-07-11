  'use strict';

  var url = require('url');
  var chalk = require('chalk');
  var ensureSlash = require('./ensureSlash');

  function getHomePage(heroCustomConfig, defaultCliConfig) {

      var original = heroCustomConfig[defaultCliConfig.homePageKey];

      var isExists = (typeof original === 'string');

      var vailidOrigin;

      if (isExists) {
          vailidOrigin = original.trim();
      }

      if (!isExists || vailidOrigin === '' || vailidOrigin.indexOf('.') === 0) {
          if (vailidOrigin && vailidOrigin.length > 2) {
              global.logger.warn(chalk.red(' Invalid value "' + original + '" of attribute ' + defaultCliConfig.homePageKey + ' in file ' + defaultCliConfig.heroCliConfig) + '. Do you mean "' + chalk.cyan(original.substring(1)) + '"?');
          }
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
