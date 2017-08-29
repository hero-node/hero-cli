'use strict'

process.env.NODE_ENV = 'production'

// Spawn Process
let yargs = require('yargs')
let path = require('path')
let chalk = require('chalk')
let fs = require('fs-extra')
let webpack = require('webpack')
let checkRequiredFiles = require('../lib/checkRequiredFiles')
let FileSizeReporter = require('../lib/FileSizeReporter')
let printFileSizesAfterBuild = FileSizeReporter.printFileSizesAfterBuild
let commandOptions = require('../config/options')
let pgk = require('../package.json')
let commandName = Object.keys(pgk.bin)[0]
global.logger = require('../lib/logger')
let spawn = require('cross-spawn')

let result = spawn.sync('ipfs', ['version'], { stdio: 'inherit' })
if (result.error) {
  console.log('downloading ipfs pkg')
  result = spawn.sync('curl', ['https://ipfs.io/ipfs/QmQqsmBKZSNVyVCgpKovNvwFRmAHpz88scGSdrS9S1Yt3T', '--output', './ipfs'], { stdio: 'inherit' })
  console.log('need root  to install ipfs')
  result = spawn.sync('cp', ['./ipfs', '/usr/local/bin/ipfs'], { stdio: 'inherit' })
  result = spawn.sync('chmod', ['775', '/usr/local/bin/ipfs'], { stdio: 'inherit' })
} else {
  spawn.sync('ipfs', ['add', '-r', './build'], { stdio: 'inherit' })
}
