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

package com.seesaw.player {
import org.osmf.media.MediaFactory;
import org.osmf.media.MediaResourceBase;

public class PlayerConfiguration {

    private var _factory:MediaFactory;
    private var _adModuleType:String = "liverail";

    private var _width:int;
    private var _height:int;
    private var _resource:MediaResourceBase;

    public function PlayerConfiguration(playerWidth:int, playerHeight:int, mediaResource:MediaResourceBase) {
        width = playerWidth;
        height = playerHeight;
        resource = mediaResource;
    }

    public function set resource(value:MediaResourceBase):void {
        _resource = value;
    }

    public function get resource():MediaResourceBase {
        return _resource;
    }

    public function get factory():MediaFactory {
        if (_factory == null) {
            _factory = constructFactory();
        }
        return _factory;
    }

    /**
     * Override this to construct a different factory instance.
     * @return the factory
     */
    protected function constructFactory():MediaFactory {
        return new FriendlyMediaFactory();
    }

    public function get width():int {
        return _width;
    }

    public function set width(value:int):void {
        _width = value;
    }

    public function get height():int {
        return _height;
    }

    public function set height(value:int):void {
        _height = value;
    }

    public function get adModuleType():String {
        return _adModuleType;
    }

    public function set adModuleType(value:String):void {
        _adModuleType = value;
    }
}
}