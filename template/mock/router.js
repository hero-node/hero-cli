import notFound from './middleware/notFound';
import fs from 'fs';
import path from 'path';

function getFileList(root) {
    var res = [],
        files = fs.readdirSync(root);

    files.forEach(file => {
        var pathname = root + '/' + file,
            stat = fs.lstatSync(pathname);

        if (!stat.isDirectory()) {
            res.push(pathname.replace(__dirname, '.'));
        } else {
            res = res.concat(getFileList(pathname));
        }
    });
    return res;
}

function init(express, app, prefix) {

    var rootPath = prefix || '';

    getFileList(path.join(__dirname, 'modules'))
        .map(url => require(url))
        .forEach(mod => {
            app.use(
                rootPath + mod.default.root,
                mod.default.router(express)
            );
        });
    app.use(rootPath, notFound);
}
export default { init };
