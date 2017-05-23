'use strict';
var path = require('path');
var fs = require('fs');
var chalk = require('chalk');

var minSupportVersion = 22;
var androidSdkPath = process.env.ANDROID_HOME;
var buildToolsPath = path.join(androidSdkPath, 'build-tools');
var supportLibPath = path.join(androidSdkPath, 'extras/android/m2repository/com/android/support/support-annotations');

function sort(versionA, versionB) {
    var a = versionA.split('.').map(function (v) {
            return parseInt(v, 10);
        }), b = versionB.split('.').map(function (v) {
            return parseInt(v, 10);
        });

    // 22.0.0 vs 24.0.0
    if (a[0] !== b[0]) {
        return b[0] - a[0];
    }
    // 24.1.0 vs 24.2.0
    if (a[1] !== b[1]) {
        return b[1] - a[1];
    }
    // 24.2.1 vs 24.2.2
    if (a[2] !== b[2]) {
        return b[2] - a[2];
    }
    // 24.0.0-alpha1 vs 24.0.0-alpha2
    return b - a;
}
function getFolderNames(root) {
    var res = [], files = fs.readdirSync(root);

    files.forEach(function (file) {
        var pathname = root + '/' + file;
        var stat = fs.lstatSync(pathname);

        if (stat.isDirectory()) {
            res.push(file);
        }
    });
    return res.sort(sort);
}
function getAndroidVersions() {
    var supportLibPaths = getFolderNames(supportLibPath);
    var buildToolsVersions = getFolderNames(buildToolsPath);

    var supportVersions = supportLibPaths[0].split('.');

    if (parseInt(supportVersions[0], 10) < minSupportVersion) {
        console.log(chalk.yellow('You\'re using com.android.support:appcompat-v7 version ' + supportVersions[0] + '.'));
    }
    return {
        supportLibVersion: supportLibPaths[0],
        compileSdkVersion: parseInt(buildToolsVersions[0].split('.')[0], 10),
        buildToolsVersion: buildToolsVersions[0]
    };
}

module.exports = getAndroidVersions;
