var notFound = require('./middleware/notFound');
var fs = require('fs');
var path = require('path');

function _getFileList(root) {
    var res = [],
        files = fs.readdirSync(root);

    files.forEach(function (file) {
        var pathname = root + '/' + file,
            stat = fs.lstatSync(pathname);

        if (!stat.isDirectory()) {
            res.push(pathname.replace(__dirname, '.'));
        } else {
            res = res.concat(_getFileList(pathname));
        }
    });
    return res;
}

function init(express, app, prefix) {

    var rootPath = prefix || '';

    _getFileList(path.join(__dirname, 'modules'))
        .map(function (url) { return require(url); })
        .forEach(function (mod) {
            app.use(
                rootPath + mod.root,
                mod.router(express)
            );
        });
    app.use(rootPath, notFound);
}
module.exports = { init };
