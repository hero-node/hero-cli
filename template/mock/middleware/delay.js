var middleware = function (req, res, next) {
    setTimeout(function () {
        next();
    }, parseInt(Math.random() * 200, 10));
};

export default middleware;
