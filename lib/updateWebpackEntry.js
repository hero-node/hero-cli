var path = require('path');
var getComponentsData = require('../lib/getComponentsData').getComponentsData;

var existsNow, existsBefore;

function equals(before, after) {
    // console.log('========');
    // console.log('before', before);
    // console.log('after', after);

    // all is empty
    if (!before && !after) {
        return true;
    }
    var beforeKeys, afterKeys;

    // all is not empty
    if (before && after) {
        beforeKeys = Object.keys(before);
        afterKeys = Object.keys(after);
        // console.log(beforeKeys, afterKeys);
        if (beforeKeys.length !== afterKeys.length) {
            return false;
        }

        return beforeKeys.every(function (key) {
            return  after[key] === before[key];
        });
    }
    return false;
}
function updateEntryFile(compiler, filePath, isDelete) {
    var entriesMetas = require('../lib/getComponentsData').entriesMetas;

    // console.log('updateEntryFile entriesMetas\n', entriesMetas);
    var entries = compiler.options.entry;
    var entryMetaData;
    var beforeEntryMeta;

    if (!entries) {
        existsBefore = false;
    } else {
        existsBefore = !!(Object.keys(entries).find(function (key) {
            return (entries[key] === filePath);
        }));
    }
    var customTemplateUrl;
    // console.log('existsBefore=' + existsBefore);
    // Change or Add

    if (isDelete) {
        return existsBefore;
    } else {
        try {
            beforeEntryMeta = entriesMetas[filePath];
            entryMetaData = getComponentsData(filePath);
            if (entryMetaData && entryMetaData.template) {
                customTemplateUrl = path.join(filePath, '../', entryMetaData.template);
                entryMetaData.template = '!!html!' + customTemplateUrl;
            }
            existsNow = !!entryMetaData;
        } catch (e) {
            throw new Error('Parse Error: ', e);
        }
        // console.log('existsNow=' + existsNow);
      // Exist Changes
        if (existsNow !== existsBefore) {
            return true;
        }
        // console.log(filePath);
        if (equals(beforeEntryMeta, entryMetaData)) {
            return false;
        }
        return true;
    }
}

module.exports = updateEntryFile;
