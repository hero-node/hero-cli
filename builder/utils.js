const path = require('path')
const glob = require('glob')

function resolve(dir) {
  return path.resolve(process.cwd(), dir)
}

function getEntries(dir = 'src/pages') {
  const entries = {}
  const root = resolve(dir) + '/'
  const files = glob.sync(root + '**/*.js', {
    ignore: [root + '**/view.js']
  })

  files.forEach((file) => {
    entries[
      file
        .replace(root, '')
        .replace('/index.js', '')
        .replace(/\//g, '_')
        .replace('.js', '')
    ] = file
  })

  return entries
}

function renameByRouter(entry, router) {
  const routes = Object.entries(router)
  Object.entries(entry).forEach(([key, val]) => {
    const target = routes.find((route) => route[1] === val)
    if (target) {
      delete entry[key]
      entry[target[0]] = val
    }
  })
  return entry
}

function getUserConfig() {
  return require(resolve('hero.config.js'))
}

module.exports = {
  resolve,
  getEntries,
  renameByRouter,
  getUserConfig
}
