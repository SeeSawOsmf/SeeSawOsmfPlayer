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
import com.seesaw.player.events.AdEvents;

import flash.errors.IllegalOperationError;

import org.osmf.events.PlayEvent;
import org.osmf.traits.MediaTraitBase;
import org.osmf.utils.OSMFStrings;

[Event(name="canPauseChange",type="com.seesaw.player.events")]


[Event(name="adStateChange",type="com.seesaw.player.events")]

public class AdTrait extends MediaTraitBase {

    public function AdTrait() {
        super(AdTraitType.PLAY);

        _canPause = true;
        _playState = AdState.STOPPED;
    }


    public final function play():void {
        attemptAdStateChange(AdState.PLAYING);
    }


    public function get canPause():Boolean {
        return _canPause;
    }

    public final function pause():void {
        if (canPause) {
            attemptAdStateChange(AdState.PAUSED);
        }
        else {
            throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.PAUSE_NOT_SUPPORTED));
        }
    }


    public final function stop():void {
        attemptAdStateChange(AdState.STOPPED);
    }


    public function get playState():String {
        return _playState;
    }


    protected final function setCanPause(value:Boolean):void {
        if (value != _canPause) {
            _canPause = value;

            dispatchEvent(new PlayEvent(PlayEvent.CAN_PAUSE_CHANGE));
        }
    }

    protected function adStateChangeStart(newPlayState:String):void {
    }


    protected function adStateChangeEnd():void {
        dispatchEvent(new PlayEvent(AdEvents.AD_STATE_CHANGE, false, false, playState));
    }

    private function attemptAdStateChange(newPlayState:String):void {
        if (_playState != newPlayState) {
            adStateChangeStart(newPlayState);

            _playState = newPlayState;

            adStateChangeEnd();
        }
    }

    private var _playState:String;
    private var _canPause:Boolean;
}
}