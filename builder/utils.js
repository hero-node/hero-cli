/* eslint-disable standard/computed-property-even-spacing */
const path = require('path')
const glob = require('glob')

const { build } = getUserConfig()

function resolve(dir) {
  return path.resolve(process.cwd(), dir)
}

function getEntries(dir = 'src/pages') {
  const entries = {}
  const root = resolve(dir) + '/'
  const files = glob.sync(root + '**/*.js', {
    ignore: [
      '**/view.js',
      '**/_*/**', '_*.js'
    ].concat(build.ignore || [])
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

function mergeEntries(entry, router) {
  const reducer = (prev, [key, val]) => {
    prev[val] = key
    return prev
  }
  const reverse = source => Object
    .entries(source)
    .reduce(reducer, {})

  return reverse(reverse(Object.assign({}, entry, router)))
}

function getUserConfig() {
  return require(resolve('hero.config.js'))
}

module.exports = {
  resolve,
  getEntries,
  mergeEntries,
  getUserConfig
}
