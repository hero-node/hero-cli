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

  <hero-label
    hero-for="(item, index) in [0, 1, 2]"
    frame="{ w: '1x', h: '50', b: '0' }"
    text="Powered by Dianrong.com">

    <d-r-button
    hero-if="index!==0"
    name="loginBtn"
    DRStyle="B1"
    enable="false"
    frame="{ x: '15', r: '15', y: '0', h: '44' }"
    yOffset="password+50"
    title="登录"
    click="{ click: 'login' }">登录</d-r-button>

  </hero-label>

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
    if (!path) {
        return hirachy;
    }

    var i, len;
    var value = hirachy;
    var paths = path.split('_');

    paths.pop();

    if (!paths.length) {
        return hirachy;
    }

    for (i = 0, len = paths.length; i < len; i++) {
        value = value.childrens[parseInt(paths[i], 10)];
    }

    return value;
}

function getMeta() {
    var hirachy = {};

    traverse($('hero-view'), function (element, path) {
        var attributes = element[0].attributes;
        var suffix = (path ? path.join('_') : '');
        var __fnName = nameFormat(element[0].tagName) + '_' + suffix;

        var nodeElement = {
            key: __fnName,
            expressions: {},
            attrs: {},
            childrens: []
        };

        if (!suffix) {
            hirachy = nodeElement;
        } else {
            getParentValue(hirachy, suffix).childrens.push(nodeElement);
        }

        var i, len;

        for (i = 0, len = attributes.length; i < len; i++) {
            if (attributes[i].name.indexOf(heryKeys) === 0) {

                nodeElement.expressions[attributes[i].name.replace(heryKeys, '')] = attributes[i].value;
                continue;
            }
            nodeElement.attrs[attributes[i].name] = attributes[i].value;
        }
    });
    return hirachy;
}

function treeObject(hirachy, parentViewName) {
    var keys = hirachy.key.split('_');
    var tagName = keys.shift();
    var paths = keys;
    var isRoot = paths && paths.length && paths[0] === '';
    var isRootChild = paths.length === 1;
    var currentViewVariableName = isRoot ? __$$heroCurrentView : __$$heroCurrentView + paths.join('_');

    console.log(hirachy.key, paths, isRoot);

    var __body = isRoot ? [_wrapperHeader] : [];

    __body.push('\n var ');
    __body.push(currentViewVariableName);
    __body.push(';');

    var fors, hasSquare;

    if (hirachy.expressions.for) {
        fors = hirachy.expressions.for.trim().split(/\bin\b/);
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

    if (hirachy.expressions.if) {
        __body.push('\nif(');
        __body.push(hirachy.expressions.if);
        __body.push('){');
    }

    var binds = Object.keys(hirachy.expressions).filter(function (heroDirective) {
        return heroDirective.indexOf(heryBindKeys) !== -1;
    });

    __body.push(currentViewVariableName);
    __body.push('={');

    var attrKeys = Object.keys(hirachy.attrs);

    if (hirachy.childrens && hirachy.childrens.length) {
        if (isRoot) {
            __body.push('\nviews:[]');
        } else {
            __body.push('\nsubViews:[]');
        }
        if (attrKeys.length || binds.length) {
            __body.push(',\n');
        }
    }
    attrKeys.forEach(function (attr, index) {
        __body.push(attr);
        __body.push(':');
        __body.push('"');
        __body.push(hirachy.attrs[attr]);
        __body.push('"');
        if (binds.length || (index < attrKeys.length - 1)) {
            __body.push(',\n');
        }
    });
    binds.forEach(function (bind, index) {
        __body.push(bind.replace(heryBindKeys, ''));
        __body.push(':');
        __body.push(hirachy.expressions[bind]);
        if (index < (binds.length - 1)) {
            __body.push(',');
        }
    });
    __body.push('\n};');

    if (hirachy.childrens && hirachy.childrens.length) {
        hirachy.childrens.forEach(function (child) {
            console.log('-----------');
            var childFn = treeObject(child, currentViewVariableName);

            console.log(childFn);
            console.log('___________');
            __body = __body.concat(childFn);

        });
    }
    if (!isRoot) {
        __body.push(parentViewName);
        if (isRootChild) {
            __body.push('.views.push(');
        } else {
            __body.push('.subViews.push(');
        }
        __body.push(currentViewVariableName);
        __body.push(');');

    }

    if (hirachy.expressions.if) {
        __body.push('}');
    }

    if (hirachy.expressions.for) {
        __body.push('});');
    }

    if (isRoot) {
        __body.push('; \nreturn ');
        __body.push(__$$heroCurrentView);
        __body.push(';}');
    }

    return __body.join('');
}

dom = new JSDOM(xml);
$ = jquery(dom.window);
var _codes = treeObject(getMeta());

console.log(_codes);

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
