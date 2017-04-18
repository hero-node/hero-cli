function contain(objs, obj) {
    var i = objs.length;

    while (i--) {
        if (objs[i] === obj) {
            return true;
        }
    }
    return false;
}
function merge(o1, o2) {
    for (var key in o2) {
        o1[key] = o2[key];
    }
    return o1;
}
function remove(arr, value) {
    if (!arr) {
        return;
    }
    var a = arr.indexOf(value);

    if (a >= 0) {
        arr.splice(a, 1);
    }
}

var _initData = null;

function getInitData() {
    if (localStorage.boot) {
        _initData = JSON.parse(localStorage.boot);
        localStorage.boot = '';
    }
    _initData = _initData || {};
    var params = (window.location.search.split('?')[1] || '').split('&');

    var param, paramParts;

    for (param in params) {
        if (params.hasOwnProperty(param)) {
            paramParts = params[param].split('=');
            _initData[paramParts[0]] = decodeURIComponent(paramParts[1] || '');
        }
    }
    return _initData;
}
export {
  remove, merge, contain,getInitData
};
