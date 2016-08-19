var exec = require('cordova/exec');

exports.play = function(url, success, error, options) {
    exec(success, error, "AdsVP", "play", [url, options]);
};