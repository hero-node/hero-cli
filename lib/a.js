var babylon = require('babylon');
var babelTypes = require('babel-types');
var traverse = require('babel-traverse');

var code = 'class DecoratePage{};DecoratePage.__page = true; DecoratePage.__title = "Hello world"; ';
var ast = babylon.parse(code, { allowReturnOutsideFunction: true });

traverse(ast, {
    enter(path) {
        if (babelTypes.classExpression(null, null, path)) {
            console.log(path);
        }
    }
});
