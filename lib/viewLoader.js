var jsdom = require('jsdom');
var jquery = require('jquery');
var JSDOM = jsdom.JSDOM;
var dom, $;
// var typeKey = '_class';
var heryKeys = 'hero-';
var heryBindKeys = 'bind:';
var __$$heroCurrentView = '__$hero$CurrentView';

// d-r-text-field --> DRTextField
function nameFormat(name) {
    return name.toLowerCase().split('-').map(function (subName) {
        return subName.charAt(0).toUpperCase() + subName.substring(1);
    }).join('');
}

function traverse(element, callback, parentIdx) {
    if (!element) {
        return null;
    }

    var idx, len;

    callback && callback(element, parentIdx);

    var childrens = element.children();

    if (childrens) {
        for (idx = 0, len = childrens.length; idx < len; idx++) {
            traverse($(childrens[idx]), callback, (parentIdx
                ? parentIdx.concat(idx)
                : [idx]), element);
        }
    }
}

function getMeta() {
    var tree = {};
    var keys = [];
    var fnMappings = {};

    traverse($('hero-view'), function (element, path) {
        var attributes = element[0].attributes;

        var suffix = (path ? path.join('_') : '');
        var __fnName = nameFormat(element[0].tagName) + '_' + suffix;
        var embeddedName = __$$heroCurrentView + suffix;

        keys.push(suffix);

        tree[suffix] = {
            key: __fnName,
            expressions: {}
        };
        var __body = [];

        __body.push(embeddedName);
        __body.push('={');

        var i, len;

        for (i = 0, len = attributes.length; i < len; i++) {
            if (attributes[i].name.indexOf(heryKeys) === 0) {

                tree[suffix].expressions[attributes[i].name.replace(heryKeys, '')] = attributes[i].value;
                continue;
            }
            __body.push('\n');
            __body.push(attributes[i].name);
            __body.push(':');
            __body.push('"');
            __body.push(attributes[i].value);
            __body.push('"');
            if (i < (len - 1)) {
                __body.push(',');
            }
            // __body += embeddedName + '["' + attributes[i].name + '"]="' + attributes[i].value + '";\n';
        }
        __body.push('};');
        fnMappings[__fnName] = __body.join('');
    });
    return {
        tree: tree,
        keys: keys,
        fnMappings: fnMappings
    };
}

function treeObject(metaData) {
    var keys = metaData.keys;
    var tree = metaData.tree;
    var fnMappings = metaData.fnMappings;

    var idx, len, expressions;
    var fors, hasSquare;
    var currentViewVariableName;
    var elementPaths, parentView;
    var j, k, kLen, bindDirective, binds, isRoot;
    // var __body = ['function generateView(context){'];
    var __body = ['module.exports = function generateView(context){'];

    for (idx = 0, len = keys.length; idx < len; idx++) {
        isRoot = keys[idx] === '';
        expressions = tree[keys[idx]].expressions;
        currentViewVariableName = __$$heroCurrentView + keys[idx];

        elementPaths = keys[idx].split('_');
        elementPaths.pop();

        parentView = __$$heroCurrentView + elementPaths.join('');
        __body.push('\n var ');
        __body.push(currentViewVariableName);
        __body.push(';');

        if (!isRoot) {
            __body.push('\nif(');
            __body.push(parentView);
            __body.push('){');
        }

        // console.log(expressions);
        if (expressions.for) {
            fors = expressions.for.trim().split(/\bin\b/);
            hasSquare = /^\(.*\)$/.test(fors[0].trim());
            if (!hasSquare) {
                fors[0] = '(' + fors[0] + ')';
            }
            __body.push('\n');
            __body.push(fors[1]);
            __body.push('.forEach(function');
            __body.push(fors[0]);
            __body.push('{');
        }

        if (expressions.if) {
            __body.push('\nif(');
            __body.push(expressions.if);
            __body.push('){');
        }

        binds = Object.keys(expressions).filter(function (heroDirective) {
            return heroDirective.indexOf(heryBindKeys) !== -1;
        });
        __body.push(fnMappings[tree[keys[idx]].key]);

        for (k = 0, kLen = binds.length; k < kLen; k++) {
            bindDirective = binds[k];
            __body.push(currentViewVariableName);
            __body.push('.');
            __body.push(bindDirective.replace(heryBindKeys, ''));
            __body.push('=');
            __body.push(expressions[bindDirective]);
            __body.push(';\n');
        }

        if (idx === 0) {
            __body.push(currentViewVariableName);
            __body.push('.views = [];\n');
        } else {
            for (j = idx + 1; j < len; j++) {
                if (keys[j].indexOf(keys[idx] + '_') !== -1) {
                    __body.push(currentViewVariableName);
                    __body.push('.subViews = [];\n');
                }
            }
            elementPaths = keys[idx].split('_');
            elementPaths.pop();

            parentView = __$$heroCurrentView + elementPaths.join('');
            if (parentView === __$$heroCurrentView) {
                __body.push(parentView);
                __body.push('.views.push(');
                __body.push(currentViewVariableName);
                __body.push(');');
            } else {
                __body.push(parentView);
                __body.push('.subViews.push(');
                __body.push(currentViewVariableName);
                __body.push(');');
            }
        }
        if (expressions.if) {
            __body.push('}');
        }

        if (expressions.for) {
            __body.push('});');
        }
        if (!isRoot) {
            __body.push('}');
        }
    }
    __body.push('; \nreturn ');
    __body.push(__$$heroCurrentView);
    __body.push(';}');
    return __body.join('');
}

module.exports = function (source) {
    this.cacheable();
    dom = new JSDOM(source);
    $ = jquery(dom.window);
    this.callback(null, treeObject(getMeta()));
};
