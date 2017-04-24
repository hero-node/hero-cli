var fs = require('fs');
var babel = require('babel-core');
var traverse = require('babel-traverse');
var chalk = require('chalk');
var DecoratorName = 'Entry';

function getComponentsData(fileAbsolutePath) {
    var code = fs.readFileSync(fileAbsolutePath, 'UTF-8');

    var ast = babel.transform(code, {
        ast: true,
        babelrc: false,
        compact: 'auto',
        sourceMaps: false,
        code: true,
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
    });

    // console.log(ast.code);

    var isFounded = false;
    var templateAttributes = {};

    traverse.default(ast.ast, {
        enter(path) {
            var node = path.node;

            if (!isFounded && node.type === 'CallExpression') {
                if (node.callee.expressions && node.arguments && node.arguments.length && node.callee.expressions.find(function (exp) {
                    return exp.type === 'MemberExpression'
                        && exp.object
                        && exp.object.type === 'Identifier'
                        && exp.object.name.indexOf('_decorator') === 0
                        && exp.property.type === 'Identifier'
                        && exp.property.name === DecoratorName;
                })) {
                    if (node.arguments.length > 1) {
                        console.log(chalk.yellow('Arguments Length in @' + DecoratorName + ' Exceed, Ignore the arguments except the first one.'));
                    }
                    if (node.arguments[0].type !== 'ObjectExpression') {
                        console.log(chalk.yellow('Arguments in @' + DecoratorName + ' should be plain object, Not Support Dynamic Attributes or Function Return Value'));
                        return;
                    }

                    isFounded = true;

                    node.arguments[0].properties.forEach(function (prop) {
                        if (prop.type !== 'ObjectProperty') {
                            console.log(chalk.yellow('Configuration in @' + DecoratorName + ' should be plain object, Not Dynamic Attributes'));
                            return false;
                        }
                        if (prop.key.type !== 'Identifier') {
                            console.log(chalk.yellow('Configuration Key ' + prop.key + ' in @' + DecoratorName + ' should be static, Not Dynamic Attributes'));
                            return;
                        }
                        if (prop.value.type !== 'StringLiteral') {
                            console.log(chalk.yellow('Value of Key [' + prop.key.name + '] in @' + DecoratorName + ' should be String, Not a variable.'));
                            return;
                        }
                        templateAttributes[prop.key.name] = prop.value.value;
                    });
                }
            }
        }
    });

    console.log(templateAttributes);
}

getComponentsData('/home/nb073/workspaces/hero-apps/hero-sample/src/entry/login.js');

module.exports = getComponentsData;
