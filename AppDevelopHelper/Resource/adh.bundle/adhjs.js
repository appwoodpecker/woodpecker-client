
function adhInit() {
    if(window.adh) {
        return;
    }
    window.adh = {
        'pluginHandlers' : {},
    };
}

adhInit();

//javascript bridge
function setupWebViewJavascriptBridge(callback) {
    if (window.WebViewJavascriptBridge) { return callback(WebViewJavascriptBridge); }
    if (window.WVJBCallbacks) { return window.WVJBCallbacks.push(callback); }
    window.WVJBCallbacks = [callback];
    var WVJBIframe = document.createElement('iframe');
    WVJBIframe.style.display = 'none';
    WVJBIframe.src = 'https://__bridge_loaded__';
    document.documentElement.appendChild(WVJBIframe);
    setTimeout(function() { document.documentElement.removeChild(WVJBIframe) }, 0);
}

function adhSetup(){    
    setupWebViewJavascriptBridge(function(bridge) {
        bridge.registerHandler('pluginCall',handlePluginCall);
        // alert("bridge init");
    });
}


function handlePluginCall(data) {
    var action = data['name'];
    var body = data['data'];
    var handler = adh.pluginHandlers[action];
    if(typeof(handler) == "function") {
        handler(body);
    }
}

function registerPluginHandler(action, handler) {
    if(action == null) {return;}
    if(typeof(handler) != "function") {return;}
    adh.pluginHandlers[action] = handler;
}

window.onload = adhSetup;

window.onerror = function(errorMessage, scriptURI, lineNumber,columnNumber,errorObj) {
    // TODO
    alert(errorMessage+' '+scriptURI+' '+lineNumber+' '+errorObj);
}


/**
 call remote App`s service method.
 
 @p service (string)
 @p action (string)
 @p data (key-value object)
 @p payload (binary data)
 */
function adhCallClientApi(service,action,data,payload,callback){
    var body = {
        'service' : service,
        'action' : action,
        'body' : data,
        'payload' : payload,
    };
    window.WebViewJavascriptBridge.callHandler('clientApi', body, function(response) {
       if(typeof callback == "function"){
           var data = response.data;
           var payload = response.payload;
           callback(data,payload);
       }
    });
}

/**
 you can save some preference(key-value) at mac client.
 
 @p key (string)
 @p value (key-value object)
 */
function adhSetPreference(key, value){
    var action = 'setPreference';
    var data = {
        'key' : key,
        'value' : value,
    };
    var body = {
        'action' : action,
        'data' : data,
    };
    window.WebViewJavascriptBridge.callHandler('localApi', body, function(response) {
        
    });
}

/**
 fetch local preference value by key
 
 @p key (string)
 */
function adhGetPreference(key, callback){
    var action = 'getPreference';
    var data = {
        'key' : key,
    }
    var body = {
        'action' : action,
        'data' : data,
    };
    setupWebViewJavascriptBridge(function(bridge) {
        bridge.callHandler('localApi', body, function(response) {
            if(typeof callback == "function"){
                var value = response;
                callback(value);
            }
        });
    });
}

function adhCallLocalApi(action,data,callback) {
    if(action == null || action.length == 0) return;
    var body = {
        'action' : action,
    };
    if(data != null) {
        body['data'] = data;
    }
    setupWebViewJavascriptBridge(function(bridge) {
        bridge.callHandler('localApi', body, function(result) {
            if(typeof callback == "function"){
                callback(result);
            }
        });
    });
}

/**
 * get current theme
 */
function adhGetTheme(callback){
    var action = 'getTheme';
    var data = {
    }
    var body = {
        'action' : action,
        'data' : data,
    };
    setupWebViewJavascriptBridge(function(bridge) {
        bridge.callHandler('localApi', body, function(response) {
            if(typeof callback == "function"){
                var value = response;
                callback(value);
            }
        });
    });
}




