var escope = require('escope');
var esprima = require('esprima');
var estraverse = require('estraverse');

function parseVairables(code) {
    // console.log(code);
    var ast = esprima.parse(code);
    // Disable ESLint Rule
    var scopeManager = escope.analyze(ast, {});

    // console.log('scopeManager', scopeManager);

    var currentScope = scopeManager.acquire(ast);   // global scope

    // console.log('currentScope');
    var parsed = false;
    var implicitVariables;
    var paramVariableName;

    estraverse.traverse(ast, {
        enter: function (node) {
        // do stuff
            if (!parsed && /Function/.test(node.type)) {
                currentScope = scopeManager.acquire(node);  // get current function scope
                // console.log('currentScope', Object.keys(currentScope));
                implicitVariables = currentScope.through.map(function (variable) {
                    return variable.identifier.name;
                });
                if (currentScope.block && currentScope.block.params && currentScope.block.params.length) {
                    paramVariableName =  currentScope.block.params[0].name;
                }
                parsed = true;
            }
        }
    });

    return {
        paramName: paramVariableName,
        implicitVariables: implicitVariables
    };
}

module.exports = parseVairables;
