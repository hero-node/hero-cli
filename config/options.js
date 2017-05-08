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
            describe: 'Build pakcage without dependecies like hero-js or webcomponents, just code in <you-project-path>/src folder. Default value is [false].'
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
            describe: 'Build pakcage only contain dependecies like hero-js or webcomponents, withou code in <you-project-path>/src folder. Default value is [false]'
        }
    }, {
        name: 'm',
        value: {
            // demandOption: false,
            describe: 'Build without sourcemap. Default value is [false], will generate sourcemap.'
        }
    }, {
        name: 'f',
        value: {
            // demandOption: false,
            describe: 'Generate AppCache file, default file name is "app.appcache". Default value is [false], will not generate this file.'
        }
    }, {
        name: 'n',
        value: {
            // demandOption: false,
            describe: 'Rename file without hashcode. Default value is [false], cause filename with hashcode.'
        }
    }, {
        name: 'c',
        value: {
            // demandOption: false,
            describe: 'The path of webpack config file used to build.'
        }
    }
];

module.exports = options;
