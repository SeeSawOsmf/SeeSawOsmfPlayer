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
import com.seesaw.player.ads.AdBreakEvent;

import org.osmf.traits.SeekTrait;
import org.osmf.traits.TimeTrait;

public class AdBreakTriggeringSeekTrait extends SeekTrait {

    private var _seekTrait:SeekTrait;
    private var _adBreaks:Vector.<AdBreak>;

    public function AdBreakTriggeringSeekTrait(time:TimeTrait, seekTrait:SeekTrait, adBreaks:Vector.<AdBreak>) {
        super(time);
        _adBreaks = adBreaks;
        _seekTrait = seekTrait;
    }

    override public function canSeekTo(time:Number):Boolean {
        return _seekTrait.canSeekTo(time);
    }

    override protected function seekingChangeStart(newSeeking:Boolean, time:Number):void {
        triggerLastAdBreakBeforeSeekPosition(time);
    }

    private function triggerLastAdBreakBeforeSeekPosition(time:Number):void {
        var adActivated:Boolean = false;

        if (_adBreaks) {
            var nextBreak:AdBreak = null;

            for each (var breakItem:AdBreak in _adBreaks) {
                if (!breakItem.complete && timeTrait.currentTime <= breakItem.startTime && time >= breakItem.startTime) {
                    nextBreak = breakItem;
                }
            }

            if (nextBreak) {
                nextBreak.addEventListener(AdBreakEvent.AD_BREAK_COMPLETED, onAdBreakCompleted);
                nextBreak.seekPointAfterAdBreak = time;
                adActivated = true;
                // liverail won't trigger exactly on the start time so seek one second back
                _seekTrait.seek(nextBreak.startTime - 1);
            }
        }

        if (!adActivated) {
            // seek normally if no ad break was triggered
            _seekTrait.seek(time);
        }
    }

    private function onAdBreakCompleted(event:AdBreakEvent):void {
        event.adBreak.removeEventListener(AdBreakEvent.AD_BREAK_COMPLETED, onAdBreakCompleted);
        _seekTrait.seek(event.adBreak.seekPointAfterAdBreak);
    }
}
}