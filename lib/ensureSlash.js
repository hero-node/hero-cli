'use strict'

function ensureSlash(path, needsSlash) {
  let hasSlash = path.endsWith('/')

  if (hasSlash && !needsSlash) {
    return path.substr(path, path.length - 1)
  } else if (!hasSlash && needsSlash) {
    return path + '/'
  } else {
    return path
  }
}

module.exports = ensureSlash
