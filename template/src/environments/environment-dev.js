var pkg = require('../../package.json');
var defaultPort = (pkg.config && pkg.config.mockServerPort) || 4005;

var environment = {
    production: false,
    backendURL: '//127.0.0.1' + (defaultPort === 80 ? '' : ':' + defaultPort)
};

module.exports = environment;
// # sourceMappingURL=environment.js.map
