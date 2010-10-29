/*
 * Copyright 2010 ioko365 Ltd.  All Rights Reserved.
 *
 *    The contents of this file are subject to the Mozilla Public License
 *    Version 1.1 (the "License"); you may not use this file except in
 *    compliance with the License. You may obtain a copy of the
 *    License athttp://www.mozilla.org/MPL/
 *
 *    Software distributed under the License is distributed on an "AS IS"
 *    basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 *    License for the specific language governing rights and limitations
 *    under the License.
 *
 *    The Initial Developer of the Original Code is ioko365 Ltd.
 *    Portions created by ioko365 Ltd are Copyright (C) 2010 ioko365 Ltd
 *    Incorporated. All Rights Reserved.
 *
 *    The Initial Developer of the Original Code is ioko365 Ltd.
 *    Portions created by ioko365 Ltd are Copyright (C) 2010 ioko365 Ltd
 *    Incorporated. All Rights Reserved.
 */

package com.seesaw.player.init {
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

    public function submit():void {
        var loader:URLLoader = new URLLoader();
        loader.dataFormat = URLLoaderDataFormat.TEXT;

        loader.addEventListener(Event.COMPLETE, completeHandler);

        if (_failHandler) {
            loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        }

        var request:URLRequest = new URLRequest(_requestUrl);
        request.method = URLRequestMethod.GET;

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