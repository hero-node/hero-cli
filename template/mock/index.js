import express from 'express';
import bodyParser from 'body-parser';
import multer from 'multer';
import router from './router';
import cors from './middleware/cors';
import delay from './middleware/delay';
import path from 'path';
import pkg from '../package.json';
import chalk from 'chalk';

var upload = multer({ dest: path.join(__dirname, '../temp/') });
var app = express();
var defaultPort = (pkg.config && pkg.config.mockServerPort) || 4005;
var port = pkg.mockServerPort || defaultPort;

app.use(bodyParser.urlencoded({
    extended: true
}));
// for parsing application/x-www-form-urlencoded
app.use(bodyParser.json());
app.use(delay);
app.use(cors);

router.init(express, app, upload);

function bootstrap() {
    process.on('uncaughtException', function (err) {
        console.log(chalk.red(('uncaughtException: ' + err).red));
    });
    process.on('unhandledRejection', function (reason, p) {
        // application specific logging, throwing an error, or other logic here
        console.log(chalk.red('Unhandled Rejection at: Promise ', p, ' reason: ', reason));
    });

    require('http').createServer(app).listen(port, function () {
        console.log(chalk.green('Start successfully!'));
        console.log();
        console.log('Mock server is running at:');
        console.log(chalk.cyan('http://localhost' + (port === 80 ? '' : ':' + port)));
        console.log();
    });
}

bootstrap();

export default { app, bootstrap };
