import log4js from 'log4js';
import chalk from 'chalk';
import http from 'http';
import pkg from './package.json';
import startMockServer from './startMockServer.js';

var httpProxy = require('http-proxy');

const servers = pkg.serverConfig.proxyTargetURLs;
const defaultPort = pkg.serverConfig.proxyBasePort;
const mockAPIPrefix = pkg.serverConfig.mockAPIPrefix;

log4js.configure({
    appenders: [
    { type: 'console' }, // 控制台输出
        {
            type: 'file', // 文件输出
            filename: __dirname + '/logs/log.log',
            maxLogSize: 1024000,
            backups: 1,
            category: 'normal'
        }
    ]
});

const logger = log4js.getLogger('normal');

logger.setLevel('INFO');

(function startProxyServer() {
    servers.forEach((url, index) => {
        var port = defaultPort + index;
        var proxy = httpProxy.createProxyServer({
            changeOrigin: true

        });

        // To modify the proxy connection before data is sent, you can listen
        // for the 'proxyReq' event. When the event is fired, you will receive
        // the following arguments:
        // (http.ClientRequest proxyReq, http.IncomingMessage req,
        //  http.ServerResponse res, Object options). This mechanism is useful when
        // you need to modify the proxy request before the proxy connection
        // is made to the target.
        //
        proxy.on('proxyReq', function (proxyReq, req, res, options) {

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
})();

startMockServer(defaultPort + servers.length, mockAPIPrefix);

(function errorHandler() {
    process.on('uncaughtException', function (err) {
        console.log(chalk.red(('uncaughtException: ' + err)));
    });
    process.on('unhandledRejection', function (reason, p) {
    // application specific logging, throwing an error, or other logic here
        console.log(chalk.red('Unhandled Rejection at: Promise ', p, ' reason: ', reason));
    });
})();
