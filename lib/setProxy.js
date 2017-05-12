var proxy = require('express-http-proxy');
var ulrParse = require('url');

function setProxy(app, targetServer, path) {
    app.use(path, proxy(targetServer, {
        decorateRequest: function (req) {
            req.headers.Referer = targetServer;
            req.headers.Host = require('url').parse(targetServer).host;
            return req;
        },
        forwardPath: function (req) {
            return path + ulrParse.parse(req.url).path;
        }
    }));
}

module.exports = setProxy;
