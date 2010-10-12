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
import flash.events.HTTPStatusEvent;
import flash.events.IEventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;

public class ServiceRequestBase {

    private var logger:ILogger = LoggerFactory.getClassLogger(ServiceRequestBase);

    private var _baseUrl:String;
    private var _successCallback:Function;
    private var _failCallback:Function;

    public function ServiceRequestBase(baseUrl:String) {
        _baseUrl = baseUrl;
    }

    public function submit():void {
    }

    protected function load(url:String):void {
        logger.debug("loading url: " + url);

        var loader:URLLoader = new URLLoader();
        configureListeners(loader);

        var request:URLRequest = new URLRequest(url);
        request.method = URLRequestMethod.GET;

        try {
            loader.load(request);
        } catch (error:Error) {
            logger.error("unable to load requested document: " + url);
        }
    }

    private function configureListeners(dispatcher:IEventDispatcher):void {
        dispatcher.addEventListener(Event.COMPLETE, completeHandler);
        dispatcher.addEventListener(Event.OPEN, openHandler);
        dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
        dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
        dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
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

    private function openHandler(event:Event):void {
        logger.debug("openHandler: " + event);
    }

    private function progressHandler(event:ProgressEvent):void {
        logger.debug("progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal);
    }

    private function securityErrorHandler(event:SecurityErrorEvent):void {
        logger.debug("securityErrorHandler: " + event);
    }

    private function httpStatusHandler(event:HTTPStatusEvent):void {
        logger.debug("httpStatusHandler: " + event);
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

    public function get baseUrl():String {
        return _baseUrl;
    }

    public function set baseUrl(value:String):void {
        _baseUrl = value;
    }
}
}