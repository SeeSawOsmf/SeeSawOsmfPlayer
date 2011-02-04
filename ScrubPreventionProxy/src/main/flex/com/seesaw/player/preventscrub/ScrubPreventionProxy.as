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
import com.seesaw.player.ads.AdMetadata;
import com.seesaw.player.ads.AdState;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.elements.ProxyElement;
import org.osmf.events.MediaElementEvent;
import org.osmf.events.MetadataEvent;
import org.osmf.events.SeekEvent;
import org.osmf.media.MediaElement;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.SeekTrait;
import org.osmf.traits.TimeTrait;

public class ScrubPreventionProxy extends ProxyElement {

    private var logger:ILogger = LoggerFactory.getClassLogger(ScrubPreventionProxy);
    private var time:TimeTrait;
    private var adMarkers:Vector.<AdBreak>;
    private var seekable:SeekTrait;
    private var offset:Number = 0.5;
    private var finalSeekPoint:Number;
    private var blockedSeekable:BlockableSeekTrait;
    private var temporaryAdMarkers:Vector.<AdBreak>;
    private var forceSeek:Boolean;
    private var adjustedSeekPoint:Number;


    public function ScrubPreventionProxy() {

    }

    public override function set proxiedElement(proxiedElement:MediaElement):void {
        if (proxiedElement) {
            super.proxiedElement = proxiedElement;

            proxiedElement.removeEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
            proxiedElement.removeEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);

            proxiedElement.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
            proxiedElement.addEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);

            if (adMetadata) {
                adMetadata.addEventListener(MetadataEvent.VALUE_ADD, onAdsMetaDataChange);
                adMetadata.addEventListener(MetadataEvent.VALUE_CHANGE, onAdsMetaDataChange);
            }


        }
    }

    override protected function setupTraits():void {

        super.setupTraits();

    }


    private function get adMetadata():AdMetadata {
        var adMetadata:AdMetadata = getMetadata(AdMetadata.AD_NAMESPACE) as AdMetadata;
        if (adMetadata == null) {
            adMetadata = new AdMetadata();
            addMetadata(AdMetadata.AD_NAMESPACE, adMetadata);
        }
        return adMetadata;
    }

    private function onAdsMetaDataChange(event:MetadataEvent):void {
        if (event.key == AdMetadata.AD_BREAKS) {
            temporaryAdMarkers = null;

            adMarkers = event.value;
            //// AdMetaEvaluation(event.key);  ///todo se if we need anything related to the adBreaks changing...
        }
        if (event.key == AdMetadata.AD_STATE && event.value == AdState.AD_BREAK_COMPLETE) {
            finalSeek();
        }
    }

    private function processTrait(traitType:String, added:Boolean):void {

        switch (traitType) {

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
        if (!forceSeek) {

            if(!adMarkers) {
                adMarkers = adMetadata.adBreaks;
            }

            for each (var breakItem:AdBreak in adMarkers) {

                if (breakItem.startTime > 0) {

                    if (event.time > (breakItem.startTime)) {

                        forceSeek = true;
                        adjustedSeekPoint = breakItem.startTime;

                        if(breakItem.hasSeen){
                             forceSeek = false;
                        }
                    }
                }
            }
        }
        if (forceSeek) {

            finalSeekPoint = event.time;
            blockedSeekable.blocking = true;
            seekable.removeEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
            seekable.seek((adjustedSeekPoint - offset));

            if (adMarkers) {
                var indexCount:int;
                for each (var value:AdBreak in adMarkers) {
                    var index:int = value.startTime;
                    if (index == (adjustedSeekPoint)) {
                        /// adMarkers[value];
                        value.hasSeen = true;
                    }
                    indexCount++
                }
            }

            temporaryAdMarkers = adMarkers;
            //// adMarkers = null;

        }
    }


    private function finalSeek():void {
        if (finalSeekPoint) {
            if (finalSeekPoint > 0) {
                seekable.seek((finalSeekPoint));
                blockedSeekable.blocking = false;
                forceSeek = false;
                seekable.addEventListener(SeekEvent.SEEKING_CHANGE, reinstateSeek);
            }
            ///  adMetadata.adBreaks = temporaryAdMarkers;
        }
    }
    private function reinstateSeek(event:SeekEvent):void {
        if (!event.seeking) {
            seekable.removeEventListener(SeekEvent.SEEKING_CHANGE, reinstateSeek);
            seekable.addEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
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