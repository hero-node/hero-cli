import { PATH as path } from './constant/index';
function init() {
    require('hero-js/src/hero-app.html');
    var args = {};
    var params = (window.location.search.split('?')[1] || '').split('&');
    var paramParts;

    for (var param in params) {
        if (params.hasOwnProperty(param)) {
            paramParts = params[param].split('=');
            args[paramParts[0]] = decodeURIComponent(paramParts[1] || '');
        }
    }
    var app = { tabs: [
    { url: args.state || path + '/pages/start.html', title: '首页' }
    ] };
    var app1 = document.createElement('hero-app');

    if (!window.document.body) {
        document.body = document.createElement('body');
    }
    window.document.body.appendChild(app1);
    app1.json = JSON.stringify(app);
}

var supportWebComponent = ('registerElement' in document
    && 'import' in document.createElement('link')
    && 'content' in document.createElement('template'));

if (!supportWebComponent) {
    require.ensure(['../public/lib/webcomponents-lite'], function () {
        window.Polymer = { lazyRegister: true, dom: 'shadow' };
        require('../public/lib/webcomponents-lite');
        init();
    });
} else {
    init();
}

console.log('process.env', process.env);
