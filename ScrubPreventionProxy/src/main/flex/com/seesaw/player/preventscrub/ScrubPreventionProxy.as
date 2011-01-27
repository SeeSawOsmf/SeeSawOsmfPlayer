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
import com.seesaw.player.ads.AdState;
import com.seesaw.player.events.AdEvent;
import com.seesaw.player.traits.ads.AdTrait;
import com.seesaw.player.traits.ads.AdTraitType;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.elements.ProxyElement;
import org.osmf.events.LoadEvent;
import org.osmf.events.MediaElementEvent;
import org.osmf.events.SeekEvent;
import org.osmf.media.MediaElement;
import org.osmf.traits.LoadTrait;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.SeekTrait;
import org.osmf.traits.TimeTrait;

public class ScrubPreventionProxy extends ProxyElement {

    private var logger:ILogger = LoggerFactory.getClassLogger(ScrubPreventionProxy);
    private var _adTrait:AdTrait;
    private var time:TimeTrait;
    private var adMarkers:Array;
    private var seekable:SeekTrait;
    private var offset:Number = 0.5;
    private var finalSeekPoint:Number;
    private var blockedSeekable:BlockableSeekTrait;
    private var temporaryAdMarkers:Array;


    public function ScrubPreventionProxy() {

    }

    public override function set proxiedElement(proxiedElement:MediaElement):void {
        if (proxiedElement) {
            super.proxiedElement = proxiedElement;

            proxiedElement.removeEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
            proxiedElement.removeEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);

            proxiedElement.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
            proxiedElement.addEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);

        }
    }

    override protected function setupTraits():void {
        logger.debug("setupTraits");

        super.setupTraits();

    }


    private function processTrait(traitType:String, added:Boolean):void {

        switch (traitType) {
            case MediaTraitType.LOAD:
                toggleLoadListeners(added);
                break;
            case MediaTraitType.SEEK:
                toggleSeekListeners(added);
                break;
            case MediaTraitType.TIME:
                toggleTimeListeners(added);
                break;
        }
    }

    private function toggleTimeListeners(added:Boolean):void {
        time = proxiedElement.getTrait(MediaTraitType.TIME) as TimeTrait;

    }


    private function toggleSeekListeners(added:Boolean):void {
        seekable = proxiedElement.getTrait(MediaTraitType.SEEK) as SeekTrait;
        if (seekable) {
            if (added) {
                seekable.addEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);

                blockedSeekable = new BlockableSeekTrait(time, seekable);
                addTrait(MediaTraitType.SEEK, blockedSeekable);
            } else {
                seekable.removeEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
                removeTrait(MediaTraitType.SEEK);
            }


        }

    }

    private function onSeekingChange(event:SeekEvent):void {
        var adjustedSeekPoint:Number;
        var forceSeek:Boolean;
        for each (var value:Number in adMarkers) {
            if (event.time > (value * time.duration)) {
                forceSeek = true;
                adjustedSeekPoint = value * time.duration;
            }
        }
        if (forceSeek) {

            finalSeekPoint = event.time;
            blockedSeekable.blocking = true;
            seekable.seek((adjustedSeekPoint - offset));

            if (adMarkers) {
                for (var i:Number = 0; i < adMarkers.length; i++) {
                    var index:Number = adMarkers[i];
                    if (index == (adjustedSeekPoint / time.duration)) {
                        adMarkers.splice(i, 1);
                    }
                }
            }
            temporaryAdMarkers = adMarkers;
            adMarkers = null;


            forceSeek = false;

        }
    }

    private function toggleLoadListeners(added:Boolean):void {
        var loadable:LoadTrait = proxiedElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
        if (loadable) {
            if (added) {
                loadable.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadableStateChange);

            }
            else {
                loadable.removeEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadableStateChange);
            }
        }
    }

    private function onLoadableStateChange(event:LoadEvent):void {
        _adTrait = proxiedElement ? proxiedElement.getTrait(AdTraitType.AD_PLAY) as AdTrait : null;

        if (_adTrait) {
            _adTrait.addEventListener(AdEvent.AD_MARKERS, adMarkerEvent);
            _adTrait.addEventListener(AdEvent.AD_STATE_CHANGE, finalSeek);
        }
    }

    private function createNewMarkers():void {

        _adTrait.createMarkers(temporaryAdMarkers);
    }

    private function reinstateSeek(event:SeekEvent):void {
        if (!event.seeking) {
            seekable.removeEventListener(SeekEvent.SEEKING_CHANGE, reinstateSeek);

        }
    }

    private function adMarkerEvent(event:AdEvent):void {
        temporaryAdMarkers = null;
        adMarkers = event.markers;
    }

    private function finalSeek(event:AdEvent):void {

        if (_adTrait.adState == AdState.AD_BREAK_COMPLETE) {
            if (finalSeekPoint > 0) {


                seekable.seek((finalSeekPoint));
                createNewMarkers();
                blockedSeekable.blocking = false;


            }
        }
    }

    private function onTraitAdd(event:MediaElementEvent):void {
        processTrait(event.traitType, true);
    }

    private function onTraitRemove(event:MediaElementEvent):void {
        processTrait(event.traitType, false);
    }

}
}