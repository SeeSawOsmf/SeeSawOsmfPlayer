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
import com.seesaw.player.ads.AdBreak;

import org.osmf.traits.SeekTrait;
import org.osmf.traits.TimeTrait;

public class AdBlockingSeekTrait extends SeekTrait {

    private var _seekTrait:SeekTrait;
    private var _adBreaks:Vector.<AdBreak>;

    public function AdBlockingSeekTrait(time:TimeTrait, seekTrait:SeekTrait, adBreaks:Vector.<AdBreak>) {
        super(time);
        _adBreaks = adBreaks;
        _seekTrait = seekTrait;
    }

    override public function canSeekTo(time:Number):Boolean {
        return _seekTrait.canSeekTo(time);
    }

    override protected function seekingChangeStart(newSeeking:Boolean, time:Number):void {
        if (newSeeking) {
            _seekTrait.seek(getMaxSeekTime(time));
        }
    }

    private function getMaxSeekTime(time:Number):Number {
        if (_adBreaks) {
            for each (var breakItem:AdBreak in _adBreaks) {
                if (!breakItem.hasSeen && breakItem.startTime <= time) {
                    // shift the time back slightly so that it it triggers ads
                    return breakItem.startTime - 0.1;
                }
            }
        }
        return time;
    }
}
}