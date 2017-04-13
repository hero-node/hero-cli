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
export {
  remove, merge, contain
};
