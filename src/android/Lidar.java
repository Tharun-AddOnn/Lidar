package com.addonn.Lidar;
public class Lidar extends CordovaPlugin {
    private CallbackContext _callbackContext;
     @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        this._callbackContext = callbackContext;
    }
}