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

package com.seesaw.player.traits.ads {
import com.seesaw.player.events.AdEvent;

import org.osmf.traits.MediaTraitBase;

[Event(name="adStateChange",type="com.seesaw.player.events")]

public class AdTrait extends MediaTraitBase {

    private var _playState:String;

    public function AdTrait() {
        super(AdTraitType.AD_PLAY);
        _playState = AdState.STOPPED;
    }

    public function get playState():String {
        return _playState;
    }

    public function set playState(value:String):void {
        if (value == null)
            throw new ArgumentError("ad state cannot be null");
        _playState = value;
        dispatchEvent(new AdEvent(value));
    }

    public function play():void {
        if (playState != AdState.PLAYING) {
            playState = AdState.PLAYING;
        }
    }

    public function stop():void {
        if (playState != AdState.STOPPED) {
            playState = AdState.STOPPED;
        }
    }

    public function pause():void {
        if (playState != AdState.PAUSED) {
            playState = AdState.PAUSED;
        }
    }
}
}