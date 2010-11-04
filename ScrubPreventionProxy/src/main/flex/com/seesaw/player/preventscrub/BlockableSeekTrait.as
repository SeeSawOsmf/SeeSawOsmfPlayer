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

package com.seesaw.player.preventscrub {
import org.osmf.events.SeekEvent;
import org.osmf.traits.SeekTrait;
import org.osmf.traits.TimeTrait;

public class BlockableSeekTrait extends SeekTrait {

    private var _blocking:Boolean;

    private var _seekTrait:SeekTrait;

    public function BlockableSeekTrait(time:TimeTrait, seekTrait:SeekTrait) {
        _seekTrait = seekTrait;
        super(time);
        addEventListener(SeekEvent.SEEKING_CHANGE, echoSeekChange)
    }

    private function echoSeekChange(event:SeekEvent):void {
        if (!blocking && event.seeking) {
            //   setSeeking(_seekTrait.seeking, event.time) ;
            _seekTrait.seek(event.time);
        }

    }

    public function get blocking():Boolean {
        return _blocking;
    }

    public function set blocking(value:Boolean):void {
        _blocking = value;
    }
}
}