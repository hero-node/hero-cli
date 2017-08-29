'use strict'

let url = require('url')
let chalk = require('chalk')
let ensureSlash = require('./ensureSlash')

function getHomePage(heroCustomConfig, defaultCliConfig) {
  let original = heroCustomConfig[defaultCliConfig.homePageKey]

  let isExists = (typeof original === 'string')

  let vailidOrigin

  if (isExists) {
    vailidOrigin = original.trim()
  }

  if (!isExists || vailidOrigin === '' || vailidOrigin.indexOf('.') === 0) {
    if (vailidOrigin && vailidOrigin.length > 2) {
      global.logger.warn(chalk.red(' Invalid value "' + original + '" of attribute ' + defaultCliConfig.homePageKey + ' in file ' + defaultCliConfig.heroCliConfig) + '. Do you mean "' + chalk.cyan(original.substring(1)) + '"?')
    }
    return {
      original: original,
      getServedPath: './',
      publicURL: '',
      isExists: isExists,
      isRelativePath: true
    }
  }

  let homepage = isExists ? ensureSlash(url.parse(original).pathname, true) : '/'

  homepage = homepage.indexOf('/') === 0 ? homepage : '/' + homepage

  return {
    original: original,
    getServedPath: homepage,
    publicURL: homepage.slice(0, -1),
    isExists: isExists,
    isRelativePath: false
  }
}
module.exports = getHomePage
