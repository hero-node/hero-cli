var fs = require('fs');
var babel = require('babel-core');
var babelTypes = require('babel-types');
var traverse = require('babel-traverse');

console.log(traverse);

function getComponentsData(fileAbsolutePath) {
    var code = fs.readFileSync(fileAbsolutePath, 'UTF-8');

    var ast = babel.transform(code, {
        ast: true,
        babelrc: false,
        compact: 'auto',
        sourceMaps: false,
        code: false,
        comments: false,
        minified: false,
        sourceType: 'module',
        presets: [
            require.resolve('babel-preset-es2015'),
            require.resolve('babel-preset-stage-2')
        ],
        plugins: [
            require.resolve('babel-plugin-transform-class-properties'),
            require.resolve('babel-plugin-transform-object-rest-spread'),
            require.resolve('babel-plugin-transform-decorators-legacy')
        ]
    }).ast;

    traverse(ast, {
        enter(path) {
            if (path.node.type === 'Identifier' && path.node.name === 'n') {
                path.node.name = 'x';
            }
        }
    });
    // console.log(JSON.stringify(ast));
}

getComponentsData('/home/nb073/workspaces/hero-apps/hero-sample/src/entry/login.js');

module.exports = getComponentsData;
