import log4js from 'log4js';
import chalk from 'chalk';
import express from 'express';
import http from 'http';
import cookieParser from 'cookie-parser';
import bodyParser from 'body-parser';
import proxy from 'express-http-proxy';
import pkg from './package.json';
import startMockServer from './startMockServer.js';
import cors from './middleware/cors';

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
        var app = express();

        app.enable('trust proxy');
        app.use(cookieParser());
        app.use(bodyParser.urlencoded({ extended: false }));
        app.use(bodyParser.json());
        app.use(cors);
        app.use('/api/v2/', proxy(url, {
            forwardPath: function (req) {
                return '/api/v2' + require('url').parse(req.url).path;
            }
        }));
        app.use('/images/captcha.jpg', proxy(url, {
            forwardPath: function (req) {
                return '/images/captcha.jpg' + require('url').parse(req.url).path.substring(1);
            }
        }));

        http.createServer(app).listen(port, function () {
            if (index === 0) {
                console.log(chalk.green('Start successfully! \n\nProxy server is running at:'));
            }
            console.log(chalk.cyan('http://localhost' + (port === 80 ? '' : ':' + port)) + ' will forward request to ' + chalk.cyan(url));
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
