var heroCliConfig = require('./hero-config.json');
var options = [
    {
        name: 'e',
        value: {
            demandOption: true,
            // default: '/etc/passwd',
            describe: 'Environment name of the configuration when start the application',
            type: 'string'
        }
    }, {
        name: 's',
        value: {
            // demandOption: false,
            describe: 'build pakcage without dependecies like hero-js or webcomponents, just code in <you-project-path>/src folder. Default value is [false].'
        }
    }, {
        name: 'i',
        value: {
            // demandOption: false,
            describe: 'Inline JavaScript code into HTML. Default value is [false].'
        }
    }, {
        name: 'b',
        value: {
            // demandOption: false,
            describe: 'build pakcage only contain dependecies like hero-js or webcomponents, withou code in <you-project-path>/src folder. Default value is [false]'
        }
    }, {
        name: 'm',
        value: {
            // demandOption: false,
            describe: 'build without sourcemap. Default value is [false], will generate sourcemap.'
        }
    }, {
        name: 'f',
        value: {
            // demandOption: false,
            describe: 'generate AppCache file, default file name is "app.appcache". Default value is [false], will not generate this file.'
        }
    }, {
        name: 'n',
        value: {
            // demandOption: false,
            describe: 'rename file without hashcode. Default value is [false], cause filename with hashcode.'
        }
    }, {
        name: 'p',
        value: {
            // demandOption: false,
            describe: 'port used to start the application. Default value is [' + heroCliConfig.devServerPort + '].'
        }
    }, {
        name: 'c',
        value: {
            // demandOption: false,
            describe: 'the path of webpack config file used to build.'
        }
    }
];

module.exports = options;
