'use strict';

var fs = require('fs');

function getEntries(root) {
    var res = [],
        files = fs.readdirSync(root);

    files.forEach(file => {
        var pathname = root + '/' + file,
            stat = fs.lstatSync(pathname);

        if (!stat.isDirectory()) {
            res.push(pathname.replace(__dirname, '.'));
        } else {
            res = res.concat(getEntries(pathname));
        }
    });
    return res;
}

module.exports = getEntries;
