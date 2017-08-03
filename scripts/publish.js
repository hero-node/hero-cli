'use strict';

process.env.NODE_ENV = 'production';

// Spawn Process
var yargs = require('yargs');
var path = require('path');
var chalk = require('chalk');
var fs = require('fs-extra');
var webpack = require('webpack');
var checkRequiredFiles = require('../lib/checkRequiredFiles');
var FileSizeReporter = require('../lib/FileSizeReporter');
var printFileSizesAfterBuild = FileSizeReporter.printFileSizesAfterBuild;
var commandOptions = require('../config/options');
var pgk = require('../package.json');
var commandName = Object.keys(pgk.bin)[0];
global.logger = require('../lib/logger');
var spawn = require('cross-spawn');

var result = spawn.sync('ipfs', ['version'], { stdio: 'inherit' });
if(result.error){
    console.log('downloading ipfs pkg');
    result = spawn.sync('curl', ['https://ipfs.io/ipfs/QmQqsmBKZSNVyVCgpKovNvwFRmAHpz88scGSdrS9S1Yt3T','--output','./ipfs'], { stdio: 'inherit' });
    console.log('need root  to install ipfs');
    result = spawn.sync('cp', ['./ipfs','/usr/local/bin/ipfs'], { stdio: 'inherit' });
    result = spawn.sync('chmod', ['775','/usr/local/bin/ipfs'], { stdio: 'inherit' });
}else{
    spawn.sync('ipfs', ['add','-r','./build'], { stdio: 'inherit' });
}


