var middleware = function (req, res, next) {

  // intercept OPTIONS method
    if ('OPTIONS' === req.method) {
        res.sendStatus(200);
    } else {
        next();
    }
};

module.exports = middleware;
