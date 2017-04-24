function _defineProp(obj, key, value) {
    Object.defineProperty(obj, key, {
        enumerable: false,
        configurable: false,
        writable: true,
        value: value
    });
}
function Entry(target, name, descriptor) {
    _defineProp(target, '__entryConfig', target[name]);
    return descriptor;
}
module.exports = {
    Entry: Entry
};
