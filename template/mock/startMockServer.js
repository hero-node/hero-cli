var express  = require('express');
var bodyParser  = require('body-parser');
var cookieParser  = require('cookie-parser');
var router  = require('./router');
var cors  = require('./middleware/cors');
var delay  = require('./middleware/delay');
var options  = require('./middleware/options');
var chalk  = require('chalk');

function startMockServer(port, prefix) {

    var app = express();

    app.use(bodyParser.urlencoded({ extended: true }));
    // for parsing application/x-www-form-urlencoded
    app.use(bodyParser.json());
    app.use(cookieParser());
    app.use(delay);
    app.use(cors);
    app.use(options);

    router.init(express, app, prefix);

    require('http').createServer(app).listen(port, function () {
        console.log(chalk.green('Mock server is running at:'));
        console.log(chalk.cyan('http://localhost' + (port === 80 ? '' : ':' + port)));
        console.log();
    });
}

module.exports = startMockServer;
