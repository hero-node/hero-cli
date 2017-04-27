var httpProxy = require('http-proxy');
var log4js = require('log4js');
var chalk = require('chalk');
var http = require('http');

var pkg = require('./package.json');
var startMockServer = require('./startMockServer.js');

log4js.configure({
    appenders: [
        {
            // 控制台输出
            type: 'console'
        },
        {
            // 文件输出
            type: 'file',
            filename: __dirname + '/logs/log.log',
            maxLogSize: 1024000,
            backups: 1,
            category: 'normal'
        }
    ]
});

var logger = log4js.getLogger('normal');
var servers = pkg.serverConfig.proxyTargetURLs;
var defaultPort = pkg.serverConfig.proxyBasePort;
var mockAPIPrefix = pkg.serverConfig.mockAPIPrefix;

logger.setLevel('INFO');

function errorHandler() {
    process.on('uncaughtException', function (err) {
        console.log(chalk.red(('uncaughtException: ' + err)));
    });
    process.on('unhandledRejection', function (reason, p) {
    // application specific logging, throwing an error, or other logic here
        console.log(chalk.red('Unhandled Rejection at: Promise ', p, ' reason: ', reason));
    });
}

function startProxyServer() {
    servers.forEach(function (url, index) {
        var port = defaultPort + index;
        var proxy = httpProxy.createProxyServer({
            changeOrigin: true

        });

        proxy.on('proxyRes', function (proxyRes, req, res) {
            res.setHeader('access-control-allow-credentials', true);
            res.setHeader('access-control-allow-origin', req.headers.origin);
        });

        var server = http.createServer(function (req, res) {
          // You can define here your custom logic to handle the request
          // and then proxy the request.
            proxy.web(req, res, {
                target: url
            });
        });

        server.listen(port, function () {
            console.log();
            console.log(chalk.green('Proxy server is running at:'));
            console.log(chalk.cyan('http://localhost' + (port === 80 ? '' : ':' + port)) + ' will proxy to ' + url);
            console.log();

        });
    });
}

errorHandler();
startProxyServer();
startMockServer(defaultPort + servers.length, mockAPIPrefix);
