import express from 'express';
import bodyParser from 'body-parser';
import router from './router';
import cors from './middleware/cors';
import delay from './middleware/delay';
import options from './middleware/options';
import chalk from 'chalk';

function startMockServer(port, prefix) {

    var app = express();

    app.use(bodyParser.urlencoded({ extended: true }));
    // for parsing application/x-www-form-urlencoded
    app.use(bodyParser.json());
    app.use(delay);
    app.use(cors);
    app.use(options);

    router.init(express, app, prefix);

    require('http').createServer(app).listen(port, function () {
        console.log();
        console.log(chalk.green('Mock server is running at:'));
        console.log(chalk.cyan('http://localhost' + (port === 80 ? '' : ':' + port)));
        console.log();
    });
}

export default startMockServer;
