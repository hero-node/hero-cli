var getComponentsData = require('../lib/getComponentsData');

var existsNow, existsBefore;

function updateEntryFile(compiler, filePath, isDelete) {
    var entries = compiler.options.entry;

    if (!entries) {
        existsBefore = false;
    } else {
        existsBefore = !!(Object.keys(entries).find(function (key) {
            return (entries[key] === filePath);
        }));
    }

    // console.log('existsBefore=' + existsBefore);
    // Change or Add
    if (!isDelete) {
        try {
            existsNow = !!getComponentsData(filePath);
        } catch (e) {
            throw new Error('Parse Error: ', e);
        }
        // console.log('existsNow=' + existsNow);
        // Exist Changes
        return existsNow !== existsBefore;
    } else {
        return existsBefore;
    }
}

module.exports = updateEntryFile;
