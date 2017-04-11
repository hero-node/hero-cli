'use strict';

var fs = require('fs');
var path = require('path');
var paths = require('../config/paths');
var chalk = require('chalk');
var filesize = require('filesize');
var stripAnsi = require('strip-ansi');
var heroCliConfig = require('../config/hero-config.json');
var gzipSize = require('gzip-size').sync;

// Prints a detailed summary of build files.
function printFileSizesAfterBuild(webpackStats) {
    var assets = webpackStats
    .toJson()
    .assets.filter(asset => /\.(js|css)$/.test(asset.name))
    .map(asset => {
        var fileContents = fs.readFileSync(path.join(paths.appBuild, asset.name));
        var size = gzipSize(fileContents);

        return {
            folder: path.join(heroCliConfig.outDir, path.dirname(asset.name)),
            name: path.basename(asset.name),
            size: size,
            sizeLabel: filesize(size)
        };
    });

    assets.sort((a, b) => b.size - a.size);
    var longestSizeLabelLength = Math.max.apply(
    null,
    assets.map(a => stripAnsi(a.sizeLabel).length)
  );

    assets.forEach(asset => {
        var sizeLabel = asset.sizeLabel;
        var sizeLength = stripAnsi(sizeLabel).length;
        var rightPadding;

        if (sizeLength < longestSizeLabelLength) {
            rightPadding = ' '.repeat(longestSizeLabelLength - sizeLength);

            sizeLabel += rightPadding;
        }
        console.log(
      '  ' +
        sizeLabel +
        '  ' +
        chalk.dim(asset.folder + path.sep) +
        chalk.cyan(asset.name)
    );
    });
}

module.exports = {
    printFileSizesAfterBuild: printFileSizesAfterBuild
};
