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
 * Date: 25/03/11
 * Time: 09:41
 * To change this template use File | Settings | File Templates.
 */
package com.seesaw.player.events {
import flash.events.Event;

public class BandwidthEvent extends Event {

    public static const BANDWITH_STATUS:String = "bandwidthStatus";

    private var _measuredBandwidth:Number;
    private var _requiredBandwidth:Number;
    private var _sufficientBandwidth:Boolean;
    private var _httpDownloadRatio:Number;

    public function BandwidthEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false,
                                   sufficientBandwidth:Boolean = true, measuredBandwidth:Number = NaN,
                                   requiredBandwidth:Number = NaN, httpDownloadRatio:Number = NaN) {
        super(type, bubbles, cancelable);
        _sufficientBandwidth = sufficientBandwidth;
        _measuredBandwidth = measuredBandwidth;
        _requiredBandwidth = requiredBandwidth;
        _httpDownloadRatio = httpDownloadRatio;
    }

    override public function clone():Event {
        return new BandwidthEvent(type, bubbles, cancelable, sufficientBandwidth, measuredBandwidth, requiredBandwidth, httpDownloadRatio);
    }

    public function get measuredBandwidth():Number {
        return _measuredBandwidth;
    }

    public function get requiredBandwidth():Number {
        return _requiredBandwidth;
    }

    public function get sufficientBandwidth():Boolean {
        return _sufficientBandwidth;
    }

    public function get httpDownloadRatio():Number {
        return _httpDownloadRatio;
    }

}
}
