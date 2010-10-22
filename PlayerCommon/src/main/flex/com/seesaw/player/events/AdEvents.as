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

package com.seesaw.player.events {
import flash.events.Event;

/**
 * A AdEvents is dispatched when the properties of a AdTrait change.
 */
public class AdEvents extends Event {

    public static const CAN_PAUSE_CHANGE:String = "canPauseChange";

    public static const AD_STATE_CHANGE:String = "adStateChange";

    public function AdEvents
            (type:String,
             bubbles:Boolean = false,
             cancelable:Boolean = false,
             playState:String = null,
             canPause:Boolean = false
                    ) {
        super(type, bubbles, cancelable);

        _playState = playState;
        _canPause = canPause;
    }

    override public function clone():Event {
        return new AdEvents(type, bubbles, cancelable, playState, canPause);
    }

    public function get playState():String {
        return _playState;
    }

    public function get canPause():Boolean {
        return _canPause;
    }

    private var _playState:String;
    private var _canPause:Boolean;
}
}
