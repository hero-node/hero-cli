var log4js = require('log4js');
var express  = require('express');
var http  = require('http');
var proxy = require('express-http-proxy');
var pkg = require('./package.json');

log4js.configure({
    appenders: [{
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

log4js.getLogger('normal').setLevel('INFO');

var app = express();

app.use(proxy(pkg.proxyTarget, {
    forwardPath: function (req) {
        console.log(require('url').parse(req.url).path);
        return require('url').parse(req.url).path;
    }
}));

http.createServer(app).listen(pkg.proxyPort, function () {
    console.log();
    console.log('Proxy server is running at:');
    console.log('http://localhost' + (pkg.proxyPort === 80 ? '' : ':' + pkg.proxyPort) + ' will proxy to ' + pkg.proxyTarget);
    console.log();
});
