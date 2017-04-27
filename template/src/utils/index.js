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
function fmoney(s, n) {
    n = n >= 0 && n <= 20 ? n : 2;
    // eslint-disable-next-line
    s = parseFloat((s + '').replace(/[^\d\.-]/g, '')).toFixed(n) + '';
    var l = s.split('.')[0].split('').reverse(),
        r = s.split('.')[1];

    var t = '', i;

    for (i = 0; i < l.length; i++) {
        t += l[i] + ((i + 1) % 3 === 0 && (i + 1) !== l.length ? ',' : '');
    }
    return t.split('').reverse().join('') + (r ? ('.' + r) : '');
}

function dataFormat(date, fmt) {
    var o = {
        'M+': date.getMonth() + 1, // 月份
        'd+': date.getDate(), // 日
        'h+': date.getHours(), // 小时
        'm+': date.getMinutes(), // 分
        's+': date.getSeconds(), // 秒
        'q+': Math.floor((date.getMonth() + 3) / 3), // 季度
        'S': date.getMilliseconds() // 毫秒
    };
    var k;

    if (/(y+)/.test(fmt)) { fmt = fmt.replace(RegExp.$1, (date.getFullYear() + '').substr(4 - RegExp.$1.length)); }
    for (k in o)        { if (new RegExp('(' + k + ')').test(fmt)) { fmt = fmt.replace(RegExp.$1, (RegExp.$1.length === 1) ? (o[k]) : (('00' + o[k]).substr(('' + o[k]).length))); } }
    return fmt;
}

function decimalAdjust(type, value, exp) {
    if (typeof exp === 'undefined' || +exp === 0) {
        return Math[type](value);
    }
    value = +value;
    exp = +exp;
    if (isNaN(value) || !(typeof exp === 'number' && exp % 1 === 0)) {
        return NaN;
    }
    if (value < 0) {
        return -decimalAdjust(type, -value, exp);
    }
    value = value.toString().split('e');
    value = Math[type](+(value[0] + 'e' + (value[1] ? (+value[1] - exp) : -exp)));
    value = value.toString().split('e');
    return +(value[0] + 'e' + (value[1] ? (+value[1] + exp) : exp));
}

function round10(value, exp) {
    return decimalAdjust('round', value, exp);
}

function floor10(value, exp) {
    return decimalAdjust('floor', value, exp);
}

function ceil10(value, exp) {
    return decimalAdjust('ceil', value, exp);
}

export {
  remove, merge, contain, getInitData, fmoney, dataFormat, round10, floor10, ceil10
};
