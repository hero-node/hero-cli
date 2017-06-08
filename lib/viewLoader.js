// Module dependencies.
var jsdom = require('jsdom');
var jquery = require('jquery');
var JSDOM = jsdom.JSDOM;
// var typeKey = '_class';
var heryKeys = 'hero-';
var $, dom;
var fnMappings = {};

function nameFormat(name) {
    return name.toLowerCase().split('-').map(function (subName) {
        // console.log(subName + '');
        return subName.charAt(0).toUpperCase() + subName.substring(1);
    }).join('');
}

function traverse(element, callback, parentIdx, parent) {
    if (!element) {
        return null;
    }

    var idx, len;

    // console.log(element);
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

module.exports = function (source) {
    this.cacheable();

    dom = new JSDOM(source);
    $ = jquery(dom.window);

    var xmlJson = {};

    traverse($('hero-view'), function (element, path, parent) {
        // console.log(path);
        var attributes = element[0].attributes;

        if (!parent) {
            xmlJson[nameFormat(element[0].tagName)] = {};
        } else {
            if (!parent.children) {
                parent.children = [];
            }
            parent.children.push(element);
        }

        var json = {},
            i,
            len;

        for (i = 0, len = attributes.length; i < len; i++) {
            // console.log(attributes[i].value);
            json[attributes[i].name] = attributes[i].value;
        }
    });

    var generatedJSCode = '';
    var tree = {};
    var keys = [];

    traverse($('hero-view'), function (element, path) {
        var attributes = element[0].attributes;

        var suffix = (path ? path.join('_') : '');
        var __fnName = nameFormat(element[0].tagName) + '_' + suffix;

        keys.push(suffix);

        tree[suffix] = {
            key: __fnName,
            expressions: {}
        };
        var fn = 'function __fnName(element, view){__body;return view;}'.replace('__fnName', __fnName);

        var __body = '';
        var json = {},
            i,
            len;

        for (i = 0, len = attributes.length; i < len; i++) {
            if (attributes[i].name.indexOf(heryKeys) === 0) {

                tree[suffix].expressions[attributes[i].name.replace(heryKeys, '')] = attributes[i].value;
                continue;
            }
            // console.log(attributes[i].value);
            __body += 'view["' + attributes[i].name + '"]="' + attributes[i].value + '";'.replace();
            json[attributes[i].name] = attributes[i].value;
        }

        fn = fn.replace('__body', __body);
        fnMappings[__fnName] = fn;

        generatedJSCode += fn;
        generatedJSCode += ';\n';
    });

    generatedJSCode += '\nvar treeObject = ' + JSON.stringify(tree) + ';\n var KEYS = ' + JSON.stringify(keys) + ';';

    console.log(generatedJSCode);
    this.callback(null, 'module.exports = function(){return ' + generatedJSCode + '};');
};
