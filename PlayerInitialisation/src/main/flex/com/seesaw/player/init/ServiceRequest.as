/*
 * Copyright 2010 ioko365 Ltd.  All Rights Reserved.
 *
 *   The contents of this file are subject to the Mozilla Public License
 *   Version 1.1 (the "License"); you may not use this file except in
 *   compliance with the License. You may obtain a copy of the License at
 *   http://www.mozilla.org/MPL/
 *
 *   Software distributed under the License is distributed on an "AS IS"
 *   basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 *   License for the specific language governing rights and limitations
 *   under the License.
 *
 *
 *   The Initial Developer of the Original Code is ioko365 Ltd.
 *   Portions created by ioko365 Ltd are Copyright (C) 2010 ioko365 Ltd
 *   Incorporated. All Rights Reserved.
 */

package com.seesaw.player.init {
import com.adobe.serialization.json.JSON;

import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;

public class ServiceRequest {

    private var logger:ILogger = LoggerFactory.getClassLogger(ServiceRequest);

    private var _requestUrl:String;
    private var _successCallback:Function;
    private var _failCallback:Function;

    public function ServiceRequest(requestUrl:String) {
        _requestUrl = requestUrl;
    }

    public function submit():void {
        logger.debug("loading url: " + requestUrl);

        var loader:URLLoader = new URLLoader();
        configureListeners(loader);

        var request:URLRequest = new URLRequest(requestUrl);
        request.method = URLRequestMethod.GET;

        try {
            loader.load(request);
        } catch (error:Error) {
            logger.error("unable to load requested document: " + requestUrl);
        }
    }

    private function configureListeners(dispatcher:IEventDispatcher):void {
        dispatcher.addEventListener(Event.COMPLETE, completeHandler);
        dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
        dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
    }

    private function completeHandler(event:Event):void {
        var loader:URLLoader = URLLoader(event.target);
        var rawData:String = String(loader.data);

        logger.debug("completeHandler: " + rawData);

        var result:Object = JSON.decode(rawData);

        if (successCallback != null) {
            successCallback.call(null, result);
        }
    }


    private function ioErrorHandler(event:IOErrorEvent):void {
        logger.debug("ioErrorHandler: " + event);
        if (failCallback != null) {
            failCallback.call();
        }
    }

    private function securityErrorHandler(event:SecurityErrorEvent):void {
        logger.debug("securityErrorHandler: " + event);
        if (failCallback != null) {
            failCallback.call();
        }
    }

    public function get successCallback():Function {
        return _successCallback;
    }

    public function set successCallback(value:Function):void {
        _successCallback = value;
    }

    public function get failCallback():Function {
        return _failCallback;
    }

    public function set failCallback(value:Function):void {
        _failCallback = value;
    }

    public function get requestUrl():String {
        return _requestUrl;
    }

    public function set requestUrl(value:String):void {
        _requestUrl = value;
    }
}
}