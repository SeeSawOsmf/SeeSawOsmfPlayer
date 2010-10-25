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

import org.osmf.traits.MediaTraitBase;

[Event(name="canPauseChange",type="com.seesaw.player.events")]


[Event(name="adStateChange",type="com.seesaw.player.events")]

public class AdTrait extends MediaTraitBase {

    public function AdTrait() {
        super(AdTraitType.AD_PLAY);


        _adState = AdState.AD_STOPPED;
    }


    public final function play():void {
        attemptAdPlayPauseChange(AdState.PLAYING);
    }

    public final function adStarted():void {
        attemptAdStateChange(AdState.AD_STARTED);
    }

    public final function adStopped():void {
        attemptAdStateChange(AdState.AD_STOPPED);
    }

    public final function pause():void {

        attemptAdPlayPauseChange(AdState.PAUSED);

    }


    public final function stop():void {
        attemptAdStateChange(AdState.AD_STOPPED);
    }


    public function get adState():String {
        return _adState;
    }


    protected function adStateChangeStart(newPlayState:String):void {
    }


    protected function adStateChangeEnd():void {
        dispatchEvent(new AdEvents(AdEvents.AD_STATE_CHANGE, false, false, adState));
    }

    protected function adPlayPauseChangeEnd():void {
        dispatchEvent(new AdEvents(AdEvents.PLAY_PAUSE_CHANGE, false, false, adState, _playPauseState));
    }


    private function attemptAdStateChange(newPlayState:String):void {
        if (_adState != newPlayState) {
            adStateChangeStart(newPlayState);

            _adState = newPlayState;

            adStateChangeEnd();
        }
    }

    private function attemptAdPlayPauseChange(newPlayState:String):void {
        if (_playPauseState != newPlayState) {
            adStateChangeStart(newPlayState);

            _playPauseState = newPlayState;

            adPlayPauseChangeEnd();
        }
    }

    private var _adState:String;
    private var _playPauseState:String;

    public function get playPauseState():String {
        return _playPauseState;
    }
}
}