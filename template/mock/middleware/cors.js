var allowMethods = 'Access-Control-Allow-Methods';
var allowCredentials = 'Access-Control-Allow-Credentials';
var allowMaxAge = 'Access-Control-Max-Age';
var allowOrigin = 'Access-Control-Allow-Origin';
var allowHeader = 'Access-Control-Allow-Headers';

var middleware = function (req, res, next) {

    var origin = req.get('Origin');

    if (origin) {

        if (req.get(allowHeader) === undefined) {
            res.header(allowHeader, 'Content-Type, Authorization');
        }
        if (req.get(allowMethods) === undefined) {
            res.header(allowMethods, 'GET,PUT,POST,DELETE');
        }

        if (req.get(allowCredentials) === undefined) {
            res.header(allowCredentials, true);
        }

        if (req.get(allowMaxAge) === undefined) {
            res.header(allowMaxAge, 3600);
        }

        res.header(allowOrigin, origin);
    }

    next();
};

module.exports = middleware;
