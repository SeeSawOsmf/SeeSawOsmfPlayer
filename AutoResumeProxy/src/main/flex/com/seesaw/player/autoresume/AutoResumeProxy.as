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

package com.seesaw.player.autoresume {
import com.seesaw.player.ads.AdBreak;
import com.seesaw.player.ads.AdMetadata;
import com.seesaw.player.ads.AdState;
import com.seesaw.player.ioc.ObjectProvider;
import com.seesaw.player.services.ResumeService;

import flash.events.TimerEvent;
import flash.utils.Timer;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.elements.ProxyElement;
import org.osmf.events.MediaElementEvent;
import org.osmf.events.MetadataEvent;
import org.osmf.events.PlayEvent;
import org.osmf.events.SeekEvent;
import org.osmf.events.TimeEvent;
import org.osmf.media.MediaElement;
import org.osmf.metadata.Metadata;
import org.osmf.traits.LoadTrait;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.PlayState;
import org.osmf.traits.PlayTrait;
import org.osmf.traits.SeekTrait;
import org.osmf.traits.TimeTrait;

public class AutoResumeProxy extends ProxyElement {

    private static const AD_BREAK_OFFSET = 0.1;
    private static const TIMER_UPDATE_INTERVAL:int = 30000;

    private var logger:ILogger = LoggerFactory.getClassLogger(AutoResumeProxy);

    private var seekTrait:SeekTrait;
    private var playTrait:PlayTrait;
    private var timeTrait:TimeTrait;
    private var seekingToResumePoint:Boolean;
    private var resumeService:ResumeService;
    private var timer:Timer;
    private var loadTrait:LoadTrait;
    private var drmMetadata:Metadata;

    public function AutoResumeProxy(proxiedElement:MediaElement = null) {
        super(proxiedElement);

        var provider:ObjectProvider = ObjectProvider.getInstance();
        resumeService = provider.getObject(ResumeService);

        if (resumeService == null) {
            throw ArgumentError("no resume service implementation provided");
        }

        timer = new Timer(TIMER_UPDATE_INTERVAL);
        timer.addEventListener(TimerEvent.TIMER, onTimerTick);
    }

    public override function set proxiedElement(element:MediaElement):void {
        if (element) {
            if (proxiedElement) {
                removeEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
                removeEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
                removeEventListener(MediaElementEvent.METADATA_ADD, onMetadataAdd);
                removeEventListener(MediaElementEvent.METADATA_REMOVE, onMetadataRemove);
            }

            super.proxiedElement = element;

            addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
            addEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
            addEventListener(MediaElementEvent.METADATA_ADD, onMetadataAdd);
            addEventListener(MediaElementEvent.METADATA_REMOVE, onMetadataRemove);
            var adMetadata:AdMetadata = getMetadata(AdMetadata.AD_NAMESPACE) as AdMetadata;
            if (adMetadata) {
                setupAdEventListener(adMetadata, true);
            }
            var DRMMetadata:Metadata = getMetadata("http://www.seesaw.com/drm/metadata") as Metadata;
            if (DRMMetadata) {
                setupDRMEventListener(DRMMetadata, true);
            }
        }
    }

    private function getAdBreakAtTime(time:Number):AdBreak {
        var adBreak:AdBreak = null;
        var adMetadata:AdMetadata = getMetadata(AdMetadata.AD_NAMESPACE) as AdMetadata;
        if (!isNaN(time) && adMetadata) {
            adBreak = adMetadata.getAdBreakWithTime(time);
        }
        return adBreak;
    }

    private function setupAdEventListener(metadata:Metadata, add:Boolean):void {
        if (add) {
            metadata.addEventListener(MetadataEvent.VALUE_ADD, onAdMetadataChange);
            metadata.addEventListener(MetadataEvent.VALUE_CHANGE, onAdMetadataChange);
            metadata.addEventListener(MetadataEvent.VALUE_REMOVE, onAdMetadataChange);
        }
        else {
            metadata.removeEventListener(MetadataEvent.VALUE_ADD, onAdMetadataChange);
            metadata.removeEventListener(MetadataEvent.VALUE_CHANGE, onAdMetadataChange);
            metadata.removeEventListener(MetadataEvent.VALUE_REMOVE, onAdMetadataChange);
        }
    }


    private function setupDRMEventListener(metadata:Metadata, add:Boolean):void {
        if (add) {
            metadata.addEventListener(MetadataEvent.VALUE_ADD, onDRMMetadataChange);
            metadata.addEventListener(MetadataEvent.VALUE_CHANGE, onDRMMetadataChange);
            metadata.addEventListener(MetadataEvent.VALUE_REMOVE, onDRMMetadataChange);
        }
        else {
            metadata.removeEventListener(MetadataEvent.VALUE_ADD, onDRMMetadataChange);
            metadata.removeEventListener(MetadataEvent.VALUE_CHANGE, onDRMMetadataChange);
            metadata.removeEventListener(MetadataEvent.VALUE_REMOVE, onDRMMetadataChange);
        }
    }

    private function onMetadataRemove(event:MediaElementEvent):void {
        if (event.namespaceURL == AdMetadata.AD_NAMESPACE) {
            setupAdEventListener(event.metadata, false);
        }
        if (event.namespaceURL == "http://www.seesaw.com/drm/metadata") {
            setupDRMEventListener(event.metadata, false);
        }
    }

    private function onMetadataAdd(event:MediaElementEvent):void {
        if (event.namespaceURL == AdMetadata.AD_NAMESPACE) {
            setupAdEventListener(event.metadata, true);
        }
        if (event.namespaceURL == "http://www.seesaw.com/drm/metadata") {
            setupDRMEventListener(event.metadata, true);
        }
    }

    private function onDRMMetadataChange(event:MetadataEvent):void {
        if (event.key == "CanSeek" && event.value == true) {
            seekToResumePosition();
        }
    }

    private function onAdMetadataChange(event:MetadataEvent):void {
        if (event.key == AdMetadata.AD_STATE) {
            var adMetadata:AdMetadata = getMetadata(AdMetadata.AD_NAMESPACE) as AdMetadata;
            if (adMetadata && adMetadata.currentAdBreak) {
                var currentAdBreak:AdBreak = adMetadata.currentAdBreak;
                if (event.value == AdState.AD_BREAK_COMPLETE) {
                    changeListeners(true, MediaTraitType.PLAY, PlayEvent.PLAY_STATE_CHANGE, onPlayStateChanged);
                    writeResumePosition(currentAdBreak.startTime + AD_BREAK_OFFSET, false);
                }
                else if (event.value == AdState.AD_BREAK_START) {
                    changeListeners(false, MediaTraitType.PLAY, PlayEvent.PLAY_STATE_CHANGE, onPlayStateChanged);
                    writeResumePosition(currentAdBreak.startTime - currentAdBreak.seekOffset - AD_BREAK_OFFSET, false);
                }
            }
        }
    }

    private function onDurationChange(event:TimeEvent):void {
        if (!timer.running) {
            timer.start();
        }
    }

    private function onSeekingChange(event:SeekEvent):void {
        if (!event.seeking) {
            // Don't write a resume point after we've made a seek request ourselves.
            if (!seekingToResumePoint)
                writeResumePosition(event.time);

            seekingToResumePoint = false;
        }
    }

    private function onComplete(event:TimeEvent):void {
        /*Due to the seek timer stangeness in OSMF we would get the seekChanges after the asset has completed/STOP etc..
         so lets remove the listener the write the resume cookie as 0*/
        changeListeners(false, MediaTraitType.SEEK, SeekEvent.SEEKING_CHANGE, onSeekingChange);
        resumeService.writeResumeCookie(0);
    }

    private function onPlayStateChanged(event:PlayEvent):void {
        switch (event.playState) {
            case PlayState.PAUSED:
                timer.stop();
                // a pause may or may not be followed by a seek or an ad break both of which will
                // write another resume position. However, there is no way we can detect a simple user activated
                // pause without adding yet more metadata, so we have to write a position here just in case.
                if (timeTrait)
                    writeResumePosition(timeTrait.currentTime);
                break;
            case PlayState.PLAYING:
                timer.start();
                break;
            case PlayState.STOPPED:
                timer.stop();
                // reset the resume point to the start
                resumeService.writeResumeCookie(0);
                break;
        }
    }

    private function seekToResumePosition():void {
        var resume:Number = resumeService.getResumeCookie();
        if (!checkDRMContent && resume > 0 && seekTrait && seekTrait.canSeekTo(resume)) {
            logger.debug("seeking to resume point at: {0}", resume);
            seekTrait.seek(resume);
            seekingToResumePoint = true;
        }
    }

    private function get checkDRMContent():Boolean {
        if (hasTrait(MediaTraitType.DRM)) {
            var DRMMetadata:Metadata = getMetadata("http://www.seesaw.com/drm/metadata") as Metadata;
            if (DRMMetadata) {
                if (DRMMetadata.getValue("CanSeek")) {
                    return false;
                } else {
                    return true;
                }
            } else {
                return true;
            }
        } else {
            return false;
        }
    }

    private function onTimerTick(event:TimerEvent = null):void {
        if (timeTrait && playTrait && playTrait.playState == PlayState.PLAYING) {
            // if the video is playing attempt to write at TIMER_UPDATE_INTERVAL intervals
            writeResumePosition(timeTrait.currentTime);
        }
    }

    private function writeResumePosition(time:Number, checkForBreak:Boolean = true):void {
        var timeToWrite:Number = time;

        if (checkForBreak) {
            // we don't write resume points exactly on ad breaks since the resume points have to be
            // offset from ad breaks a little depending on whether the break has been seen or not
            var adBreak:AdBreak = getAdBreakAtTime(time);
            if (adBreak) {
                // the ad events take care of writing the actual resume points in this case
                return;
            }
        }

        timeToWrite = timeToWrite < 0 ? 0 : timeToWrite;
        logger.debug("recording resume point: {0}", timeToWrite);
        resumeService.writeResumeCookie(timeToWrite);
    }

    private function onTraitAdd(event:MediaElementEvent):void {
        updateTraitListeners(event.traitType, true);
    }

    private function onTraitRemove(event:MediaElementEvent):void {
        updateTraitListeners(event.traitType, false);
    }

    private function updateTraitListeners(traitType:String, add:Boolean):void {
        switch (traitType) {
            case MediaTraitType.SEEK:
                changeListeners(add, traitType, SeekEvent.SEEKING_CHANGE, onSeekingChange);
                seekTrait = getTrait(MediaTraitType.SEEK) as SeekTrait;
                seekToResumePosition();
                break;
            case MediaTraitType.PLAY:
                changeListeners(add, traitType, PlayEvent.PLAY_STATE_CHANGE, onPlayStateChanged);
                playTrait = getTrait(MediaTraitType.PLAY) as PlayTrait;
                break;
            case MediaTraitType.TIME:
                changeListeners(add, traitType, TimeEvent.COMPLETE, onComplete);
                changeListeners(add, traitType, TimeEvent.DURATION_CHANGE, onDurationChange);
                timeTrait = getTrait(MediaTraitType.TIME) as TimeTrait;
                break;
            case MediaTraitType.LOAD:
                loadTrait = getTrait(MediaTraitType.LOAD) as LoadTrait;
                break;
        }
    }

    private function changeListeners(add:Boolean, traitType:String, event:String, listener:Function):void {
        if (add) {
            getTrait(traitType).addEventListener(event, listener);
        }
        else if (hasTrait(traitType)) {
            getTrait(traitType).removeEventListener(event, listener);
        }
    }
}
}
