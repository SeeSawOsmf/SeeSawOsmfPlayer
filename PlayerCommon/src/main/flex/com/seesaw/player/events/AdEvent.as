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

package com.seesaw.player.events {
import flash.events.Event;

/**
 * A AdEvents is dispatched when the properties of a AdTrait change.
 */
public class AdEvent extends Event {

    public static const PLAY_PAUSE_CHANGE:String = "playPauseChange";
    public static const AD_STATE_CHANGE:String = "adStateChange";
    public static const AD_MARKERS:String = "adMarkers";

    public function AdEvent
            (type:String, bubbles:Boolean = false, cancelable:Boolean = false, adState:String = null, adMarkers:Array = null) {
        super(type, bubbles, cancelable);

        _adState = adState;
        _canPause = canPause;
        _adMarkers = adMarkers;
    }

    override public function clone():Event {
        return new AdEvent(type, bubbles, cancelable, adState, markers);
    }

    public function get adState():String {
        return _adState;
    }

    public function get canPause():Boolean {
        return _canPause;
    }

    public function get markers():Array {
        return _adMarkers;
    }

    public function set markers(value:Array):void {
        _adMarkers = value;
    }

    private var _adState:String;
    private var _adMarkers:Array;
    private var _canPause:Boolean;


}
}
