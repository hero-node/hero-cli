function _defineProp(obj, key, value) {
    Object.defineProperty(obj, key, {
        enumerable: false,
        configurable: false,
        writable: true,
        value: value
    });
}
function Title(target, name, descriptor) {
    _defineProp(target, '__title', target[name]);
    return descriptor;
}
function Template(target, name, descriptor) {
    _defineProp(target, '__template', target[name]);
    return descriptor;
}
module.exports = {
    Title: Title,
    Template: Template
};
