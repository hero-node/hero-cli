'use strict';
// Spawn Process
var fs = require('fs');
var path = require('path');
var chalk = require('chalk');
var shell = require('shelljs');
var yargs = require('yargs');

global.argv = yargs.argv;

function showUsage() {
    console.log();
    console.log('Please specify the project directory with an empty folder:');
    console.log(chalk.cyan('    hero init ') + chalk.green('<project-directory>'));
    console.log();
    console.log('For example:');
    console.log(chalk.cyan('    hero init ') + chalk.green('my-react-app'));
    console.log();

    process.exit(1);
}
if (global.argv.h) {
    showUsage();
}
var generatedApp = global.argv._[0];

if (!generatedApp) {
    showUsage();
}
function generate(appName) {
    var displayedCommand = 'npm';
    var targetPath = path.join(process.cwd(), appName);

    var existsPath = fs.existsSync(targetPath);

    if (existsPath) {
        console.log(chalk.red('Error: Folder ' + appName + ' is already exists!'));
        showUsage();
    }

    shell.mkdir('-p', targetPath);

    var templatePath = path.join(__dirname, '../template');

    shell.cp('-Rf', templatePath + '/*', targetPath);

    var dotFiles = ['editorconfig', 'gitattributes', 'gitignore', 'hero-cli.json'];

    dotFiles.forEach(file => {
        shell.mv('-f', path.join(targetPath, file), path.join(targetPath, '.' + file));
    });

    console.log();
    console.log(chalk.green('Created project ' + appName + ' successfully at ' + targetPath));
    console.log('Inside that directory, you can run several commands:');
    console.log();
    console.log(chalk.cyan('  ' + displayedCommand + ' start'));
    console.log('    Starts the development server.');
    console.log();
    console.log(chalk.cyan('  ' + displayedCommand + ' run build'));
    console.log('    Bundles the app into static files for production.');
    console.log();
    console.log(chalk.cyan('  ' + displayedCommand + ' run mock'));
    console.log('    Starts the mock server.');
    console.log();
    console.log('Welcome to the Hero!');
    console.log();
}
generate(generatedApp, true);
