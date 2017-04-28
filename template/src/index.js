import 'hero-js/src/hero-app.html';

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

var arr = [2, 3];

console.log(...arr);
console.log(process.env);
