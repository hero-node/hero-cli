require('hero-js');

var API = window.API;

API.boot = function () {
  
};
// eslint-disable-next-line
API.special_logic = function (data) {
    if (data.click === 'login') {
        API.out({ command: 'showLoading' });
        API.in({ http: { 'url': 'http://localhost:3009/api/user', method: 'GET', data: { identity: window.ui2Data.phone, password: window.ui2Data.password } } });
    }
    if (window.ui2Data.phone && window.ui2Data.password && window.ui2Data.phone.length > 0 && window.ui2Data.password.length > 0) {
        API.out({ datas: { name: 'loginBtn', enable: true } });
    } else {
        API.out({ datas: { name: 'loginBtn', enable: false } });
    }
};

API.reloadData = function (data) {
    if (data.api === '/api/v2/users/login') {
        API.out({ command: 'goto:' + window.location.origin + '/mkt/asset2cash/index.html' });
    }
};
window.ui = {
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
            frame: { x: '15', r: '15', y: '115', h: '50' },
            placeHolder: '手机号码',
            name: 'phone',
            textFieldDidEditing: { name: 'phone' }
        },
        {
            class: 'DRTextField',
            theme: 'green',
            frame: { x: '15', r: '15', y: '178', h: '50' },
            placeHolder: '密码',
            name: 'password',
            drSecure: { 'secure': true }, // 带小眼睛
            textFieldDidEditing: { name: 'password' }
        },
        {
            class: 'AppButton',
            frame: { x: '15', r: '15', y: '0', h: '44' },
            title: '我的按钮'
        },
        {
            class: 'DRButton',
            name: 'loginBtn',
            DRStyle: 'B1',
            enable: false,
            frame: { x: '15', r: '15', y: '0', h: '44' },
            yOffset: 'password+50',
            title: '登录',
            click: { click: 'login' }
        },
        {
            class: 'HeroLabel',
            size: 14,
            textColor: '00bc8d',
            text: '忘记密码?',
            frame: { x: '15', w: '100', h: '40', y: '0' },
            yOffset: 'loginBtn+10'
        },
        {
            class: 'HeroButton',
            frame: { x: '15', w: '100', h: '40', y: '0' },
            yOffset: 'loginBtn+10',
            click: { command: 'goto:' + window.path + '/forget.html' }
        },
        {
            class: 'HeroLabel',
            frame: { w: '1x', h: '50', b: '0' },
            text: 'Powered by Dianrong.com',
            alignment: 'center',
            attribute: {
                'color(0,10)': 'aaaaaa',
                'color(10,13)': '00bc8d',
                'size(0,23)': '14'
            }
        },
        {
            class: 'HeroToast',
            name: 'toast'
        }

    ]
};
