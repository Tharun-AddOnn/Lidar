var exec = require('cordova/exec');

pluginName = 'Lidar';

exports.ErrorCodes = {
    Unsupported: 1
};

exports.isLiDARAvailable = function(successCallback, errorCallback) {
    exec(successCallback, errorCallback, pluginName, "isLiDARAvailable", []);
};

exports.startScannin = function(successCallback, errorCallback) {
    exec(successCallback, errorCallback, pluginName, "startScanning", []);
};

exports.stopScanning = function(successCallback, errorCallback) {
    exec(successCallback, errorCallback,pluginName, "stopScanning", []);
};