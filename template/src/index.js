import { PATH as path } from './constant/index';

function init() {
    // Hero Core Web Components
    require('hero-js/src/hero-app.html');
    var args = {};
    var params = (window.location.search.split('?')[1] || '').split('&');
    var paramParts;
    var param;

    for (param in params) {
        if (params.hasOwnProperty(param)) {
            paramParts = params[param].split('=');
            args[paramParts[0]] = decodeURIComponent(paramParts[1] || '');
        }
    }
    var app = {
        tabs: [
            {
                url: args.state || path + '/pages/start.html',
                title: '首页',
                class: 'DRViewController',
                image: 'home_green'
            }
        ]
    };

    window.document.write('<hero-app json=' + JSON.stringify(app) + '></hero-app>');
}

// Dynamic Load WebComponents Polyfills
var supportWebComponent = (
  'registerElement' in document
  && 'import' in document.createElement('link')
  && 'content' in document.createElement('template'));

if (!supportWebComponent) {
    require.ensure(['../public/lib/webcomponents-lite'], function () {
        window.Polymer = {
            lazyRegister: true,
            dom: 'shadow'
        };
        require('../public/lib/webcomponents-lite');
        init();
    });
} else {
    init();
}

// You can access all the global variables via `process.env`
console.log('process.env', process.env);
