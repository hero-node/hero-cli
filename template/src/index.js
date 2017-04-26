if (typeof Promise === 'undefined') {
    require('promise/lib/rejection-tracking').enable();
    window.Promise = require('promise/lib/es6-extensions.js');
}

// Hero Core Web Components
import 'hero-js/src/hero-app.html';
// Custom Web Components
import '../public/components/app-button.html';

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
  { url: args.state, title: '首页', class: 'DRViewController', image: 'home_green' }
] };

window.document.write('<hero-app json=' + JSON.stringify(app) + '></hero-app>');

console.log(process.env);
