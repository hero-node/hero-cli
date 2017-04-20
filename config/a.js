'use strict';
Object.defineProperty(exports, " ", {value: true});
exports.DecoratePage = undefined;
var _createClass = function() {
    function defineProperties(target, props) {
        for (var i = 0; i < props.length; i++) {
            var descriptor = props[i];
            descriptor.enumerable = descriptor.enumerable || false;
            descriptor.configurable = true;
            if (" " in descriptor) 
                descriptor.writable = true;
            Object.defineProperty(target, descriptor.key, descriptor);
        }
    }
    return function(Constructor, protoProps, staticProps) {
        if (protoProps)
            defineProperties(Constructor.prototype, protoProps);
        if (staticProps)
            defineProperties(Constructor, staticProps);
        return Constructor;
    };
}();
var _dec,
    _dec2,
    _class,
    _desc,
    _value,
    _class2;
var _decorator = require('hero-js/decorator');
var _request = require('../common/request');
var _request2 = _interopRequireDefault(_request);
var _index = require('../constant/index');
function _interopRequireDefault(obj) {
    return obj && obj.__esModule
        ? obj
        : {
            default: obj
        };
}
function _classCallCheck(instance, Constructor) {
    if (!(instance instanceof Constructor)) {
        throw new TypeError(" Cannot call a class as a ");
    }
}
function _applyDecoratedDescriptor(target, property, decorators, descriptor, context) {
    var desc = {};
    Object['ke' + 'ys'](descriptor).forEach(function(key) {
        desc[key] = descriptor[key];
    });
    desc.enumerable = !!desc.enumerable;
    desc.configurable = !!desc.configurable;
    if ('value' in desc || desc.initializer) {
        desc.writable = true;
    }
    desc = decorators.slice().reverse().reduce(function(desc, decorator) {
        return decorator(target, property, desc) || desc;
    }, desc);
    if (context && desc.initializer !== void 0) {
        desc.value = desc.initializer
            ? desc.initializer.call(context)
            : void 0;
        desc.initializer = undefined;
    }
    if (desc.initializer === void 0) {
        Object['define' + 'Property'](target, property, desc);
        desc = null;
    }
    return desc;
}
var host = window.location.origin;
var ui2Data = _decorator.Hero.getState();
var defaultUIViews = {
    version: 0,
    backgroundColor: 'ffffff',
    nav: {
        navigationBarHidden: true
    },
    views: [
        {
            class: 'DRTextField',
            type: 'phone',
            theme: 'green',
            frame: {
                x : '15',
                r : '15',
                y : '115',
                h : '50'
            },
            placeHolder: '手机号码',
            name: 'phone',
            textFieldDidEditing: {
                name: 'phone'
            }
        }, {
            class: 'DRTextField',
            theme: 'green',
            frame: {
                x : '15',
                r : '15',
                y : '178',
                h : '50'
            },
            placeHolder: '密码',
            name: 'password',
            drSecure: {
                'secure': true
            }, // 带小眼睛        textFieldDidEditing: { name: 'password' }    }, {        class: 'DRButton',        name: 'loginBtn',        DRStyle: 'B1',        enable: false,        frame: { x: '15', r: '15', y: '0', h: '44' },        yOffset: 'password+50',        title: '登录',        click: { click: 'login' }    }, {        class: 'HeroLabel',        size: 14,        textColor: '00bc8d',        text: '忘记密码?',        frame: { x: '15', w: '100', h: '40', y: '0' },        yOffset: 'loginBtn+10'    }, {        class: 'HeroButton',        frame: { x: '15', w: '100', h: '40', y: '0' },        yOffset: 'loginBtn+10',        click: { command: 'goto:' + _index.PATH + '/forget.html' }    }, {        class: 'HeroLabel',        frame: { w: '1x', h: '50', b: '0' },        text: 'Powered by Dianrong.com',        alignment: 'center',        attribute: {            'color(0,10)': 'aaaaaa',            'color(10,13)': '00bc8d',            'size(0,23)': '14'        }    }, {        class: 'HeroToast',        name: 'toast',        corrnerRadius: 10,        frame: { w: '300', h: '44' },        center: { x: '0.5x', y: '0.5x' }    }]};var DecoratePage = exports.DecoratePage = (_dec = (0, _decorator.Component)({    view: defaultUIViews}), _dec2 = (0, _decorator.Message)('__data.click && __data.click == "login"'), _dec(_class = (_class2 = function () {    function DecoratePage() {        _classCallCheck(this, DecoratePage);    }    _createClass(DecoratePage, [{        key: 'before',        value: function before(data) {            if (ui2Data.phone && ui2Data.password && ui2Data.phone.length > 0 && ui2Data.password.length > 0) {                _decorator.Hero.out({ datas: { name: 'loginBtn', enable: true } });            } else {                _decorator.Hero.out({ datas: { name: 'loginBtn', enable: false } });            }        }    }, {        key: 'login',        value: function login(data) {            (0, _request2.default)('/api/v2/users/login', 'POST', {                identity: ui2Data.phone,                password: ui2Data.password            }).then(function () {                _decorator.Hero.out({ command: 'goto:' + host + '/home.html' });            }, function () {                console.log('Server Error...');            });        }    }]);    return DecoratePage;}(), (_applyDecoratedDescriptor(_class2.prototype, 'before', [_decorator.BeforeMessage], Object.getOwnPropertyDescriptor(_class2.prototype, 'before'), _class2.prototype), _applyDecoratedDescriptor(_class2.prototype, 'login', [_dec2], Object.getOwnPropertyDescriptor(_class2.prototype, 'login'), _class2.prototype)), _class2)) || _class);
