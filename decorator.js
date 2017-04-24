function _defineProp(obj, key, value) {
    Object.defineProperty(obj, key, {
        enumerable: false,
        configurable: false,
        writable: true,
        value: value
    });
}
function Entry(config) {
    return function (Target) {
        _defineProp(Target, '__entryConfig', config);
    };
}

module.exports = {
    Entry: Entry
};
