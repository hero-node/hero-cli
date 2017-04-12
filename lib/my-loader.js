// Identity loader
var fileLoader = require('file-loader');

module.exports = function (source) {
    console.log(this);
    console.log(fileLoader.call(this, source));
    return source;
};
