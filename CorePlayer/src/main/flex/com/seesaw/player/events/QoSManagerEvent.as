/*
 * Copyright 2011 ioko365 Ltd.  All Rights Reserved.
 *
 * The contents of this file are subject to the Mozilla Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the
 * License athttp://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 * The Initial Developer of the Original Code is ioko365 Ltd.
 * Portions created by ioko365 Ltd are Copyright (C) 2011 ioko365 Ltd
 * Incorporated. All Rights Reserved.
 *
 * The Initial Developer of the Original Code is ioko365 Ltd.
 * Portions created by ioko365 Ltd are Copyright (C) 2011 ioko365 Ltd
 * Incorporated. All Rights Reserved.
 */

/**
 * Created by IntelliJ IDEA.
 * User: ibhana
 * Date: 29/03/11
 * Time: 09:22
 * To change this template use File | Settings | File Templates.
 */
package com.seesaw.player.events {
import flash.events.Event;

public class QoSManagerEvent extends Event {

    public static const CONNECTION_STATUS:String = "connectionStatus";

    private var _connectionTooSlow:Boolean;
    private var _bufferTime:Number;
    private var _bufferLength:Number;

    public function QoSManagerEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, connectionTooSlow:Boolean = false,
            bufferTime:Number = NaN, bufferLength:Number = NaN) {
        super(type, bubbles, cancelable);
        _connectionTooSlow = connectionTooSlow;
        _bufferTime = bufferTime;
        _bufferLength = bufferLength;
    }

    public function get connectionTooSlow():Boolean {
        return _connectionTooSlow;
    }

    public function get bufferTime():Number {
        return _bufferTime;
    }

    public function get bufferLength():Number {
        return _bufferLength;
    }
}
}
