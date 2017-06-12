var xml = `
<hero-view  hero-if="hasHeroView" version="0" backgroundColor="ffffff" nav="navigationBarHiddenH5=true;">
  <d-r-text-field
      hero-if="showTelephone"
      name="phone"
      type="phone"
      theme="green"
      hero-bind:size="14"
      placeHolder="手机号码"
      hero-bind:frame="{ x: '15', r: '15', y: '115', h: '50' }"
      textFieldDidEditing="{ name: 'phone' }"></d-r-text-field>
  <u-i-view frame="{ w: '1x', h: '1x' }" name="payView"
      hidden="true" backgroundColor="000000aa">
    <hero-image-view frame="{ r: '5', y: '7', w: '12', h: '12' }"
      image="/images/close_gray.png"></hero-image-view>
  </u-i-view>

  <d-r-text-field
      name="password"
      theme="green"
      secure="true"
      placeHolder="密码"
      frame="{ x: '15', r: '15', y: '178', h: '50' }"
      drSecure="{ secure: true }"
      textFieldDidEditing="{ name: 'password' }">密码</d-r-text-field>

    <d-r-button
    name="loginBtn"
    DRStyle="B1"
    enable="false"
    frame="{ x: '15', r: '15', y: '0', h: '44' }"
    yOffset="password+50"
    title="登录"
    click="{ click: 'login' }">登录</d-r-button>

  <hero-label
    hero-for="(item, index) in [0, 1, 2]"
    frame="{ w: '1x', h: '50', b: '0' }"
    text="Powered by Dianrong.com">Powered by Dianrong.com</hero-label>

  <hero-label
    hero-for="(item) in labels"
    frame="{ w: '1x', h: '50', b: '0' }"
    hero-bind:text="item">Powered by Dianrong.com</hero-label>
  <!-- BACCCC -->
  <hero-toast
    name="toast"
    corrnerRadius="10"
    frame="{ w: '300', h: '44' }"
    center="{ x: '0.5x', y: '0.5x' }"></hero-toast>

</hero-view>


`;

var jsdom = require('jsdom');
var jquery = require('jquery');
var parseVairables = require('./parseVairables');

var JSDOM = jsdom.JSDOM;
var dom, $;
// var typeKey = '_class';
var heryKeys = 'hero-';
var heryBindKeys = 'bind:';
var __$$heroCurrentView = '__$hero$CurrentView';
var _wrapperHeader = 'module.exports = function generateView(context){';
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

function getParentValue(hirachy, path) {

    console.log('path', hirachy, path);

    if (!path) {
        return hirachy;
    }

    var i, len;
    var value = hirachy;
    var paths = path.split('_');

    paths.pop();

    console.log('paths', paths);
    console.log('paths.length', paths.length);
    if (!paths.length) {
        return hirachy;
    }

    for (i = 0, len = paths.length; i < len; i++) {
        value = value.childrens[parseInt(paths[i], 10)];
    }

    console.log('value', value);
    return value;
}

function getMeta() {
    var tree = {};
    var keys = [];
    var fnMappings = {};
    var hirachy = {};

    traverse($('hero-view'), function (element, path) {
        var attributes = element[0].attributes;
        var suffix = (path ? path.join('_') : '');
        var __fnName = nameFormat(element[0].tagName) + '_' + suffix;
        var embeddedName = __$$heroCurrentView + suffix;

        keys.push(suffix);
        var nodeElement = {
            key: __fnName,
            expressions: {},
            attrs: {},
            childrens: []
        };


        tree[suffix] = nodeElement;
        if (!suffix) {
            hirachy = nodeElement;
        } else {
            getParentValue(hirachy, suffix).childrens.push(nodeElement);
        }


        var __body = [];

        __body.push(embeddedName);
        __body.push('={');

        var i, len;

        for (i = 0, len = attributes.length; i < len; i++) {
            if (attributes[i].name.indexOf(heryKeys) === 0) {

                tree[suffix].expressions[attributes[i].name.replace(heryKeys, '')] = attributes[i].value;
                continue;
            }
            nodeElement.attrs[attributes[i].name] = attributes[i].value;
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
    console.log(JSON.stringify(tree));
    console.log(JSON.stringify(hirachy));
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
    var __body = [_wrapperHeader];

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

dom = new JSDOM(xml);
$ = jquery(dom.window);
var _codes = treeObject(getMeta());
var _variables = parseVairables(_codes);
var variableDeclares = ['\n'];

_variables.implicitVariables.forEach(function (_varaible) {
    variableDeclares.push('var ');
    variableDeclares.push(_varaible);
    variableDeclares.push('=');
    variableDeclares.push(_variables.paramName);
    variableDeclares.push('.');
    variableDeclares.push(_varaible);
    variableDeclares.push(';\n');
});
// console.log(_codes.replace(_wrapperHeader, _wrapperHeader + variableDeclares.join('')));

module.exports = function (source) {
    // // this.cacheable();
    // dom = new JSDOM(source);
    // $ = jquery(dom.window);
    // var _codes = treeObject(getMeta());
    // var _variables = parseVairables(_codes);
    // var variableDeclares = ['\n'];
    //
    // _variables.implicitVariables.forEach(function (_varaible) {
    //     variableDeclares.push('var ');
    //     variableDeclares.push(_varaible);
    //     variableDeclares.push('=');
    //     variableDeclares.push(_variables.paramName);
    //     variableDeclares.push('.');
    //     variableDeclares.push(_varaible);
    //     variableDeclares.push('\n');
    // });
    // _codes = _codes.replace(_wrapperHeader, _wrapperHeader + variableDeclares.join(''));
    // // console.log(_codes);
    // this.callback(null, _codes);
};
