'use strict'
let path = require('path')
let fs = require('fs')
let chalk = require('chalk')

let minSupportVersion = 22
let androidSdkPath = process.env.ANDROID_HOME
let buildToolsPath = path.join(androidSdkPath, 'build-tools')
let supportLibPath = path.join(androidSdkPath, 'extras/android/m2repository/com/android/support/support-annotations')

function sort(versionA, versionB) {
  let a = versionA.split('.').map(function(v) {
      return parseInt(v, 10)
    }), b = versionB.split('.').map(function(v) {
      return parseInt(v, 10)
    })

    // 22.0.0 vs 24.0.0
  if (a[0] !== b[0]) {
    return b[0] - a[0]
  }
  // 24.1.0 vs 24.2.0
  if (a[1] !== b[1]) {
    return b[1] - a[1]
  }
  // 24.2.1 vs 24.2.2
  if (a[2] !== b[2]) {
    return b[2] - a[2]
  }
  // 24.0.0-alpha1 vs 24.0.0-alpha2
  return b - a
}
function getFolderNames(root) {
  let res = [], files = fs.readdirSync(root)

  files.forEach(function(file) {
    let pathname = root + '/' + file
    let stat = fs.lstatSync(pathname)

    if (stat.isDirectory()) {
      res.push(file)
    }
  })
  return res.sort(sort)
}
function getAndroidVersions(userSpecifyConfigs) {
  let supportLibPaths
  let buildToolsVersions

  if (userSpecifyConfigs.length === 3) {
    buildToolsVersions = [userSpecifyConfigs[1]]
    supportLibPaths = [userSpecifyConfigs[2]]
  } else if (userSpecifyConfigs.length === 2) {
    buildToolsVersions = [userSpecifyConfigs[1]]
    supportLibPaths = getFolderNames(supportLibPath)
  } else {
    buildToolsVersions = getFolderNames(buildToolsPath)
    supportLibPaths = getFolderNames(supportLibPath)
  }
  let supportVersions = supportLibPaths[0].split('.')
  let underOld22Version = parseInt(supportVersions[0], 10) < minSupportVersion
  let isOld22Version = (parseInt(supportVersions[0], 10) <= minSupportVersion) && ((parseInt(supportVersions[1], 10) < 2))

  // Version under 22.2.0, Show Warnings
  if (underOld22Version || isOld22Version) {
    console.log(chalk.yellow('You\'re using version com.android.support:appcompat-v7:' + supportLibPaths + '.'))
  }
  return {
    supportLibVersion: supportLibPaths[0],
    compileSdkVersion: parseInt(buildToolsVersions[0].split('.')[0], 10),
    buildToolsVersion: buildToolsVersions[0]
  }
}

module.exports = getAndroidVersions
