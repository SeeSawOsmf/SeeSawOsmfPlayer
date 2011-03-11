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

package com.seesaw.player.preventscrub {
import com.seesaw.player.ads.AdBreak;
import com.seesaw.player.ads.AdBreakEvent;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.events.SeekEvent;
import org.osmf.traits.SeekTrait;
import org.osmf.traits.TimeTrait;

public class AdBreakTriggeringSeekTrait extends SeekTrait {

    private var logger:ILogger = LoggerFactory.getClassLogger(AdBreakTriggeringSeekTrait);

    private var _seekTrait:SeekTrait;
    private var _adBreaks:Vector.<AdBreak>;

    public function AdBreakTriggeringSeekTrait(time:TimeTrait, seekTrait:SeekTrait, adBreaks:Vector.<AdBreak>) {
        super(time);
        _adBreaks = adBreaks;
        _seekTrait = seekTrait;

        seekTrait.addEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChanged, false, 0, true);

    }

    /**
     * If the 'inner' item stops seeking we should also stop seeking.
     * We don't need to do the true state as that is done behind .seek.
     * @param event
     */
    private function onSeekingChanged(event:SeekEvent):void {
        if (event.seeking == false) {
            setSeeking(false, event.time);
        }
    }


    override public function canSeekTo(time:Number):Boolean {
        return _seekTrait.canSeekTo(time);
    }

    override protected function seekingChangeStart(newSeeking:Boolean, time:Number):void {
        if (newSeeking) {
            triggerLastAdBreakBeforeSeekPosition(time);
        }
    }

    private function triggerLastAdBreakBeforeSeekPosition(time:Number):void {
        var adActivated:Boolean = false;

        if (_adBreaks) {
            var nextBreak:AdBreak = null;

            for each (var breakItem:AdBreak in _adBreaks) {
                if (!breakItem.complete && time >= breakItem.startTime) {
                    nextBreak = breakItem;
                }
                if(nextBreak){
                    if(breakItem.complete && time >= breakItem.startTime &&  time >= nextBreak.startTime){
                        nextBreak = null;
                    }
                }
            }

            if (nextBreak) {
                nextBreak.addEventListener(AdBreakEvent.AD_BREAK_COMPLETED, onAdBreakCompleted);
                nextBreak.seekPointAfterAdBreak = time;
                adActivated = true;
                // liverail won't trigger exactly on the start time so seek one second back
                _seekTrait.seek(nextBreak.startTime - nextBreak.seekOffset);
            }
        }

        if (!adActivated) {
            // seek normally if no ad break was triggered
            _seekTrait.seek(time);
        }
    }

    private function onAdBreakCompleted(event:AdBreakEvent):void {
        logger.debug("ad break completed, seeking to: {0}", event.adBreak.seekPointAfterAdBreak);
        event.adBreak.removeEventListener(AdBreakEvent.AD_BREAK_COMPLETED, onAdBreakCompleted);
        _seekTrait.seek(event.adBreak.seekPointAfterAdBreak);
    }
}
}