require('hero-js');

var API = window.API;

API.boot = function () {};
// eslint-disable-next-line
API.special_logic = function () {};
API.reloadData = function () {};

window.ui = {
    version: 0,
    backgroundColor: 'f5f5f5',
    nav: {
        title: '快速变现',
        navigationBarHiddenH5: true
    },
    views: [
        {
            class: 'HeroWebView',
            frame: {
                w: '1x',
                h: '1x'
            },
            url: window.path + '/license.html'
        }
    ]
};
