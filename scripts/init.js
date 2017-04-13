'use strict';

var fs = require('fs');
var path = require('path');
var chalk = require('chalk');
var shell = require('shelljs');
var generatedApp = process.argv[2];

if (!generatedApp) {
    console.log('Please specify the project directory:');
    console.log(chalk.cyan('    hero init ') + chalk.green('<project-directory>'));
    console.log();
    console.log('For example:');
    console.log(chalk.cyan('    hero init ') + chalk.green('my-react-app'));

    process.exit(1);
}
function generate(appName) {
    var displayedCommand = 'npm';
    var targetPath = path.join(process.cwd(), appName);

    var existsPath = fs.existsSync(targetPath);

    if (existsPath) {
        console.log(chalk.red('    Folder ' + appName + ' is already exists!'));
        process.exit(1);
    }

    shell.mkdir('-p', targetPath);

    var templatePath = path.join(__dirname, '../template');

    shell.cp('-Rf', templatePath + '/*', targetPath);

    var dotFiles = ['babelrc', 'editorconfig', 'gitattributes', 'gitignore', 'hero-cli.json'];

    dotFiles.forEach(file => {
        shell.mv('-f', path.join(targetPath, file), path.join(targetPath, '.' + file));
    });

    console.log();
    console.log(chalk.green('Success! Created ' + appName + ' at ' + targetPath));
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
    console.log('Happy hacking!');
}
generate(generatedApp, true);
