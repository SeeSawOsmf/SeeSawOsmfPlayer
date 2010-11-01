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
import org.osmf.traits.PlayTrait;
import org.osmf.traits.SeekTrait;
import org.osmf.traits.TimeTrait;

public class ScrubPreventionProxy extends ProxyElement {

    private var logger:ILogger = LoggerFactory.getClassLogger(ScrubPreventionProxy);
    private var _adTrait:AdTrait;
    private var time:TimeTrait;
    private var adMarkers:Array;
    private var seekable:SeekTrait;

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
        addLocalTraits();
        super.setupTraits();

    }


    private function processTrait(traitType:String, added:Boolean):void {
        logger.debug(" --------- traitType -----------" + traitType);

        switch (traitType) {
            case MediaTraitType.LOAD:
                toggleLoadListeners(added);
                break;
            case MediaTraitType.SEEK:
                toggleSeekListeners(added);
                break;
        }
    }


    private function toggleSeekListeners(added:Boolean):void {
        seekable = proxiedElement.getTrait(MediaTraitType.SEEK) as SeekTrait;

        if (seekable) {
            seekable.addEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
        } else {
            seekable.removeEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
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
        var playTrait:PlayTrait = proxiedElement.getTrait(MediaTraitType.PLAY) as PlayTrait;
        _adTrait = proxiedElement ? proxiedElement.getTrait(AdTraitType.AD_PLAY) as AdTrait : null;

        if (_adTrait)_adTrait.addEventListener(AdEvent.AD_MARKERS, adMarkerEvent);


        time = proxiedElement.getTrait(MediaTraitType.TIME) as TimeTrait;
        if (playTrait) {

            ///  playTrait.pause();
        }
    }

    private function onSeekingChange(event:SeekEvent):void {
        logger.debug("On Seek Change:{0}", event.time);
        var finalSeekPoint:Number;
        var forceSeek:Boolean;
        for each (var value:Number in adMarkers) {
            if (event.time > (value * time.duration)) {
                forceSeek = true;
                finalSeekPoint = value * time.duration;
            }
        }
        if (forceSeek) {
            seekable.seek((finalSeekPoint));
        }

    }

    private function adMarkerEvent(event:AdEvent):void {
        adMarkers = event.markers;
    }

    private function onTraitAdd(event:MediaElementEvent):void {
        processTrait(event.traitType, true);
    }

    private function onTraitRemove(event:MediaElementEvent):void {
        processTrait(event.traitType, false);
    }

    private function addLocalTraits():void {

    }

    private function removeLocalTraits():void {

    }

}
}