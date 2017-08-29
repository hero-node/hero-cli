'use strict'

let fs = require('fs')
let path = require('path')
let chalk = require('chalk')
let filesize = require('filesize')
let stripAnsi = require('strip-ansi')
let heroCliConfig = require('../config/hero-config.json')
let gzipSize = require('gzip-size').sync

// Prints a detailed summary of build files.
function printFileSizesAfterBuild(webpackStats) {
  let paths = global.paths
  let assets = webpackStats
    .toJson()
    .assets.filter(asset => /\.(js|css)$/.test(asset.name))
    .map(asset => {
      let fileContents = fs.readFileSync(path.join(paths.appBuild, asset.name))
      let size = gzipSize(fileContents)

      return {
        folder: path.join(heroCliConfig.outDir, path.dirname(asset.name)),
        name: path.basename(asset.name),
        size: size,
        sizeLabel: filesize(size)
      }
    })

  assets.sort((a, b) => b.size - a.size)
  let longestSizeLabelLength = Math.max.apply(
    null,
    assets.map(a => stripAnsi(a.sizeLabel).length)
  )

  assets.forEach(asset => {
    let sizeLabel = asset.sizeLabel
    let sizeLength = stripAnsi(sizeLabel).length
    let rightPadding

    if (sizeLength < longestSizeLabelLength) {
      rightPadding = ' '.repeat(longestSizeLabelLength - sizeLength)

      sizeLabel += rightPadding
    }
    console.log(
      '  ' +
        sizeLabel +
        '  ' +
        chalk.dim(asset.folder + path.sep) +
        chalk.cyan(asset.name)
    )
  })
}

module.exports = {
  printFileSizesAfterBuild: printFileSizesAfterBuild
}
