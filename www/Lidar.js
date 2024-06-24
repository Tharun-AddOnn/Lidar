var exec = require('cordova/exec');

var Lidar = {
    isLiDARAvailable: function(successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "Lidar", "isLiDARAvailable", []);
    },

    startScanning: function(successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "Lidar", "startScanning", []);
    },

    stopScanning: function(successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "Lidar", "stopScanning", []);
    }
};

module.exports = Lidar;