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

package com.seesaw.player.traits.ads {
import com.seesaw.player.ads.AdState;
import com.seesaw.player.events.AdEvent;

import org.osmf.traits.MediaTraitBase;

[Event(name="canPauseChange",type="com.seesaw.player.events.AdEvent")]

[Event(name="adStateChange",type="com.seesaw.player.events.AdEvent")]

public class AdTrait extends MediaTraitBase {

    private var _adState:String;
    private var _playState:String;
    private var _markers:Array;

    public function AdTrait() {


        super(AdTraitType.AD_PLAY);

        _adState = AdState.STOPPED;


    }

    public function get adState():String {
        return _adState;
    }

    public function get markers():Object {
        return _markers;
    }

    public function set adState(value:String):void {
        if (value != _adState) {
            _adState = value;
            dispatchEvent(new AdEvent(AdEvent.AD_STATE_CHANGE, false, false, _adState));
        }
    }

    public function get playState():String {
        return _playState;
    }

    public function set playState(value:String):void {
        if (value != _playState && _adState == AdState.AD_BREAK_START) {
            _playState = value;
            dispatchEvent(new AdEvent(AdEvent.PLAY_PAUSE_CHANGE, false, false, _playState));
        }
    }

    public function started():void {
        // _playState = AdState.PLAYING;
        adState = AdState.AD_BREAK_START;
    }

    public function createMarkers(object:Array):void {
        _markers = object;
        dispatchEvent(new AdEvent(AdEvent.AD_MARKERS, false, false, _adState, object));
    }

    public function stopped():void {
        _playState = null;
        adState = AdState.STOPPED;
    }

    public function play():void {
        // playState = AdState.PLAYING;
    }

    public function pause():void {
        // playState = AdState.PAUSED;
    }
}
}