/*
 * The contents of this file are subject to the Mozilla Public License
 *   Version 1.1 (the "License"); you may not use this file except in
 *   compliance with the License. You may obtain a copy of the License at
 *   http://www.mozilla.org/MPL/
 *
 *   Software distributed under the License is distributed on an "AS IS"
 *   basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 *   License for the specific language governing rights and limitations
 *   under the License.
 *
 *   The Initial Developer of the Original Code is Arqiva Ltd.
 *   Portions created by Arqiva Limited are Copyright (C) 2010, 2011 Arqiva Limited.
 *   Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe
 * 	Systems Incorporated.
 *   All Rights Reserved.
 *
 *   Contributor(s):  Adobe Systems Incorporated
 */

package com.seesaw.player.utils {
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;

public class ServiceRequest {

    private var _requestUrl:String;
    private var _successHandler:Function;
    private var _failHandler:Function;

    public function ServiceRequest(requestUrl:String, successHandler:Function, failHandler:Function = null) {
        if (requestUrl == null) {
            throw ArgumentError("a request url is required");
        }

        if (successHandler == null) {
            throw ArgumentError("a success handler function is required");
        }

        _requestUrl = requestUrl;
        _successHandler = successHandler;
        _failHandler = failHandler;
    }

    public function submit(data = null):void {
        var loader:URLLoader = new URLLoader();
        loader.dataFormat = URLLoaderDataFormat.TEXT;

        loader.addEventListener(Event.COMPLETE, completeHandler);

        if (_failHandler) {
            loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        }

        var request:URLRequest = new URLRequest(_requestUrl);

        if (data == null) {
            request.method = URLRequestMethod.GET;
        } else {
            request.method = URLRequestMethod.POST;
            request.data = data;
        }

        loader.load(request);
    }

    private function completeHandler(event:Event):void {
        if (_successHandler != null) {
            var loader:URLLoader = URLLoader(event.target);
            _successHandler.call(null, loader.data);
        }
    }

    private function securityErrorHandler(event:SecurityErrorEvent):void {
        if (_failHandler != null) {
            _failHandler.call(null);
        }
    }

    private function ioErrorHandler(event:IOErrorEvent):void {
        if (_failHandler != null) {
            _failHandler.call(null);
        }
    }

    public function get requestUrl():String {
        return _requestUrl;
    }

    public function set requestUrl(value:String):void {
        _requestUrl = value;
    }

}
}
